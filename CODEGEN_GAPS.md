# Codegen Gaps and Unsupported Constructs

This document tracks constructs that are accepted by the parser/semantics but not properly handled by the backends, leading to GCC failures or silent miscompilation.

## TokenKind::Number (Fixed)

**Issue**: Parser used `TokenKind::Number` which doesn't exist in the TokenKind enum.

**Error**: `error: 'crl__loc__coral_common__token__TokenKind_Number' undeclared`

**Root Cause**: When parsing member alignment (`align N`), the parser tried to match `TokenKind::Number` which is not a valid token kind. The correct token kinds for numeric literals are:
- `TokenKind::Dec` - decimal numbers
- `TokenKind::Hex` - hexadecimal numbers  
- `TokenKind::Oct` - octal numbers
- `TokenKind::Bin` - binary numbers
- `TokenKind::Float` - floating point numbers

**Fix**: Use the appropriate numeric token kind or accept any numeric token kind.

**Status**: Fixed in `compiler/coral-parser/decl.crl`

## Struct Member Alignment (align N)

**Issue**: Added `align` field to Field struct but C backend doesn't handle it.

**Potential Issue**: The C backend may not generate correct struct layouts when member alignment is specified.

**Status**: Needs verification in C backend codegen.

## Reference Types (Implemented)

**Status**: Implemented in AST, parser, semantics, and IR.

**Syntax**: `T&` for reference types.

**Semantics**:
- References must bind to lvalues (`i32& b = 42` is rejected)
- References use `.` for field/method access (not `->`)
- References cannot be indexed (`ref[i]` is rejected)
- References are not implicitly convertible to pointers
- References auto-dereference on return
- References can be parameters, return types, and local variables

**IR**: Lowered to pointer types in IR; semantic checks enforce reference rules.

**Backend**: Works through existing pointer support.

## Function Attributes Validation

**Issue**: Added semantic validation for function attributes but some attributes may not be fully supported by backends.

**Attributes Validated**:
- `#[[noreturn]]` - must return void
- `#[[naked]]` - cannot have body  
- `#[[entry]]` - only for main
- `extern` - cannot have body

**Status**: Validation added, backend support varies.

## Positional Struct Literals

**Issue**: Added validation for positional struct literals in semantics.

**Validation Added**:
- Incomplete positional literals warn
- Type mismatches are hard errors
- Excess fields error

**Status**: Fixed in `compiler/coral-semantics/expr.crl`

## Unsupported Constructs in Backends

### C Backend (coral-backend/codegen.crl)

**Explicitly Unsupported**:
- `defer` statements - `cgErrorUnsupportedConstruct` at line 5674
- File-scope constant initializers that aren't constant expressions - `cgErrorUnsupported` at lines 6899, 6904
- `typeof` expressions - `cgError` at line 4123
- Unresolved `TypeRef` - `cgError` at line 4113
- Unsupported builtin calls - `cgError` at line 4067
- Unsupported expression kinds - `cgError` at line 4129
- Unsupported statement kinds - `cgError` at line 5800
- Pattern lowering failures - `cgError` at lines 4490, 4586, 4604
- Enum variant not a literal - `cgError` at line 6315
- Constant initializer refers to itself - `cgError` at line 6641

**Potential Silent Failures**:
- Array constant initialization with non-literal - `cgError` at line 6892
- Too many arguments (>64) - `cgError` at lines 2752, 3673, 3727
- Too many struct fields (>256) - `cgError` at line 3831
- Too many array elements (>16) - `cgError` at line 3874
- Too many tuple elements (>16) - `cgError` at line 3896
- Too many switch cases (>256) - `cgError` at line 4801
- Temp capacity exceeded - `cgError` at line 339
- Too many live locals with drop methods - `cgError` at line 392

### Muvm Backend (lib/muvm/target/fast/x86_64.crl)

**Explicitly Unsupported**:
- Vector operand shapes - line 455
- AtomicRMW ops: Nand, Max, Min, UMax, UMin - lines 2397-2403
- Unsupported opcodes - lines 2505, 2513
- LandingPad, ExtractValue, InsertValue, GcRoot, GcWriteBarrier, GcSafepoint - line 2502

**Behavior**: Emits `ud2` (trap) for unsupported opcodes to fail loudly.

### Wasm Backend (lib/muvm/target/fast/wasm32.crl)

**Explicitly Unsupported**:
- Various GEP patterns (raw pointer, struct index non-constant, etc.) - multiple `failMsg` calls
- Bitcast width mismatches - lines 1488, 1493
- Alloca without element type - line 1556
- Call to unknown function - line 1581
- Indirect call without function type - line 1589
- Indirect call of unregistered type - line 1596
- Extractelement/insertelement with non-constant index - lines 2182, 2201
- Terminator reached generic dispatcher - line 2218
- Branch to block outside function - line 2285
- Cond branch to block outside function - line 2301

**Behavior**: Emits error messages via `failOp`/`failMsg` and returns false.

## Reference Implementation Status

**Complete**:
- AST: `TypeKind::Reference` in types.crl
- Parser: `T&` suffix parsing in type.crl
- Semantics: lvalue binding, field/method access, no indexing, no implicit pointer conversion
- IR: lowered to pointer types in lower.crl
- Backend: works through existing pointer support

**Edge Cases Tested**:
- Reference declarations and initialization
- Reference parameters and return types
- Reference field access with `.`
- Reference method calls
- Reference arithmetic
- Reference assignment
- Reference to pointer conversion (rejected)
- Address-of on references (unwraps to base type)
- References in generics
- References in arrays
- References to array elements
- References in structs
- Chained references
- Reference conditionals (rejected - not lvalue)
- Reference function pointers (syntax TBD)

**Known Limitations**:
- Conditional expressions cannot bind to references (correct behavior)
- Function pointer syntax for references needs verification
- Some complex generic reference cases may need additional testing
