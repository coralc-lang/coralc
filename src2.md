  You were right to push back. I was wrong. Let me correct myself with the actual GCC source code.

---

## GCC's Lexer: `>>` is Always `CPP_RSHIFT`

From `libcpp/lex.cc` in GCC:

```c
case'>':
    result->type = CPP_GREATER;
    if (*buffer->cur == '=')
        buffer->cur++, result->type = CPP_GREATER_EQ;
    else if (*buffer->cur == '>')
    {
        buffer->cur++;
        IF_NEXT_IS ('=', CPP_RSHIFT_EQ, CPP_RSHIFT);
    }
    break;
```

The lexer **always** emits `CPP_RSHIFT` for `>>`. It does **not** split it into two `CPP_GREATER` tokens in the lexer. The lexer is context-free.

---

## GCC's Parser: `greater_than_is_operator_p` Handles `>>`

From `gcc/cp/parser.h`:

> *"TRUE if the \`>' token should be interpreted as the greater-than operator. FALSE if it is the end of a template-id or template-parameter-list. In C++0x mode, this flag also applies to \`>>' tokens, which are viewed as two consecutive \`>' tokens when this flag is FALSE."* 

And from `gcc-4.8/gcc/cp/parser.c`:

> *"A '>>' treated like two '>' tokens, in a template-argument-list."* 

So the **parser** has a boolean flag `greater_than_is_operator_p`. When this flag is `false` (inside a template argument list), the parser treats `CPP_RSHIFT` as **two consecutive `>` tokens**. This is done at the parser level, not the lexer level.

---

## How It Actually Works

```c
// In cp_parser_binary_expression, the precedence lookup:
#define TOKEN_PRECEDENCE(token) \
    (((token->type == CPP_GREATER \
       || ((cxx_dialect != cxx98) && token->type == CPP_RSHIFT)) \
      && !parser->greater_than_is_operator_p) \
     ? PREC_NOT_OPERATOR \
     : binops_by_token[token->type].prec)
```

When `greater_than_is_operator_p` is `false`:
- `CPP_GREATER` is **not** an operator (it closes a template list).
- `CPP_RSHIFT` is **not** an operator (it closes two template lists).

The parser effectively splits `>>` into two `>` closes by treating it as having `PREC_NOT_OPERATOR` precedence, which causes it to exit the expression parsing loop.

---

## What I Got Wrong

I claimed GCC's lexer splits `>>` into two `>` tokens. It does not. The lexer emits `CPP_RSHIFT` always. The parser handles the semantic reinterpretation via `greater_than_is_operator_p`.

This is actually **cleaner** than lexer-level splitting because:
- The lexer stays a pure DFA with no parser state.
- The parser controls when `>` means "operator" vs "template close" via a simple boolean flag.
- No token stream rewriting or synthetic token injection needed.

---

## For Coral

Your DFA lexer should emit `RSHIFT` for `>>` always. The parser should have a `greater_than_is_operator_p` equivalent (call it `inGenericContext` or similar). When inside a generic argument list:

- `GT` closes one generic level.
- `RSHIFT` closes two generic levels.
- Neither is treated as a comparison operator.

When outside generics:
- `GT` is the greater-than operator.
- `RSHIFT` is the right-shift operator.

This is the GCC approach, and it's the right one. Thanks for calling me out — I should have checked the source before asserting.

---

## 1. Lexer: Direct-Coded DFA

The lexer is a single function. It owns the source bytes and emits a flat array of tokens. It has **zero parser state**.

### Token
```coral
struct Token {
    TokenKind kind;
    u32 start;      // byte offset into source
    u32 len;
    u32 line;
    u32 col;
}
```

### Token Kinds
Emit these and only these. No context-sensitive tokens.

| Category | Kinds |
|---|---|
| **EOF** | `EOF` |
| **Word** | `IDENT`, `NUMBER`, `STRING` |
| **Keywords** (text-matched after lexing `IDENT`) | `pub`, `struct`, `trait`, `distinct`, `static`, `extern`, `flag`, `constexpr`, `const`, `null`, `true`, `false`, `if`, `else`, `for`, `while`, `return`, `assert`, `mod`, `import`, `asm`, `volatile` |
| **Operators** (maximal munch) | `+`, `-`, `*`, `/`, `%`, `&`, `|`, `^`, `~`, `!`, `=`, `.`, `,`, `;`, `:`, `(`, `)`, `{`, `}`, `[`, `]`, `->`, `::`, `++`, `--`, `<<`, `>>`, `<=`, `>=`, `==`, `!=`, `&&`, `||`, `+=`, `-=`, `*=`, `/=`, `%=`, `&=`, `|=`, `^=`, `<<=`, `>>=` |
| **Comparison** | `<`, `>` |

