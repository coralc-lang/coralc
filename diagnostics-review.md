# Coral Diagnostics Quality Review — Repeated Error Messages & Split Proposals

## Implementation status (2026-10-21, later same session)

Done: **##1** (number errors re-routed to L0006), **##3** (T0017 `SemaIterProtocol` @iter conformance), **##4** partly (E-code re-key), **##6** (L0008 `LexMalformedRawString`), **##10** (keyword expects), **##16** (reserved-`self` reword at the name site), **##19** (homoglyph re-keyed to L0009; P2 done), **##20** (const-name found-token). New this batch: **##7** T0023 `SemaMalformedImportPath` (re-codes the three sema import-path sites, quotes the path, explain entry), **##11** (P0016 "expected a switch pattern, found '…'"), **##12** (P0014 "…at file scope, found '…'"), **##17** (P0002/P0003/P0004 now append found-token via the shared `reportExpectedWith` helper in recovery.crl). Remaining: **##2/#6-group** (T0002 `typeMismatchMsg` enrichment), **##5** (@compileError re-code to T0014), **##8** (generic-arity counts), **##9** (name the identifier at the three T0001 stragglers), **##13** (tuple-index re-code), **##14** ("must be bool" ×7), **##15**/**#18** (variant-family naming/candidate lists).

## Method

**Scope.** Read-only review of the self-hosted Coral compiler at `/home/cerie/Documents/coral/compiler`. Every diagnostic *emission site* in `coral-lexer/`, `coral-parser/`, `coral-semantics/`, `coral-mono/`, `coral-backend/` was grepped (`reportError(`, `reportCurrentError(`, `reportErrorAtHelp(`, `reportWarning(`, `reportWarningAt(`, `reportExpected(`, `reportAllocFailed(`, `semaError*(`, `semaWarn*(`, `emitError/Warning/Note/Allowed/Fatal`, `cgError*(`) and read in context to capture the **verbatim** message text, including texts assembled through `String`/`nameMsg`/`typeMismatchMsg`/`paramMismatchMsg` buffers. The diagnostics tables (`coral-diagnostics/code.crl`, `msg.crl`, `error.crl` `helpFor()`, `explain.crl`) were read in full. Driver-level `printf` messages in `coral-frontend/` are noted but are outside the `ErrorCode` system.

**Key architectural fact.** `msg.crl:getFormat()` says it plainly: *"formats are fixed strings and the interesting wording lives at call sites or in helpFor()"* (msg.crl:6-7). Callers almost always pass an explicit message, so the **code → default-text table is dead for most codes**; duplication therefore lives in the call-site strings, keyed by shared `ErrorCode`. This review groups by (a) verbatim-identical strings, (b) identical message *templates*, and (c) one `ErrorCode` masking distinct situations behind whatever text the call site supplied. The `helpFor()`/`explain.crl` layers are also part of the user-visible message, so a shared code also forces a shared help/explain paragraph — the strongest argument for splitting.

**Funnel APIs audited specially:**
- `Parser.expect(kind)` (parser.crl:51-68) → `reportExpected` (recovery.crl:109-134) → `ParseExpectedToken` (P0001): **~200 call sites** (`self.expect(` counts: decl.crl 99, stmt.crl 41, expr.crl 38, file.crl 6, type.crl 8, pattern.crl 8).
- `reportCurrentError` (recovery.crl:28): 18 call sites, all read individually below.
- `reportAllocFailed` (recovery.crl:29): ~40 call sites, one message by design.
- `semaErrorNode(SemaTypeMismatch, …)`: **54 sites** (expr.crl 39, stmt.crl 15).

---

## Emission-site inventory

Legend: **Code** = `ErrorCode` (stable string per `codeStr`, code.crl:91-157). Texts in quotes are verbatim; `⟨…⟩` marks runtime-interpolated parts. "via" = funnel entry.

### Lexer — `coral-lexer/` (22 sites)

| file:line | Code | Verbatim text |
|---|---|---|
| skip_ws.crl:62 | LexUnterminatedComment (L0004) | `"unterminated block comment"` |
| ident.crl:183-184 | LexHomoglyph (E0103) | `"identifier contains a non-ASCII lookalike character (U+"⟨cp⟩") that mimics ASCII '"⟨mimic⟩"' (U+"⟨mimic⟩")"` |
| string.crl:29 | LexInvalidEscape (L0005) | `"invalid escape sequence"` |
| string.crl:42 | LexUnterminatedString (L0002) | `"unterminated string literal"` |
| string.crl:60 | LexInvalidEscape (L0005) | `"invalid escape sequence"` |
| string.crl:71 | LexUnterminatedString (L0002) | `"unterminated C string literal"` |
| string.crl:80 | LexUnterminatedString (L0002) | `"expected '\"' after R for raw string"` |
| string.crl:94 | LexUnterminatedString (L0002) | `"expected '(' in raw string delimiter"` |
| string.crl:131 | LexUnterminatedString (L0002) | `"unterminated raw string literal"` |
| lexer.crl:87 | LexInvalidEscape (L0005) | `"invalid escape sequence"` |
| lexer.crl:98 | LexUnterminatedChar (L0003) | `"unterminated character literal"` |
| lexer.crl:108 | LexUnknownChar (L0001) | `"unknown character"` |
| number.crl:30 | **LexInvalidChar (L0007)** via base.crl:61-63 | `"invalid integer literal"` |
| number.crl:34 | **LexInvalidChar (L0007)** | `"invalid digit for integer base"` |
| number.crl:40 | **LexInvalidChar (L0007)** | `"integer literal out of range"` |
| number.crl:45 | **LexInvalidChar (L0007)** | `"integer literal out of range"` |
| number.crl:83 | **LexInvalidChar (L0007)** | `"invalid mix of float and unsigned suffix"` |
| number.crl:88 | **LexInvalidChar (L0007)** | `"invalid mix of float and long suffix"` |
| number.crl:94 | **LexInvalidChar (L0007)** | `"float suffix on an integer literal"` |
| number.crl:156 | **LexInvalidChar (L0007)** | `"hex literal has no digits"` |
| number.crl:179 | **LexInvalidChar (L0007)** | `"binary literal has no digits"` |
| number.crl:199 | **LexInvalidChar (L0007)** | `"octal literal has no digits"` |

Note: number.crl uses the convenience `Lexer.reportError` (base.crl:61-63) which hard-codes `ErrorCode::LexInvalidChar`. `LexInvalidNumber` (L0006) exists in `code.crl:19`, `msg.crl:90`, `error.crl:90`, `explain.crl:91-98` — and is **never emitted by any call site**.

### Parser — `coral-parser/` (29 textual sites + funnels)

| file:line | Code | Verbatim text |
|---|---|---|
| recovery.crl:29 | DriverOutOfMemory (D0003) | `"out of memory while parsing"` (via `reportAllocFailed`, ~40 call sites incl. parser.crl:83, stmt.crl:275/374/410/414/419/464/514/561/589/618/622/640/644/663, type.crl:55/59/180/183/443/528/532/557/561/580/584/604, pattern.crl:33/155/175/197, file.crl:53/82/135, expr.crl:116/121/168/385/386/657/662/697/701/735/777/780/817/820/868/882/883/935/938/942, decl.crl:331/654/658/727/730/867/882/906/961/1000/1022/1023/1033/1091/1104/1120/1180/1260/1502/1540/1618/1654) |
| recovery.crl:113 | ParseUnexpectedEof (P0006) | `"unexpected end of file"` (via every `expect()` at EOF) |
| recovery.crl:127,133 | ParseExpectedToken (P0001) | `"expected ')'"` … etc. + `", found '"⟨token⟩"'"` (via ~200 `expect()` sites: file.crl 6, decl.crl 99, stmt.crl 41, expr.crl 38, type.crl 8, pattern.crl 8) |
| decl.crl:289/291 | ParseUnknownAttr (P0012) | `"unknown attribute '"⟨name⟩"'"` (+ help `"did you mean '"⟨cand⟩"'?"` when close match) |
| decl.crl:323 | ParseDuplicateAttr (E0807, warn) | `"attribute '"⟨name⟩"' is listed more than once"` |
| decl.crl:458 | ParseExpectedDecl (P0004) | `"expected a declaration: a function, var, const, struct or a type here"` |
| decl.crl:647 | ParseExpectedToken (P0001) | `"expected ')' to close the parameter list of '"⟨name⟩"', found '{'"` / `"'<eof>'"` |
| decl.crl:730 | ParseExpectedToken (P0001) | `"expected '>' to close generic parameters"` |
| decl.crl:770 | ParseExplicitSelfParam (P0013) | `"explicit \`self\` parameters are not supported"` |
| decl.crl:821 | ParseExplicitSelfParam (P0013) | `"explicit \`self\` parameters are not supported"` |
| decl.crl:1305 | ParseExpectedToken (P0001) | `"expected a constant name"` |
| decl.crl:1674 | ParseInvalidImportPath (P0011) | `"expected an import path: a bare name or a module path"` |
| decl.crl:1703 | ParseInvalidImportPath (P0011) | `"expected an import path: a bare name or a module path"` |
| stmt.crl:72-73 | ParseDocCommentOnStmt (E0105, warn) | `"documentation comment is attached to a statement, not a declaration"` |
| stmt.crl:82-83 | ParseMisplacedAttr (E0104, warn) | `"attribute has no meaning on a statement; attach it to a declaration instead"` |
| stmt.crl:166 | ParseCondAssign (P0010) | `"use of '=' in condition; mark with #[[condassign]] to allow it"` |
| stmt.crl:271 | ParseTooManyForBindings (P0015) | `"for-in supports at most 16 bindings"` |
| stmt.crl:544 | ParseNoFlagArm (P0017) | `"no arm of this flag statement matched; add an \`else\` arm"` |
| expr.crl:468 | ParseNoFlagArm (P0017) | `"no arm of this flag expression matched; add an \`else\` arm"` |
| expr.crl:599 | ParseExpectedStrExpr (P0021) | `"expected a path, call or struct literal after \`str\`"` |
| expr.crl:745 | ParseExpectedSizeof (P0018) | `"sizeof must be written @sizeof(T)"` |
| expr.crl:831 | ParseExpectedExpr (P0002) | `"expected an expression"` |
| type.crl:145 | ParseExpectedArraySize (P0019) | `"array size must be an integer literal, a const int, or a generic parameter"` |
| type.crl:550 | ParseExpectedTupleType (P0020) | `"tuple types are written 'struct(A, B)'"` |
| type.crl:595 | ParseExpectedType (P0003) | `"expected a type"` |
| pattern.crl:223 | ParseExpectedSwitchPattern (P0016) | `"expected switch pattern"` |
| pattern.crl:226 | ParseExpectedSwitchPattern (P0016) | `"expected switch pattern"` |
| file.crl:73 | ParseUnexpectedClosingToken (P0014) | `"unexpected closing token"` |

