# Union / Variant lowering in muvm IR — design note

Status: design for a later implementation pass. Verified against
`lib/muvm/base/irtypes.crl`, `lib/muvm/base/irBuilder.crl`,
`lib/muvm/passes/alias_analysis.crl`, and `compiler/coral-ir/*` on
2026-11-22.

## Current state (the bug)

`muvDeclTy` (`compiler/coral-ir/types.crl`) lowers both decls to opaque
byte blobs:

- `union U { … }` → `[maxFieldSize x i8]` — field access fails with the
  misleading "unknown struct field" because `muvFieldIdx` only knows
  `IrTypeKind::Struct` field tables.
- `variant V { Case { fields }, … }` → fixed `[16 x i8]` — construction
  hits `G0001 "variant construction (Phase 3)"`, and
  `PatKind::Variant`/`PatKind::Struct` patterns are rejected outright.

The C backend already implements the target semantics
(`compiler/coral-backend/codegen.crl`):

- `union` → C `union { fields }`: every field at offset 0, size = max.
- `variant` → C `struct { int32_t tag; union { struct{…} v0; … } u; }`:
  `tag` holds the case **ordinal** (0-based, declaration order).

Language surface that must keep working (all already sema-checked):

- `u.field` read/write on unions — fields overlap at offset 0.
- `V::Case { .f = x, … }` construction; `V::Case` in value position is the
  ordinal constant (assignment `x.tag = V::Case` writes the tag).
- `x.payload.Case.field` payload access (the `payload` member is the
  synthetic union-of-cases; `Case` selects the case struct).
- `switch (v) { Case { .f = b } => …, … }` variant patterns with field
  bindings; `switch (v.tag)` on the bare ordinal also works.
- `x.tag` reads the ordinal.

## Key fact that makes this cheap: muvm is a slot machine

muvm values are untyped 64-bit slots; `IrType` is carried for GEP
descent, load/store typing, and ABI classification — not for pointer
identity. Concretely:

- `IrBuilder::load(IrType* ty, IrValue* ptr)` takes the result type
  **explicitly** — the pointer operand does not need a matching pointee
  type.
- `IrOpcode::Bitcast` on pointers lowers to a no-op on every backend
  (x86_64: `Trunc | Bitcast` just moves the slot; arm64 and wasm32 the
  same).
- `alias_analysis.crl` already propagates points-to info **through**
  `Bitcast` (lines ~185, ~319), so bitcast-based field access stays
  visible to AA, GVN, LICM, etc.
- `Gep` takes arbitrary constant index chains and descends Struct (field
  index) and Array/Vector (element index) pointees.

**Conclusion: no new `IrTypeKind`, no IR/verifier/pass changes are
required.** Union and variant lower entirely in `compiler/coral-ir` using
existing `Alloca`, `Gep`, `Bitcast`, `Load`, `Store`, `ConstInt`.

## Recommended representation

### Union — byte blob + typed bitcast access

Keep the storage type as an opaque blob but make it a proper sized
struct-of-bytes so `irTypeSizeOf`/`alignOf` and aggregate ABI
classification work:

```
unionTy = struct { i8 data align=maxFieldAlign }   // or [N x i8] array
```

Simplest correct choice: reuse today's `[maxSize x i8]` array type
(`tyArray(tyInt(8), maxSize)`), but track per-decl field metadata in the
lowering context (`Muv`) keyed by the union's `Ty`/decl — a small
`UnionInfo { fields[], types[], offsets all 0 }` table built alongside
`muvDeclTy`.

Field access `u.f` (lvalue or rvalue):

```
addr  = address-of u                  // existing muvAddrOf path
fptr  = bitcast addr -> ptr(fieldTy) // IrBuilder bitcast; ptr→ptr is free
val   = load(fieldTy, fptr)          // or store(val, fptr)
```

- Union fields all sit at offset 0, so **no GEP arithmetic at all** —
  just the bitcast. This is faster than struct access, not slower.
- Loads/stores carry the field type explicitly, so i32-vs-f64 punning is
  exact; strict-aliasing concerns don't exist (muvm has no TBAA).
- Whole-union copy (`dst = src`) stays an aggregate memcpy/load-store of
  the blob — same as today.
- `align`: the blob's alignment must be max(field aligns) or later
  `alloca`/global placement can under-align an f64 field. If `[N x i8]`
  reports align 1, switch the storage to a one-field struct
  `{ i64/i8 pad }` or set the array's element type to the max-align
  integer (`tyInt(maxAlign*8)`) — check `irTypeAlignOf(Array)` returns
  elem align (it does: `alignOf(elem)`). Using `tyArray(tyInt(64), ceil)`
  when any field needs 8-byte align is the zero-IR-change fix; a cleaner
  long-term option is a `tflags` bit marking union structs (see below).

### Variant — `{ i32 tag; union payload }` as a real IrStructType

Mirror the C layout exactly:

```
variantTy = struct {
    i32  tag;                      // field 0: case ordinal
    blob payload;                  // field 1: [maxCaseSize x i8],
                                   //   align = max field align
}
```

