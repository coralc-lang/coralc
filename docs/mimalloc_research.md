# mimalloc — research notes (source-verified, for aligning our port)

Sources fetched and line-verified 2026-10-24:

- v1 line: microsoft/mimalloc `dev` branch (~1.15.x) — `src/{alloc,page,
  segment,segment-map,heap}.c`, `include/mimalloc/{types,internal}.h`.
  This is the classic **segment** architecture our port targets.
- v3 line: microsoft/mimalloc `main3` (v3.6.0, released 2026-10-23) —
  `src/heap/page-map.c`, `src/alloc/{alloc-generic,page-queue}.c`,
  `include/mimalloc/types.h`. A rewrite: no segments, arena pages
  (§10). The intermediate v2 line (`main`, ~2.x) keeps segments.
- MSR-TR-2019-18 "Mimalloc: Free List Sharding in Action".

Version mapping (previously misstated in this doc): `dev` = v1,
`main` = v2, `main3` = v3 (current release). We target **v1** semantics.

## 1. Architecture (v1)

```
thread → theap (thread-local heap) → pages (one per size class)
       → segments (reserved from OS/arena) → blocks
```

- **Segment**: **4 MiB** on 64-bit (`MI_SEGMENT_SHIFT ==
  MI_LARGE_PAGE_SHIFT == 22`, types.h:185 — comment "4MiB"), aligned
  to its size, so the segment containing pointer `p` is found by
  masking: `_mi_ptr_segment(p) = ((p-1) & ~MI_SEGMENT_MASK)`
  (internal.h:543). Memory committed on demand. Segment starts with
  metadata (segment + page structs), then page data. Segments are
  per-thread; when a thread ends its live segments are **abandoned**
  (`thread_id = 0`) and reclaimed by other threads (work-stealing).
- **Page** kinds (types.h:203-205): small 64 KiB (blocks ≤ 8 KiB),
  medium 512 KiB (≤ 64 KiB), large 4 MiB = one per segment (≤ 1 MiB),
  huge = one page per segment of arbitrary size (> 1 MiB or alignment
  > large). Every segment/page combo exists so `free` has a uniform
  code path with no special cases.
- **Size classes** ("bins"): 8-byte steps up to 128, then 16, 24, 32…
  through 10240, 12288, 14336, 16384. Our `_miBlockSize` table already
  matches the real bin tail.
- **theap** has a direct array of pointers `small_pages[index]` where
  `index = (size + sizeof(void*))/sizeof(void*)` — constant-time page
  lookup. Pointers are never null (empty-page sentinels with
  `free == NULL`) so the fast path needs no null checks.
- **Pointer→page resolution**: v1 needs no window logic — segment
  masking covers any interior pointer; the segment map (bitmap) maps
  segment bases in O(1). Our port instead carves segments from 64 KiB
  arena slices (unaligned) and must maintain its own page map — the
  source of bug 9.1.

## 2. The three free lists per page (the big idea)

Every page has **three** lists:

| list | owner | operation |
|---|---|---|
| `free` | page (thread-local) | allocation pops head — no atomics |
| `local_free` | owning thread | same-thread `free` pushes here — no atomics |
| `thread_free` (xthread_free) | any thread | cross-thread `free` pushes with **one CAS** |

Fast malloc (release build ~7 instructions):

```c
block = page->free;
if (block == NULL) return malloc_generic(heap, size);  // slow path
page->free = block->next;   // encoded next
page->used++;
return block;
```

Fast free:

```c
page = ptr_page(p);
if (page->thread_id == thread_id()) {   // local
    block->next = page->local_free;
    page->local_free = block;
    if (--page->used == 0) page_free(page);
} else {                                // cross-thread: one CAS
    do { block->next = page->thread_free; }
    while (!cas(&page->thread_free, block->next, block));
    atomic_inc(&page->thread_freed);
}
```

