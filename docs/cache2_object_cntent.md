// # Coral Content Store for `.crlo` Objects

// ## 0. The problem

// Two projects both use `coral-common` at the same commit. Today, each project's `.coral/cache/` holds its own copy of `coral-common/lib.crlo`. Same bytes, twice on disk. Multiply by N projects and M shared modules, and you're storing the same object a hundred times.

// The content store fixes this: **compiled objects are stored once, globally, keyed by their content hash.** Any project that produces the same object reuses it.

// Bonus: because the key is content-derived, this store is also the foundation for a **remote cache** later. Same shape, different backend.

// ---

// ## 1. Core idea

// - Every compiled module produces one **object artifact** (`.crlo`) plus some metadata.
// - The object is hashed. The hash **is** its address.
// - The store is a flat, sharded, content-addressed directory.
// - Projects keep an **index** mapping `module + fingerprint → object hash`, but the object itself lives in the shared store.
// - If the object already exists in the store, nothing is written. If not, it's written once atomically.

// Two-level indirection:

// ```
// project cache  →  module fingerprint  →  object hash  →  store path
// ```

// - Fingerprint answers "do I need to recompile this module?" (project-local)
// - Object hash answers "does this exact compiled byte sequence exist anywhere?" (global)

// They're different hashes because they answer different questions. Fingerprint includes dep fingerprints; object hash is just the bytes.

// ---

// ## 2. Store layout

// ```
// ~/.coral/store/
// ├── v1/                             # store format version
// │   ├── objects/
// │   │   ├── ab/
// │   │   │   ├── abcdef0123456789...crlo
// │   │   │   └── abcdef0123456789....meta
// │   │   ├── cd/
// │   │   │   └── cdef0123456789ab...crlo
// │   │   └── ...
// │   ├── tmp/                        # staging for atomic writes
// │   └── LOCK
// └── config                          # store config (size limit, gc policy)
// ```

// Two-char shard = 256 buckets. Keeps any one directory from holding millions of files. Standard trick (git, casync, nix all do this).

// Per object, two files:

// - `<hash>.crlo` — the compiled object, raw bytes.
// - `<hash>.meta` — a small text sidecar describing it.

// ### `<hash>.meta`

// ```
// # coral store object v1
// hash         = abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789
// size         = 48213
// kind         = object              # object | archive
// compiler     = coralc 0.1.0
// target       = native-x86_64
// opt          = release
// created_at   = 2026-09-20T14:32:11Z
// refcount     = 3                   # informational; not authoritative

// # provenance — where did this come from
// origin_module   = coral-lexer
// origin_project  = /home/you/projects/coralc

// # optional debug info
// symbols      = lex, scan_ident, scan_number
// exports      = lexer::lex
// imports      = common::token, common::slice, lexer::ident
// ```

// Text, line-oriented, diffable, forward-compatible (unknown keys ignored). Human-readable so `coral store cat <hash>.meta` gives you something useful.

// ---

// ## 3. Object hashing

// The object hash is:

// ```
// object_hash = BLAKE3(
//     "coral-object-v1"       || 0x00 ||
//     compiler_version        || 0x00 ||
//     target                  || 0x00 ||
//     opt                     || 0x00 ||
//     raw_object_bytes
// )
// ```

// Include compiler/target/opt in the hash so two compilers or two opt levels can't collide on the same bytes. Two different compilers producing byte-identical output should still be distinguishable — you might want to know which one made it.

// **Important: this is not the module fingerprint.** The module fingerprint cascades through deps and source hashes. The object hash is purely about the artifact. A module can have a new fingerprint (because a dep changed) but produce a byte-identical object (because the dep change didn't affect this module's codegen). In that case, the object hash is the same → store dedupes it.

// That's the whole point. **Fingerprint changes ≠ object changes.**

// ### Optional: stripping for better dedup

// If you want maximum dedup across builds, strip **non-semantic** parts of the object before hashing:

// - Timestamps
// - Absolute paths
// - Debug paths (or keep, per policy)

// Policy is per-project, in the build file:

// ```crlb
// build "coralc" {
//     ...
//     store {
//         strip_paths  = true;
//         strip_time   = true;
//         keep_symbols = true;
//     }
// }
// ```

// If stripping is on, two builds of the same source on different machines produce the same object hash. That's what enables cross-machine dedup.

// ---

// ## 4. Store config

// `~/.coral/store/config`:

// ```
// # coral store config v1
// format_version  = 1
// max_size_gb     = 50
// gc_policy       = lru              # lru | none | size
// gc_min_age      = 7d               # don't gc objects younger than this
// verify_on_read  = true             # rehash on read, paranoid mode
// compression     = none             # none | zstd
// ```

// - `max_size_gb` — soft cap. When exceeded, `coralc store gc` trims.
// - `gc_policy` — how trimming picks victims.
// - `verify_on_read` — expensive but catches disk corruption. Off by default in `--release`, on in `--debug`.
// - `compression` — if `zstd`, `<hash>.crlo` is a zstd stream. Store knows by reading `.meta`'s `compression` field, or by extension `.crlo.zst`.

// ---

// ## 5. Project-side integration

