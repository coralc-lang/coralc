# wallvm — public API & entry-point map

Purpose: a precise map of wallvm's **public surface and entry points**, written so
another compiler can import `lib/wallvm` directly as its IR → machine-code backend
(build IR → optimize → allocate → emit assembly → assemble → link).

Scope: `lib/wallvm/**` only. The `compiler/` folder was **not** consulted (per
instruction). Real usage examples were taken from `test/wallvm/*.crl` and
`test/object/*.crl`.

Legend: every claim carries `file:line`. Items marked **[?]** are explicitly
unverified. Nothing here is inferred from docs alone — docs under
`lib/wallvm/docs/` are referenced only in §13.

---

## 1. Package & module map

### 1.1 Manifest

`lib/wallvm/manifest.base.crlb:9-15` — schema 1, `strict = true`, build name
`"wallvm"`, `root = "lib/wallvm/"`, `modules = ["wallvm"]`, empty
`platform_root`. The manifest states wallvm has no platform files of its own;
platform selection resolves through std's manifests. Both manifests also note
that `include/extends/platform_root` resolution is *not implemented in the
builder yet* (`manifest.base.crlb:6-7`, `linker/manifest.base.crlb:6`).

### 1.2 How import paths resolve (inferred from working consumers, ⚠)

| Import path | Resolves to | Evidence |
|---|---|---|
| `wallvm::wallvm` | `lib/wallvm/wallvm.crl` (the driver) | `test/wallvm/irtool.crl:5` |
| `wallvm::irtypes` | alias in `lib.crl:3` → `base/irtypes.crl` | `irtool.crl:6` |
| `wallvm::irBuilder` / `irOps` / `irMetadata` / `domtree` | aliases in `lib.crl:4,5,6,10` | throughout `base/` |
| `wallvm::irParser` / `irPrinter` / `irStrings` | aliases in `lib.crl:7,8,7` → `text/*` | `irtool.crl:7` |
| `wallvm::passes::validate` | `passes/lib.crl:43` alias → `passes/validate.crl` | `wallvm.crl:4` |
| `wallvm::passes::safety` | **file fallback** — `safety.crl` is *absent* from `passes/lib.crl` (42 aliases, no `safety`; `rg safety passes/lib.crl` → no match) yet imported at `wallvm.crl:43` | verified both sides |
| `wallvm::rules::asm_rules` | `rules/lib.crl:2` (also re-aliased `lib.crl:13`) | `wallvm.crl:70` |
| `wallvm::regalloc::lsra` / `::graph` | `regalloc/lib.crl:3,2` | `irtool.crl:8` |
| `wallvm::target::x86_64_V` etc. | aliases in `target/lib.crl:6-12` (`x86_64_V = use x86_64::linux::linux`, `x86_64_win`, `x86_V`, `wasm`, `x86_64_generic`, `x86_64_base`, `x86_base`) | `wallvm.crl:47-56` |
| `wallvm::linker::x86::link` | folder chain — there is **no** `linker/lib.crl` and `lib.crl` does not alias `linker`; `linker/x86/lib.crl:2-9` aliases its children | `test/object/linktool.crl:2` |
| `wallvm::assembly::x86::obj`, `wallvm::assembly::wasm::encode` | `assembly/lib.crl:3-5`, `assembly/x86/lib.crl:5-9`, `assembly/wasm/lib.crl:2-5` | `test/object/asmtest.crl`, `test/wallvm/wastool.crl:6-7` |
| `wallvm::ffi::_extern` | `ffi/lib.crl:2` `pub mod _extern = use _extern;` ("extern is a keyword"); file on disk is `ffi/extern.crl` — exact path **[?]** | source |

Rule of thumb (⚠ inferred): a submodule resolves either through a `pub mod`
alias in its parent's `lib.crl` **or** directly by file name (proved by
`passes::safety`). Aliases in the root `lib.crl` are what make short paths
(`wallvm::irtypes`) work at all — there is no `lib/wallvm/irtypes.crl`.

### 1.3 Visibility rules

- Only `pub` items are API. Files are `#[[no_drop_all]]` (e.g. `wallvm.crl:1`).
- Struct *methods* carry no `pub` marker yet are callable cross-module:
  `IrPrinter.output()` is un-marked (`irPrinter.crl:44`) but called from
  `wallvm.crl:102`. Conversely `printModule` is marked `pub` (`irPrinter.crl:1013`).
  The marker on methods is inconsistent; treat all methods of a `pub` struct as
  accessible.
- `pub` does **not** mean *wired* or *safe to use*: several public symbols are
  dead or unwired (§13).

---

## 2. Entry points — the driver (`wallvm.crl`)

All signatures verbatim from `lib/wallvm/wallvm.crl`.

### 2.1 Primary entries

```coral
pub CompileResult irCompile(IrModule* modd, IrContext* ctx, CallingConvention cc, u32 optLevel)   // :539
pub str           irCompileAsm(IrModule* modd, IrContext* ctx, CallingConvention cc, u32 optLevel) // :605
pub bool          irCodegen(IrModule* modd, rawptr userdata, CallingConvention cc)                 // :664
pub bool          irOptimize(IrFunc* func, IrContext* ctx, CallingConvention cc, u32 optLevel)     // :342
pub bool          irStructureLane(IrFunc* func, IrContext* ctx)                                   // :387
```

- **`irCompileAsm` is the only entry that returns actual output** (assembly
  text). It runs the full pipeline itself: per-function `irOptimize` →
  `irStructureLane` → regalloc (lsra, or graph at O3 for leaf ≤8-block funcs) →
  target `*Asm` codegen (`:605-662`). Buffer lives for the program lifetime
  (comment `:602-604`); `str::empty()` is returned on any failure.
- **`irCompile`** runs phases 1–2 the same way but ends in `irCodegen`
  (`:539-600`) — see §13-G1: the bool codegen variants currently **discard**
  their output. Do not use `irCompile`/`irCodegen` to obtain code.
- `irCodegen` dispatch (`:668-681`): SysV/SyscallX86_64/SyscallMacOS →
  `irLinux_X86_64`; Win64/SyscallWin64 → `irWinX86_64`; Cdecl/Stdcall/SyscallX86 →
  `irCodegenX86`; Wasm32 → `irCodegenWasm32`; **else → `irCodegenX86_64Bare`**
  (silent fallback, §13-G2).
- `irCompileAsm` dispatch (`:649-661`): same first four groups → `*Asm`
  variants; **else → `str::empty()`**.
- Ordering contract (`:554-558`): *all* functions must be optimized +
  structure-laned before *any* regalloc runs (inliner clones callee IR; lsra
  detaches phis). If you drive phases manually, preserve this.

### 2.2 Results, options, version

```coral
pub struct CompileResult { bool success; str errorMsg; u32 errorLine; }  // :447
pub CompileResult compileSuccess()                                      // :454
pub CompileResult compileError(str msg, u32 line)                       // :463
```
Error reporting is a message string + line (line almost always 0 — failures are
phase labels like "codegen failed", `:596-597`).

Global knobs (process-wide, mutable, not thread-safe — §13-G15):

| Symbol | Default | Effect | Ref |
|---|---|---|---|
| `gUnrollEnabled` | `false` | unroller runs in structure lane (irtool sets it at O3) | `:80`, `irtool.crl:42` |
| `gSafetyChecks` | `true` | bounds/null/divzero/overflow instrumentation, **O0 only**, skipped for wasm ccs | `:83`, `:352-358` |
| `gKeepPhisEnabled` | `true` | keep register-form phis for lsra; `false` forces alloca demotion (`WALLVM_LOWER_PHIS`) | `:88`, `:436` |
| `gPipelineVerbose` | `false` | dump module around optimization | `:94` |
| `gPrintAfterPass` | `false` | dump after every mutating pass | `:95` |
| `WALLVM_VERSION_MAJOR/MINOR/PATCH` | 0.1.0 | version consts | `:75-77` |

Per-pass flags: `gLsraVerbose` (`regalloc/lsra.crl:19`), `gSccpVerbose`
(`passes/sccp.crl:10`), plus borrowcheck printing via
`irPassBorrowCheckPrint` (`passes/borrowcheck.crl:1471`, used by irtool).

### 2.3 Pipeline driver

```coral
typedef PassFn = bool(IrFunc*, rawptr);                                  // :107
pub struct PassPipeline { PassFn* passes; str* names; u32 count; u32 capacity; }  // :109
    static PassPipeline new(); void add(PassFn, str); void clear();
    bool runOnFunc(IrFunc*, rawptr);                                     // :159
    bool runOnFuncIterate(IrFunc*, rawptr, u32 maxIters);                // :182
pub PassPipeline pipelineLevel0();                                       // :209
pub PassPipeline pipelineLevel1(CallingConvention cc);                   // :236
pub PassPipeline pipelineLevel2(CallingConvention cc);                   // :262
pub PassPipeline pipelineLevel3(CallingConvention cc);                   // :294
```

Contract: a pass returns `true` = *mutated* (not error). On mutation the driver
bumps `IrContext.analysisGeneration` (`:170`) so cached analyses go stale.
Iteration counts in `irOptimize` (`:370`): O0=1, O1=2, O2=5, O3=8.
`optnone` funcs are forced to O0 (`:347`). Safety runs *before* the pipeline at
O0 (`:352-358`).

`abiLowerPassFor(cc)` (`:226-234`): Win64/SyscallWin64 → Windows pass
(`target::x86_64::windows::abi_lower::irABILower`), everything else → System V
(`irABILower` from `x86_64::linux::abi_lower`).

Pipeline orders are reproduced verbatim in §10.2.

`irStructureLane` (`:387-445`): borrowcheck (diagnostic only, never fails) →
optional unroll + its sccp/constfold/simplify/jump_thread/adce cleanup
(iterate ≤10) → conditional `irLowerPhis` (when `!gKeepPhisEnabled ||
!irPhisAreFriendly`) → validate. Always returns `true` except null args.

`targetConsumesRegAlloc(cc)` (`:475-491`) and `regallocConfigFor(cc)`
(`:493-531`): see §8.

---

## 3. Integration recipes (end-to-end)

### 3.1 Textual IR → assembly text (what `irtool` does)