**Collection cadence** (`_mi_page_free_collect`, page.c — verified
identical in v1 and v3): when `free` is empty the generic path promotes
lists: `thread_free` is atomically swapped to NULL and appended to
`local_free`; `local_free` becomes `free` when `free` is empty — and is
appended to `free` (walk-to-tail, then `tail->next = free`) only on
`force` (shutdown/forced retire), since the append is linear. This
guarantees the generic path is taken after a bounded number of
allocations — amortizing page extend/retire, delayed-free processing,
and cross-thread collection with a single check in the fast path.

## 3. Cross-thread delayed free (present in v1 too)

- First cross-thread free on a full page sets the **delayed flag** in
  the packed `xthread_free` word (`MI_USE_DELAYED_FREE` →
  `MI_DELAYED_FREEING`) and pushes the block onto the **heap's**
  `thread_delayed_free` list (also CAS), then resets the flag.
  Subsequent frees go straight onto the page's `thread_free` list.
- The owning thread processes `thread_delayed_free` in
  `_mi_heap_delayed_free_partial` (atomic take-over of the list) and
  `_mi_free_delayed_block` (collect page lists, then local free).
- Abandoned segments: a free on `segment->thread_id == 0` first tries
  `_mi_segment_attempt_reclaim` and then re-frees locally.

## 4. Free-list pointer encoding (security)

Per-page random keys `k1, k2`; `NULL` is encoded through a separate
sentinel (`null` argument) so `(k2<<<k1)+k1` never appears as a real
sentinel:

```c
set:  block->next = (rotl(next ^ k2, k1)) + k1;      // next==NULL → sentinel
get:  b = rotr(block->next - k1, k1) ^ k2;           // b==sentinel → NULL
```

Decode must also verify `b` lies in the same page (corruption → fatal).
Keys are unique per page. Double-free detection walks the three lists
and reports (then ignores). Our port has `_miFreeBlockEncode/Decode` —
verify it matches this formula exactly (it is NOT plain `p ^ k1`).

## 5. Locks and atomics (include/mimalloc/atomic.h)

`mi_lock_t` is **never a plain non-atomic spin**. Choices, in order:
Win32 `SRWLOCK`, pthreads `pthread_mutex_t`, C++ `std::mutex`, and the
fallback:

```c
// _Atomic(uintptr_t) mutex
try_acquire:  expected = 0; cas_strong_acq_rel(&mutex, &expected, 1)
acquire:      for (i = 0; i < 10000; i++) { if (try_acquire()) return;
                                            _mi_prim_thread_yield(); }
              error "lock cannot be acquired"
release:      store_release(&mutex, 0)
```

Locks are used only for arena reservation and the abandoned list —
the allocation fast path is lock-free.

Atomic primitives used throughout: `cas_weak/cas_strong` (release /
acq_rel / relaxed), `exchange`, `fetch_add/sub`, `load_acquire`,
`store_release`, `thread_fence`. Memory-order rules that matter:
- cross-thread list push: CAS **release** (or acq_rel on the collect
  side: `cas_weak_acq_rel` when taking over `thread_free`/delayed list)
- local counters: relaxed
- publishing heap/page ownership: acquire loads of `xheap`/`thread_id`.

Our codebase's equivalent: `lib_old/std/concurrent/thread.crl` defines
`AtomicU64` with `flag (ARCH)` dispatch and inline asm
(x86_64 `lock cmpxchg` / `lock xadd` / `stlr`+`ldar` on arm64, etc.):
`load()`, `store(v)`, `fetchAdd(delta)`, plus a CAS method. concurrent
is not yet ported, so until it is, mimalloc may carry a private copy of
these helpers (modeled on that file) and yield via a local
`extern("C") i32 sched_yield();`.

## 6. Page lifecycle (src/page.c)

- `mi_page_init`: block_size, page_start, `reserved = page_size /
  block_size` (u16), per-page random keys, `block_size_shift` for
  power-of-two sizes, initial `mi_page_extend_free`.
- `mi_page_extend_free`: bounded — `max_extend = MI_MAX_EXTEND_SIZE /
  bsize` (with `MI_MIN_EXTEND` floor), so worst-case work is bounded;
  only the touched prefix of the page is committed (lean RSS).
  Sequential extend: `mi_page_free_list_extend` chains blocks and
  prepends to `free` (secure mode: random slice threading).