**Never-emitted codes (dead table rows):** `ParseExpectedStmt` (P0005), `ParseMissingSemicolon` (P0009), `ParseInvalidAssignTarget` (P0007), `ParseDuplicateModifier` (P0008), `LexInvalidNumber` (L0006) — present in `code.crl`/`msg.crl`/`error.crl`/`explain.crl` but with zero emission sites (grep across the tree).

### Semantics — `coral-semantics/` (≈101 sites)

**expr.crl:**

| file:line | Code | Verbatim text |
|---|---|---|
| expr.crl:112 | SemaUndeclaredIdent (T0001) | `"undeclared identifier '"⟨name⟩"'"` |
| expr.crl:161 | SemaUndeclaredIdent (T0001) | `"cannot assign: undeclared identifier"` |
| expr.crl:167 | SemaInvalidAssignTarget (T0008) | `"cannot assign: this name is not a variable"` |
| expr.crl:172 | SemaInvalidAssignTarget (T0008) | `"cannot assign to a constant"` |
| expr.crl:253 | SemaArityMismatch (T0003) | `"wrong number of arguments in function-pointer call: expected "⟨n⟩", got "⟨m⟩` |
| expr.crl:260-261 | SemaTypeMismatch (T0002) | `typeMismatchMsg("argument type", …)` = `"argument type: got \`X\`, expected \`Y\`"` |
| expr.crl:273 | SemaUndeclaredIdent (T0001) | `"call to undeclared function"` |
| expr.crl:286-287 | SemaTypeMismatch (T0002) | `"type '"⟨name⟩"' is not callable"` + help `"construct a struct with \`Type { .field = value }\`, …"` |
| expr.crl:329 | SemaArityMismatch (T0003) | `"wrong number of arguments in call to '"⟨name⟩"': expected "⟨n⟩[" or more]", got "⟨m⟩` |
| expr.crl:374/377 | SemaTypeMismatch (T0002) | `paramMismatchMsg(…)` = `"argument \`x\`: got \`X\`, expected \`Y\`"` / `typeMismatchMsg("argument type", …)` |
| expr.crl:461 | SemaUndeclaredIdent (T0001) | `"undeclared module in path"` |
| expr.crl:490 | SemaUnknownMember (T0006) | `"symbol not exported by module"` |
| expr.crl:510 | SemaIntToPtr (T0009, emitAllowed) | `"cannot assign an integer to a pointer"` + help `"use \`null\` …, or cast the integer explicitly"` |
| expr.crl:511 | SemaIntToPtr (T0009) | `"cannot assign an integer to a pointer"` |
| expr.crl:865-866, 877-878, 912-913 | SemaTypeMismatch (T0002) | `typeMismatchMsg("binary operand types", …)` |
| expr.crl:1133 | SemaTypeMismatch (T0002) | `"left operand of &&/\|\| must be bool"` |
| expr.crl:1135 | SemaTypeMismatch (T0002) | `"right operand of &&/\|\| must be bool"` |
| expr.crl:1254-1259 | SemaUnknownMember (T0006) | `"static method '"⟨m⟩"' not found on type '"⟨T⟩"'"` |
| expr.crl:1269-1274 | SemaTypeMismatch (T0002) | `"method '"⟨m⟩"' on type '"⟨T⟩"' is not static; it needs a receiver"` |
| expr.crl:1282-1288 | SemaArityMismatch (T0003) | `"wrong number of arguments to static method '"⟨m⟩"': expected "⟨n⟩", got "⟨m⟩` |
| expr.crl:1301 | SemaTypeMismatch (T0002) | `"static arg type mismatch"` |
| expr.crl:1325 | SemaUnknownMember (T0006) | `"symbol not exported by module"` |
| expr.crl:1375-1380 | SemaUnknownMember (T0006) | `"static method '"⟨m⟩"' not found on type '"⟨T⟩"'"` |
| expr.crl:1392-1395 | SemaTypeMismatch (T0002) | `"method '"⟨m⟩"' on type '"⟨T⟩"' is not static; it needs a receiver"` |
| expr.crl:1406-1409 | SemaArityMismatch (T0003) | `"wrong number of arguments to static method '"⟨m⟩"': expected …, got …"` |
| expr.crl:1424-1431 | SemaTypeMismatch (T0002) | `"type mismatch in argument "⟨i⟩" of static call to '"⟨f⟩"': expected '"⟨T⟩"'"` |
| expr.crl:1480-1493 | SemaUnknownMember (T0006) | `"method '"⟨m⟩"' not found on type '"⟨T⟩"'"` (+ @iter-specific help at 1489/1491 when receiver implements @iter) |
| expr.crl:1500-1501 | SemaExplicitDrop (E1301) | `"explicit call to drop is not allowed; drop runs automatically at scope exit"` |
| expr.crl:1521-1527 | SemaArityMismatch (T0003) | `"wrong number of arguments to method '"⟨m⟩"': expected …, got …"` |
| expr.crl:1548-1552 | SemaTypeMismatch (T0002) | `paramMismatchMsg` / `typeMismatchMsg("method argument type", …)` |
| expr.crl:1570 | SemaUnknownMember (T0006) | `"unknown variant case in payload"` |
| expr.crl:1586 | SemaUnknownMember (T0006) | `"field not found on variant case"` |
| expr.crl:1598-1615 | SemaUnknownMember (T0006) | `"field '"⟨f⟩"' not found on type '"⟨T⟩"'"` + `\n\ndid you mean '…'?` + available-fields list |
| expr.crl:1631 | SemaUnknownMember (T0006) | `"unknown variant case in payload"` |
| expr.crl:1647 | SemaUnknownMember (T0006) | `"field not found on variant case"` |
| expr.crl:1659-1665 | SemaUnknownMember (T0006) | `"field '"⟨f⟩"' not found through pointer of type '"⟨T⟩"'"` |
| expr.crl:1694-1700 | SemaTypeMismatch (T0002) | `"cannot index "⟨expr⟩": value of type '"⟨T⟩"' is not indexable (expected array, slice, pointer, or str)"` |
| expr.crl:1706 | SemaTypeMismatch (T0002) | `"array index must be an integer type"` |
| expr.crl:1726-1729 | SemaIndexOutOfBounds (T0013) | `"constant array index is out of bounds (array length "⟨n⟩")"` |
| expr.crl:1776-1782 | SemaTypeMismatch (T0002) | `"cannot dereference "⟨expr⟩": value of type '"⟨T⟩"' is not a pointer"` |
| expr.crl:1804 | SemaTypeMismatch (T0002) | `"negative literal out of range"` |
| expr.crl:1848-1849 | SemaTypeMismatch (T0002) | `typeMismatchMsg("assignment", …)` |
| expr.crl:1851-1852 | SemaSelfAssign (E0606, warn) | `"self-assignment has no effect"` |
| expr.crl:1863-1864, 1874-1875 | SemaTypeMismatch (T0002) | `typeMismatchMsg("compound assignment", …)` |
| expr.crl:1931 | SemaUnknownMember (T0006) | `"tuple index out of range"` |
| expr.crl:1949, 1961 | SemaUnknownMember (T0006) | `"variant construction needs a variant type"` |
| expr.crl:1955 | SemaUndeclaredIdent (T0001) | `"unknown type name: "⟨name⟩` |
| expr.crl:1967 | SemaUnknownMember (T0006) | `"not a variant type"` |
| expr.crl:1983 | SemaUnknownMember (T0006) | `"unknown variant"` |
| expr.crl:1996 | SemaUnknownMember (T0006) | `"too many positional fields in variant construction"` |
| expr.crl:2014 | SemaUnknownMember (T0006) | `"unknown field in variant construction"` |
| expr.crl:2024-2028 | SemaTypeMismatch (T0002) | `paramMismatchMsg` / `typeMismatchMsg("field type", …)` |
| expr.crl:2052-2074 | SemaUnknownMember (T0006) | `"unknown field '"⟨f⟩"' in struct literal of type '"⟨T⟩"'"` (+did-you-mean) / `"too many positional fields in struct literal of type '"⟨T⟩"'"` |
| expr.crl:2084-2088 | SemaTypeMismatch (T0002) | `paramMismatchMsg` / `typeMismatchMsg("struct field type", …)` |
| expr.crl:2120-2123 | SemaUnknownMember (T0006) | `"static method '"⟨m⟩"' not found on type '"⟨T⟩"'"` |
| expr.crl:2135-2138 | SemaTypeMismatch (T0002) | `"method '"⟨m⟩"' on type '"⟨T⟩"' is not static; it needs a receiver"` |
| expr.crl:2149-2152 | SemaArityMismatch (T0003) | `"wrong number of arguments to static method …"` |
| expr.crl:2167-2171 | SemaTypeMismatch (T0002) | `paramMismatchMsg` / `typeMismatchMsg("static method argument type", …)` |
| expr.crl:2227 | **SemaTypeMismatch (T0002)** | `@compileError` user text, or `"@compileError tripped"` |
| expr.crl:2258-2259 | SemaTypeMismatch (T0002) | `"@typeof is only allowed inside a comptime block"` |
| expr.crl:2264-2265 | SemaTypeMismatch (T0002) | `"@typeof takes exactly one argument"` |
| expr.crl:2272-2273, 2292-2293 | SemaTypeMismatch (T0002) | `"@typeof argument must be a type, variable, or literal"` |
| expr.crl:2363 | SemaTypeMismatch (T0002) | `"ternary condition must be bool"` |
| expr.crl:2380 | SemaTypeMismatch (T0002) | `"ternary branch types do not match"` |
| expr.crl:2408 | SemaTypeMismatch (T0002) | `"if-expression condition must be bool"` |
| expr.crl:2417 | SemaTypeMismatch (T0002) | `"if-expression branch types do not match"` |
| expr.crl:2473 | SemaTypeMismatch (T0002) | `"switch arm types do not match"` |
| expr.crl:2481 | SemaInternal (T0007) | `"unhandled expression kind in checkExpr"` |

