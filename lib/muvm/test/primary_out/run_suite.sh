#!/bin/bash
T=./primary_out/muvm_tool
PASS=0; FAIL=0; SKIP=0
for ir in cases/cases_aa/*.ir; do
  n=$(basename "$ir" .ir)
  $T "$ir" x O2 --module --emit-asm --arch x86_64 --os linux --backend primary 2>/dev/null > primary_out/$n.s
  if [ ! -s primary_out/$n.s ]; then SKIP=$((SKIP+1)); continue; fi
  if ! as --64 -o primary_out/$n.o primary_out/$n.s 2>primary_out/$n.err; then echo "ASM-FAIL $n"; FAIL=$((FAIL+1)); continue; fi
  if ! gcc -no-pie -o primary_out/$n primary_out/$n.o 2>/dev/null; then echo "LINK-FAIL $n"; FAIL=$((FAIL+1)); continue; fi
  primary_out/$n >/dev/null 2>&1; pe=$?
  $T "$ir" x O2 --module --emit-asm --arch x86_64 --os linux --backend fast 2>/dev/null > primary_out/${n}_f.s
  as --64 -o primary_out/${n}_f.o primary_out/${n}_f.s 2>/dev/null && gcc -no-pie -o primary_out/${n}_f primary_out/${n}_f.o 2>/dev/null
  primary_out/${n}_f >/dev/null 2>&1; fe=$?
  if [ "$pe" = "$fe" ]; then PASS=$((PASS+1)); else echo "DIFF $n primary=$pe fast=$fe"; FAIL=$((FAIL+1)); fi
done
echo "pass=$PASS fail=$FAIL skip=$SKIP"
