#!/usr/bin/env python3
# semantic_eq.py A B — true when A and B are the same module, up to
# alpha-equivalence (instruction/ssa names renumbered) and in-place
# swaps of operands of commutative opcodes (add/mul/and/or/xor/min/max/
# fadd/fmul). Renaming-only drift is invisible; opcode swaps in non-
# commutative ops are always a real difference.
import sys, re

tok = re.compile(r'%[A-Za-z_][A-Za-z0-9_.$]*')
comm = re.compile(r'(add|fadd|mul|fmul|and|or|xor|smin|smax|umin|umax) (i[0-9]+|f16|f32|f64|bf16) (%%x|%[0-9]+), (%%x|%[0-9]+)')

def normalize(text):
    order = {}
    def repl(m):
        v = m.group(0)
        if v not in order:
            order[v] = len(order)
        return '%{}'.format(order[v])
    text = tok.sub(repl, text)
    def sort_args(m):
        op, ty, a, b = m.groups()
        if a > b:
            a, b = b, a
        return '{} {} {}, {}'.format(op, ty, a, b)
    text = comm.sub(sort_args, text)
    return text

a, b = sys.argv[1], sys.argv[2]
sys.exit(0 if normalize(open(a).read()) == normalize(open(b).read()) else 1)
