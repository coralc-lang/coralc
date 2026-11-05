To anchor Coral's module and import system all the way down to the metal, we need a deterministic name-mangling scheme.

Because Coral supports local files, project-rooted modules (`file::`), and global library shelves (`import(lib)`), the linker needs a guarantee that two functions named `pow` or `sqrt` in different packages or paths never collide, while keeping the mangled output predictable and debug-friendly.

---

## 1. Design Goals for Coral Mangling

1. **Collision Freedom:** Completely isolate local project code, standard library modules, and external downloaded packages.
2. **Path Preservation:** Encode the exact module and file hierarchy into the symbol name.
3. **Linker Safety:** Use characters that are universally safe across C-compatible linkers, object file formats (ELF, Mach-O, COFF), and debuggers (`_`, `$`, alphanumeric).

---

## 2. The Mangling Anatomy

Every mangled Coral symbol follows this structural pattern:

```text
crl$<location>$<path_segments>$<symbol_name>

```

* **`crl$`**: The global magic prefix identifying a compiled Coral symbol.
* **`<location>`**:
* the symbol's location in the module/import system for local project files — the file's path relative to the entry root, `/` rendered as `$` (never a system path, never a literal scope word).
* `lib` for global shelf packages (`import(lib)`).


* **`<path_segments>`**: For `lib`, every component after the `lib/` root, separated by single underscores (`_`). For local files the module path already occupies this position (see above).
* **`<symbol_name>`**: The final function, struct, or constant name.

---

## 3. Concrete Examples

### Example 1: Local Project Function

* **Source:** `src/math/core.crl` defining `pub fn square(x: int)` in project `my_app`.
* **Mangled Output:**
```text
crl$src$math$core$square

```



### Example 2: Standard Library Function

* **Source:** `import(lib) std::math { pow }` from `~/.coral/lib/std.crl`.
* **Mangled Output:**
```text
crl$lib$std$math$pow

```



### Example 3: Downloaded Third-Party Library

* **Source:** `import(lib) serde::json { parse }` from `~/.coral/lib/serde.crl`.
* **Mangled Output:**
```text
crl$lib$serde$json$parse

```



### Example 4: Conflict Resolution (The `as` alias case)

When a user imports two conflicting functions (`std::math::sqrt` and `geometry::sqrt`):

* **`std::math::sqrt`** mangles to: `crl$lib$std$math$sqrt`
* **`geometry::sqrt`** mangles to: `crl$lib$geometry$sqrt`

Because the package and module paths are strictly baked into the mangled name, the local alias (`geo_sqrt`) is purely a frontend syntax convenience for the compiler's symbol table; the backend sees two completely distinct, non-colliding symbols.

---

## 4. Handling Overloads & Generics (Future-Proofing)

If Coral introduces function overloading or generic types down the road, type descriptors can be appended as an optional hash suffix or type-encoding string:

```text
crl$<location>$<path_segments>$<symbol_name>$<type_hash>

```

This keeps the base naming clean while ensuring type-parameterized instantiations remain distinct in the object file.
*/

// for externed items

/*
Got it. That syntax keeps C-interop clean and explicit, aligning with standard system-programming conventions.

Here is the updated **`extern` Exemption Rule** reflecting the correct syntax:

---

## The `extern` Exemption Rule

To support seamless Foreign Function Interface (FFI) integration with C and other native libraries, any symbol declared with `extern` **bypasses the Coral name-mangling scheme entirely**.

The linker receives the exact, raw identifier so it can bind correctly to external shared libraries, object files, or system routines without modification.

### 1. Syntax Forms

* **Standard C Interop:**
```c
extern i32 puts(const cchar*);

```


* **ABI-Specified Interop:**
```crl
extern("C") i32 sqlite3_open(const char* filename, sqlite3** pp);

```



### 2. Linker Output

* `puts` mangles to: **`puts`**
* `sqlite3_open` mangles to: **`sqlite3_open`**

No `crl$` prefixes, scope tags, or module path components are injected into `extern` declarations, ensuring zero friction when linking against native C libraries.
