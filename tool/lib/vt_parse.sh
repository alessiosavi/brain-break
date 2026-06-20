#!/usr/bin/env bash
# Pure parsing of a VirusTotal v3 file-info JSON. No network.
# vt_counts <vt.json> -> prints VT_MALICIOUS/SUSPICIOUS/HARMLESS/UNDETECTED=<int>
vt_counts() {
  local f="${1:?vt_counts <vt.json>}"
  local base='.data.attributes.last_analysis_stats'
  printf 'VT_MALICIOUS=%s\n'  "$(jq -r "(${base}.malicious  // 0)" "$f")"
  printf 'VT_SUSPICIOUS=%s\n' "$(jq -r "(${base}.suspicious // 0)" "$f")"
  printf 'VT_HARMLESS=%s\n'   "$(jq -r "(${base}.harmless   // 0)" "$f")"
  printf 'VT_UNDETECTED=%s\n' "$(jq -r "(${base}.undetected // 0)" "$f")"
}
