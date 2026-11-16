#!/bin/bash
# Module-stage runner: same driver contract as run.sh, but each case is
# fed through muvm_tool --module (module inline + IPA + per-function
# optimize). Keep this separate so the function-stage goldens in
# expected/ remain untouched.
set -u
cd "$(dirname "$0")"
MODE=module CASES=cases_module EXTRA_CASES= EXPECTED=expected_module OUT=output_module exec ./run.sh "$@"