**stmt.crl:**

| file:line | Code | Verbatim text |
|---|---|---|
| stmt.crl:49-50 | SemaTypeMismatch (T0002) | `"initializer for \`"⟨name⟩"\` does not match its declared type"` |
| stmt.crl:52 | SemaTypeMismatch (T0002) | `"initializer type does not match variable type"` |
| stmt.crl:71 | SemaTypeMismatch (T0002) | `"cannot infer type: add an explicit type annotation"` |
| stmt.crl:120-122 | SemaUnreachableCode (E0603, warn) | `"unreachable code: the preceding statement always leaves this block"` |
| stmt.crl:144-149 | SemaTypeMismatch (T0002) | `"return with no value in function returning '"⟨T⟩"'"` + help |
| stmt.crl:155 | SemaTypeMismatch (T0002) | `"return value type does not match function return type"` |
| stmt.crl:165 | SemaTypeMismatch (T0002) | `"if condition must be bool"` |
| stmt.crl:174 | SemaTypeMismatch (T0002) | `"while condition must be bool"` |
| stmt.crl:188 | SemaTypeMismatch (T0002) | `"for-in range start must be an integer"` |
| stmt.crl:190 | SemaTypeMismatch (T0002) | `"for-in range end must be an integer"` |
| stmt.crl:212 | SemaTypeMismatch (T0002) | `"for-in iterator must be an array, slice, or @iter collection"` + help |
| stmt.crl:222-226 | SemaUnknownMember (T0006) | `"method 'count' not found on type '"⟨T⟩"'"` + @iter help |
| stmt.crl:232-236 | SemaUnknownMember (T0006) | `"method 'at' not found on type '"⟨T⟩"'"` + @iter help |
| stmt.crl:245-249 | SemaUnknownMember (T0006) | `"method 'range' not found on type '"⟨T⟩"'"` + @iter help |
| stmt.crl:263 | SemaTypeMismatch (T0002) | `"@iter range() must return IterRange"` + help |
| stmt.crl:277 | SemaTypeMismatch (T0002) | `"for-in bind type does not match the iterator's element type"` |
| stmt.crl:291 | SemaTypeMismatch (T0002) | `"for-in multi-binding requires at() to return a tuple with one element per binding"` + help |
| stmt.crl:339 | SemaTypeMismatch (T0002) | `"for condition must be bool"` |
| stmt.crl:429 | SemaInternal (T0007) | `"unhandled statement kind in checkStmt"` |
| stmt.crl:697-700 | SemaUnusedVar (T0012, warn) | `"unused local '"⟨name⟩"'"` |
| stmt.crl:851 | SemaTypeMismatch (T0002) | `"function with a comptime generic parameter needs a comptime {} block in its body"` |
| stmt.crl:875-876 | SemaMissingReturn (T0011) | `"non-void function can reach the end without returning a value"` |
| stmt.crl:967-968 | SemaUnknownSwitchConstant (T0015) | `"unknown constant in switch pattern: "⟨name⟩` |
| stmt.crl:998 | SemaUnknownMember (T0006) | `"unknown variant in pattern"` |
| stmt.crl:1019 | SemaUnknownMember (T0006) | `"unknown field in pattern"` |
| stmt.crl:1108-1111 | SemaUnreachableSwitchCase (E0609, warn) | `"unreachable switch case: '"⟨name⟩"' is already covered by an earlier arm"` |
| stmt.crl:1154-1207 | SemaNonExhaustiveSwitch (E0608) | `"switch on '"⟨T⟩"' is not exhaustive; missing 'A', 'B', …"` |

**decl.crl / typecheck.crl / sema.crl:**

| file:line | Code | Verbatim text |
|---|---|---|
| decl.crl:668 | SemaUndeclaredIdent (T0001) | `notFoundMsg` = `"symbol not found in imported library"` (from decl.crl:737) / `"symbol not found in imported file"` (759) / `"symbol not found in imported module"` (808) |
| decl.crl:675, 681, 727, 731 | SemaDuplicateDecl (T0004) | `"conflicting import: already bound in this file — alias it with \`as\` or use a qualified path: "⟨name⟩` |
| decl.crl:706 | SemaUndeclaredIdent (T0001) | `"missing import path"` |
| decl.crl:747 | SemaUndeclaredIdent (T0001) | `"invalid import path"` |
| decl.crl:776 | SemaUndeclaredIdent (T0001) | `"invalid module member in import path"` |
| decl.crl:782, 801 | SemaUnknownMember (T0006) | `"symbol not exported by module"` |
| decl.crl:818 | SemaInternal (T0007) | `"checkFile called with null file"` |
| decl.crl:823 | SemaInternal (T0007) | `"scopes.enter failed"` |
| typecheck.crl:27 | SemaInternal (T0007) | `"allocTypeSlot failed (type table full)"` |
| typecheck.crl:490-494 | SemaLiteralOverflow (T0010) | `"integer literal '"⟨n⟩"' does not fit in the declared integer type"` (neg: `"'-…"`) |
| typecheck.crl:551 | SemaUndeclaredIdent (T0001) | `"unknown type name: "⟨name⟩` |
| typecheck.crl:580 | SemaArityMismatch (T0003) | `"wrong number of generic arguments"` |
| typecheck.crl:599-600 | SemaNonConstArraySize (T0016) | `"array size is not a compile-time constant: "⟨name⟩` |
| sema.crl:631-632 | SemaDuplicateDecl (T0004) | `"duplicate declaration of \`"⟨name⟩"\`"` |
| sema.crl:636-637, 653-654 | SemaDuplicateDecl (T0004, note) | `"previous declaration of \`"⟨name⟩"\` is here"` |
| sema.crl:650-651 | SemaDuplicateDecl (T0004) | `prefix` + name (dup member variants) |

