Here is a complete scheme you could adopt as the default. I designed it around what you've already locked in: canonical-path identity, `::` paths, sized types, generics, methods, and `#[[no_mangle]]`.

## Core rule

A symbol is a pure function of the declaration's **canonical path**, its **kind**, and its **signature**. It never depends on the alias, re-export, or import spelling used to reach it. This is how duplicate `mod` bindings to one module collapse to a single symbol, as you wanted.

```
symbol := "_C" scope kind-suffix
scope  := "N" root segment* "E"
root   := "f"            // the `file` root
        | "l" ident      // lib package, e.g. l3std
        | "r" ident      // any other project root
segment:= ident [ "I" type* "E" ]   // generic args attach to their segment
ident  := <decimal length><bytes>   // 3pow, 8onUpdate
```

Length-prefixed identifiers make the format unambiguous. Any identifier characters are safe, and the grammar is prefix-free, so demangling never guesses.

## Kind suffixes

```
function : [ "M" self ] "F" param* "_" ret
           self := v (by value) | p (self*) | c (const self*)
global   : "G"
trait impl segment : "X" scope   // inside the path: Point, then X<trait>, then method
```

Static methods and free functions omit `M`. The return type is encoded, so the symbol covers the whole signature.

## Type encoding

```
i8 a   i16 s   i32 i   i64 x   isize y
u8 h   u16 t   u32 j   u64 m   usize z
f32 f  f64 d   bool b  void v  str S   rawptr r

P<T>     pointer          K<T>     const
A<n>_<T> fixed array      Y<params>_<ret>E  function pointer
N...E    user type (struct/enum/variant), same form as a scope
```

Generic instantiations use `I<args>E` on the type's segment. Variant cases aren't symbols, because the variant is a type and is encoded by its path.

## Examples

```
std::math::pow(f64, f64) -> f64
_CNl3std4math3powEFdd_d

mu::player::onUpdate(f32) -> void
_CNl2mu6player8onUpdateEFf_v

Entity.tick(f32) in file game/entity     (implicit self by value)
_CNf4game6entity6Entity4tickEMvFf_v

std::hashmap<u64,u32>.get(u64) -> Option<u32>    (self*)
_CNl3std7hashmapImjE3getEMpFm_Nl3std6OptionIjEE
```

## Rules that matter

- **`#[[no_mangle]]` and `extern`** skip mangling entirely and use the raw name. Other attributes (`inline`, `deprecated`, `weak`) never affect the name.
- **No version in the symbol.** `coral.crlb` already guarantees one package per name per build, so versions would only break ABI stability.
- **Layout isn't encoded.** A struct has exactly one declaration, so its path fixes its layout, `packed` and `reorder` included.
- **Private items** need no extra marker. The file's module path is already in the scope, so two files can't collide. Mark them internal linkage.
- **Generic instances** are emitted once per distinct fingerprint, as merged or comdat symbols, so every file that instantiates `hashmap<u64,u32>` links to one copy.
- **`_C` is reserved**, so it can't clash with C libc symbols. Mach-O prepends its own underscore, which is harmless.

## Why this suits your Mu setup

Mu emits the same scheme with `mu` in front, so the engine declares the expected script function as an extern prototype in the `mu` namespace and lets the compiler produce the name. Since params and return type are both encoded, a wrong signature gives a different hash, so `resolve` returns `NotFound`. `sigHash` and `expectedSig` become redundant and can go. Mu's types must map onto the same letters, or its hashes won't match.

## Optional later

Add back-references (`R<n>_`) to shorten deeply nested generic names. It's a pure size optimization and changes no semantics.

Should `mu` be a lib root (`l2mu`, as I wrote it), or should it get its own root letter, so a script namespace can never be confused with an installed package?