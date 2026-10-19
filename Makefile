# coralc — build the compiler executables from the packaged C sources.
#
#   make            build the host executable (linux on Linux, windows on Windows)
#   make linux      build dist/coralc-linux-x86_64 from dist/coralc-linux.c
#   make windows    build dist/coralc-windows-x86_64.exe from dist/coralc-windows.c
#   make install    install the host executable + lib/ into $(PREFIX) (default ~/.coral)
#   make package    regenerate dist/coralc-{linux,windows}.c (internal, no binaries)
#   make clean      remove built executables (the C sources are kept)
#
# The C sources carry the default std platform baked at package time;
# --platform overrides it at run time.

ifeq ($(OS),Windows_NT)
  HOST     := windows
  EXE      := .exe
  HOST_BIN := dist/coralc-windows-x86_64.exe
  MINGW    ?= gcc
else
  HOST     := linux
  EXE      :=
  HOST_BIN := dist/coralc-linux-x86_64
  MINGW    ?= x86_64-w64-mingw32-gcc
endif

CC     ?= cc
PREFIX ?= $(HOME)/.coral

.PHONY: all linux windows install package clean

all: $(HOST)

linux: dist/coralc-linux-x86_64

windows: dist/coralc-windows-x86_64.exe

dist/coralc-linux.c:
	@echo "error: $@ is missing; run ./package.sh on a build host" >&2
	@exit 1

dist/coralc-windows.c:
	@echo "error: $@ is missing; run ./package.sh on a build host" >&2
	@exit 1

dist/coralc-linux-x86_64: dist/coralc-linux.c
	$(CC) -std=gnu11 -O0 -o $@ $< -lm

dist/coralc-windows-x86_64.exe: dist/coralc-windows.c
	@command -v "$(MINGW)" >/dev/null 2>&1 || { \
		echo "error: $(MINGW) not found (install mingw-w64 or w64devkit)"; exit 1; }
	$(MINGW) -std=gnu11 -O0 -o $@ $< -lm

install: $(HOST)
	mkdir -p "$(PREFIX)/bin"
	cp "$(HOST_BIN)" "$(PREFIX)/bin/coralc$(EXE)"
	rm -rf "$(PREFIX)/lib"
	cp -R lib "$(PREFIX)/lib"

package:
	./package.sh

clean:
	rm -f dist/coralc-linux-x86_64 dist/coralc-windows-x86_64.exe