### Mono / Backend

| file:line | Code | Verbatim text |
|---|---|---|
| mono/instantiate.crl:766 | ComptimeError (T0014) | `ct.errMsg` (user `@compileError` text) |
| mono/instantiate.crl:776 | ComptimeError (T0014) | `"comptime type switch has no matching arm"` |
| backend/codegen.crl:316 | CodegenInternal (G0002) | `"temp capacity exceeded"` |
| codegen.crl:369 | G0002 | `"too many live locals with drop methods"` |
| codegen.crl:1450 | G0002 | `"out of memory"` |
| codegen.crl:1497 | G0002 | `"no unique mono instance for call"` |
| codegen.crl:1816 | G0002 | `"unresolved type param in codegen"` |
| codegen.crl:3042, 3063, 3104, 3116 | G0002 | `"no monomorphized instance for generic call; the call site was not collected"` |
| codegen.crl:3163, 3293, 3347 | G0002 | `"too many arguments (cap 16)"` |
| codegen.crl:3451 | G0002 | `"too many struct fields (cap 256)"` |
| codegen.crl:3463 | G0002 | `"variant case not found"` |
| codegen.crl:3494 | G0002 | `"too many array elements (cap 16)"` |
| codegen.crl:3516 | G0002 | `"too many tuple elements (cap 16)"` |
| codegen.crl:3740 | G0002 | `"unsupported builtin call"` |
| codegen.crl:3759 | G0002 | `"unresolved TypeRef"` |
| codegen.crl:3769 | G0002 | `"typeof not supported"` |
| codegen.crl:3775 | G0002 | `"unsupported expression kind"` |
| codegen.crl:3869 | G0002 | `"expected expression node"` |
| codegen.crl:4008 | G0002 | `"expected lvalue node"` |
| codegen.crl:4030, 4570 | G0002 | `"expected statement node"` |
| codegen.crl:4136, 4232, 4250 | G0002 | `"pattern lowering failed"` |
| codegen.crl:4174 | G0002 | `"pattern names an unknown constant"` |
| codegen.crl:4447 | G0002 | `"too many switch cases (cap 256)"` |
| codegen.crl:4657 | G0002 | `"array local needs array-literal init"` |
| codegen.crl:4802, 4810 | G0002 | `"break outside of loop"` / `"continue outside of loop"` |
| codegen.crl:5049 | G0002 | `"for-in over non-slice/array without @iter count()/at()"` |
| codegen.crl:5055 | G0002 | `"for-in over unknown iterator type"` |
| codegen.crl:5102 | G0002 | `"for-in range() not found"` |
| codegen.crl:5247 | G0002 | `"for-in multi-binding requires a matching tuple element type"` |
| codegen.crl:5305 | G0002 | `"defer is not supported"` |
| codegen.crl:5344 | G0002 | `"asm template pieces must be string literals"` |
| codegen.crl:5369, 5395 | G0002 | `"asm operand constraint must be a string literal"` |
| codegen.crl:5421 | G0002 | `"asm clobber must be a string literal"` |
| codegen.crl:5431 | G0002 | `"unsupported statement kind"` |
| codegen.crl:5552 | G0002 | `"explicit self with unknown owner"` |
| codegen.crl:5953 | G0002 | `"enum variant is not a literal"` |
| codegen.crl:6251 | G0002 | `"constant initializer refers to itself"` |
| codegen.crl:6369 | G0002 | `"too many file-scope variables with runtime initializers"` |
| codegen.crl:6474 | G0002 | `"array constant needs an array-literal initializer"` |
| codegen.crl:6481, 6486 | CodegenUnsupported (G0001) | unsupported file-scope const shapes |

---

## Duplicate-message groups (core analysis)

### Group 1 — `LexInvalidChar` (L0007) as the bucket for ALL number-literal errors — **10 sites, WRONG CODE** — **SPLIT (re-route)**

Sites: number.crl:30, 34, 40, 45, 83, 88, 94, 156, 179, 199 — all via `Lexer.reportError` (base.crl:61-63) which hard-codes `ErrorCode::LexInvalidChar`.

Situations: bad digit alphabet, digit ≥ base, u64 overflow (×2), illegal suffix mixes (×3), digitless `0x`/`0b`/`0o`. These are *ten genuinely distinct numeric-syntax errors* — and the strings themselves are good. The problem is the **code**: every one renders as `error[L0007]`, whose default text (msg.crl:91) is `"invalid character literal"`, whose help (error.crl:91) is *"this character cannot start a token"*, and whose `--explain L0007` (explain.crl:99-105) talks about tokens. Meanwhile `LexInvalidNumber`/L0006 ("invalid numeric literal", help "use digits in the matching base…", full explain at explain.crl:91-98) is fully built out and **emitted nowhere**. Verdict: not a text collision but a code-routing collision — one code doing L0006's job across 10 distinct numeric situations. **Fix without any new strings**: change `number.crl` to call `reportErrorCode(ErrorCode::LexInvalidNumber, …)` (or give `base.crl` a `reportNumberError` wrapper). The two identical `"integer literal out of range"` sites (40/45) are MERGE-BY-DESIGN (wrap-on-multiply vs add-overflow — indistinguishable to users).

### Group 2 — `"method 'X' not found on type 'T'"` family — **7 sites across 3 genuinely different situations** — **SPLIT (@iter) / MERGE (rest)**

| site | situation |
|---|---|
| sema/expr.crl:1480-1493 | instance method call `x.m()` — method lookup on the receiver's type failed (2 hidden @iter help variants at 1489/1491) |
| sema/expr.crl:1254-1259 | static method `Foo<i32>::m()` — lookup on an *instantiated generic* TypeRef head |
| sema/expr.crl:1375-1380 | static method `Foo::m()` — lookup on a named type via path call |
| sema/expr.crl:2120-2123 | static method via `StaticCall` expression kind — third duplicate of the static path |
| sema/stmt.crl:222-226 | for-in over @iter type missing `count()` — **protocol conformance**, not a typo |
| sema/stmt.crl:232-236 | for-in over @iter type missing `at()` — protocol conformance |
| sema/stmt.crl:245-249 | ranged for-in over @iter type missing `range()` — protocol conformance |

