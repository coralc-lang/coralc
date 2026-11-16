#!/bin/bash
rm -rf ~/.coral/lib && cp -r /home/cerie/Documents/coral/lib ~/.coral/
rm -f ~/.coral/bin/coralc && cp -r /home/cerie/Documents/coral/compiler/build/coralc ~/.coral/bin

echo "Replace done successfully"
rm -f muvm_tool

coralc /home/cerie/Documents/coral/test/muvm/muvm_tool.crl -o muvm_tool
