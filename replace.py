#!/usr/bin/env python3
import os
import re
import sys

ROOT = sys.argv[1] if len(sys.argv) > 1 else "."
DRY_RUN = "--dry-run" in sys.argv
EXTENSIONS = None  # e.g. {".js", ".ts"} to restrict; None = all text files
SKIP_DIRS = {".git", "node_modules", ".venv", "__pycache__", ".idea", ".vscode"}

# Strings are matched first and left untouched; the target is matched only outside them.
PATTERN = re.compile(
    r"""
    (?P<string>
        "(?:\\.|[^"\\\n])*"      # double-quoted
      | '(?:\\.|[^'\\\n])*'      # single-quoted
      | `(?:\\.|[^`\\])*`        # backtick (can span lines)
    )
    |
    (?P<target>\bimport\s*\(\s*lib\s*\))
    """,
    re.VERBOSE,
)

def replace(match):
    return match.group("string") or "_Import_Lib"

def is_binary(path):
    with open(path, "rb") as f:
        return b"\0" in f.read(4096)

def process(path):
    try:
        if is_binary(path):
            return
        with open(path, "r", encoding="utf-8", newline="") as f:
            text = f.read()
    except (UnicodeDecodeError, OSError):
        return

    new_text = PATTERN.sub(replace, text)
    if new_text != text:
        print(("[dry-run] " if DRY_RUN else "updated: ") + path)
        if not DRY_RUN:
            with open(path, "w", encoding="utf-8", newline="") as f:
                f.write(new_text)

for dirpath, dirnames, filenames in os.walk(ROOT):
    dirnames[:] = [d for d in dirnames if d not in SKIP_DIRS]
    for name in filenames:
        if EXTENSIONS and os.path.splitext(name)[1] not in EXTENSIONS:
            continue
        process(os.path.join(dirpath, name))
