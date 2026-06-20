#!/usr/bin/env bash
# MobSF static analysis via REST. Network orchestration only; parsing in tool/lib.
# Usage: mobsf-scan.sh <apk> <out-dir>
set -euo pipefail
here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=/dev/null
source "$here/lib/mobsf_parse.sh"

APK="${1:?usage: mobsf-scan.sh <apk> <out-dir>}"
OUT="${2:?usage: mobsf-scan.sh <apk> <out-dir>}"
MOBSF_URL="${MOBSF_URL:-http://localhost:8000}"
: "${MOBSF_API_KEY:?MOBSF_API_KEY is required}"
mkdir -p "$OUT"
log() { echo "[mobsf] $*" >&2; }
auth=(-H "Authorization: ${MOBSF_API_KEY}")

log "waiting for MobSF at ${MOBSF_URL}"
ready=0
for _ in $(seq 1 60); do
  code="$(curl -s -o /dev/null -w '%{http_code}' "${MOBSF_URL}/" || true)"
  [ "$code" = "200" ] && { ready=1; break; }
  sleep 3
done
[ "$ready" -eq 1 ] || { log "MobSF never became ready"; exit 1; }

log "uploading APK"
hash="$(curl -s -X POST "${MOBSF_URL}/api/v1/upload" "${auth[@]}" \
  -F "file=@${APK};type=application/octet-stream" | jq -r '.hash // empty')"
[ -n "$hash" ] || { log "upload failed (no hash)"; exit 1; }

log "scanning (synchronous; may take minutes)"
curl -s -X POST "${MOBSF_URL}/api/v1/scan" "${auth[@]}" \
  --data-urlencode "hash=${hash}" --max-time 1800 > "${OUT}/report.json"

log "fetching scorecard + pdf"
curl -s -X POST "${MOBSF_URL}/api/v1/scorecard" "${auth[@]}" \
  --data-urlencode "hash=${hash}" > "${OUT}/scorecard.json"
curl -s -X POST "${MOBSF_URL}/api/v1/download_pdf" "${auth[@]}" \
  --data-urlencode "hash=${hash}" -o "${OUT}/report.pdf"

# Guard: MobSF can return a JSON error object (e.g. {"error":"..."}) with HTTP 200
# from /scorecard. That parses to HIGH=0 and would make the security gate go GREEN
# on a failed scan. A real scorecard always carries the finding arrays; an error
# object does not. Fail loudly instead of reporting a false clean result.
if ! jq -e '(has("error")|not) and has("high")' "${OUT}/scorecard.json" >/dev/null 2>&1; then
  log "scorecard is not a valid MobSF scorecard (error/empty response):"
  cat "${OUT}/scorecard.json" >&2 || true
  exit 1
fi

mobsf_counts "${OUT}/scorecard.json"   # key=value to stdout
