#!/usr/bin/env bash
# Pure parsing of a MobSF scorecard JSON. No network.
# mobsf_counts <scorecard.json> -> prints MOBSF_SCORE/HIGH/WARNING/INFO=<int>
mobsf_counts() {
  local f="${1:?mobsf_counts <scorecard.json>}"
  local score high warning info
  score="$(jq -r '.security_score // 0'        "$f")"
  high="$(jq -r   '(.high    // []) | length'  "$f")"
  warning="$(jq -r '(.warning // []) | length' "$f")"
  info="$(jq -r   '(.info    // []) | length'  "$f")"
  printf 'MOBSF_SCORE=%s\n'   "$score"
  printf 'MOBSF_HIGH=%s\n'    "$high"
  printf 'MOBSF_WARNING=%s\n' "$warning"
  printf 'MOBSF_INFO=%s\n'    "$info"
}
