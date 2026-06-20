#!/usr/bin/env bash
# Discovers and runs every tool/test/test_*.sh. Each test script exits non-zero on failure.
set -euo pipefail
here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
fail=0
for t in "$here"/test_*.sh; do
  [ -e "$t" ] || continue
  echo "== $(basename "$t") =="
  if bash "$t"; then echo "  PASS"; else echo "  FAIL"; fail=1; fi
done
exit "$fail"
