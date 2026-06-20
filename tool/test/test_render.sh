#!/usr/bin/env bash
set -euo pipefail
here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=/dev/null
source "$here/../lib/render.sh"

export TAG=v0.0.2 PKG=com.alessiosavi.brainbreak SCAN_DATE=2026-06-20
export SHA256=deadbeef MOBSF_SCORE=72 MOBSF_HIGH=0 MOBSF_WARNING=2 MOBSF_INFO=1
export VT_STATE=found VT_MALICIOUS=0 VT_SUSPICIOUS=0 VT_HARMLESS=58 VT_UNDETECTED=12
export VT_GUI_URL="https://www.virustotal.com/gui/file/deadbeef"
export MOBSF_IMAGE_DIGEST="opensecurity/...@sha256:abc"

md="$(render_scan_md)"
for needle in "v0.0.2" "deadbeef" "MobSF" "VirusTotal" "0/70" "generato automaticamente" "APK pulito"; do
  echo "$md" | grep -qi "$needle" || { echo "scan_md missing: $needle"; exit 1; }
done

# Findings case: footer must NOT claim "pulito" and SHOULD flag riscontri.
export MOBSF_HIGH=1 VT_MALICIOUS=0 VT_SUSPICIOUS=0
findings_md="$(render_scan_md)"
echo "$findings_md" | grep -qi "riscontri da verificare" || { echo "footer not conditional on findings"; exit 1; }
if echo "$findings_md" | grep -qi "APK pulito"; then echo "footer wrongly claims clean APK despite findings"; exit 1; fi

# Accepted-only case: raw HIGH=1 but gated=0 -> verdict should read clean.
export MOBSF_HIGH=1 MOBSF_HIGH_GATED=0 VT_MALICIOUS=0 VT_SUSPICIOUS=0
accepted_md="$(render_scan_md)"
echo "$accepted_md" | grep -qi "APK pulito" || { echo "gated=0 should render clean verdict"; exit 1; }
if echo "$accepted_md" | grep -qi "riscontri da verificare"; then echo "gated=0 should not flag findings"; exit 1; fi
unset MOBSF_HIGH_GATED

export MOBSF_HIGH=1 VT_MALICIOUS=3
issue="$(render_issue_md)"
echo "$issue" | grep -qi "v0.0.2" || { echo "issue missing tag"; exit 1; }
echo "$issue" | grep -qi "MobSF" || { echo "issue missing mobsf"; exit 1; }
