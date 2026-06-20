#!/usr/bin/env bash
set -euo pipefail
here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=/dev/null
source "$here/../lib/mobsf_parse.sh"

out="$(mobsf_counts "$here/fixtures/scorecard.json")"
assert() { echo "$out" | grep -qx "$1" || { echo "MISSING: $1"; echo "GOT:"; echo "$out"; exit 1; }; }
assert "MOBSF_SCORE=72"
assert "MOBSF_HIGH=0"
assert "MOBSF_WARNING=2"
assert "MOBSF_INFO=1"

# Missing arrays default to 0, not error
tmp="$(mktemp)"; echo '{"security_score":0}' > "$tmp"
out="$(mobsf_counts "$tmp")"
echo "$out" | grep -qx "MOBSF_HIGH=0" || { echo "missing-array default failed"; exit 1; }