```coral
import wallvm::wallvm { irCompileAsm, gUnrollEnabled /*, other knobs */ };
import wallvm::irtypes { IrContext, IrModule, irCtxCreate, irCtxDestroy };
import wallvm::irParser { IrParser, new, destroy, parseModule, getError, getErrorLine };
import wallvm::rules::asm_rules { CallingConvention };

IrContext* ctx = irCtxCreate();
IrParser p = new(ctx);
IrModule* modd = parseModule(&p, src);            // str input, whole module
if (modd == null) { /* getErrorLine(&p), getError(&p) */ }
str asmText = irCompileAsm(modd, ctx, CallingConvention::SystemV, 2);
// asmText is assembly source; write it to a .s file (irtool does)
irCtxDestroy(ctx);
```
Source: `test/wallvm/irtool.crl:5-13, 69-80` (+ run at O0..O3, `:25-37`).

### 3.2 Programmatic IR construction → assembly

```coral
IrContext* ctx = irCtxCreate();                    // irtypes.crl:1082
IrModule*  m   = ctx->createModule("name");        // irtypes.crl:1074
IrFunc*    f   = ctx->createFunc("main", retTy, params, nparams); // :1063
f->addArg(...); m->addFunc(f);
IrBlock* entry = ctx->createBlock("entry");        // :1053
f->addBlock(entry);
IrBuilder b = IrBuilder::new(ctx);                 // irBuilder.crl:20
b.pos(entry, null);                                // insert point = block, before=null (append)
IrInst* i = b.add(a, b.load(ty, p));               // ... build body
b.ret(c);
str asmText = irCompileAsm(m, ctx, cc, 2);
```
Types come from `ctx->tyInt(bits)/tyPtr/tyFloat/tyDouble/tyArray/tyFunc/tyVector`
(`irtypes.crl:754-765`) — structs need `createStructType` (`:866`) — constants
from `ctx->constInt/constFloat/constArray/createStructConst` (`:933-1003`),
globals from `ctx->createGlobal(...)` (`:767`). There is no
separate module registration step — `createModule` is enough, then `m->addFunc`.
Function signatures are **incomplete until you add the arguments yourself** —
full recipe (args, vararg, extern) in §4.13; source-type mapping table in §4.12;
layout rules and their quirks in §4.11.

### 3.3 Assembly text → object → linked image

```coral
// assemble (x86/x86-64)
import wallvm::assembly::x86::obj { AsmObject, asmObjectNew, asmObjectDeinit, emitElf, emitCoff, emitRaw };
import wallvm::assembly::x86::x86_64 { assembleText };
AsmObject o = asmObjectNew();
AsmParseError err;                                 // { str msg; u32 lineNo; } common.crl:60
if (!assembleText(asmText, &o, &err)) { /* err.lineNo, err.msg */ }
AsmBytes out = AsmBytes::new();                    // x86/common.crl:145 {u8* data; u32 len; u32 cap;}
emitElf(&o, &out, &err);                           // or emitCoff / emitRaw(obj.crl:202,449,709)

// link
import wallvm::linker::x86::link { Config, Arch, configFor, Linker, Buffer, linkBuffers };
import wallvm::linker::x86::elf { FMT_ELF_EXE, FMT_ELF_DYN, FMT_PE_EXE, FMT_PE_DLL };
Config cfg = configFor(Arch::X86_64);              // entry "_start", FMT_ELF_EXE, symtab on (link.crl:50)
Linker l = Linker::new(cfg);                       // link.crl:81
l.addObject("unit.o", objBytes);                   // :108  (or addObjectFile(path,&err):139, addBuffer:129)
l.addExport("name"); l.setEntryAddress(addr);      // :92, :102
Result<Vec<u8>, String> img = l.produce();         // :147 — in-memory image
l.write(path, &err);                               // :164 — or write to disk
// one-shot: Result<Vec<u8>,String> linkBuffers(Config cfg, Vec<Buffer> inputs)  link.crl:980
```
Sources: `test/object/linktool.crl`, `test/object/asmtest.crl`.

### 3.4 WAT → wasm binary (+ JS bindings)

```coral
import wallvm::assembly::wasm::encode { wasmAssemble };
import wallvm::assembly::wasm::bindings { wasmBindings };
wasmAssemble(wat, &outBytes, &error, &errorLine);                    // encode.crl:877
wasmBindings(wat, moduleName, &js, &dts, &error, &errorLine);        // bindings.crl:366
```
Front half: `irCompileAsm(..., CallingConvention::Wasm32, ...)` produces wasm
assembly text (`wastool.crl` then assembles it).

---

## 4. IR data model (`wallvm::irtypes` = `base/irtypes.crl`)

### 4.1 Containers & ownership

- `irCtxCreate()` / `irCtxDestroy(ctx)` — `irtypes.crl:1082,1089`.
  Destroy frees only the context's own arrays (types/consts/caches pointer
  tables, `:1092-1099`) — **not** the pointed-to `IrType`/`IrValue` objects, not
  modules/functions/blocks/instructions. There is **no** destroy API for
  Module/Func/Block (grep: none). The whole library is `#[[no_drop_all]]`;
  teardown is partial by design (§13-G10).
- Selected destructors exist for: `irGlobalDestroy`, `irStringConstDestroy`,
  `irArrayConstDestroy`, `irStructTypeDestroy` (`:1101-1126`), plus
  `IrInst.erase()` (`:256-294`, unlinks + frees one instruction).
- Strings created inside IR are duplicated via `irDupStr` (`:6-10`, heap).

### 4.2 `IrContext` (`:673`)

Fields: type table (`types/ntypes/capTypes`, uniqued via `tyGetOrCreate`),
`nextId` (value id counter, `nextValueId()`), constant pools
(`constInts`, `constFloats`, `arrayConsts`, `structConsts`), analysis caches
(`analysisCaches`), and:

```coral
u32 analysisGeneration;   // monotonic; pipeline bumps on every mutation (wallvm.crl:170)
FunctionAnalysisCache* getAnalysisCache(IrFunc*);
FunctionAnalysisCache* getOrCreateAnalysisCache(IrFunc*);
void clearAnalysisCaches();
```

Type constructors (`:754-765`): `tyVoid, tyInt(u32 bits), tyFloat /*f32*/,
tyDouble /*f64*/, tyPtr(IrType* elem) /*width hardcoded 64*/,
tyArray(elem,count), tyFunc(ret,params,nparams,isVararg),
tyVector(elem,count), tyStruct(IrStructType*)` — all interned.

Object creators: `createGlobal(name,ty,isConst,isExtern,init,alignment)` (`:767`),
`stringConstLabel(id)` (`:782`), `createStringConst(data,length)` (`:801`),
`createStructType(name, fields, fieldNames, nfields)` (`:866`),
`constInt/constFloat/constArray/createStructConst` (`:933-1003`),
`createInst(op,ty,ops,nops,icmpP,fcmpP)` (`:1027`), `createBlock(name)` (`:1053`),
`createFunc(name,ret,params,nparams)` (`:1063`), `createModule(name)` (`:1074`).
Free helpers: `irTypeAlignOf` (`:820`), `irTypeSizeOf` (`:842`), `irTypeEqual`
(`:1129`), `irTypeStr` (`:1161`), `wallvmClz64/wallvmCtz64` (`:1188,1200`).

### 4.3 `IrModule` (`:534`)

`ctx, name, funcs/nfuncs/capFuncs, globals/nglobals, constStrings/nconstStrings,
structs/nstructs`. Methods: `addFunc, getFunc(name), addGlobal, addConstString,
findConstString(data,length) /*dedup, only looks*/ , addStruct`.

### 4.4 `IrFunc` (`:454`)

`base(IrValue), parent, blocks/nblocks/capBlocks, retType, paramTypes/nparams,
isExtern, externLib, externSym, metadata(rawptr), args/nargs/capArgs`.
Methods: `addBlock, addArg, removeBlock, isLeaf()` (no `Call` anywhere, `:521`).
Calling convention is **not** stored on the function — cc is a driver argument.
`isExtern` functions are skipped by every compile phase.

### 4.5 `IrBlock` (`:301`)

`base, parent, insts/ninsts, preds, succs` (explicit pred/succ arrays).
Methods: `addInst, insertBefore(inst,anchor), addPred, addSucc /*addSucc also
addPred on target*/, removePred, removeSucc, hasPred, hasNoSideEffects()
(`:416`), terminator()` (`:441` — scans for Br/CondBr/Ret/Unreachable/Noret).
Note: `terminator()` does **not** include Switch/LandingPad; keep preds/succs in
sync manually when editing edges (addSucc is the only auto-maintaining one).

### 4.6 `IrValue` (`:71`) and kinds (`:24`)

`kind, type, id, valData, name, users/nusers/capUsers`.
`IrValueKind = Inst, ConstInt, ConstArray, ConstFloat, Block, Func, Global, Arg,
StringConst, StructConst`.
Methods: `addUser, removeUser, replaceAllUses(newVal)` (`:111` — also patches
self-references inside the replacement), `valueKind(), valueType()`.

**`valData` is the regalloc↔backend channel**: after lsra it packs
`SPILL_BIT=0x8000_0000`, `FLOAT_BIT=0x4000_0000` and the physreg index
(constants are *file-private* in `regalloc/lsra.crl:11-12` — consumers decode by
convention, see §8.4).

Subtypes embed `IrValue base` first: `IrGlobal` (`:145`: parent, isConst,
isExtern, initVal, alignment, metadata), `IrStringConst` (`:156`: data, length),
`IrArrayConst` (`:164`), `IrStructConst` (`:174` — one elem per field, decl
order), `IrStructType` (`:181`: irType, name, fieldTypes, fieldNames, size,
offsets).

### 4.7 `IrInst` (`:193`)

`base, opcode, parent, prev, next, ops/nops/capOps, icmpPred, fcmpPred,
debugLoc, varDbg/nvarDbg, asmString/asmConstraints/asmClobbers/asmNumSideEffects,
metadata(rawptr)`.
Methods: `prevInst/nextInst/instParent, setDebugLoc(file,line,col),
isUnsignedArith()` (Add/Sub/Mul with `IR_AUX_UNSIGNED` in the aux slot,
`:229-237`), `addVarDebug, erase(), instOpcode(), numOps(), operand(i)`.
The `icmpPred` field doubles as the unsigned-flag aux slot for Add/Sub/Mul —
don't assume it's always a predicate.