- `_mi_page_free_collect`: CAS-swap `thread_free` → walk to tail →
  append to `local_free`; then `local_free` → `free` when `free` is
  empty (append only on forced/shutdown collect). Updates `used`.
- Retire: generic path linearly walks the size-class queue, frees
  pages with no used blocks (bounded count kept cached), stops at first
  page with room and rotates the queue. Abandon: page released to
  segment, thread_id → 0.

## 7. Allocation flow (src/alloc.c)

```
mi_malloc(size):
  if size <= MI_SMALL_SIZE_MAX:               // fast (≤ 8 KiB)
      page = theap->small_pages[(size+ptr)/ptr]
      return page_malloc_zero(heap, page, size)  // pop free list
  else: return _mi_heap_malloc_generic(...)      // slow: extend/collect
```

`_mi_page_malloc_zero`: pop `page->free`; if null →
`_mi_malloc_generic` (collect local/thread lists, extend, retire);
`used++`; optional zeroing (`free_is_zero` short-circuit); padding
canary (`mi_ptr_encode_canary`) when MI_PADDING.

## 8. What "real mimalloc" means for our port (acceptance list)

1. Lock = CAS+bounded retry+yield (per §5), never `while(locked){} locked=1;`.
2. All shared-state accesses (thread_free list head, used/thread_freed
   counters, delayed flags, segment thread_id) go through atomics with
   the memory orders from §5.
3. Exactly three lists per page with promotion in the generic path
   (§2); fast paths match the pseudocode.
4. Cross-thread free follows §3 (delayed-flag dance + heap delayed
   list), not a naive shared mutex around everything.
5. Encoding matches §4 (rotate-add-xor, two per-page keys, sentinel,
   same-page validation on decode).
6. Bounded extend + retire per §6 (no unbounded loops, no full-page
   zeroing up front — commit on demand).
7. Double-free detected and ignored; stats counters kept.
8. Thread yield on lock contention; arena/abandoned-list are the only
   lock users.

Not in scope: guard pages / MI_SECURE padding, valgrind/TSAN hooks,
commit/purge masks, the v3 arena/page-map rewrite (§10 — tracked but
not ported), CPython heap-walk support.

## 9. Port audit vs upstream (2026-10-24) — OOM root cause + fixes

Context: the compiler reported transient "out of memory" (D0003 /
`__oomFatal`) with multiple GB of RAM free, worse with LSP server
instances running. Audited `lib/std/x86_64/{linux,windows}/allocators/
mimalloc.crl` line-by-line against upstream sources (microsoft/mimalloc
`dev` branch, cross-checked against `main3` v3.6.0 — see §10):

- https://raw.githubusercontent.com/microsoft/mimalloc/dev/src/segment-map.c
- https://raw.githubusercontent.com/microsoft/mimalloc/dev/src/page.c
- https://raw.githubusercontent.com/microsoft/mimalloc/dev/src/alloc.c
- https://raw.githubusercontent.com/microsoft/mimalloc/dev/src/segment.c
- https://raw.githubusercontent.com/microsoft/mimalloc/main3/src/heap/page-map.c

### 9.1 PRIMARY BUG — segment map indexes by `capacity`, not `reserved`