**Critical rule:** `<` is always `LT`. `>` is always `GT`. `>>` is always `RSHIFT`. The lexer does **not** emit `GENERIC_LT` or split `>>` into two `GT`s. The parser handles generic nesting.

### Lexer Loop (Pseudocode)
```coral
while (pos < srcLen)
{
    ch = src[pos];
    switch (state)
    {
    case START:
        if (isAlpha(ch) || ch == '_')  { state = IDENT; start = pos; }
        else if (isDigit(ch))          { state = NUMBER; start = pos; }
        else if (ch == '"')            { state = STRING; start = pos; }
        else if (ch == '/' && peek(1) == '/') { skipLineComment(); }
        else if (ch == '/' && peek(1) == '*') { skipBlockComment(); }
        else if (isWhitespace(ch))     { pos++; }
        else                           { lexOperator(); }
        break;
    case IDENT:
        while (isAlnum(src[pos])) pos++;
        emit(IDENT);
        state = START;
        break;
    // ... NUMBER, STRING, operators ...
    }
}
```

After emitting `IDENT`, check the text against the keyword table. If it matches `pub`, `struct`, etc., overwrite `kind` to the keyword kind.

### `>>` and Generics
The lexer emits `RSHIFT` as a single token. The parser, when inside a generic argument list, accepts `RSHIFT` as **two closing `>` tokens**. This is exactly what C++11 and Rust do. No lexer hack needed.

---

## 2. Token Stream

The parser holds a reference to the token array and a cursor.

```coral
struct Parser {
    Token* tokens;
    u32 pos;
    u32 count;
    // error state, allocator, etc.
}

Token* peek(u32 offset = 0) { return &tokens[pos + offset]; }
Token* consume()            { return &tokens[pos++]; }
bool   match(TokenKind k)   { if (peek()->kind == k) { pos++; return true; } return false; }

// For tentative parsing / backtracking
u32 save()    { return pos; }
void restore(u32 saved) { pos = saved; }
```

---

## 3. Top-Level: Module

```coral
AstModule* parseModule()
{
    AstModule* mod = newModule();
    while (peek()->kind == KW_IMPORT || peek()->kind == KW_MOD)
        parseImport(mod);
    while (peek()->kind != EOF)
        parseDecl(mod);
    return mod;
}
```

`parseImport` handles both forms:
```coral
mod std = import(lib, "std");
mod std = import("std");
```

---

## 4. Declarations

Every declaration starts with optional `pub`, then a keyword or type.

```coral
AstDecl* parseDecl()
{
    bool isPub = match(KW_PUB);
    
    switch (peek()->kind)
    {
    case KW_STRUCT:   return parseStruct(isPub);
    case KW_TRAIT:    return parseTrait(isPub);
    case KW_EXTERN:   return parseExtern(isPub);
    case KW_FLAG:     return parseFlagBlock(isPub);
    case KW_CONSTEXPR:
    case KW_CONST:    return parseConst(isPub);
    default:
        // Must be a type-start: function, variable, or function-type alias
        return parseTypeStartDecl(isPub);
    }
}
```

### `parseTypeStartDecl` — The Hard One

This handles:
- `void(i32) SigHandler;` — function type alias
- `void(i32) handle(i32 sig, SigHandler* handler) { ... }` — function def
- `i32 x = 5;` — variable
- `Allocator libcAllocator = { ... };` — variable with struct init

Algorithm:
1. Parse the **type** (this may consume generic args: `vec<T>`).
2. Expect an `IDENT` — the name.
3. Lookahead:
   - If next is `(` and the type looks like a function type (ends with `)`), it's a function declaration.
   - If next is `(` and the type is a simple type, it's still a function declaration.
   - If next is `;` or `=`, it's a variable or type alias.
   - If next is `{` and we saw `=`, it's a struct initializer.

