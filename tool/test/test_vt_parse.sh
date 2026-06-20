#!/usr/bin/env bash
set -euo pipefail
here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=/dev/null
source "$here/../lib/vt_parse.sh"

out="$(vt_counts "$here/fixtures/vt-found.json")"
assert() { echo "$out" | grep -qx "$1" || { echo "MISSING: $1"; echo "GOT:"; echo "$out"; exit 1; }; }
assert "VT_MALICIOUS=0"
assert "VT_SUSPICIOUS=0"
assert "VT_HARMLESS=58"
assert "VT_UNDETECTED=12"

# Empty/absent stats default to 0 (capture first: grep -q on a live pipe would
# SIGPIPE vt_counts mid-run under `set -o pipefail`).
tmp="$(mktemp)"; echo '{}' > "$tmp"
defout="$(vt_counts "$tmp")"
echo "$defout" | grep -qx "VT_MALICIOUS=0" || { echo "default failed"; exit 1; }
