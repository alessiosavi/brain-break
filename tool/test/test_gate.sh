#!/usr/bin/env bash
set -euo pipefail
here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=/dev/null
source "$here/../lib/gate.sh"

sc_high="$here/fixtures/scorecard-high.json"   # 2 HIGH: minSdk + cleartext
sc_clean="$here/fixtures/scorecard.json"        # 0 HIGH
allow="$here/fixtures/accepted.txt"             # allowlists "minSdk=24"

eq() { [ "$1" = "$2" ] || { echo "expected '$2', got '$1' ($3)"; exit 1; }; }

eq "$(high_unaccepted "$sc_high" "$allow")"  1 "minSdk accepted -> 1 remains"
eq "$(high_unaccepted "$sc_high")"           2 "no allowlist -> both count"
eq "$(high_unaccepted "$sc_high" "$here/fixtures/does-not-exist.txt")" 2 "missing allowlist -> both count"
eq "$(high_unaccepted "$sc_clean" "$allow")" 0 "no HIGH -> 0"
echo "gate ok"
