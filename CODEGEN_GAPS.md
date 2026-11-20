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

## Reference Types (Deferred)

**Issue**: Attempted to add `TypeKind::Reference` but didn't implement full feature.

**Status**: Removed from TypeKind enum. Full implementation deferred.

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
- Incomplete positional literals error
- Type mismatches are hard errors
- Excess fields error

**Status**: Fixed in `compiler/coral-semantics/expr.crl`