The port's global page map (`_miGlobalPages`, 4 MiB-window hash chains)
substitutes for upstream's bitmap. Upstream needs no window logic at
all: segments are aligned to their size, so `_mi_ptr_segment(p)` masks
any interior pointer to the segment base (segment-map.c: "the segment
start is aligned to the segment size"), and the map lookup is
O(1) by construction.

The port carves segments from 64 KiB arena slices (unaligned), so it
hashes `addr >> 22` into 64 buckets and chains `(pageBase, page)`
entries per window. The bug: `_miSegmentMapInsert` registered the page
using `page->capacity * page->blockSize`, where capacity is only
`MI_INITIAL_CAPACITY` (4) at creation. `_miPageExtend` later doubles
capacity up to `reserved` (~64 KiB worth of blocks) WITHOUT re-indexing.

Consequences for a page whose base sits within one page-size of a
4 MiB window boundary (~1.6% of pages, ASLR-dependent → transient!):

1. `realloc()` → `_miPageFind(ptr)` hashes the pointer to the *next*
   window's bucket, which has no entry for this page → returns null →
   realloc returns null → `AstContext.grow`/`growStable` set the sticky
   `ctx.error` → parser reports D0003 "out of memory", or Vec/String
   growth hits `__oomFatal`. **This is the observed bug** — free RAM is
   irrelevant; the allocator cannot resolve its own pointers.
2. `free()` → page not found → silently returns → the block is leaked
   forever (page->used never drops, page never retires).

More server instances ⇒ more live pages ⇒ higher odds one straddles a
window boundary. Matches the reported symptom exactly.

Fix (both ports): index the page's full `reserved * blockSize` extent
at insert time (reserved never changes post-creation). `_miPageFree`
remove uses the same extent for symmetry. Cited behavior: upstream
covers the entire segment up front precisely so every interior pointer
resolves.

### 9.2 Retired-page reuse dropped the `free` list

`alloc()` slow-path "try a retired page" did
`page->free = page->localFree`, discarding the old `free` chain. A
retired page has `used == 0`, so its blocks are split across free ∪
localFree — overwriting leaks the free-chain blocks permanently.
Upstream merges: `_mi_page_free_collect` moves local_free → free only
when free is empty, otherwise appends (page.c). Fix: merge the lists
(walk localFree to tail, encode tail→free, head = localFree), reset
`retireCount` (was never reset → immediate re-retire), and clear
`prev` (stale prev spliced foreign lists on the next move-to-full).

### 9.3 Missing move-to-full after slow-path extend

After `_miPageExtend` + block pop, the fast path checks
`freeCount == 0 && capacity >= reserved → _miPageMoveToFull`; the slow
path did not. Harmless today (extend always adds ≥ 4 blocks) but the
same rule must hold everywhere — added for parity with
`_mi_page_malloc_zero`'s full check (alloc.c / page.c).

### 9.4 Huge-page cross-thread free unlinked the wrong heap

Huge pages (segment == null, one mmap each) live on `heap->hugePages`.
`free()` walked `self.heap.hugePages` — if freed from another thread's
allocator, the owner's list keeps a dangling `MiPage*` (UAF on the next
walk) while the memory is already munmapped. Upstream tracks the
owning heap on the page (segment->thread_id / tld). Fix: added
`MiPage.owner`, set at both creation sites (`_miPageAlloc` and the
huge path); huge free unlinks from `page->owner->hugePages`.

### 9.5 Known divergences left as-is (documented, not fixed here)

- `_miMapInsertChain` mmaps a 24-byte `MiSegmentMapEntry` per (page,
  window) instead of upstream's bitmap: **1 bit per `MI_SEGMENT_ALIGN`
  (4 MiB)** — note upstream's own segment-map.c:12 header comment says
  "64MiB" but that is stale even upstream; types.h defines
  `MI_SEGMENT_ALIGN == MI_SEGMENT_SIZE == 4 MiB` and
  `MI_SEGMENT_MAP_PART_BIT_SPAN = MI_SEGMENT_ALIGN` (segment-map.c:31).
  Each ~8 KiB bitmap part covers ~252 GiB. Our per-entry mmaps are
  heavier under heavy page churn; not the OOM cause.
- Pages/segments never return to the OS: `_miPageFree` has no callers;
  retired pages are reused but never unmapped. Real mimalloc frees
  abandoned segments. Affects long-running `coralc --serve` RSS.
- `MiAlloc.init(0)` → no pre-reserved arena → every segment is a fresh
  mmap. Upstream pre-reserves segment-map-backed arenas.
- `_miLockAcquire` panics after 10000 spin/yield retries (upstream
  spins with backoff; the 10000 bound with yield is itself upstream's
  `MI_LOCK_*` fallback, but upstream then errors rather than panicking
  mid-allocation).