// Project cache changes slightly. Before:

// ```
// .coral/cache/v1/coral-lexer/
// ├── meta
// ├── fingerprint
// └── lib.crlo           ← the object lives here
// ```

// After:

// ```
// .coral/cache/v1/coral-lexer/
// ├── meta               ← includes `object_hash = abc123...`
// └── fingerprint
// ```

// The `.crlo` is gone from the project — it lives in the store. Lookup:

// ```
// 1. read .coral/cache/v1/<module>/meta
// 2. object_hash = meta.object_hash
// 3. object_path = ~/.coral/store/v1/objects/<hh>/<object_hash>.crlo
// 4. if exists → link/copy/read from store
//    if missing → object was evicted, recompile and repopulate store
// ```

// ### Linking vs copying vs reading

// Three strategies:

// | Strategy | Pros | Cons |
// |---|---|---|
// | **Symlink** | Zero copy, instant | Breaks if store is wiped; symlinks confuse some tools |
// | **Hardlink** | Zero copy, survives store wipe | Same filesystem only; editing one affects both (don't edit objects) |
// | **Copy** | Portable, store wipe is safe | Uses disk; defeats the point of dedup if you copy everywhere |
// | **Read-through** | No link, no copy — link step reads from store directly | Requires linker to support it |

// **Recommended: hardlink when possible, fall back to copy.** The object is immutable, so hardlinking is safe. If cross-filesystem, copy (and note it in `meta`). Never symlink — too fragile.

// `coralc build` handles the link/copy transparently.

// ---

// ## 6. Hashing and identity — worked example

// ### Project A builds `coral-lexer`

// ```
// sources_hash  = a1b2...
// surface_hash  = 0123...
// deps_hash     = fedc...   (coral-common, coral-ast)
// context_hash  = 1111...

// fingerprint(A, coral-lexer) = 7f3a91c2...

// compile → bytes B1
// object_hash(B1) = abcdef0123...
// ```

// Store: `~/.coral/store/v1/objects/ab/abcdef0123....crlo` written.

// ### Project B builds the same `coral-lexer`

// Same sources, same deps, same compiler → same fingerprint **and** same bytes.

// ```
// object_hash(B1) = abcdef0123...   (same)
// ```

// Store already has it. **Nothing written.** Project B hardlinks.

// ### Project A changes a comment in `coral-lexer/lexer.coralc`

// ```
// sources_hash  = new
// fingerprint(A, coral-lexer) = 5e4d3c2b...   (changed)

// compile → bytes B2
// object_hash(B2) = 99887766...   (changed, because file content changed)
// ```

// Store: writes new object `99887766...crlo`. Old `abcdef0123...` still there, still referenced by project B and anything else.

// ### Project A changes a comment in a *dependency* that doesn't affect lexer codegen

// ```
// sources_hash  = same            (lexer source unchanged)
// surface_hash  = same
// deps_hash     = new             (dep fingerprint changed)
// fingerprint(A, coral-lexer) = 3a2b1c0d...   (changed → recompiles)

// compile → bytes B1              (byte-identical output!)
// object_hash(B1) = abcdef0123... (same as before)
// ```

// Store: **hit**. Nothing written. Project A's `meta` now points to the old object under the new fingerprint. This is the second-biggest dedup win — recompile happens, but output is reused.

// ---

// ## 7. Garbage collection

// Objects are only reachable via references from project caches. The store doesn't track who references what — that would require a daemon or global registry.

// Instead: **refcount by scan.**

// ```
// coralc store gc
//   1. scan every project listed in ~/.coral/projects
//   2. read each .coral/cache/v1/*/meta, collect object_hash values
//   3. build set of live object hashes
//   4. walk ~/.coral/store/v1/objects/
//   5. for each object not in live set and older than gc_min_age → delete
//   6. update refcount in .meta for live objects (informational)
// ```

// Where does `~/.coral/projects` come from? Whenever `coralc build` runs in a project, it appends the project path (idempotent). Over time this lists every project that has ever used the store. Stale entries get dropped when their path no longer exists.

// Alternative for CI / containers: **no automatic GC**. Set `max_size_gb`, run `coralc store gc --force` on a cron, accept that the store is a cache and losing it just means recompilation.

// Simpler still: **LRU by access time.** Touch `.crlo` on read (via `utimes`). GC evicts oldest-touched first when size exceeds cap. No scanning needed. This is what I'd ship for v1.

// ---

// ## 8. Verification

// Disk corruption is real. `coralc store verify`:

// ```
// coralc store verify
//   walk every object
//   rehash bytes
//   compare to filename
//   report mismatches, optionally delete
// ```

// Output:

// ```
// scanned   14203 objects
// verified  14203 ok
//           0 mismatched
//           0 unreadable
// ```

// `coralc store verify --delete-bad` removes corrupt objects. Their projects recompile on next build (cache miss, not fatal).

// Optional: on every read, rehash. Slower but bulletproof. Controlled by `verify_on_read` in store config.

// ---

// ## 9. Concurrency

// Multiple builds writing to the store at once:

