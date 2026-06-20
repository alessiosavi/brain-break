#!/usr/bin/env bash
# EXPERIMENTAL: MobSF dynamic analysis driven from inside android-emulator-runner.
# Best-effort: prints diagnostics but each external call tolerates failure.
# Usage: mobsf-dynamic.sh <apk> <out-dir>
set -uo pipefail
APK="${1:?usage: mobsf-dynamic.sh <apk> <out-dir>}"
OUT="${2:?usage: mobsf-dynamic.sh <apk> <out-dir>}"
mkdir -p "$OUT"
: "${MOBSF_API_KEY:?MOBSF_API_KEY required}"
MOBSF="${MOBSF_URL:-http://127.0.0.1:8000}"
H=(-H "X-Mobsf-Api-Key: ${MOBSF_API_KEY}")
log() { echo "[dyn] $*" >&2; }

log "preparing rooted, writable device over TCP"
adb wait-for-device
adb root || log "adb root failed (non-playstore image required)"
sleep 5; adb wait-for-device
adb remount || true
adb tcpip 5555 || true
sleep 3
adb connect 127.0.0.1:5555 || true
adb devices >&2

log "starting MobSF (host networking so it can reach host adb)"
docker run -d --name mobsf --network host \
  -e MOBSF_API_KEY="$MOBSF_API_KEY" \
  -e MOBSF_ANALYZER_IDENTIFIER=127.0.0.1:5555 \
  opensecurity/mobile-security-framework-mobsf:latest

for _ in $(seq 1 60); do
  [ "$(curl -s -o /dev/null -w '%{http_code}' "${MOBSF}/" || true)" = "200" ] && break
  sleep 3
done

hash="$(curl -s -X POST "${MOBSF}/api/v1/upload" "${H[@]}" \
  -F "file=@${APK};type=application/octet-stream" | jq -r '.hash // empty')"
[ -n "$hash" ] || { log "upload failed"; exit 0; }   # exit 0: experimental
curl -s -X POST "${MOBSF}/api/v1/scan"                  "${H[@]}" --data-urlencode "hash=${hash}" --max-time 1800 >/dev/null || true

log "dynamic: start"
curl -s -X POST "${MOBSF}/api/v1/dynamic/start_analysis" "${H[@]}" --data-urlencode "hash=${hash}" || true
sleep 20
log "exercise all activities (test=activity => else-branch => ALL)"
curl -s -X POST "${MOBSF}/api/v1/android/activity"       "${H[@]}" --data-urlencode "hash=${hash}" --data-urlencode "test=activity" || true
curl -s -X POST "${MOBSF}/api/v1/android/activity"       "${H[@]}" --data-urlencode "hash=${hash}" --data-urlencode "test=exported" || true
curl -s -X POST "${MOBSF}/api/v1/android/tls_tests"      "${H[@]}" --data-urlencode "hash=${hash}" || true
sleep 10
log "dynamic: stop"
curl -s -X POST "${MOBSF}/api/v1/dynamic/stop_analysis"  "${H[@]}" --data-urlencode "hash=${hash}" || true
curl -s -X POST "${MOBSF}/api/v1/dynamic/report_json"    "${H[@]}" --data-urlencode "hash=${hash}" -o "${OUT}/dynamic-report.json" || true
curl -s -X POST "${MOBSF}/api/v1/download_pdf"           "${H[@]}" --data-urlencode "hash=${hash}" -o "${OUT}/report.pdf" || true
log "done (experimental — see ${OUT})"