The first four are the *same* user mistake (misspelled/unimported method) seen from three resolution paths — MERGE-BY-DESIGN, and the "static method"/"method" wording already distinguishes them. The three stmt.crl sites are a different animal: the type *advertises* `@iter`, so "not found" misleads (rustc's E0599-should-be-split debate, see Comparison). The per-site `helpFor` saves them today only because each passes a bespoke help string; the headline is still wrong. **SPLIT**: new code `SemaIterProtocol` (T0017) — *"type `T` does not fully implement @iter: missing method `count()`"* — for stmt.crl:222/232/245 and the @iter help branches at expr.crl:1489/1491.

### Group 3 — `"symbol not exported by module"` — **4 verbatim-identical sites, 2 different contexts** — **SPLIT-lite (enrich, share code)**

Sites: sema/decl.crl:782 (member of an import path `a::b::c` not exported), sema/decl.crl:801 (imported symbol not exported), sema/expr.crl:490 (path *expression* `m::name`), sema/expr.crl:1325 (path *call* `m::name()`). None names the symbol or the module — the user gets a caret and four words. Contexts differ (import binding vs use-site resolution) but the defect is identical. Judgment: MERGE-BY-DESIGN for the code (T0006 is defensible), but the message must be split into context-flavored, name-bearing variants: *"symbol `foo` is not exported by module `bar`; mark it `pub` in bar, or import a different name"* (decl sites) vs *"symbol `foo` is not exported by module `bar`"* (expr sites).

### Group 4 — `"wrong number of arguments to static method 'M': expected N, got M"` — **3 sites, same situation** — **MERGE-BY-DESIGN**

expr.crl:1282-1288, 1406-1409, 2149-2152 are the three static-call resolution paths producing the identical good message. Fine as-is. Contrast: typecheck.crl:580 `"wrong number of generic arguments"` (also T0003) carries **no counts and no type name** — the odd one out of the arity family (see Vague list).

### Group 5 — `"method 'M' on type 'T' is not static; it needs a receiver"` — **3 sites, same situation** — **MERGE-BY-DESIGN**

expr.crl:1269-1274, 1392-1395, 2135-2138. Same three static-call paths. Good message. Keep.

### Group 6 — `SemaTypeMismatch` (T0002) — **54 sites; ~40 distinct situations** — **BORDERLINE (code shared by design; ~10 texts need enrichment; a few need new codes)**

The workhorse. Sub-groups by *text template*:

- **`typeMismatchMsg(what, …)` = `"⟨what⟩: got \`X\`, expected \`Y\`"`** (sema.crl:575-605) used at expr.crl:260, 377, 865, 877, 912, 1848, 1863, 1874, 2027, 2087, 2170 — **MERGE-BY-DESIGN**, rustc-E0308-quality.
- **`paramMismatchMsg` = `"argument \`x\`: got …, expected …"`** (sema.crl:536) at expr.crl:374, 1548, 2024, 2084, 2167 — MERGE-BY-DESIGN, good.
- **Condition-must-be-bool family (7 sites)**: stmt.crl:165 `"if condition must be bool"`, 174 `"while condition must be bool"`, 339 `"for condition must be bool"`, expr.crl:1133/1135 `"left/right operand of &&/|| must be bool"`, 2363 `"ternary condition must be bool"`, 2408 `"if-expression condition must be bool"`. Genuinely parallel situations (same rule, different syntax) — MERGE-BY-DESIGN for the code, but none reports the **found type**; enrich each to `typeMismatchMsg("if condition", found, bool)`. Note the semantics differ: statement-if allows int/pointer truthiness (stmt.crl:164) while ternary/if-expr demand strict bool (expr.crl:2405-2408) — the two "condition must be bool" messages that *do* fire are for different acceptance rules and could say so.
- **Branch/arm mismatch family (3 sites)**: expr.crl:2380 `"ternary branch types do not match"`, 2417 `"if-expression branch types do not match"`, 2473 `"switch arm types do not match"` — same defect class (unifying result type failed), different constructs. Distinct texts already; both missing the two types. Enrich: `"ternary branches have incompatible types: \`i32\` and \`str\`"`.
- **Bare/misc**: 1301 `"static arg type mismatch"` (worst offender), 155 `"return value type does not match function return type"`, 52 `"initializer type does not match variable type"`, 277 `"for-in bind type does not match the iterator's element type"` — all *could* reuse the available `typeMismatchMsg` helpers but don't. Not new codes needed — enrichment only.
- **Wrong-code sub-groups** (should leave T0002): expr.crl:2227 `@compileError` user text (should be ComptimeError T0014 — mono/instantiate.crl:766 already uses T0014 for the *same situation*; this is the clearest code-split in the tree); expr.crl:2258/2264/2272/2292 `@typeof` usage errors (a builtin-usage code would be better); expr.crl:1983-ish family already on T0006.

### Group 7 — `SemaUnknownMember` (T0006) as a second catch-all — **29 sites** — **BORDERLINE; 2 clear re-codes**

Distinct situations behind "no member named" (msg.crl:127):
- true member/method misses (good) — MERGE-BY-DESIGN;
- **@iter protocol** (stmt.crl:222/232/245; expr.crl:1489/1491) — SPLIT, see Group 2;
- **tuple index**: expr.crl:1931 `"tuple index out of range"` — not a member lookup at all; re-code to `SemaIndexOutOfBounds` (T0013) with *"tuple index 4 is out of range for \`struct(i32, str)\` (2 elements)"*;
- **module export**: 4 sites, Group 3;
- **variant/payload plumbing**: expr.crl:1570/1631 `"unknown variant case in payload"` (×2 = same situation through Field vs DerefField — MERGE), 1586/1647 `"field not found on variant case"` (×2 MERGE), 1949/1961 `"variant construction needs a variant type"` (×2 MERGE), 1967 `"not a variant type"`, 1983 `"unknown variant"`, 1996, 2014, stmt.crl:998 `"unknown variant in pattern"`, 1019 `"unknown field in pattern"` — these are *enum/variant-specific* name errors that share code with struct member misses; the texts mostly don't name the missing/candidate names. BORDERLINE: one `SemaUnknownVariant`-style code would let explain.crl give variant-flavored guidance, but the text fix (name the case/type) matters more.

### Group 8 — `SemaUndeclaredIdent` (T0001) doing four jobs — **10 sites, 4 situations** — **SPLIT (import-path shape)**

- genuine unknown names: expr.crl:112 (names it ✓), 161, 273 (don't — enrich), typecheck.crl:551 / expr.crl:1955 `"unknown type name: X"` (good);
- **import resolution**: decl.crl:668 `"symbol not found in imported library/file/module"` (3 flavors via parameters — arguably fine, but none names the symbol);
- **path shape** errors: decl.crl:706 `"missing import path"`, 747 `"invalid import path"`, 776 `"invalid module member in import path"` — these are *syntax-ish* defects reported as "unknown name" (T0001's help says "check the spelling, or import the module…", explain.crl:189-195 talks about undeclared identifiers — actively misleading). **SPLIT**: new `Parse/SemaMalformedImportPath` (suggest T0018 or reuse P0011) with the offending path segment quoted.

### Group 9 — Parser `ParseExpectedToken` (P0001) funnel — **~200 sites behind one code** — **MERGE-BY-DESIGN with two holes**

`reportExpected` (recovery.crl:109-134) does the right thing: *"expected ';', found 'x'"* with a 64-byte cap. The code is shared by design (clang's `err_expected_semi`/`expected` family is similarly one diagnostic with a substituted token). Two holes:
1. `expectedTokenText` (recovery.crl:87-107) covers 14 kinds; the other expects in the tree — `String`×5, `Import`, `Variant`, `Var`, `Union`, `Typedef`, `Trait`, `Struct`, `Mod`, `Flag`, `Extend`, `Enum`, `Distinct`, `Const`, `Comptime`, `Asm`, `Hash`, `Colon`, `Less` (~22 sites) — fall to the `else => "expected token"` arm: the user sees *"expected token, found 'struct'"* — pure noise. Fix: extend the table to `"expected keyword \`struct\`"` etc.
2. Non-`expect` P0001 sites invent their own texts: decl.crl:647 (excellent), 730, 1305 `"expected a constant name"` (no found-token, and the situation — a const decl with no declarator name — deserves either the found-token suffix or its own P0022).

### Group 10 — `ParseExplicitSelfParam` (P0013), identical text, two situations — **SPLIT (borderline)**

decl.crl:770: an explicit receiver (`self`, `const self*`, `self*`) written in the parameter list. decl.crl:821: an ordinary parameter *named* `self` (`param.name == intern("self")`). Same fix advice in aggregate (explain P0013 covers both, explain.crl:278-285), but the second is "the name `self` is reserved", not "remove the receiver". Split text at 821: *"parameter name \`self\` is reserved; rename the parameter"* — same code is acceptable; a distinct sentence is not.

### Group 11 — `LexUnterminatedString` (L0002) covering malformed raw strings — **5 sites, 3 situations** — **SPLIT**

string.crl:42 `"unterminated string literal"`, 71 `"unterminated C string literal"` — genuinely unterminated (MERGE-BY-DESIGN, flavor-named ✓). string.crl:80 `"expected '\"' after R for raw string"`, 94 `"expected '(' in raw string delimiter"` — the raw string was *never opened correctly*; nothing is unterminated, and L0002's help ("close the string with a matching quote", error.crl:86) / explain (talks about `"` on one line, explain.crl:58-65) actively misdescribes the defect. string.crl:131 `"unterminated raw string literal"` — truly unterminated but needs the `)delim"` terminator named. **SPLIT**: new `LexMalformedRawString` for 80/94 (see code-space note below); keep 131 on L0002 but reword help/explain to mention the `)delim"` form.

### Group 12 — `"invalid escape sequence"` — **3 verbatim sites** — **MERGE-BY-DESIGN, enrich**

string.crl:29 (string), 60 (C-string), lexer.crl:87 (char literal). Same defect, three literal flavors — one message is correct. But `EscapeResult` already knows the offending byte; include it: *"invalid escape sequence \`\\q\`"*. L0005's help/explain already list valid escapes — good.

### Group 13 — `"explicit \`self\` parameters are not supported"` — see Group 10.

### Group 14 — `"expected an import path: a bare name or a module path"` — **2 verbatim sites** — **MERGE-BY-DESIGN**

decl.crl:1674 (plain `import`) and 1703 (`import(lib)`-style) — identical situation (a string literal where a path was expected), two entry points. Fine. Would improve by quoting the string: *"import path must be a bare name or \`a::b\` path, found string literal"*.

### Group 15 — `"expected switch pattern"` — **2 verbatim sites** — **MERGE-BY-DESIGN, enrich**

pattern.crl:223 (at a recovery boundary — don't consume) and 226 (eat one token). Same situation, two recovery strategies. The text should adopt the P0001 found-token pattern: *"expected a switch pattern, found '}'"*.

### Group 16 — `ParseNoFlagArm` statement vs expression — **2 near-identical sites** — **MERGE-BY-DESIGN**

stmt.crl:544 `"no arm of this flag statement matched; add an \`else\` arm"` vs expr.crl:468 `"no arm of this flag expression matched; …"`. Same construct in two syntactic positions; the one-word distinction is exactly right. Keep.

### Group 17 — `"conflicting import: already bound in this file — …"` — **4 sites (2 pairs)** — **MERGE-BY-DESIGN**

decl.crl:675/681 (symbol pull) and 727/731 (module name); each pair is counted-vs-already-counted (`semaError` vs `semaErrorCounted`) for the same logical failure. Correct merge.

### Group 18 — `SemaInternal` (T0007) — **5 sites** — **MERGE-BY-DESIGN**

decl.crl:818/823, typecheck.crl:27, stmt.crl:429, expr.crl:2481. Internal invariants; distinct texts; shared code with a "please report this" help (error.crl:119) — exactly what a catch-all internal code should be.

### Group 19 — Backend G0002 catch-alls — **~40 sites** — **MERGE-BY-DESIGN with 2 collisions**

"no monomorphized instance…" ×4, "too many arguments (cap 16)" ×3, "pattern lowering failed" ×3, "asm operand constraint…" ×2, "expected statement node" ×2 — each duplicate set is the same invariant checked at sibling lowering paths; correct merges. `"unsupported expression kind"` (3775) / `"unsupported statement kind"` (5431) / `"variant case not found"` (3463) are vague even for internal codes (name the `ExprKind`/`StmtKind` tag).

### Group 20 — `@compileError` reported under two different codes — **reverse-split (merge)**

sema/expr.crl:2227 emits the user's `@compileError` text (or `"@compileError tripped"`) as **SemaTypeMismatch (T0002)**; mono/instantiate.crl:766 emits the same category of message as **ComptimeError (T0014)**. Same situation, two codes → two misleading helps ("convert one side with an explicit cast" vs "the text above is the message from the comptime code that ran"). Re-code 2227 to `ComptimeError`.

### Group 21 — `"unknown type name: X"` — **2 sites** — **MERGE-BY-DESIGN**

typecheck.crl:551 and expr.crl:1955 — same situation (Named type entry with no symbol), good text.

### Group 22 — `"cannot assign an integer to a pointer"` — **2 sites** — **MERGE-BY-DESIGN**

expr.crl:510 (allowed path, `emitAllowed`) and 511 (error path) — same diagnostic, flag-gated severity. Correct.

---

## Split proposals

For every SPLIT verdict: concrete replacement text per site, and whether a new `ErrorCode` is needed (with insertion point in `code.crl` + companion rows in `msg.crl`/`error.crl`/`explain.crl`).

### P1. Number-lexer codes (Group 1) — **no new code; re-route to existing L0006**
- `coral-lexer/number.crl` (all 10 sites): replace `self.reportError(...)` with `self.reportErrorCode(ErrorCode::LexInvalidNumber, self.bufStart, self.bufEnd, ptr, msg)`.
- Optionally merge number.crl:30 (`"invalid integer literal"`) into :34's clearer `"invalid digit for integer base"` — :30 fires for non-alphabet garbage where :34's phrasing still fits ("`g` is not a valid hex digit").
- No `msg.crl`/`explain.crl` change — L0006 rows already exist and finally become reachable.

### P2. Homoglyph code-space cleanup (prerequisite for P3)
`code.crl:102` maps `LexHomoglyph => "E0103"`, `error.crl:135` has help for E0103, but `explain.crl:257-263` carries the homoglyph text under **`L0008`** — a code `codeStr` never produces. So `--explain E0103` prints the index and `--explain L0008` prints text for a code that is never emitted. Fix direction: re-key the explain entry at explain.crl:257 from `"L0008"` to `"E0103"` (no user-visible code change). This frees `L0008` for P3.

### P3. Malformed raw string (Group 11) — **NEW code `LexMalformedRawString` → L0008**
- `code.crl` (after LexHomoglyph, line ~21): add `LexMalformedRawString,`; `codeStr`: `=> { return "L0008"; }`.
- `msg.crl` (with the lexer rows, ~line 91): `LexMalformedRawString => { return "malformed raw string literal"; }`.
- `error.crl` helpFor: `if (code.equals("L0008")) return "raw strings are spelled R\\\"delim( … )delim\\\"";`.
- `explain.crl`: add L0008 entry: why "a raw string's opening delimiter is malformed", fix "`R\"(hello)\"` — quote after R, then anything up to `(`".
- Sites: string.crl:80 → *"expected '\"' after \`R\` to open a raw string"*, code L0008; string.crl:94 → *"expected '(' after the raw string delimiter"*, L0008; string.crl:131 stays L0002 with text *"unterminated raw string literal: missing \`)delim\"` terminator"*.

### P4. @iter protocol conformance (Groups 2/7) — **NEW code `SemaIterProtocol` → T0017**
- `code.crl` (semantics block, after SemaNonExhaustiveSwitch, line ~70): `SemaIterProtocol,`; `codeStr: => "T0017"`.
- `msg.crl`: `SemaIterProtocol => { return "type does not fully implement @iter"; }`, Severity Error.
- `error.crl` helpFor: `T0017 → "a type used in for-in must provide usize count(), T at(usize), and — for ranged for-in — IterRange range(usize, usize); declare them in \`extend Type : @iter {}\`"`.
- `explain.crl`: new T0017 entry describing the protocol.
- Sites and replacement headlines (keeps the existing bespoke helps):
  - stmt.crl:222 → *"type \`"T"\` does not implement @iter: missing method \`count\`"*
  - stmt.crl:232 → *"type \`"T"\` does not implement @iter: missing method \`at\`"*
  - stmt.crl:245 → *"type \`"T"\` does not implement @iter: missing method \`range\`"*
  - stmt.crl:263 → *"@iter method \`range\` must return \`IterRange\`, found \`"R"\`"* (also re-code here from T0002)
  - expr.crl:1489 branch → *"type \`"T"\` does not fully implement @iter: missing \`range(usize, usize)\`"*; expr.crl:1491 branch → *"…missing \`count()\`/`at(usize)\`"* — both under T0017.

### P5. Module-export messages (Group 3) — **no new code; split text per context**
- decl.crl:782 → *"symbol `"⟨member⟩"` is not exported by module `"⟨root⟩"`; declare it \`pub\` or import a different name"*
- decl.crl:801 → *"imported symbol `"⟨name⟩"` is not exported by its module"*
- expr.crl:490 → *"symbol `"⟨name⟩"` is not exported by module `"⟨root⟩"`"*
- expr.crl:1325 → *"function `"⟨name⟩"` is not exported by module `"⟨root⟩"`"*
- All keep T0006; update explain.crl T0006 to mention export errors.

### P6. Bare T0002 texts → `typeMismatchMsg` enrichment (Group 6) — **no new codes**
- expr.crl:1301 → `typeMismatchMsg("static argument type", actual, want)` (mirrors 1424's better sibling) → *"static argument type: got \`X\`, expected \`Y\`"*.
- stmt.crl:155 → `typeMismatchMsg("return value", got, retTy)` → *"return value: got \`str\`, expected \`i32\`"*.
- stmt.crl:52 → `typeMismatchMsg("initializer", actual, declaredType)`.
- stmt.crl:277 → *"for-in binding type: got \`X\`, expected element type \`Y\`"* via typeMismatchMsg.
- stmt.crl:165/174/339, expr.crl:1133/1135/2363/2408 → `typeMismatchMsg("if condition" / "while condition" / …, foundTy, boolType)`.
- expr.crl:2380/2417/2473 → *"ternary branch types do not match: \`X\` vs \`Y\`"* (append both spellings, like rustc's expected/found children).

### P7. `@compileError` re-code (Group 20) — **no new code; use existing T0014**
- expr.crl:2227: `ErrorCode::SemaTypeMismatch` → `ErrorCode::ComptimeError`. The existing T0014 explain (explain.crl:314-320) already describes this exact situation. Optionally prefix non-literal messages: *"@compileError: "⟨text⟩"*.

### P8. Undeclared-name enrichment (Group 8) — **partial new code for path shape (T0018)**
- expr.crl:161 → `self.nameMsg("undeclared identifier '", name)`-style: *"cannot assign to undeclared identifier \`x\`"*.
- expr.crl:273 → *"call to undeclared function \`f\`"* (needs the name from the callee node — available at callId).
- expr.crl:461 → *"undeclared module \`⟨root⟩\` in path"*.
- decl.crl:668 (all 3 flavors) → append the symbol: *"symbol not found in imported file: `⟨name⟩`"*.
- **NEW `SemaMalformedImportPath` → T0018** for decl.crl:706 (*"import declaration is missing a path"*), 747 (*"invalid import path segment in `⟨path⟩`"*), 776 (*"empty module member in import path `⟨path⟩`"*). `msg.crl`: *"malformed import path"*; helpFor: *"an import path is a bare name or `name::item`; quote segments cannot be empty"*; explain entry mirrors P0011's.

### P9. Parser found-token enrichment (Groups 9/15) — **no new codes**
- pattern.crl:223/226 → build like `reportExpected`: *"expected a switch pattern, found '"⟨tok⟩"'"* (P0016).
- file.crl:73 → *"unexpected closing token '"⟨tok⟩"' at file scope"* (P0014).
- type.crl:595 → *"expected a type, found '"⟨tok⟩"'"* (P0003).
- expr.crl:831 → *"expected an expression, found '"⟨tok⟩"'"* (P0002).
- decl.crl:458 → *"expected a declaration, found '"⟨tok⟩"'"* (P0004).
- decl.crl:1305 → *"expected a constant name, found '"⟨tok⟩"'"* (P0001, or new P0022 `ParseExpectedDeclaratorName` if you want explain text about `const NAME = …;`).
- recovery.crl:87-107 `expectedTokenText`: add arms for the ~19 keyword/kinds actually `expect`ed → *"expected keyword \`struct\`"* etc.; kills the remaining "expected token" bare texts.

### P10. Variant/tuple miscodes (Group 7 tail) — **no new codes**
- expr.crl:1931 → re-code to `SemaIndexOutOfBounds` (T0013); text *"tuple index "⟨i⟩" is out of range for `"⟨T⟩"` ("⟨n⟩" elements)"*.
- expr.crl:1967 → *"cannot construct with `⟨case⟩`: `⟨T⟩` is not a variant type"*.
- expr.crl:1983 → *"unknown variant case `⟨case⟩` in `⟨T⟩`; expected one of …"* (mirror the pushAvailableFields helper used at 2073).
- stmt.crl:998/1019 → append the name: *"unknown variant `⟨v⟩` in pattern"* / *"unknown field `⟨f⟩` in pattern"*, and list available names like the struct-literal path does.

### P11. Explicit-self second site (Group 10) — **no new code; reword decl.crl:821**
- decl.crl:821 → *"the parameter name \`self\` is reserved; rename it"* (keep P0013).

### P12. Escape-sequence enrichment (Group 12) — **no new code**
- string.crl:29/60, lexer.crl:87 → *"invalid escape sequence \`⟨esc⟩\`"* (byte available from `EscapeResult`).

---

## Vague-wording (secondary)

Ten sites that are weak even read alone:

1. **semantics/expr.crl:1301** — `"static arg type mismatch"` → *"static argument \`⟨n⟩\` of \`⟨f⟩\`: got \`X\`, expected \`Y\`"* (its sibling at 1424 already does this).
2. **semantics/typecheck.crl:580** — `"wrong number of generic arguments"` → *"type \`⟨T⟩\` expects ⟨n⟩ generic arguments, got ⟨m⟩"*.
3. **semantics/expr.crl:273** — `"call to undeclared function"` → name the function.
4. **semantics/expr.crl:161** — `"cannot assign: undeclared identifier"` → name it (compare expr.crl:112 which does).
5. **parser/file.crl:73** — `"unexpected closing token"` → name the token, say "at file scope".
6. **parser/pattern.crl:223/226** — `"expected switch pattern"` → add found-token.
7. **semantics/expr.crl:1983** — `"unknown variant"` → name case + type + candidates.
8. **semantics/expr.crl:461** — `"undeclared module in path"` → name the module.
9. **backend/codegen.crl:3775 / 5431** — `"unsupported expression kind"` / `"unsupported statement kind"` → append the `ExprKind`/`StmtKind` tag name.
10. **parser/type.crl:595 / expr.crl:831** — `"expected a type"` / `"expected an expression"` → add found-token (the parser *already knows how* — recovery.crl:116-133).

Runner-up: **coral-lexer/lexer.crl:108** `"unknown character"` → include the byte/hex, as ident.crl's homoglyph message already does.

---

## Ranked top-20 fixes

| # | file:line (all sites) | shared message/code | verbatim current text | problem class | why insufficient | suggested replacement(s) | new code? |
|---|---|---|---|---|---|---|---|
| 1 | lexer/number.crl:30,34,40,45,83,88,94,156,179,199 | LexInvalidChar / **L0007** | (texts fine; code wrong) | repeated-across-10-situations (code) | every number error renders as "invalid character in token" with token-flavored help/`--explain` | re-route to existing **L0006 LexInvalidNumber** | no (reuse L0006) |
| 2 | semantics/expr.crl 54 sites (esp. 1301,155,52 stmt,277,2380,2417,2473) | SemaTypeMismatch / T0002 | `"static arg type mismatch"`, `"return value type does not match…"`, … | both (catch-all + vague) | T0002's help "convert one side with an explicit cast" is wrong for most of these; bare texts name no types | P6 enrichments via `typeMismatchMsg` | no |
| 3 | semantics/stmt.crl:222,232,245,263 + expr.crl:1489,1491 | "method 'X' not found on type 'T'" / T0006 | `"method 'count' not found on type '"T"'"` etc. | repeated-across-3-situations | protocol-conformance failure disguised as a typo hint | **T0017** "type does not fully implement @iter: missing `⟨m⟩`" (P4) | **yes T0017** |
| 4 | semantics/decl.crl:782,801 + expr.crl:490,1325 | `"symbol not exported by module"` / T0006 | same, ×4 verbatim | repeated-across-4 (context) + vague | names neither symbol nor module; user must guess | context-split name-bearing variants (P5) | no |
| 5 | sema/expr.crl:2227 vs mono/instantiate.crl:766 | @compileError text under **T0002 vs T0014** | user text / `"@compileError tripped"` | both (code split inverted) | cast-conversion help on a comptime failure | re-code 2227 to ComptimeError T0014 (P7) | no |
| 6 | lexer/string.crl:80,94,(131) | LexUnterminatedString / L0002 | `"expected '\"' after R for raw string"`, `"expected '(' in raw string delimiter"` | repeated-across-situations | "close the string with a matching quote" help is wrong for an unopened raw string | **L0008 LexMalformedRawString** (P3) | **yes L0008** |
| 7 | semantics/decl.crl:706,747,776 | SemaUndeclaredIdent / T0001 | `"missing import path"`, `"invalid import path"`, `"invalid module member in import path"` | repeated-across-situations (wrong code) | undeclared-ident explain tells users to check spelling/import modules | **T0018 SemaMalformedImportPath** quoting the path (P8) | **yes T0018** |
| 8 | semantics/typecheck.crl:580 | SemaArityMismatch / T0003 | `"wrong number of generic arguments"` | vague | no counts, no type name | *"type `⟨T⟩` expects ⟨n⟩ generic arguments, got ⟨m⟩"* | no |
| 9 | semantics/expr.crl:161,273,461 | SemaUndeclaredIdent / T0001 | `"cannot assign: undeclared identifier"`, `"call to undeclared function"`, `"undeclared module in path"` | vague | names nothing; inconsistent with expr.crl:112 which names the identifier | name the identifier/module at each site | no |
| 10 | parser/recovery.crl:87-107 (via ~22 keyword `expect` sites) | ParseExpectedToken / P0001 `else` arm | `"expected token"` | repeated-across-N-situations | "expected token, found 'struct'" is useless | *"expected keyword `⟨kw⟩\`"* table arms | no |
| 11 | parser/pattern.crl:223,226 | ParseExpectedSwitchPattern / P0016 | `"expected switch pattern"` ×2 | vague | no found-token (breaks the house style set by reportExpected) | *"expected a switch pattern, found '⟨tok⟩'"* | no |
| 12 | parser/file.crl:73 | ParseUnexpectedClosingToken / P0014 | `"unexpected closing token"` | vague | doesn't name `}`/`)`/`]` or the file-scope context | *"unexpected closing token '⟨tok⟩' at file scope"* | no |
| 13 | sema/expr.crl:1931 | SemaUnknownMember / T0006 | `"tuple index out of range"` | wrong-code + vague | T0006 help says "the type has no member with this name" | re-code T0013; *"tuple index ⟨i⟩ out of range for `struct(…)`"* | no |
| 14 | sema/stmt.crl:165,174,339; expr.crl:1133,1135,2363,2408 | "… must be bool" ×7 / T0002 | `"if condition must be bool"` etc. | repeated-template + vague | never reports the found type; two different truthiness rules share wording | typeMismatchMsg("if condition", found, bool); note expression-form strictness | no |
| 15 | sema/expr.crl:1967,1983; stmt.crl:998,1019 | variant-family / T0006 | `"not a variant type"`, `"unknown variant"`, `"unknown field in pattern"` | vague | no names; no candidate list (struct-literal path already has `pushAvailableFields`) | name case/type; reuse pushAvailableFields | no |
| 16 | parser/decl.crl:770 vs 821 | ParseExplicitSelfParam / P0013 | `"explicit \`self\` parameters are not supported"` ×2 | repeated-across-2-situations | reserved-name case ≠ explicit-receiver case | reword 821: *"the parameter name `self` is reserved"* | no |
| 17 | parser/type.crl:595; expr.crl:831; decl.crl:458 | P0003/P0002/P0004 | `"expected a type"`, `"expected an expression"`, `"expected a declaration: …"` | vague | parser elsewhere appends found-token; these don't | append *", found '⟨tok⟩'"* | no |
| 18 | sema/expr.crl:1570,1631;1586,1647;1949,1961 | payload/variant pairs / T0006 | `"unknown variant case in payload"` etc. ×2 each | borderline (same situation, duplicated text) | text omits the case/field names | merge text; append `⟨case⟩`/`⟨field⟩` names | no |
| 19 | explain.crl:257 (L0008) vs code.crl:102 (E0103) | homoglyph code mismatch | explain keyed to L0008; emitted code is E0103 | both (bookkeeping) | `--explain E0103` falls to the index | re-key explain entry to E0103; frees L0008 (P2) | no |
| 20 | parser/decl.crl:1305 | ParseExpectedToken / P0001 | `"expected a constant name"` | vague | no found-token; const-declarator context lost | *"expected a constant name, found '⟨tok⟩'"* or new P0022 | optional P0022 |

---

## Comparison: clang/rustc

Grounding for the proposals above (wording verified via web):

1. **rustc E0599** — *"no method named `chocolate` found for type `Mouth`"* (dev-doc.rust-lang.org/stable/error_codes/E0599.html). Coral's `"method 'count' not found on type 'T'"` matches the shape — which is exactly why the @iter sites (P4) are wrong: rustc's own tracker (rust-lang/rust#138476, "E0599 message misleads… Maybe split out cases out of E0599?") argues the *same* split Coral needs: a "can't be called / doesn't satisfy the protocol" phrasing instead of "not found".
2. **rustc E0308** — *"mismatched types … expected `i32`, found `&str`"* with a secondary *"expected due to this"* span (E0308 index; rust test stderr). Coral's `typeMismatchMsg` ("…: got `X`, expected `Y`") is the right house style — the bare T0002 texts in the top-20 (##2, ##14) are the outliers to convert.
3. **rustc E0004** — *"non-exhaustive patterns: `HastaLaVistaBaby` not covered"* (E0004 index). Coral's `SemaNonExhaustiveSwitch` message (stmt.crl:1154-1207, *"switch on 'T' is not exhaustive; missing 'A', 'B'"*) already matches this quality bar — listed under "already good".
4. **clang** — *"use of undeclared identifier 'x'"* (clang InternalsManual verify example; ubiquitous). Coral's expr.crl:112 matches; sites 161/273/461 (##9) are the non-matching stragglers.
5. **clang** — *"too few arguments to function call, expected 3, have 2"* (real clang output, xmmintrin.h builds). Coral's arity messages (expr.crl:329 etc.) match; typecheck.crl:580 (##8) lacks the counts.
6. **clang** — *"expected ';' after expression"* (classic clang). Coral's `reportExpected` (recovery.crl:109-134) reproduces this "expected X, found Y" pattern — which is why the bare `"expected a type"`/`"expected switch pattern"` sites (##11, ##17) look inconsistent with the compiler's own best practice.
7. **clang** — *"redefinition of 'x'"* + *"note: previous definition is here"* (CS1010 clang messages digest). Coral's `dupDeclDiag` (sema.crl:625-655) already implements the error+note pair — good.
8. **clang wording doctrine** (clang/docs/InternalsManual.md, "Diagnostic Wording"): *"prefer wording like `missing semicolon` over … `syntax error` (which is not actionable)"*; *"The wording should clearly explain what is wrong … rather than restating what the code does"*; quotes use single quotes. Directly supports ##5 (`"symbol not exported"` → say what to do: mark `pub`), ##12, ##15.
9. **rustc-dev-guide** (diagnostics.md): *"Error messages should be succinct … don't make it so terse that it's hard to understand"*; verbose detail belongs behind `--explain`. Coral's split of msg/help/explain follows this; the failures are where `--explain` describes a *different* situation than the code now carries (L0007-on-numbers, T0002-on-@compileError, L0002-on-raw-strings).
10. **clang** *"too many arguments to function call"*-style cap errors — Coral's backend "too many arguments (cap 16)" (codegen.crl:3163 etc.) is comparable; fine as internal G0002.

---

## Already good

Exemplary messages that the split work should *not* touch:

1. **`reportExpected` output** — *"expected ')', found 'x'"* with 64-byte token cap (recovery.crl:116-133) — clang-quality, one code, situation-specific text.
2. **Field-not-found with discovery help** — *"field 'x' not found on type 'T'"* + *"did you mean 'y'?"* + full available-field list (semantics/expr.crl:1598-1615, and the struct-literal twin at 2052-2074) — rustc-grade.
3. **Non-exhaustive switch** — *"switch on 'Color' is not exhaustive; missing 'Red', 'Green'"* (stmt.crl:1154-1207) — matches rustc E0004.
4. **Arity with counts** — *"wrong number of arguments in call to 'f': expected 2, got 3"* / *"...to method 'push': expected 1, got 2"* (expr.crl:321-329, 1521-1527) — clang "expected N, have M".
5. **Named-parameter mismatch** — *"argument \`width\`: got \`str\`, expected \`i32\`"* via `paramMismatchMsg` (sema.crl:536-573) — rustc expected/found style.
6. **Parameter-list closer** — *"expected ')' to close the parameter list of 'main', found '{'"* (decl.crl:639-647) — names the construct, the owner, and the found token.
7. **Unreachable switch case** — *"unreachable switch case: 'Red' is already covered by an earlier arm"* (stmt.crl:1108-1111).
8. **Initializer naming the variable** — *"initializer for \`count\` does not match its declared type"* (stmt.crl:49-50).
9. **Return-with-no-value** — *"return with no value in function returning 'i32'"* + targeted help (stmt.crl:144-149).
10. **Duplicate declaration + note** — *"duplicate declaration of \`x\`"* + *"previous declaration of \`x\` is here"* (sema.crl:625-655); **conflicting import** message that embeds the fix (decl.crl:675).

---

## Recommended order

Biggest-collision / highest-misdirection first; each step is independently shippable.

1. **P1 — Number lexer → L0006** (10 sites, zero new strings; fixes the largest wrong-code cohort). No table work.
2. **P2 — Homoglyph explain re-key E0103** (bookkeeping; unblocks L0008).
3. **P4 — T0017 @iter conformance** (6 emission sites + backend echoes; add rows: `code.crl` enum + `codeStr`, `msg.crl` severity/format, `error.crl` helpFor, `explain.crl` entry).
4. **P5 — "symbol not exported" name-bearing split** (4 sites; text-only).
5. **P6 — bare T0002 enrichments** (~12 sites; text-only; biggest single-site quality win is expr.crl:1301).
6. **P7 — @compileError → T0014** (1 site; removes a genuine help-text lie).
7. **P8 — import-path shape → T0018 + undeclared-name enrichment** (3 + 4 sites; new code T0018 with `msg.crl`/`helpFor`/`explain` rows; mirrors existing P0011 text).
8. **P3 — L0008 malformed raw string** (2 sites; new code; depends on P2 for clean code-space).
9. **P9 — parser found-token enrichment** (pattern.crl ×2, file.crl, type.crl, expr.crl, decl.crl:458/1305; plus the `expectedTokenText` keyword table — ~22 latent sites).
10. **P10/P11/P12 — tail re-codes and rewords** (tuple index → T0013; variant texts name names; `self`-reserved reword; escape enrichment).

Housekeeping discovered along the way (no message-quality impact, but cheap): `ParseExpectedStmt` (P0005), `ParseMissingSemicolon` (P0009), `ParseInvalidAssignTarget` (P0007), `ParseDuplicateModifier` (P0008) are fully plumbed (code + severity + format + help + explain) but **emitted nowhere** — either wire them (e.g. P0009 could replace generic P0001 at the 16 `expect(Semicolon)` sites, giving semis their own explain text like clang's `expected ';' after …`) or delete them; and explain.crl:77-80's own comment admits the L0004 text ("block comments may nest") is a lie about the non-nesting lexer — fix lexer or text together.

---

**Counts.** Distinct textual emission sites reviewed: **≈199** (lexer 22, parser 29 + ~240 funnel invocations of `expect`/`reportAllocFailed`, semantics ≈101, mono 2, backend 45). Distinct message texts (verbatim strings/templates): **≈160**. Texts or templates shared by ≥2 sites: **~25 groups** (listed above). Largest group by site count: `SemaTypeMismatch` (T0002) at **54 sites**; largest verbatim-identical text group: **4 sites** (three-way tie: "symbol not exported by module", "conflicting import: …", "no monomorphized instance for generic call…"); largest wrong-code cohort: **10 sites** (number literals under L0007). New codes proposed: **3** (T0017, T0018, L0008) plus one re-route onto an existing dead code (L0006).
