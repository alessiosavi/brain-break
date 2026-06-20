#!/usr/bin/env bash
# VirusTotal check, by-hash first (free-tier safe). Never fails the caller.
# Usage: vt-scan.sh <apk> <out-dir>
set -uo pipefail   # intentionally NOT -e: VT issues must not abort
here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=/dev/null
source "$here/lib/vt_parse.sh"

# Soft arg guards: `${1:?}` would exit non-zero, breaking the never-fail contract.
APK="${1:-}"
OUT="${2:-}"
if [ -z "$APK" ] || [ -z "$OUT" ]; then
  echo "[vt] usage: vt-scan.sh <apk> <out-dir>" >&2
  echo "VT_STATE=unknown"
  exit 0
fi
mkdir -p "$OUT"
log() { echo "[vt] $*" >&2; }

SHA256="$(sha256sum "$APK" | cut -d' ' -f1)"
echo "VT_SHA256=${SHA256}"
echo "VT_GUI_URL=https://www.virustotal.com/gui/file/${SHA256}"

if [ -z "${VT_API_KEY:-}" ]; then
  log "VT_API_KEY not set — skipping"
  echo "VT_STATE=unknown"; exit 0
fi

api="https://www.virustotal.com/api/v3/files/${SHA256}"
http="$(curl -s -o "${OUT}/vt.json" -w '%{http_code}' \
  --request GET --url "$api" --header "x-apikey: ${VT_API_KEY}" || echo 000)"
log "by-hash lookup HTTP ${http}"

if [ "$http" = "200" ]; then
  echo "VT_STATE=found"
  vt_counts "${OUT}/vt.json"
  exit 0
fi

if [ "$http" = "404" ]; then
  # Best-effort submit. Large files (>32MB) need upload_url and may 403 on free keys.
  log "not on VT; attempting best-effort submission"
  size="$(stat -f%z "$APK" 2>/dev/null || stat -c%s "$APK" 2>/dev/null || echo 0)"
  if [ "$size" -lt $((32*1024*1024)) ]; then
    up="https://www.virustotal.com/api/v3/files"
  else
    up="$(curl -s --request GET --url https://www.virustotal.com/api/v3/files/upload_url \
          --header "x-apikey: ${VT_API_KEY}" | jq -r '.data // empty')"
  fi
  if [ -n "${up:-}" ] && curl -s --request POST --url "$up" \
       --header "x-apikey: ${VT_API_KEY}" --form "file=@${APK}" -o /dev/null; then
    echo "VT_STATE=pending"
  else
    log "submission unavailable on this key/size"
    echo "VT_STATE=notfound"
  fi
  exit 0
fi

log "unexpected VT response ${http}"
echo "VT_STATE=unknown"
exit 0