Actually, in Coral, `Type Name;` at module scope is ambiguous between variable and type alias. But the parser doesn't need to decide. It emits a `Decl` node with the type, name, and optional init/body. Semantic analysis later determines if `SigHandler` is used as a type.

```coral
AstDecl* parseTypeStartDecl(bool isPub)
{
    AstType* ty = parseType();        // parses `void(i32)`, `vec<T>`, `i32`, etc.
    Token* name = expect(IDENT);
    
    if (match(LPAREN))
    {
        // Function declaration or definition
        AstParam* params = parseParams();
        if (match(LBRACE))
            return parseFuncBody(isPub, ty, name, params);
        expect(SEMI);
        return newFuncDecl(isPub, ty, name, params);
    }
    
    // Variable or type alias
    AstExpr* init = null;
    if (match(ASSIGN))
        init = parseExpr();
    expect(SEMI);
    return newVarDecl(isPub, ty, name, init);
}
```

---

## 5. Type Parsing

Type parsing is **context-sensitive** in one way: inside type context, `IDENT <` is **always** a generic.

```coral
AstType* parseType()
{
    AstType* base = parseBaseType();
    
    // Pointers: postfix *
    while (match(STAR))
        base = newPointerType(base);
    
    return base;
}

AstType* parseBaseType()
{
    if (match(KW_DISTINCT))
    {
        AstType* inner = parseType();
        return newDistinctType(inner);
    }
    
    // Function type: ReturnType(ParamList)
    // But we need to detect if we're at a function type vs a parenthesized type.
    // In Coral, `void(i32)` is a function type. `(i32)` alone is not a valid type.
    // So: if we see a type, then `(`, and the type is not already a function type,
    // and what follows looks like parameters, it's a function type.
    
    AstType* left = parseSimpleType();
    
    if (peek()->kind == LPAREN && isFunctionTypeContext())
    {
        // This is `ReturnType(ParamList)` function type syntax
        consume(); // (
        AstType** params = parseTypeList(); // comma-separated types
        expect(RPAREN);
        return newFunctionType(left, params);
    }
    
    return left;
}

AstType* parseSimpleType()
{
    if (match(KW_VOID) || match(KW_I32) || match(KW_U64) /* etc */)
        return newPrimitiveType(previous());
    
    Token* name = expect(IDENT);
    AstType* ty = newNamedType(name);
    
    // In TYPE CONTEXT, IDENT < is ALWAYS generic
    if (match(LT))
    {
        AstType** args = parseGenericArgs(); // parses types until matching >
        ty = newGenericType(ty, args);
    }
    
    return ty;
}
```

### `parseGenericArgs`

```coral
AstType** parseGenericArgs()
{
    AstType** args = null;
    if (peek()->kind == GT || peek()->kind == RSHIFT)
    {
        // empty: <>
        expectClosingGeneric();
        return args;
    }
    
    do {
        pushGenericDepth();
        args.push(parseType());
        popGenericDepth();
    } while (match(COMMA));
    
    expectClosingGeneric();
    return args;
}

void expectClosingGeneric()
{
    if (match(GT)) return;
    if (match(RSHIFT))
    {
        // >> counts as two > closes. We already consumed one > as RSHIFT.
        // Inject a synthetic GT token so the next peek sees it.
        // Implementation: decrement pos by 1? No, better: set a flag or re-lex.
        // Simpler: don't consume RSHIFT fully. Or: in the token stream,
        // replace RSHIFT with GT and leave a second GT to be consumed next.
        // In practice: unget one GT token.
        ungetGT();
        return;
    }
    error("expected >");
}
```

---

## 6. Expression Parsing: Precedence Climbing

Recursive descent fails for left-associative binary operators. Use precedence climbing (Pratt parsing).

```coral
AstExpr* parseExpr(u32 minPrec = 0)
{
    AstExpr* left = parsePrimary();
    
    while (true)
    {
        Token* op = peek();
        u32 prec = getPrecedence(op->kind);
        if (prec < minPrec) break;
        
        // Check for generic disambiguation: IDENT < might be generic, not less-than
        if (op->kind == LT && left->kind == EXPR_NAME && isGenericFollow())
        {
            // This is handled in parsePrimary or parsePostfix, not here.
            // Actually, generic function calls are postfix, so parsePostfix should handle them.
            break;
        }
        
        consume();
        u32 nextMinPrec = prec + (isRightAssociative(op->kind) ? 0 : 1);
        AstExpr* right = parseExpr(nextMinPrec);
        left = newBinary(op, left, right);
    }
    
    return left;
}
```

### Precedence Table (High to Low)

| Precedence | Operators |
|---|---|
| 12 | `()` `[]` `::` `.` `->` (postfix) |
| 11 | `++` `--` (postfix) |
| 10 | `++` `--` `+` `-` `!` `~` `*` `&` (prefix) |
| 9 | `*` `/` `%` |
| 8 | `+` `-` |
| 7 | `<<` `>>` |
| 6 | `<` `>` `<=` `>=` |
| 5 | `==` `!=` |
| 4 | `&` |
| 3 | `^` |
| 2 | `|` |
| 1 | `&&` |
| 0 | `||` |

Assignment (`=`, `+=`, etc.) is right-associative and sits below `||` or as a separate statement-level parse.

### `parsePrimary` and Postfix

```coral
AstExpr* parsePrimary()
{
    switch (peek()->kind)
    {
    case NUMBER: return newLiteral(consume());
    case STRING: return newLiteral(consume());
    case IDENT:  return parseNameOrGenericOrCall();
    case LPAREN: return parseParenOrCast();
    case KW_NULL: return newNull(consume());
    // ... true, false ...
    default: error("expected expression"); return null;
    }
}

AstExpr* parseNameOrGenericOrCall()
{
    Token* name = expect(IDENT);
    AstExpr* expr = newNameExpr(name);
    
    // Postfix chain: generic, call, field access, index
    while (true)
    {
        if (peek()->kind == LT && isGenericStart(expr))
        {
            // Tentative parse for generic args
            u32 saved = save();
            AstType** args = tryParseGenericArgs();
            if (args != null && isGenericFollow(peek()))
            {
                expr = newGenericExpr(expr, args);
                continue;
            }
            restore(saved);
        }
        
        if (match(LPAREN))
        {
            AstExpr** args = parseArgList();
            expect(RPAREN);
            expr = newCallExpr(expr, args);
            continue;
        }
        
        if (match(DOT))
        {
            Token* field = expect(IDENT);
            expr = newFieldExpr(expr, field);
            continue;
        }
        
        if (match(ARROW))
        {
            Token* field = expect(IDENT);
            expr = newArrowExpr(expr, field);
            continue;
        }
        
        if (match(COLONCOLON))
        {
            Token* assoc = expect(IDENT);
            expr = newAssocExpr(expr, assoc);
            continue;
        }
        
        break;
    }
    
    return expr;
}
```

### Generic Disambiguation: `tryParseGenericArgs`

```coral
AstType** tryParseGenericArgs()
{
    // We are at LT. Try to parse < Type (, Type)* >
    u32 saved = save();
    consume(); // <
    
    AstType** args = null;
    if (peek()->kind == GT || peek()->kind == RSHIFT)
    {
        if (consumeClosingGeneric()) return args;
        restore(saved); return null;
    }
    
    while (true)
    {
        pushGenericDepth();
        AstType* arg = tryParseType(); // parseType but with error recovery to null
        popGenericDepth();
        if (arg == null) { restore(saved); return null; }
        args.push(arg);
        if (match(COMMA)) continue;
        if (peek()->kind == GT || peek()->kind == RSHIFT) break;
        restore(saved); return null;
    }
    
    if (!consumeClosingGeneric()) { restore(saved); return null; }
    return args;
}
```

### `isGenericFollow`

After a successful generic arg parse, the next token must be one of these:

```coral
bool isGenericFollow(Token* tok)
{
    switch (tok->kind)
    {
    case LPAREN:     // foo<T>(args)
    case COLONCOLON: // foo<T>::bar
    case GT:         // nested generic: foo<bar<T>>
    case RSHIFT:     // nested generic: foo<bar<T>> (>> closes two)
    case SEMI:       // type context: vec<T>;
    case COMMA:      // type list:  vec<T>, U
    case RPAREN:     // (vec<T>)
    case RBRACKET:   // arr[vec<T>]
    case ASSIGN:     // type alias or variable init
    case DOT:        // unlikely but possible
    case ARROW:      // unlikely
        return true;
    default:
        return false;
    }
}
```

**In expression context**, be more conservative. Only accept `(`, `::`, `>`, `RSHIFT`. This prevents `a < b > c` from being parsed as a generic.

**In type context**, accept the full set.

---

## 7. Statement Parsing

```coral
AstStmt* parseStmt()
{
    switch (peek()->kind)
    {
    case LBRACE:     return parseBlock();
    case KW_IF:      return parseIf();
    case KW_FOR:     return parseFor();
    case KW_WHILE:   return parseWhile();
    case KW_RETURN:  return parseReturn();
    case KW_ASSERT:  return parseAssert();
    default:
        // Declaration or expression statement
        if (isTypeStart(peek()))
            return parseDeclStmt();
        return parseExprStmt();
    }
}

AstStmt* parseExprStmt()
{
    AstExpr* expr = parseExpr();
    expect(SEMI);
    return newExprStmt(expr);
}

AstStmt* parseIf()
{
    consume(); // if
    expect(LPAREN);
    AstExpr* cond = parseExpr();
    expect(RPAREN);
    AstStmt* thenBranch = parseStmt();
    AstStmt* elseBranch = null;
    if (match(KW_ELSE))
        elseBranch = parseStmt();
    return newIf(cond, thenBranch, elseBranch);
}
```

---

## 8. `flag` Blocks

```coral
AstFlag* parseFlagBlock(bool isPub)
{
    consume(); // flag
    expect(LPAREN);
    Token* cond = expect(IDENT); // platform, ARCH, etc.
    expect(RPAREN);
    expect(LBRACE);
    
    AstFlagCase** cases = null;
    while (peek()->kind == IDENT)
    {
        Token* label = consume();
        expect(COLON);
        AstDecl** body = null;
        while (!isFlagCaseStart(peek()) && peek()->kind != RBRACE)
            body.push(parseDecl());
        cases.push(newFlagCase(label, body));
    }
    expect(RBRACE);
    return newFlagBlock(isPub, cond, cases);
}
```

---

## 9. `asm volatile`

```coral
AstAsm* parseAsm()
{
    consume(); // asm
    bool isVolatile = match(KW_VOLATILE);
    expect(LBRACE);
    
    // Parse asm body: string literals, constraints, etc.
    // For now, just collect string tokens until }
    while (peek()->kind != RBRACE && peek()->kind != EOF)
        consume();
    
    expect(RBRACE);
    return newAsm(isVolatile);
}
```

---

## 10. Error Recovery: Panic Mode

When `expect()` fails or `parseType()` hits garbage:

```coral
void error(const char* msg)
{
    report(msg, peek()->line, peek()->col);
    panicMode = true;
}

void synchronize()
{
    if (!panicMode) return;
    panicMode = false;
    
    while (peek()->kind != EOF)
    {
        if (previous()->kind == SEMI) return;
        switch (peek()->kind)
        {
        case KW_PUB:
        case KW_STRUCT:
        case KW_TRAIT:
        case KW_EXTERN:
        case KW_FLAG:
        case KW_CONST:
        case KW_CONSTEXPR:
        case RBRACE:
            return;
        }
        consume();
    }
}
```

Call `synchronize()` at the start of `parseDecl()`, `parseStmt()`, and after any `expect()` that fails.

---

## Summary: The Pipeline

| Stage | Responsibility | Key Rule |
|---|---|---|
| **Lexer** | Bytes → Tokens | DFA, no parser state, `>>` = `RSHIFT` |
| **Token Stream** | Lookahead, backtracking | `save()` / `restore()` for tentative parsing |
| **Type Parser** | Types, generics | In type context, `IDENT <` is always generic |
| **Expr Parser** | Precedence climbing | `IDENT <` is generic only if tentative parse succeeds + follow set matches |
| **Decl Parser** | Top-level, structs, functions | `Type Name` disambiguation by lookahead: `(` = function, `;`/`=` = variable |
| **Stmt Parser** | Control flow | Sync on `;`, `}`, or declaration keywords |
| **Error Recovery** | Panic mode, skip to sync point | Don't cascade errors |

This architecture eliminates the GLR state explosion. The lexer is a pure DFA. The parser is recursive descent with one localized backtracking point (generic args in expressions). Everything else is single-pass with bounded lookahead.