Each case `Case { T1 f1; T2 f2; }` is treated as an anonymous struct
`{ T1 f1; T2 f2; }` for layout purposes (empty case → `{ i8 _e }`, same
trick as the C backend's `char _e`). Case structs need **not** be
interned as named IrStructTypes — the lowering only needs their field
type lists to compute offsets, which `IrStructType.offsets` already
provides if we build the type once per variant decl.

Operations:

- **Construction** `V::Case { .f = x }`: alloca `variantTy`; `store(i32
  ordinal, gep(v,0))`; for each field, `store(x, payloadCaseFieldAddr)`
  where `payloadCaseFieldAddr = gep(gep(v,1) ->bitcast-> ptr(caseStruct),
  fieldIdx)` — i.e. bitcast the payload pointer to the case's struct
  type, then reuse the existing `muvGepField` path unchanged.
- **`x.payload.Case`**: today `cgIsPayloadAccess` + `u.v<idx>` in C.
  In IR: `payloadPtr = gep(xAddr, 1)`; `casePtr = bitcast payloadPtr ->
  ptr(caseStructTy)`; result is `casePtr` as an lvalue (subsequent `.f`
  accesses go through normal `muvFieldAddr`/`muvGepField`).
- **`x.tag` / `x.tag = V::Case`**: ordinary struct field 0 access;
  `V::Case` in value position is `constInt(i32, ordinal)` — matches the
  C backend's `cgVariantCaseIdx` behavior.
- **Patterns** `Case { .f = b } =>`: load tag (`load(i32, gep(x,0))`),
  `icmp eq` against ordinal const, branch; bindings use the same
  `payloadCaseFieldAddr` path. `switch (x.tag)` needs nothing new — it's
  an i32 switch after one load.
- **`PatKind::Variant` with `typeName`** (scrutinee already the ordinal,
  `switch (x.tag)` spelled out in source): compare the loaded/int
  scrutinee directly — same as C backend's `tagField == false` arm.

## Alternative considered: real `IrTypeKind::Union`

Rejected for now. Adding a kind means touching every `switch(kind)` in
`irtypes.crl` (sizeOf/alignOf/equal/print/parse), the text IR
printer/parser, all three asm backends, and ~30 passes (sroa, mem2reg,
gvn, licm, slp_vec, simd_vec, dce…). The bitcast approach gets identical
runtime code — on x86_64/arm64/wasm a union field access is *just* a
load/store at offset 0 — with changes confined to `coral-ir`.

If a future pass needs union-awareness (e.g. SROA scalarizing a union
into per-field registers would be **wrong** — overlapping fields must
stay memory-backed), the escape hatch is a `tflags` bit (bit 4 is free;
bits 0–3 are packed/bfloat/opaque/nominal) on the blob's IrType marking
it union, which passes can test via `irTypeIsUnion(t)`. Not needed for
correctness of the lowering itself: today's passes treat it as an opaque
aggregate and are already conservative.

## Work items for the implementing agent

1. `types.crl`: build a per-decl union info table (field types, count,
   max size, max align) in `Muv`; `muvDeclTy` Union returns the aligned
   blob; Variant returns the `{i32, blob}` struct type. Generics go
   through the existing mono substitution path — field types must be
   resolved under `w.subs` like `muvStructTy` does.
2. `expr.crl`: teach `muvFieldAddr`/`muvFieldIdx` (or a parallel
   `muvUnionFieldAddr`) the union path — detect `TypeKind::Named`
   resolving to `DeclKind::Union`, emit bitcast+load/store. Extend the
   `payload.Case` access path (`cgIsPayloadAccess` equivalent — check
   whether coral-ir already has one; if not, add it mirroring
   codegen.crl:4116).
3. Variant construction in `StructLiteral` lowering (`variantName != 0`
   currently errors in static storage and is unimplemented elsewhere):
   emit tag store + per-field stores.
4. `stmt.crl`: `PatKind::Variant` lowering — tag compare + bindings;
   keep the `typeName` ordinal-scrutinee path.
5. `V::Case` path-expr lowering to ordinal const (mirror
   `cgVariantCaseIdx`, codegen.crl:1210).
6. Tests: union read/write overlap, variant construct/match/bind,
   `switch(v.tag)`, nested variant-in-struct, generic variant
   monomorphization, `--muvm` and C backend parity.

## Watch items

- **Alignment**: blob element type must carry max field alignment or
  `alloca`/global placement under-aligns (see Union section).
- **SROA/mem2reg**: they may try to promote the blob alloca; loads through
  bitcast are typed differently per field, which is fine, but verify no
  pass assumes one alloca = one scalar layout. If SROA miscompiles,
  mark union allocas non-promotable (there is likely an existing
  "don't promote" flag/metadata path — check `irMetadata.crl`).
- **Aggregate ABI**: variant passed/returned by value goes through the
  same struct classification as `{i32, blob}` — should already work since
  structs do; verify a `fn f(V) -> V` round-trip.
- **`str`-like blobs**: none — unions/variants never contain `str`
  without going through the same field-type machinery as structs.