// - **Per-object lock, not global.** Two builds writing the *same* object: one wins, the other sees it exists and skips.
// - Write path: `tmp/<random> → fsync → rename into place`. Rename is atomic. If destination exists, discard the tmp and use the existing one. This is idempotent.
// - No global lock needed for writes.
// - **GC takes a global lock** (`.coral/store/v1/LOCK`) because deleting while another process reads is bad. Reads take a shared lock; GC takes exclusive.

// Advisory lock file with PID + start time. `coralc store gc --break-lock` for stale locks.

// ---

// ## 10. Remote store (future)

// Because the object address is content-derived, the store interface is trivial to move over HTTP:

// ```
// GET  /objects/<hh>/<hash>.crlo
// HEAD /objects/<hh>/<hash>.crlo
// PUT  /objects/<hh>/<hash>.crlo
// GET  /objects/<hh>/<hash>.meta
// ```

// Build flow:

// ```
// 1. compute object_hash locally
// 2. if local store has it → use
// 3. else HEAD remote → if exists, GET into local store, use
// 4. else compile, PUT to remote, use
// ```

// No protocol negotiation, no auth dance in the object format itself. Auth in the HTTP layer. This is how Bazel, Nix, and ccache remote all work, and it's the right design.

// Not building this now — just noting the local store is shaped so it drops in later.

// ---

// ## 11. CLI surface

// ```
// coralc store stat                    # size, object count, hit rate
// coralc store list                    # list all objects (hash, size, module)
// coralc store cat <hash>              # dump .meta for an object
// coralc store get <hash> <outfile>    # extract object to a file
// coralc store put <file>              # add an object manually (rare)
// coralc store verify [--delete-bad]   # rehash everything
// coralc store gc [--force]            # evict per policy
// coralc store path <hash>             # print canonical path
// coralc store prune                   # drop unreferenced objects (scan-based)
// ```

// ---

// ## 12. Build-file additions

// Optional `store` block, everything defaultable:

// ```crlb
// build "coralc" {
//     ...
//     store {
//         enabled       = true;
//         path          = "~/.coral/store"; # or default
//         mode          = "hardlink";       # hardlink | copy | read
//         strip_paths   = true;
//         strip_time    = true;
//         verify_on_read = false;
//         max_size_gb   = 50;
//         gc_policy     = "lru";
//     }
// }
// ```

// Default: enabled, `~/.coral/store`, hardlink, strip paths and time, no verify, 50 GB, LRU.

// To disable per-project:

// ```crlb
// store { enabled = false; }
// ```

// Or per-invocation: `coralc build --no-store`.

// ---

// ## 13. Interaction with the module cache

// Two caches, two jobs:

// | Cache | Scope | Key | Answers |
// |---|---|---|---|
// | Module cache | per-project | module fingerprint | "do I recompile this module?" |
// | Content store | global | object hash | "do I already have this compiled artifact?" |

// Order of operations in `coralc build` for a module:

// ```
// 1. module cache lookup by fingerprint
//    - hit → done, no work
//    - miss → continue

// 2. compile sources → bytes
// 3. object_hash = hash(bytes)
// 4. store lookup
//    - hit  → use existing object
//    - miss → write to store
// 5. update module cache:
//    meta.fingerprint = new
//    meta.object_hash = object_hash
// ```

// Module cache miss **does not** imply store miss. That's the win.

// ---

// ## 14. Failure modes

// | Situation | Behavior |
// |---|---|
// | Store dir missing | Create on first write; reads return miss |
// | Store on read-only FS | Warn once, degrade to project-local object storage |
// | Store object missing but `meta` says present | Cache miss; recompile; repopulate |
// | Object corrupt (hash mismatch) | `verify_on_read` catches; treat as miss |
// | Cross-filesystem hardlink fails | Fall back to copy; note in project `meta` |
// | Disk full during write | `tmp` file cleaned up; error propagates; existing objects untouched |
// | GC runs during build | GC takes exclusive lock; build waits or errors with retry hint |
// | Same object written concurrently | rename is idempotent; second write discards tmp |

// ---

// ## 15. Summary table

// | Aspect | Choice |
// |---|---|
// | Address | `BLAKE3(compiler‖target‖opt‖bytes)` |
// | Layout | `store/v1/objects/<hh>/<hash>.crlo` |
// | Sidecar | `<hash>.meta`, line-oriented text |
// | Sharding | 2 hex chars deep (256 buckets) |
// | Project link | Hardlink, fallback copy |
// | Dedup trigger | Any two builds producing identical bytes |
// | GC | LRU by access time, size cap |
// | Concurrency | Atomic rename + per-object idempotency |
// | Verification | `coralc store verify`, optional on-read |
// | Remote | Same protocol, HTTP transport |
// | Two-level | Module fingerprint (project) vs object hash (global) |

// ---

// That's the content store. If you want, next I can:

// - Write the **`object_hash` implementation** in `.coralc`, including the strip-paths/strip-time normalization pass.
// - Design the **remote store protocol** end-to-end (auth, chunking, resumable GETs, metrics).
// - Wire the **linker** to read objects directly from the store (read-through mode, no hardlink needed).
// - Design **`coralc store`** as a standalone binary vs a subcommand of `coralc`.

// Which?