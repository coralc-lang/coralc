#!/usr/bin/env python3
"""Structural checker for coral files: strip comments/strings/char lits,
then verify (), [], {} balance with a stack. Prints PASS or the failure."""
import sys


def check(path):
    src = open(path, encoding="utf-8", errors="replace").read()
    i, n = 0, len(src)
    line = 1
    stack = []
    pairs = {")": "(", "]": "[", "}": "{"}
    opens = set(pairs.values())
    while i < n:
        c = src[i]
        if c == "\n":
            line += 1
            i += 1
            continue
        if c == "/" and i + 1 < n and src[i + 1] == "/":
            while i < n and src[i] != "\n":
                i += 1
            continue
        if c == "/" and i + 1 < n and src[i + 1] == "*":
            i += 2
            while i + 1 < n and not (src[i] == "*" and src[i + 1] == "/"):
                if src[i] == "\n":
                    line += 1
                i += 1
            i = min(i + 2, n)
            continue
        if c == '"':
            i += 1
            while i < n and src[i] != '"':
                if src[i] == "\\":
                    i += 1
                elif src[i] == "\n":
                    print(f"{path}:{line}: unterminated string")
                    return False
                i += 1
            i += 1
            continue
        if c == "'":
            i += 1
            while i < n and src[i] != "'":
                if src[i] == "\\":
                    i += 1
                elif src[i] == "\n":
                    print(f"{path}:{line}: unterminated char literal")
                    return False
                i += 1
            i += 1
            continue
        if c in opens:
            stack.append((c, line))
            i += 1
            continue
        if c in pairs:
            if not stack or stack[-1][0] != pairs[c]:
                print(f"{path}:{line}: unmatched '{c}' (stack top: {stack[-1] if stack else 'empty'})")
                return False
            stack.pop()
            i += 1
            continue
        i += 1
    if stack:
        print(f"{path}:{stack[-1][1]}: unclosed '{stack[-1][0]}'")
        return False
    print(f"PASS {path}")
    return True


ok = True
for p in sys.argv[1:]:
    if not check(p):
        ok = False
sys.exit(0 if ok else 1)