- Codegen `ebuf`/`tybuf` streams (coral-backend/codegen.crl) grow
  O(output × depth) and never truncate — a separate, real multi-GB
  transient-memory source on large compiles; tracked in
  COMPILER_PERFORMANCE_REVIEW.md P0 #11, unrelated to the allocator.

### 9.6 Validation of the five fixes (2026-10-24)

- **ASAN+UBSAN** (`gcc -fsanitize=address,undefined -O0 -g`):
  - OLD allocator, same stress test (1.03M individual allocs, 7 size
    classes incl. 400K × 8-byte blocks ≈ 63 pages so window-straddlers
    are guaranteed by ASLR; realloc every block; retire/reuse cycles;
    huge-path churn): **4424 failures** — null reallocs from unresolvable
    valid pointers, exactly bug 9.1's signature.
  - FIXED allocator: **0 failures, clean exit, no ASAN/UBSAN reports**.
  - Test harness: `/tmp/opencode/alloc_stress.crl` (v2 — individual
    per-block allocations; an earlier v1 that freed interior pointers
    of one giant allocation was itself buggy and munmapped live data).
- **rr 5.9.0** (Zen SpecLockMap caveat): recorded the full stress test
  (PASS under rr's syscall interception) and a compiler self-build
  (`coralc build --force`, 15 modules, clean). Replay of the
  memory-heavy stress trace was SIGKILLed by environmental memory
  pressure, not an allocator fault; the record runs are the validation.
- Coralc rebuilt 5× consecutively with the fixed allocator
  (`CORAL_HOME=<repo> ./build/coralc build`); the first rebuild with
  the old bootstrap binary reproduced D0003 live before the fix landed.

## 10. v3 (3.6.0, `main3`) architecture — current upstream release

v3 is a rewrite our port should eventually track for the page-map
design, but it does **not** change the free-list/collect semantics we
rely on:

- **No segments.** Memory comes from **arena slices** of 64 KiB
  (`MI_ARENA_SLICE_SIZE`, types.h:242). A page owns one or more
  contiguous slices (`slice_index`/`slice_count`) and can span them
  (types.h:484 — page info pointer may live in a separate slice).
- **page-map** (`src/heap/page-map.c`) replaces segment-map: a flat
  byte-per-slice map (each byte stores `slice_offset+1`; 0 = free),
  paged in via `mi_page_map_ensure_committed`. Lookup of a pointer is
  O(1) by masking to `MI_ARENA_SLICE_SIZE` (64 KiB default)
  granularity.
- **`_mi_page_map_register` registers the FULL page extent at page
  creation** — `mi_page_map_get_idx` computes the page's start-slice +
  slice_count and sets every covered byte (for huge pages, up to the
  "furthest interior pointer" bound `MI_LARGE_PAGE_SIZE -
  MI_ARENA_SLICE_SIZE`). This is the exact upstream analogue of fix
  9.1: the entire allocation range is resolvable from the moment the
  page exists, never an initial-prefix subset. (Our fix applies the
  same rule to the port's windowed hash map by indexing
  `reserved * blockSize`.)
- **Free-list collect is unchanged from v1**: `_mi_page_free_collect`
  still does free==NULL → move local_free→free, else append only on
  force — identical code to v1 page.c. Retire/expire lifecycle also
  survives (in `page-queue.c` now).
- Huge pages: v3 owns page memory through arena slices (no
  `heap->hugePages` segment path); the port's huge-page owner fix (9.4)
  remains the right model for any heap-tracked non-slice allocations.

Reference: fetched sources under `/tmp/opencode/mimalloc-v1` (dev) and
`/tmp/opencode/mimalloc-v3` (main3); URLs:
- https://raw.githubusercontent.com/microsoft/mimalloc/dev/src/segment-map.c
- https://raw.githubusercontent.com/microsoft/mimalloc/dev/src/page.c
- https://raw.githubusercontent.com/microsoft/mimalloc/main3/src/heap/page-map.c
- https://raw.githubusercontent.com/microsoft/mimalloc/main3/include/mimalloc/types.h