### 4.8 `IrType` (`:38`)

`IrTypeKind = Void, Int, Float, Ptr, Array, Func, Vector, Struct` (`:12`).
Fields: `kind, width, elem, count, ret, params, nparams, isVararg`; methods
`kind(), width(), isEqual(other)` (`:49-51` — same names as fields, **[?]** how
Coral disambiguates `t.kind` field vs `t.kind()` method).
`Float` width 32/64 only (`tyFloat`/`tyDouble`); `Ptr` width hardcoded 64;
vector = `tyVector(elem,count)` with `width = elem->width*count` (`:761`).
No x86-specific or arbitrary-precision float kinds exist.

### 4.9 Debug support types

`IrDebugLoc {file,line,col}` (`:54`), `IrVarDebugInfo {varName, varType, line,
col, argIndex /* ~0u if not an arg */}` (`:61`).

---

### 4.10 Type construction & identity (for in-memory generation)

All type constructors are methods on `IrContext` (`irtypes.crl:754-765`):

```
tyVoid()  tyInt(bits)  tyFloat()  tyDouble()  tyPtr(elem)
tyArray(elem, count)  tyVector(elem, count)
tyFunc(ret, params, nparams, isVararg)  tyStruct(st)
```

- **`tyStruct` takes an `IrStructType*`** (`:765`) — there is no "make a struct
  type from a bare field list" entry. The record from
  `createStructType(name, fields, fieldNames, nfields)` (`:866-881`) is the front
  door; it computes field offsets (each field `alignUpTo(cur, alignOf(field))`)
  and `size = alignUpTo(end, maxFieldAlign)`, interns the `IrType`, and stores
  name/fields/size/offsets on the record. `fieldNames` may be `null` (the printer
  then synthesizes `f0:`, `f1:` — `irPrinter.crl:933-941`). Register with
  `m->addStruct(st)` so dumps resolve `struct @Name`; unregistered struct types
  print inline at every use site (§5.3 P9).
- **Interning → pointer identity.** `tyGetOrCreate` (`:882-919`) linearly scans
  `ctx->types` and returns the existing type when the shape matches. Within one
  context, `IrType* == IrType*` **is** the equality test; `irTypeEqual` (`:1129`)
  is the explicit structural compare (also for cross-context). Consequences: hold
  one pointer per shape and reuse it; you *cannot* create two distinct types of
  identical shape — a source-language `typedef`/alias collapses for free, but so
  do two semantically different named structs.
- **Intern key** (`:890-907`): Int/Float by `width`; Ptr/Array/Vector also
  compare `elem` recursively; Func compares ret + params + `isVararg`; **Struct
  compares `width` (= size) + field types** — names are *not* in the key
  (comment `:762-764`: size is in the key so `{i32,i32}` and `{f32,f32}` don't
  fold). Two `IrStructType` records with equal shape share one `IrType` pointer
  but keep separate names/offsets (dump hazard, §5.3 P9).
- **No other type-construction APIs exist**: no opaque/forward-declared structs,
  no typedef records, no address-space or packed/aligned wrappers, no bitfield
  or union kinds (§4.12, §13 G-type5).

### 4.11 Layout rules (`irTypeAlignOf` `:820-841`, `irTypeSizeOf` `:842-856`)

| kind | align | size |
|---|---|---|
| Void | 1 | 0 |
| Int / Float | `ceil(width/8)` min 1 → **i1 = 1 byte** | same as align |
| Ptr / Func | **8** (always) | **8** (always) |
| Array / Vector | `alignOf(elem)` | `sizeOf(elem) × count`, **`count==0` treated as 1** (`:851`) |
| Struct | **8, hardcoded** (`:838`) | `t->width` as precomputed by `createStructType` (natural max-field align) |

Verified quirks:

1. **`alignOf(struct)` can exceed the struct's real alignment and even its size.**
   `struct { i8 }` → size 1, reported align 8. `createStructType` sizes structs
   to *natural* max-field alignment, not to 8 — the two layout paths disagree
   about "the struct's alignment". Consumers that pad with `irTypeAlignOf`
   (e.g. the text frontend's global alignment, `irParser.crl:2489`;
   codegen's align fallback, `x86_64_base.crl:756-757`) over-align such objects.
2. **Pointer size is target-blind: 8 at IR level, 4 in the wasm32 backend**
   (`target/wasm/wasm.crl:296,303` size Ptr/Func as 4). Any struct containing a
   pointer has an IR-computed layout (`createStructType` offsets,
   `irTypeSizeOf`) that is **wrong on wasm32**; i386 handling of
   `IrTypeKind::Ptr` is **[?]** (no matches in `target/x86/x86_base.crl`).
   There is **no DataLayout object** — you cannot ask the context which target
   layout is in force.
3. **i1 occupies 1 byte in memory** — bools are byte-sized after spills; the only
   register-width encoding lives in `valData` spill bits (§8.4), not in the type.
4. **Vector `width` = `elem->width × count`** (`:761`) is informational only;
   `sizeOf(Vector) = size(elem)×count` (no lane padding), `alignOf(Vector) =
   alignOf(elem)` — no 16/32/64-byte SIMD alignment is implied.
5. Struct sizes are **not** rounded to their reported (8) alignment: `{i32}` →
   size 4 / align 8; `array T N` stride = `size(T)×N` with no per-element
   realignment.

### 4.12 Mapping source-language types → wallvm

| Source construct | wallvm | Notes |
|---|---|---|
| `bool` | `ctx->tyInt(1)` | 1 byte in memory (§4.11); `icmp`/`fcmp` results are `i1`; pass 0/1 to `constInt` (dump shows `true`/`false` for width 1) |
| `i8…i64` / `u8…u64` | `ctx->tyInt(bits)` | **signedness is not in the type.** Pick `sext`/`zext` at the frontend; mark `add/sub/mul` on unsigned operands — the model keeps `IR_AUX_UNSIGNED` in the `icmpPred` aux slot (`isUnsignedArith`, `irtypes.crl:232-239`), which the dump prints as `add.u`/`sub.u`/`mul.u` |
| integer constant | `ctx->constInt(ty, val)` (`:933`) | stores the raw u64 **unmasked — no truncation to `ty->width`**; values ≥ 2⁶³ print signed (§5.3 P3); `i1`: store 0/1 (printer reads bit 0, `irPrinter.crl:331-337`) |
| `float` | `ctx->tyFloat()` | f32 constants are stored as **f64 value bits** (`constFloat` takes f64; x86 emitter narrows at emission, `x86_64_base.crl:793-800`) |
| `double` | `ctx->tyDouble()` | `constFloat(ty, v)` dedups on **raw bits only, ignoring `ty`** (`:960-962`) — an f32 and f64 constant with equal bits collide (§4.14) |
| `enum` | any `tyInt(bits)` | no enum type; names/values live in your own metadata (`wallvm::irMetadata`) or side tables |
| `T*` / `void*` | `ctx->tyPtr(ty)` / `tyPtr(null)` | `elem` documents gep/load typing; size fixed 8 at IR level (§4.11) |
| `T[N]` | `ctx->tyArray(ty, N)` | `N==0` sizes as 1 element (`:851`) |
| named `struct` | `ctx->createStructType(...)` + `m->addStruct(st)` | natural layout only (§4.11); same-shape structs share one `IrType`; two named records with equal shape → dump shows the first name everywhere (§5.3 P9) |
| anonymous struct | `createStructType` with empty `name` | never printed as `type @…`; appears inline at each use |
| `union` | **no representation** | manual: max-size byte array (`tyArray(tyInt(8), size)`) + `bitcast`/typed `load` per variant; no punning type exists |
| bitfield | **no representation** | split into integer shift/mask ops at the frontend |
| `packed` struct / field alignment | **no representation** | `createStructType` always uses natural alignment; no override hooks (only `IrGlobal.alignment` for whole globals, `setAlignment` metadata on some insts) |
| function | `ctx->createFunc(...)` | **incomplete on its own** — recipe in §4.13 |
| function pointer | `ctx->tyPtr(ctx->tyFunc(...))` | `call` takes any callee atom; function-typed *values* are `IrValueKind::Func` (dump prints `@name`) |
| vararg function | `createFunc`, then patch `f->base.type = ctx->tyFunc(ret, params, n, true)` | `createFunc` hardcodes `isVararg=false` in the func type (`:1066`); full reference setup in the text frontend: `irParser.crl:2237-2251` |
| extern declaration (`printf`) | `createFunc` + `f->isExtern=true; f->externLib="libc"; f->externSym="printf"` | fields on `IrFunc` (`irtypes.crl:464-466`) |
| string literal | two representations — see below | |
| SIMD vector | `ctx->tyVector(elem, lanes)` | `width = elem.width×lanes` (`:761`); backend support varies per opcode **[?]** |
| local `alloca T` | `builder.alloca(ty)` → result type **`ptr T`** (`irBuilder.crl:178-182`) | the printer also tolerates aggregate-typed alloca results (comment `irPrinter.crl:535-541`), i.e. a manually created `createInst(Alloca, structTy, …)` |
| debug info | `inst->setDebugLoc(file,line,col)` (`irtypes.crl:221-227`), `inst->addVarDebug(...)`, `MetadataSet` | **`debugLoc` is never printed** (§5.3 P6) |

**String literals — two representations:**

- **Path A (module string constant):** `ctx->createStringConst(data, len)`
  (`irtypes.crl:801`) → `IrStringConst`, type `[len+1 x i8]` with NUL appended,
  auto-label `.Lcs<id>` (`:778`). **No dedup** — call `m->findConstString(data,
  len)` first (§4.3) and reuse the record, then `m->addConstString(sc)`.
- **Path B (global with byte-array init):** `wallvm::irStrings::createStringConstant(ctx, m, data)`
  (`irStrings.crl:18`) → a `const` global **always named `.str`** (`:30`), type
  `ptr [len+1 x i8]`, `constArray` init. Calling it twice yields two globals with
  the same name; `emitGlobals` prints names raw (`x86_64_base.crl:762`) — the
  assembly text then contains two `.str:` labels, with no uniquifier found
  anywhere **[?]** (likely duplicate-label failure).
- `getStringPointer(ctx, sv, block)` (`irStrings.crl:52`) **appends the GEP to
  the block's end** (`bb->addInst` at `:72`) — it ignores `IrBuilder` insert
  points; build the GEP yourself if you need it at the current position.

### 4.13 Function signatures, args, varargs, externs — the manual recipe

`createFunc(name, ret, params, nparams)` (`irtypes.crl:1063-1071`) sets
`base.type = tyFunc(ret, params, nparams, false)`, copies `retType/paramTypes/
nparams` onto the `IrFunc`, and leaves **`args[]` empty, `blocks[]` empty, no
calling-convention field** (cc is a driver-level per-compile argument, §2.1).
There is **no `createArg` helper anywhere in `lib/wallvm`** (grep) — every
in-memory consumer hand-rolls this loop (the text frontend does exactly the
same, `irParser.crl:2242-2251`):

```coral
IrFunc* f = ctx->createFunc("main", retTy, params, nparams);
// vararg? patch the type:
// f->base.type = ctx->tyFunc(retTy, params, nparams, true);   // irParser.crl:2238
for (u32 i = 0; i < nparams; i++) {
    IrValue* a = alloc<IrValue>(1);
    *a = IrValue { IrValueKind::Arg, params[i], ctx->nextValueId(), 0,
                   str::empty(), null, 0, 0 };   // named: slot 4 = irDupStr(name)
    f->addArg(a);                                // irParser.crl:2244-2249
}
f->isExtern = false;   // extern? true + f->externLib / f->externSym
m->addFunc(f);
IrBlock* entry = ctx->createBlock("entry"); f->addBlock(entry);
```

- Arg values are plain heap `IrValue`s — nothing registers them in a name table;
  hold the pointers (or set `name` so dumps print `%name` instead of `%<id>`).
- **Two sources of truth on `IrFunc`**: `base.type` (Func type: ret/params/
  vararg) vs `retType`/`paramTypes`/`args[]`. The text frontend keeps them in
  lockstep; manual construction must too. The dump prints only `args[]`
  (§5.3 P15); which side the ABI classifier reads on your path is **[?]** —
  keep them equal and the question is moot.
- Blocks print/codegen in `f->blocks[]` insertion order — modulo the printer's
  def-first reordering (§5.3 P1).

### 4.14 Constants & aggregates

- **`constInt(ty, val)` (`:933-953`)** — dedup key = (type, raw bits); **no
  masking to `ty->width`**; store normalized values yourself.
- **`constFloat(ty, f64)` (`:955-974`)** — dedup key = **raw bits only, `ty` is
  not compared** (`:960-962`; contrast `constInt` at `:935` which checks
  `type == ty`). Creating `constFloat(f32Ty, 1.0)` *after* `constFloat(f64Ty, 1.0)`
  hands back the f64-typed constant — order-dependent type confusion. Values are
  always f64 bit patterns, even for `f32` (§4.12).
- **`constArray(ty, elems, n)` / `createStructConst(elems, n)` (`:991-1003`)** —
  `IrArrayConst`/`IrStructConst` hold per-element `IrValue*`s, each carrying its
  own type; struct elems in **declaration order**, placement uses precomputed
  offsets (comment `irtypes.crl:188-192`).
- **Aggregates in SSA:** opcodes `ExtractValue`/`InsertValue` exist
  (`irOps.crl:93-94`). Builder has `extractValue(agg, idx)` (`irBuilder.crl:481`)
  but **no `insertValue` method** (grep = 0) — use
  `ctx->createInst(IrOpcode::InsertValue, ty, ops, 3, 0, 0)` + `bb->addInst(...)`.
  `call` (`:514`), `phi` (`:528`), `select` (`:541`) do exist (phi takes explicit
  vals/blocks arrays).
- **Globals:** `createGlobal(name, ty, isConst, isExtern, init, alignment)`
  (`:767-776`) — `alignment` lands in the struct field only (metadata stays
  `null`) → invisible in dumps (§5.3 P8); `init` = one const value or `null`
  (null = zero-fill at emission, indistinguishable from an extern in dumps,
  §5.3 P7).

---

## 5. Construction, parsing & printing

### 5.1 `IrBuilder` (`wallvm::irBuilder`, `base/irBuilder.crl`)

State: `ctx, block, insertBefore`; `static new(ctx)`, `pos(block, before)`
(`:20-34`). All methods insert at the pos; `before = null` appends.

| Group | Methods (all `IrInst*` unless noted) | Line |
|---|---|---|
| Terminators | `retVoid, ret, br, condBr, unreachable, noret` | `:36-77` |
| Int arith | `add sub mul sdiv udiv srem urem andOp orOp xorOp shl ashr lshr neg notOp` | `:82-172` |
| Float arith | `fadd fsub fmul fdiv` | `:112-127` |
| Memory | `alloca(ty), load(ty,ptr), store(val,ptr), gep(ptr,idxs,nidxs)` | `:178-199` |
| Casts | `trunc zext sext fpTrunc fpExt fpToSi fpToUi siToFp uiToFp bitcast` | `:234-279` |
| Compare | `icmp(IrICmpPred,l,r), fcmp(IrFCmpPred,l,r)` | `:285-294` |
| Bit intrinsics | `ctPop ctLz ctTz rotl rotr bswap` | `:304-329` |
| Min/max/abs | `smin smax umin umax abs` | `:335-355` |
| Float intrinsics | `fma(a,b,c) fabs fsqrt` | `:362-376` |
| SIMD | `shuffleVector(v1,v2,mask,n) extractElement insertElement` | `:381-409` |
| Inline asm | `inlineAsm(tmpl,constraints,clobbers,isVolatile,...)` | `:411` |
| Atomics | `atomicLoad atomicStore atomicRmw atomicCmpXchg fence` | `:425-466` |
| EH | `landingPad(ty,personalityFn,numClauses)` | `:472` |
| Aggregates | `extractValue(agg,idx)` | `:481` |
| GC | `gcRoot gcWriteBarrier gcSafepoint` | `:494-509` |
| Calls/phi | `call(callee,args,nargs) phi(ty,vals,blocks,n) select(c,t,f)` | `:514-541` |
| Raw | `allocOps(count) createBinary createUnary2 createUnary3 createInst` | `:550-577` |

### 5.2 `IrParser` (`wallvm::irParser`, `text/irParser.crl`)

```coral
pub struct IrParser { ... errMsg; errLine; ... }               // :35
pub IrParser new(IrContext* ctx)                               // :104
pub void    destroy(IrParser* p)                               // :133
pub str     getError(IrParser* p)                              // :149
pub u32     getErrorLine(IrParser* p)                          // :150
pub IrModule* parseModule(IrParser* p, str text)               // :2569
```
Whole-module string input; resets line/position/error state per call
(`:2570-2584`). Returns `null` on error; diagnostics via `getError*`.
Known rejection: `"unsupported aggregate element type"` (`:2390`).

### 5.3 `IrPrinter` (`wallvm::irPrinter`, `text/irPrinter.crl`) — the IR dump

**API** — `static IrPrinter new()` (`:34`), `destroy()` (`:39`, frees the buffer),
`str output()` (`:44`, view into the internal `String`), `pub void printModule(IrModule*)`
(`:1013`). Per-unit entry points are plain methods (callable cross-module per §1.3):
`printInst` (`:828`), `printBlock` (`:910`), `printStructDecl` (`:923`),
`printGlobal` (`:947`), `printStringDecl` (`:964`), `printFunc` (`:974-1008`),
plus emitters `emitType` (`:184`), `emitValueRef` (`:277`), `emitAtom` (`:323`),
`emitFloat` (`:120`). Nothing is written to disk/stdout — take `output()` and write it.

**Usage notes**

- The buffer is **append-only**: there is no `reset()`; two `printModule` calls
  concatenate. Use one printer per dump (or track `output()` offsets).
  `destroy()` frees the buffer; the `str` from `output()` dangles after it.
- Only `printModule` is `pub` (same unmarked-method visibility quirk as
  everywhere, §1.3).

**Output shape** (what a dump looks like):

```
module "name"
type @Point = struct { x: i32, y: i32 };
global const @g: i32 = 42;
string @.Lcs7: "hi";
func @main(%0: i32, ...) i32 {
b1:
    %2 = add i32 %0, 1
    ret i32 %2
}
```

4-space instruction indent, labels at column 0, one blank line between top-level
decls; ` = ` is printed only for non-void results (`:828-838`); metadata rides as
`!key` / `!key = v` clauses after the instruction/decl (`emitMetaEntry :375-390`;
bare `!key` means value 1, except `alignment`); per-variable debug prints
` !var = "name", ty, line, col[, argIdx]` (`emitVarDebug :402-419`). Block refs
print without `%` (`br b1`), value refs with `%` (`%2`).

**Problems in the output (verified)**

- **P1 — block order is rewritten.** `printBlocksWithDefsFirst` (`:847-908`)
  Kahn-sorts blocks so every def precedes its uses; the printed sequence is
  generally **not** `f->blocks[]` order — i.e. not what a pass left behind. Bad
  for eyeballing block-order effects of the inliner/structure passes. Entry is
  kept first when it has indegree 0; cycles (invalid SSA) fall back to array
  order; cost is an O(n²) adjacency matrix per function.
- **P2 — value ids are context-global and never recycled.** Unnamed results print
  as `%<id>` / `b<id>` where `id = IrContext.nextValueId()` — a monotonic counter
  over *everything* ever created in the context (deleted values leave gaps).
  Two logically identical modules dump with different numbers unless the exact
  same allocation history occurred; diffs are noisy.
- **P3 — unsigned constants print signed.** `emitAtom` ConstInt →
  `emitI64((i64)valData)` (`:339`): a `u64` constant `0xFFFF…FF` dumps as `-1`;
  the literal carries no type suffix, so without surrounding type context the
  sign is a lie.
- **P4 — wide integers are truncated in the model itself.** `IrValue.valData` is
  a single `u64` (`irtypes.crl:76`) — there is no second word; `i128`+ constants
  keep only the low 64 bits (then P3 applies).
- **P5 — float output.** `emitFloat` (`:120-158`) tries `%g` precisions 1..17
  with a reparse check and an added `.0`; the fallback prints **raw hex bits**
  (`emitHexU64`). NaNs print as `nan` / `-nan` — **payload and signaling bit are
  dropped**. f32 constants carry f64 bits (§4.12), so an `f32` literal dumps with
  double precision (e.g. `f32 3.14159265358979`).
- **P6 — `debugLoc` is never printed.** `IrInst.debugLoc` / `setDebugLoc`
  (`irtypes.crl:205`, `:221-227`) has **zero references in `irPrinter.crl`**
  (grep) — source file/line set by the frontend is invisible in dumps; only
  `!var` clauses and generic `metadata` print.
- **P7 — extern globals are indistinguishable from zero-initialized ones.**
  `printGlobal` (`:947-963`) has no `isExtern` branch: `global @x: ty;` is what
  both an extern import and a defined-but-uninitialized global print as — while
  codegen treats them oppositely (skips externs, `x86_64_base.crl:747`, emits
  `.zero` for the latter).
- **P8 — programmatic global alignment is invisible.** `createGlobal(..., alignment=N)`
  sets only the struct field (`irtypes.crl:767-776`); the dump shows alignment
  only when it was also attached as `!alignment` metadata (what the text frontend
  does, `irParser.crl:2493-2501`). Codegen honors the field
  (`x86_64_base.crl:756-757`).
- **P9 — struct naming in dumps can be internally inconsistent.** Types intern by
  shape (§4.10), so two named records (`@A`, `@B`) with identical fields share
  one `IrType`. `printModule` prints **both** `type @A`/`type @B` decls
  (`:1016-1025`, no dedup), while `emitType` resolves `struct @Name` by scanning
  for the **first** record whose `irType` pointer matches (`:247-256`) — every use
  prints `@A`, and `@B`'s decl is dead text. Unregistered struct types
  (in-memory build without `m->addStruct`) print inline `struct { … }` at
  **every** use site.
- **P10 — broken IR prints plausible-looking symbols.** Null operand → `@missing`
  (`:327`), unknown value kind → `%missing` (`:350`), null typed-arg slot →
  `void @missing` (`:444`) — no slot index, no marker that the IR is malformed.
- **P11 — inline-asm value-mode operands print self-references.** A null asm
  output slot prints as the instruction's own result (`emitTypedArgs :423-444`) —
  the dump shows `%7 = inlineasm … (%7)`, which looks like a cyclic def.
- **P12 — no comments, ever.** Even with `debugLoc` set (P6) there are no
  `// file:line` annotations; the dump is pure grammar.
- **P13 — formatting is fixed**: 4-space indent, one blank line between top-level
  decls, struct fields in declaration order, funcs/globals/structs in array
  (insertion) order. No compact mode, no "print blocks in array order" option,
  no stable-renumbering option, no type-alias folding control.
- **P14 — `irTypeStr` (`irtypes.crl:1161-1185`) is not the printer's spelling
  and is lossy**: `Float` width 32 → `"float"` (printer says `f32`), `Struct` →
  `"unknown"`, `Array`/`Func`/`Vector` → bare words with no payload, unusual int
  widths → `iN`. Fine for logs; never use it where the string must identify a
  type.
- **P15 — vararg and parameter list come from different fields.** `printFunc`
  prints `...` from `base.type->isVararg` and parameters from `args[]`
  (`:974-1008`); `paramTypes` is never shown — a `createFunc`-built function
  (never vararg unless patched, §4.13), or one whose `args[]` and `paramTypes`
  diverge, dumps as whatever `args[]` says.
- **P16 — string decls print name + payload only** (`:964-973`) — no type, no
  length, no NUL information (the model type is `[len+1 x i8]`, §4.12).

**Missing from the dump (not modeled → never printable)**

- Calling convention per function / per call (lives only in the driver's `cc`
  argument, §2.1).
- Target triple / data layout / optimization level / pass history (the §2.3
  `g*` flags are process state, not IR).
- Load/store **volatile** flag and **alignment** — no `IrInst` fields exist.
- `gep` inbounds; `exact`/`nsw`/`nuw` for anything besides add/sub/mul (those
  three ride the `IR_AUX_UNSIGNED` aux slot and print as `add.u` —
  `irtypes.crl:232-239`).
- Function attributes (`nounwind`, `readnone`, …); branch weights (only via
  generic `!metadata` if you attach it yourself).
- Analysis/regalloc state: domtrees, alias sets, live intervals / `valData`
  spill bits (§8.4) — all invisible; the only dump is IR text.

### 5.4 `IrStrings` (`wallvm::irStrings`, `text/irStrings.crl`)

`createStringConstant(ctx, m, data) -> IrString` (`:18`),
`getStringPointer(ctx, sv, block) -> IrValue*` (`:52`),
`createStringCompare(...)` (`:76`), plus generic string utils
`stringCopy/stringConcat/stringContains/stringSubstring/stringToInt/intToString`
(`:180-264`).

---

## 6. Metadata & analyses support

### 6.1 `wallvm::irMetadata` (`base/irMetadata.crl`)

- Sets: `newMetadataSet()`, `addInt/addString/addIRValue/addFloat/addBool/addType`,
  `find`, `metadataSetFree` (`:69-233`); attach: `attachFuncMetadata,
  attachInstMetadata, attachGlobalMetadata, attachStringMetadata` (`:324-360`);
  getters `getInstMetadata/getFuncMetadata` (`:424-430`).
- Inst properties: `setDebugLocation setAlignment setNoAlias setNoCapture
  setReadOnly setInlineHint setBranchWeights setRange` (`:372-417`).
- Func attributes (setters `:439-543`): `NoReturn ReadOnly ReadNone NoUnwind
  NoInline AlwaysInline InlineHint OptNone Hot Cold Naked Entry EntryAddr
  NoMangle UwTable Section Visibility Align Personality`.
  Predicates: `hasFuncAttr funcAttrInt funcAttrStr` (`:545-577`) and shorthands
  `funcIsNaked/Entry/NoReturn/ReadOnly/ReadNone/NoInline/AlwaysInline/OptNone/
  Hot/Cold/NoMangle` (`:579-589`).
- Process-global store: `metadataInit/metadataShutdown` (`:291,306`) +
  `DebugLocation/DebugFuncInfo/DebugVarInfo/MetadataStore` (`:248-273`).
  **`metadataInit` has zero callers in `lib/` and `test/` (grep) — requiredness
  is [?]** (§13-G11).
- Untyped escape hatches: `IrFunc.metadata`, `IrInst.metadata`,
  `IrGlobal.metadata`, `IrStringConst.metadata` are plain `rawptr`s.

### 6.2 `wallvm::domtree` (`base/domtree.crl`)

`IrDomTree` (`:5`), `irDomtreeNew(IrFunc*)` (`:45`), `irDomtreeFree` (`:234`),
`irDomtreeIdom` (`:242`), `irDomtreeDominates(dt,a,b)` (`:253`),
`irDomtreeLevel` (`:270`). Built from the CFG; any CFG mutation invalidates it
(consumers rebuild per use).

### 6.3 `FunctionAnalysisCache` (`irtypes.crl:657`)

`aliasAnalysis, memorySSA, func, generation, destroyAliasAnalysis,
destroyMemorySSA`. Ownership protocol is documented first-person at
`:650-670`: publishing pass owns the heap object, `clearAnalysisCaches` runs
registered destroyers. Comment at `:655-656`: *memorySSA "is optional and
currently never published, hence always null in practice."*

---

## 7. Calling conventions & ABI rules (`wallvm::rules::asm_rules`)

### 7.1 `CallingConvention` (`asm_rules.crl:46-80`) — 30 variants

`SystemV, Win64, Aapcs, Aapcs64, Cdecl, Stdcall, Fastcall, Riscv64,
SyscallX86_64, SyscallX86, SyscallArm64, SyscallArm, SyscallRiscv64,
SyscallMacOS, SyscallWin64, Ppc64, Ppc, Mips64, Mips, SparcV9, Aapcs64MacOs,
Aapcs64Ios, WinX86_32, SyscallPpc64, SyscallPpc, SyscallMips64, SyscallMips,
SyscallSparc64, Wasm32, Wasm64`. (No explicit values — ordinal enum.)

### 7.2 `ABIRules` (`:93-123`)

`cc, name, argRegs/numArgRegs, floatArgRegs/numFloatArgRegs, returnReg,
floatReturnReg, stackArgReg, calleeSaveRegs/num, callerSaveRegs/num, frameReg,
stackAlignment, hasRedZone, calleeCleanupStack, shadowSpaceBytes, syscallInst,
syscallNumberReg, syscallArgRegs/num, syscallNumberShift`.

- `abiForCc(cc)` (`:841-877`) covers **all 30** variants (falls through to
  `sysvAbi()`); `formatForCc(cc)` (`:821-839`): 64-bit x86 ccs → AT&T,
  Cdecl/Stdcall/Fastcall/SyscallX86/WinX86_32 → Intel (x86LinuxRules format,
  `:1087`), **everything else defaults to x86_64/AT&T** (`:837`).
- Named constructors: `sysvAbi win64Abi aapcs64Abi aapcs64MacOsAbi aapcs64IosAbi
  aapcsAbi cdeclAbi stdcallAbi fastcallAbi winX86_32Abi riscv64Abi ppc64Abi
  ppcAbi mips64Abi mipsAbi sparcV9Abi x86_64SyscallAbi x86_64MacOSSyscallAbi
  x86SyscallAbi arm64SyscallAbi armSyscallAbi riscv64SyscallAbi ppc64SyscallAbi
  ppcSyscallAbi mips64SyscallAbi mipsSyscallAbi sparc64SyscallAbi wasm32Abi
  wasm64Abi` (`:223-817`).
  Quirk: `SyscallWin64` maps to plain `win64Abi()` (`:859`), not a dedicated
  syscall table.
- SysV facts worth knowing (`:223-250`): 6 int arg regs (rdi..r9), 8 xmm, return
  rax/xmm0, 16-byte align, red zone on, callee-saves rbx/rbp/r12-r15.
- `noretTemplate(ABIRules*)` (`:881`) → syscall exit snippet (used by
  `noret/noret.crl:99`).
- Rule tables (`AsmRule/AsmRuleTable/findRule`, `AsmRuleOperand/OperandKind`,
  `RegisterInfo`; `:13-42,82,198`) and `x86_64LinuxRules/arm64LinuxRules/
  x86LinuxRules/armLinuxRules/riscv64LinuxRules/ppc*/mips*/sparc64LinuxRules`
  (`:966-1353`): public, but **no caller outside `asm_rules.crl`** (grep
  verified) — the actual selectors are hand-written (§13-G4).

---

## 8. Register allocation (`wallvm::regalloc`)

### 8.1 Config — `regalloc/lsra.crl`

```coral
pub struct RegAllocConfig {          // :21
    bool useCalleeSave;              // false → caller-save only (no prologue/epilogue)
    bool backendHandlesSpills;       // true → backend decodes SPILL_BIT, no IR spill rewrite
    str* reservedIntRegs;  u32 numReservedIntRegs;
    str* reservedFloatRegs; u32 numReservedFloatRegs;
}
pub RegAllocConfig defaultRegAllocConfig()   // :31 — useCalleeSave=true, backendHandlesSpills=false, no reserved
```

`wallvm.crl:regallocConfigFor(cc)` (`:493-531`) is the reference configuration:
starts `useCalleeSave=false`, `backendHandlesSpills=targetConsumesRegAlloc(cc)`;
for SysV/Win64/syscall-64 ccs enables callee-saves and reserved sets
`X86_64_RESERVED_INT` (7 regs) / `X86_64_RESERVED_FLOAT` (3); for
Cdecl/Stdcall/SyscallX86 uses `X86_RESERVED_INT/FLOAT` (2/2).
`targetConsumesRegAlloc` (`:475-491`): true for all x86(-64) ccs listed there,
false otherwise (wasm, and anything falling to bare).

Reserved tables: `X86_64_RESERVED_INT/FLOAT`, `X86_64_INT_REGS(+_WIN64)`,
`X86_64_FLOAT_REGS` (`target/x86_64/x86_64_base.crl:14-42`),
`X86_RESERVED_INT/FLOAT`, `X86_INT_REGS`, `X86_INT_CALLEE_SAVE`, ...
(`target/x86/x86_base.crl:7-27`).

### 8.2 Entries

```coral
pub bool irLinearScanRegAlloc(IrFunc* func, rawptr userdata, ABIRules* abi, RegAllocConfig* cfg)  // lsra.crl:2043
pub bool irGraphRegAlloc(IrFunc* func, rawptr userdata, ABIRules* abi, RegAllocConfig* cfg)       // graph.crl:322
pub struct LinearScanRegAlloc  // lsra.crl:98 — object form (ctx, numRegs, reg name tables, abi, ...)
pub struct LiveInterval { u32 vreg, start, end, physReg; i32 spillSlot; bool isFloat, spansCall; u32 uses, defs; f64 spillWeight; }  // :55
```
Driver choice (`wallvm.crl:581-592`): graph coloring only when
`optLevel>=3 && func->isLeaf() && nblocks<=8`, else lsra; skipped entirely for
Wasm32/Wasm64. Both must run **after** optimize+structure-lane, before codegen.

### 8.3 Phi contract

With `gKeepPhisEnabled` (default), lsra materializes phis as register edge
copies — only for shapes `irPhisAreFriendly` accepts; otherwise the structure
lane runs `irLowerPhis` (alloca demotion) and lsra assumes the demoted form
(`wallvm.crl:429-436`). lsra's output is all-or-nothing on this choice.

### 8.4 valData encoding (backend contract)

After lsra, each `IrValue.valData` packs: `SPILL_BIT 0x80000000` (spill),
`FLOAT_BIT 0x40000000` (xmm class), otherwise physreg index; `EDGE_NO_REG
0xFFFF_FFFF_FFFF_FFFF` marks a phi edge copy with an embedded operand
(`lsra.crl:11-15`). Backends that "consume regalloc" decode this directly
(`backendHandlesSpills`); others get spills rewritten into the IR. The constants
are private to `lsra.crl` — a third-party backend must hardcode them (§13).

---

## 9. Codegen targets (`wallvm::target`)

### 9.1 Entry signatures

| Function | Signature | File |
|---|---|---|
| `irLinux_X86_64` / `irLinux_X86_64Asm` | `(IrModule*, rawptr userdata /*IrContext**/, bool useAtt) -> bool / str` | `target/x86_64/linux/linux.crl:5,55` |
| `irWinX86_64` / `irWinX86_64Asm` | same | `target/x86_64/windows/windows.crl:10,63` |
| `irCodegenX86` / `irCodegenX86Asm` | `(IrModule*, rawptr) -> bool / str` (no syntax flag) | `target/x86/linux/linux.crl:34,47` |
| `irCodegenWasm32` / `irCodegenWasm32Asm` | `(IrModule*, rawptr) -> bool / str` | `target/wasm/wasm.crl:2689,2699` |
| `irCodegenX86_64Bare` / `irCodegenX86_64BareAsm` | `(IrModule*, rawptr, bool useAtt) -> bool / str` | `target/x86_64/generic.crl:10,59` |
| ABI lowering | `irABILower(IrFunc*, rawptr) -> bool` — SysV: `target/x86_64/linux/abi_lower.crl:913`; Win64: `target/x86_64/windows/abi_lower.crl:782`; x86-32: `target/x86/linux/abi_lower.crl:655` | three same-named exports (see `wallvm.crl:58-60`) |

Aliases: `wallvm::target::{x86_64_V, x86_64_win, x86_V, wasm, x86_64_generic,
x86_64_base, x86_base}` (`target/lib.crl:6-12`).

### 9.2 What the targets consume / produce

- Input: fully optimized, phi-resolved (or lsra-phi-materialized), regalloc'd
  IR; `valData` per §8.4 when `backendHandlesSpills`.
- Output shape: GAS-style assembly text with `.section .text` prologue
  (`x86_64_base.crl:690-693`), const strings emitted as mergeable, read-only,
  string-sized records (`emitConstStrings`, `x86_64_base.crl` ~696 — SHF_MERGE +
  SHF_STRINGS per its comment), then globals. CPU features are hardwired in the driver:
  SSE2…AVX2/FMA/BMI/POPCNT/LZCNT always on for Linux x86-64
  (`linux.crl:11-24`); `CpuFeatures`/`defaultCpuFeatures` are public if you call
  codegen yourself (`x86_64_base.crl:56,74`).
- **Where output goes**: the `*Asm` variants return
  `codegen.emitter.getOutput()` (e.g. `linux.crl:102`). The bool variants
  (`irLinux_X86_64` etc.) build the same string and **never read it** — no file,
  no stdout, no sink (verified: `linux.crl:5-52`; the only `getOutput()`
  call sites in `target/` are the five `*Asm` returns). See §13-G1.

### 9.3 Dispatch facts

- `ccUsesAtt(cc)` (`wallvm.crl:534-537`) feeds `useAtt` from `formatForCc`.
- `irCompileAsm` never emits for: Aapcs/Aapcs64/Riscv64/Ppc*/Mips*/SparcV9/
  Wasm64/… → `str::empty()`; `irCodegen` sends those same CCs to
  `irCodegenX86_64Bare` (`wallvm.crl:679`). See §13-G2.
- ABI lowering runs as the first real pass of L1–L3 (after validate) —
  it lowers arguments/returns/struct passing per target before mem2reg.

---

## 10. Passes (`wallvm::passes`)

### 10.1 Interface

- Signature convention: `bool pass(IrFunc*, rawptr /*IrContext*/)`. Exceptions:
  `irPassSafety(IrFunc*, IrContext*)` (`passes/safety.crl:472`),
  `irPassBorrowCheckPrint` returns a violation count (`borrowcheck.crl:1471`),
  analyses return richer objects internally (`AliasAnalysis`, `MemorySSA`,
  `IrLoop**`).
- `true` = mutated; driver bumps `analysisGeneration` (§2.3).
- Analyses: `irAliasAnalysis` (`alias_analysis.crl:692`), `irMemorySSA`
  (`memory_ssa.crl:359`), `irLoopDetectNatural/irDetectLoops`
  (`loop_detect.crl:111,15`), `irPassValidate` + `IrValidator`
  (`validate.crl:12,310`), borrowcheck family
  (`irPassBorrowCheck`, `irPassAliasCheck`, `irPassBorrowCheckCollect`,
  `irPassBorrowCheckPrint`, `borrowKindName`; `borrowcheck.crl:1394-1471`).
- `irPassSafety` constants: `TRAP_BOUNDS/NULL/DIVZERO/OVERFLOW/BADVARIANT`
  (`safety.crl:53-57`); instrumentation emits calls to `_trap` and runs at O0
  only.

Entry inventory (symbol → module → wired level; levels per §10.2, "—" = never
wired):

| Module | Public entry | Level |
|---|---|---|
| `validate` | `irPassValidate`, `IrValidator` | all |
| `algebraic` | `irPassSimplify` | L0-L3 |
| `constfold` | `irPassConstfold` | L0-L3 |
| `sccp` | `irPassSccp`, `gSccpVerbose` | L0-L3 |
| `dce` | `irPassDce`, `irPassAdce` | dce L0-L3, adce L2+ |
| `mem2reg` | `irPassMem2Reg` | L1-L3 |
| `comm_canon` | `irPassCommCanonicalize` | L1-L3 |
| `involution` | `irPassInvolution` | L1-L3 |
| `range` | `irPassRange`, `irPassRangeBranchElim` | L1-L3 |
| `branchprop` | `irPassBranchProp` | L1-L3 |
| `branch_inversion` | `irPassBranchInversionFlat` | L1, L3 |
| `cse` | `irPassCse` | L1-L3 |
| `cast_elim` | `irPassCastElimination` | L1-L3 |
| `dse` | `irPassDse` | L1-L3 |
| `jump_thread` | `irPassJumpThread` | L1-L3 + unroll cleanup |
| `idiom` | `irPassIdiom` | L1-L3 |
| `peephole` | `irPassPeephole` | L1-L3 |
| `sroa` | `irPassSROA` | L2-L3 |
| `alias_analysis` | `irAliasAnalysis` (+ `AliasAnalysis` types) | L2-L3 |
| `memory_ssa` | `irMemorySSA` (+ `MemorySSA`) | L2-L3 |
| `licm` | `irPassLicm`, `createPreheader`, `isLoopInvariant`, `hoistToPreheader` | L2-L3 |
| `gvn` | `irPassGvn` | L2-L3 |
| `loopcse` | `irPassLoopCse` | L2-L3 |
| `inline` | `irPassInline` | L2-L3 |
| `stack_layout` | `irPassStackLayout` | L3 |
| `lex_canon` | `irPassLexCanonicalize` | L3 |
| `branch_factoring` | `irPassBranchFactoring` | L3 |
| `divmod` | `irPassDivMod` | L3 |
| `loop_interchange` | `irPassLoopInterchange` | L3 |
| `loop_distribute` | `irPassLoopDistribute` | L3 |
| `tail_dup` | `irPassTailDup` | L3 |
| `tco` | `irPassAccumulate` | L3 |
| `simd_vec` | `irPassAutoVectorize` | L3 |
| `idempotent` | `irPassIdempotent` | L3 |
| `macro_fusion` | `irPassMacroFusion` | L3 |
| `machine_opt` | `irMachineOpt` | L3 |
| `select_to_branch` | `irPassSelectToBranch` | L3 |
| `unroll` | `irPassUnroll`, `UnrollPass` | structure lane if `gUnrollEnabled` |
| `lower_phis` | `irLowerPhis`, `irPhisAreFriendly` | structure lane, conditional |
| `safety` | `irPassSafety`, `TRAP_*` | pre-pipeline, O0 only |
| `borrowcheck` | `irPassBorrowCheck` + 4 more (above) | structure lane (diagnostic) |
| `loop_detect` | `IrLoop`, `irDetectLoops`, `irLoopDetectNatural` | analysis for licm/loopcse/unroll/simd |
| `ipa_cp` | `irPassIPAConstProp` | **— unwired** (§13-G8) |

### 10.2 Verbatim pipeline orders (`wallvm.crl`)

- **L0** (`:209-219`): validate, simplify, constfold, sccp, dce, validate.
- **L1** (`:236-260`): validate, abi_lower(cc), mem2reg, comm_canon, simplify,
  constfold, involution, sccp, range, range_br_elim, branchprop,
  branch_inv_flat, cse, cast_elim, dse, jump_thread, idiom, peephole, dce,
  validate.
- **L2** (`:262-292`): validate, abi_lower, mem2reg, sroa, comm_canon, simplify,
  constfold, involution, range, range_br_elim, branchprop, sccp, adce, cse,
  alias, mssa, licm, gvn, loopcse, jump_thread, inl, cast_elim, idiom,
  peephole, dse, validate.
- **L3** (`:294-338`): validate, abi_lower, mem2reg, sroa, stack_layout,
  comm_canon, lex_canon, simplify, constfold, involution, range, range_br_elim,
  branchprop, branch_inv_flat, branch_fact, divmod, sccp, adce, cse, alias,
  mssa, licm, gvn, loopcse, loop_interchange, loop_distribute, jump_thread,
  tail_dup, inl, tco, simd_vec, idiom, idempotent, cast_elim, macro_fusion,
  peephole, machine_opt, sel2br, dse, validate.
- **Structure lane** (`:387-445`): borrowcheck → [unroll → sccp, constfold,
  simplify, jump_thread, adce (iterate ≤10)] → [lowrphis if needed] → validate.

---

## 11. Assembly, objects, linker

### 11.1 x86 assembler (`wallvm::assembly::x86`)

- `assembleText(str text, AsmObject* obj, AsmParseError* err) -> bool`
  (`x86_64.crl:2414`); lower level: `encodeLine` (`:1908`),
  `matchAndEncode` (`:1009`).
- `AsmParseError { str msg; u32 lineNo; }` (`assembly/common.crl:60`).
- `AsmObject` (`obj.crl:56`): fixed sections `text, data, hot, cold`, and
  **fixed caps**: `AsmSymbol syms[ASM_MAX_SYMS=512]`,
  `AsmReloc relocs[ASM_MAX_RELOCS=1024]`, `ASM_MAX_ORDER=513`
  (`obj.crl:12-14`). Also `AsmSection {name, AsmBytes data, u64 align}` (`:49`),
  `AsmRelocKind` (`:17`), `asmObjectNew/asmObjectDeinit/asmFindSym/
  asmFindOrAddSym/asmAddReloc` (`:68-116`).
- Emission: `emitElf` (`:202`), `emitCoff` (`:449`), `emitRaw(base)` (`:709`)
  — into `AsmBytes {u8* data; u32 len; u32 cap;}` (`x86/common.crl:145`).
  **No PE/COFF-image emit here** — PE comes from the linker (§11.3).
- Lexer/operands: `AsmLexer`, `parseAttLine` (`assembly/common.crl:90,696`),
  `parseConstraints` (`:830`, for inline asm), `X86Reg/lookupReg/encodeMem/
  X86Rex/X86Vex/X86Evex` (`x86/common.crl`), SSE/AVX table hooks
  `trySseTable` (`x86_sse.crl:557`), `tryVecTable` (`x86_avx.crl:812`).

### 11.2 Wasm assembler (`wallvm::assembly::wasm`)

`wasmAssemble(wat, String* out, String* error, u32* errorLine) -> bool`
(`encode.crl:877`); `wasmBindings(wat, moduleName, js, dts, error, errorLine)`
(`bindings.crl:366`); WAT model types `WatNode/WasmFunc/WasmExport/...`,
`WasmAssembler` (`core.crl:191`); opcode lookups `wasmI32Op/wasmI64Op/...`
(`ops.crl`). Limits: no folded instructions (`encode.crl:370`), reference-type
and const-expr restrictions (`:208,219,648`).

### 11.3 Linker (`wallvm::linker::x86`)

- `enum Arch { X86_64, I386 }` (`link.crl:25`); `Config {arch, entry, imageBase,
  emitSymtab, outFmt, subsystem, isDll, entryAddr, entryAddrSet}` (`:31`);
  `configFor(arch)` defaults: `entry="_start"`, `FMT_ELF_EXE`, symtab on,
  subsystem 3 (`:50-63`).
- `Linker` (`:73`): `static new(cfg)`, `addExport`, `setExportAll`,
  `setModuleName`, `setEntryAddress`, `addObject(name,bytes)`,
  `addObjectOwned`, `addBuffer(Buffer{name,data})`, `addObjectFile(path,&err)`,
  `produce() -> Result<Vec<u8>,String>` (`:147`), `write(path,&err)` (`:164`).
  One-shot `linkBuffers(cfg, Vec<Buffer>)` (`:980`).
- Formats (`elf.crl:22-26`): `FMT_ELF_EXE=0, FMT_ELF_DYN=1, FMT_PE_EXE=2,
  FMT_PE_DLL=3, FMT_RAW=4`. Relocation sets for x86-64 (`R_X86_64_64/PC32/PLT32/
  COPY/GLOB_DAT/JUMP_SLOT/RELATIVE/GOTPCREL/32/32S/PC64/GOTPCRELX/REX_GOTPCRELX`,
  `elf.crl:97-120`) and i386 (`:111-120`); COFF/PE relocs (`coff.crl:42-56`).
- Components: object parsing `parseObject` (`object.crl:120`) / `parseObjectCoff`
  (`coff.crl:210`), archives `parseArchive/isArchive` (`archive.crl:34,79`),
  shared libs `parseShared/sharedFind` (`shared.crl:86,96`), imports
  (`imports.crl`), layout (`layout.crl:28-38` SEC_* sections),
  `resolveSyms` (`resolve.crl:106`), `applyRels` (`reloc.crl:113`),
  `emitImage/emitPeImage/finalizeElfDyn` (`emit.crl:372,681,204`).
- Explicitly unsupported: TLS sections (`layout.crl:379`), compressed debug
  sections (`layout.crl:385`), extended section counts (`object.crl:158`,
  `shared.crl:133`).

---

## 12. Support modules

- **`wallvm::ffi`** (`ffi/extern.crl`): `ExternLib` (`:14`), `FfiCtx` (`:22`),
  `irFuncIsExtern(IrFunc*)` (`:111`), `externCallingConvention(f, hostCc)`
  (`:117`), `emitLinkerDirectives(ffi, buf, cap, cc) -> u32` (`:141`).
  Import-path caveat §1.2.
- **`wallvm::gc`** (`gc/gc.crl`) — runtime support for generated programs:
  `GcConfig/defaultGcConfig` (`:8,18`), `GcHeader/GcRoot/GcState` (`:33-61`),
  `gcInit/gcShutdown`, `gcAlloc/gcAllocWithFinalizer`, `gcRootAdd/Remove`,
  `gcWriteBarrier`, `gcSafepoint`, `gcCollect`, `gcBytesAllocated/gcHeapSize/
  gcGeneration` (`:78-325`).
- **`wallvm::noret`**: `KNOWN_ARCHS[14]`, `hasNoretSupport(arch)`,
  `isNoret(IrInst*)`, `emitNoret(arch, exitCode)` (`noret.crl:7-96`), with
  per-arch structs `NoretArm/NoretArm64/NoretBare/NoretX86_64`. Note: arm/arm64
  exist **here** but have no codegen target (§13).

---

## 13. What's missing / gotchas (all verified)

**Entry & output**

- **G1 — `irCompile`/`irCodegen` produce no observable artifact.** All five
  bool codegen variants assemble into an in-memory `String` and discard it:
  `irLinux_X86_64` ends at `linux.crl:52` with no `getOutput()`/write, while its
  twin returns it at `:102`. The only `getOutput()` call sites under `target/`
  are the `*Asm` returns. The comment "instead of emitting it to a sink"
  (`wallvm.crl:602-604`) describes a sink that does not exist. **Use
  `irCompileAsm`/`*Asm` only.**
- **G2 — unsupported calling conventions fail silently, sometimes wrong-target.**
  `irCompileAsm` → `str::empty()` for every cc not in its switch (Aapcs64,
  Riscv64, Ppc*, Mips*, SparcV9, Wasm64, SyscallArm* …; `wallvm.crl:649-661`).
  `irCodegen`'s `else` branch compiles those same CCs **as x86-64 bare**
  (`wallvm.crl:679`) and still returns success. Wasm64 has `wasm64Abi()` but no
  codegen function at all.
- **G5 — no single-call IR→object/exe entry.** The driver stops at assembly
  text; consumers must hand-chain `irCompileAsm → assembleText → emitElf/
  emitCoff → Linker` (exactly what the three test tools do). No wrapper exists.
- **G6 — `irCodegenX86_64BareAsm` is unreachable** through `irCompileAsm`'s
  switch (bare only via the bool `irCodegen` path).
- **G15 — configuration is process-global** (`g*` flags in `wallvm.crl:80-95`,
  per-pass verbose flags); no options object, no thread safety, no per-compile
  isolation.

**Targets & rules**

- **G3 — ABI tables exist for ~14 architectures; backends exist for 3**
  (x86-64, x86-32, wasm32). `abiForCc` covers all 30 CCs
  (`asm_rules.crl:841-877`) but `target/` contains only x86_64/x86/wasm.
  `arm64LinuxRules/riscv64LinuxRules/ppc*/mips*/sparc64LinuxRules` and their ABI
  constructors have **zero callers outside `asm_rules.crl`** (grep-verified;
  `noret.crl` only uses the ABI constructors for exit snippets).
- **G4 — the rules-driven selector is not wired.** `AsmRule/AsmRuleTable/
  findRule` are public but nothing consumes them; instruction selection is
  hand-written across `target/x86_64/x86_64_base.crl` (7.4k lines). You cannot
  retarget wallvm by supplying rule tables.
- **G9 — no exception lowering on x86-64.** `IrInst` can build `landingPad`
  (`irBuilder.crl:472`) but `IrOpcode::LandingPad` has **0 matches** in
  `target/x86_64/x86_64_base.crl` (1 match in wasm only). No DWARF/eh_frame
  emission path found either **[?]**.
- **G-cc-syntax** — `formatForCc` returns **Intel** for the Cdecl/Stdcall/
  Fastcall/SyscallX86/WinX86_32 family (x86LinuxRules format, `asm_rules.crl:1087`)
  and AT&T for x86-64 (`:1001`), defaulting AT&T (`:837`); yet
  `irCodegenX86(modd, userdata)` takes **no** syntax parameter
  (`x86/linux/linux.crl:34`) — for 32-bit the flag is ignored by the entry.

**Assembly & linking**

- **G7 — assembler hard caps**: 512 symbols, 1024 relocations per object
  (`obj.crl:12-14`); larger translation units cannot be represented.
- **No PE object emission from the assembler** — `emitElf/emitCoff/emitRaw` only;
  PE images are produced solely by the linker (`emitPeImage`, `emit.crl:681`).
- Linker rejects TLS and compressed debug sections and extended section counts
  (§11.3 refs). No Mach-O anything.

**Passes**

- **G8 — `irPassIPAConstProp` is public but unwired**: `// TODO, implement
  module-level entry point` (`passes/ipa_cp.crl:289`); not in any pipeline.
- `memorySSA` is documented as never published to the analysis cache
  (`irtypes.crl:655-656`) — cached memory-SSA consumers get `null` by design.
- Safety instrumentation requires the host to link a `_trap` symbol at O0
  ("driver TODO", `passes/safety.crl:17`), and is skipped for wasm because
  "wasm has no error.crl to link" (`wallvm.crl:351`).

**Printer & dump output** (full audit §5.3)

- **G-print1 — dumps hide state the model has**: `debugLoc` (never printed),
  `IrGlobal.isExtern`, programmatic `alignment`, `IrFunc.paramTypes` — you
  cannot fully reconstruct codegen intent from a dump.
- **G-print2 — dumps lie about order and numbers**: blocks Kahn-reordered (not
  `f->blocks[]`/pass order); context-global monotonic value ids (churn across
  runs, never recycled).
- **G-print3 — dumps lie about values**: unsigned constants print signed;
  `i128+` constants truncated to 64 bits in the model; NaN payloads dropped;
  f32 literals show f64 precision.
- **G-print4 — no dump options**: one whole-module entry, fixed formatting,
  append-only buffer (no `reset()`), no file writer, no analysis/regalloc dumps,
  no comments/`debugLoc` annotations.
- **G-print5 — extern vs zero-init globals print identically** (codegen treats
  them oppositely); struct dumps can name two decls while uses resolve to one.

**Types & in-memory construction** (details §4.10–4.14)

- **G-type1 — `createFunc` produces an incomplete function**: no argument values
  (hand-roll `IrValueKind::Arg` + `addArg`; no `createArg` helper exists),
  `isVararg` always false (patch `base.type` yourself), no calling-convention
  field, `args[]`/`paramTypes` dual source of truth.
- **G-type2 — layout is target-blind**: `tyPtr`/`Func` size and align fixed at 8;
  the wasm32 backend uses 4 (`wasm.crl:296,303`) → IR-computed struct layouts are
  wrong on wasm32; i386 ptr handling **[?]**; no DataLayout object to ask.
- **G-type3 — `irTypeAlignOf(Struct)` is hardcoded 8** while `createStructType`
  sizes structs to natural max-field alignment → reported align can exceed size
  (`{i8}` = size 1, align 8); the two layout paths disagree.
- **G-type4 — constants**: `constInt` doesn't mask to width; `constFloat` dedups
  ignoring `ty` (f32/f64 type confusion, order-dependent); single `u64 valData`
  truncates wide ints; f32 constants store f64 bits by convention.
- **G-type5 — no type features**: unions, bitfields, packed/aligned attributes,
  address spaces, opaque/typedef distinctions (same-shape types intern to one
  pointer), enums, function attributes, load/store alignment & volatile,
  `gep` inbounds, count-0 arrays size as 1 element.
- **G-type6 — builder/string gaps for aggregates**: `insertValue` missing from
  `IrBuilder` (opcode only, use `createInst`); `createStringConstant` always
  names globals `.str` (duplicate labels if used twice, `irStrings.crl:30`);
  `getStringPointer` ignores the builder insert point (`:72`).

**Lifetime & misc**

- **G10 — no ownership story for IR.** No `irModuleDestroy`/`irFuncDestroy`/
  `irBlockDestroy` exist (grep); `irCtxDestroy` frees only the context's pointer
  arrays (`irtypes.crl:1089-1099`), not interned types/constants or any IR
  object. Everything is `#[[no_drop_all]]`. `irCompileAsm`'s buffer is
  never freed by design (`wallvm.crl:602-604`). Plan for process-lifetime
  memory or write your own teardown walking the IR.
- **G11 — `metadataInit()`/`metadataShutdown()` have zero callers** anywhere in
  `lib/` or `test/` (grep). Whether the debug-metadata store works without an
  explicit init is **[?]**.
- **G13 — build-system caveats**: manifests say `include/extends/platform_root`
  resolution is not implemented yet (`manifest.base.crlb:6-7`); wallvm resolves
  `std` through std's own platform manifests.
- **G14 — `wallvm::ffi` import path is odd** (`pub mod _extern = use _extern`
  with file `extern.crl`; "extern is a keyword", `ffi/lib.crl:2`) — exact
  consumer path **[?]**.
- **Runtime contract for the host**: generated code expects `_start`
  (linker default entry, `link.crl:54`), `_trap` (safety, O0), `sqrt`
  (`pub extern f64 sqrt` in `irtypes.crl:1186`), per-arch exit snippets from
  `noret`, and whatever externs you declared with `isExtern`/`externSym`.
- **`IrType` field/method name collision** (`kind`, `width` exist as both field
  and method, `irtypes.crl:41,49-50`) — semantics of `t.kind` vs `t.kind()` are
  **[?]**.
- Known *code-quality* gaps (miscompiles, ABI edges, machine-level TODOs) are
  tracked in `lib/wallvm/docs/pipeline-gaps.md` and `next-todos.md`; they are
  outside this API map's scope but were not re-verified here.

---

## Appendix A — quick symbol index (driver-level)

```
wallvm::wallvm          irCompile irCompileAsm irCodegen irOptimize irStructureLane
                        CompileResult compileSuccess compileError
                        PassPipeline pipelineLevel0..3
                        gUnrollEnabled gSafetyChecks gKeepPhisEnabled gPipelineVerbose gPrintAfterPass
                        WALLVM_VERSION_{MAJOR,MINOR,PATCH}
wallvm::irtypes         IrContext IrModule IrFunc IrBlock IrValue IrType IrInst IrGlobal
                        IrStringConst IrArrayConst IrStructConst IrStructType IrDebugLoc IrVarDebugInfo
                        IrTypeKind IrValueKind FunctionAnalysisCache
                        irCtxCreate irCtxDestroy irTypeEqual irTypeStr irTypeAlignOf irTypeSizeOf
                        irGlobalDestroy irStringConstDestroy irArrayConstDestroy irStructTypeDestroy
wallvm::irOps           IrOpcode IrICmpPred IrFCmpPred IrAtomicRmwOp IrAtomicOrdering IR_AUX_UNSIGNED
                        irOpcodeIs{Terminator,Vector,Atomic,Gc,Binary,Cast,Memory,Commutative}
                        irOpcodeStr irICmpStr irFCmpStr irAtomicRmwOpStr irAtomicOrderingStr
wallvm::irBuilder       IrBuilder (+ all build methods, §5.1)
wallvm::irMetadata      MetadataSet/Value/Entry MetadataStore + add*/attach*/set*/funcIs* (§6.1)
wallvm::irParser        IrParser new destroy parseModule getError getErrorLine
wallvm::irPrinter       IrPrinter new destroy output printModule (+ methods)
wallvm::irStrings       IrString createStringConstant getStringPointer createStringCompare (+ utils)
wallvm::domtree         IrDomTree irDomtreeNew irDomtreeFree irDomtreeIdom irDomtreeDominates irDomtreeLevel
wallvm::rules::asm_rules  CallingConvention ABIRules AsmFormat abiForCc formatForCc noretTemplate (+ §7)
wallvm::regalloc::lsra  RegAllocConfig defaultRegAllocConfig LiveInterval LinearScanRegAlloc
                        irLinearScanRegAlloc gLsraVerbose
wallvm::regalloc::graph irGraphRegAlloc InterferenceGraph GraphRegAlloc
wallvm::target::*       codegen entries + reserved-reg tables (§9.1)
wallvm::passes::*       irPass* inventory (§10.1)
wallvm::assembly::*     assembleText AsmObject emitElf emitCoff emitRaw wasmAssemble wasmBindings (§11)
wallvm::linker::x86::*  Config Arch configFor Linker linkBuffers + formats (§11.3)
wallvm::ffi / gc / noret  §12
```
