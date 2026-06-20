#!/usr/bin/env bash
# Gate helpers. No network.
#
# high_unaccepted <scorecard.json> [allowlist-file]
#   Prints the number of MobSF HIGH findings whose title does NOT match any entry
#   in the allowlist (case-insensitive, fixed substring). Findings already triaged
#   and accepted (e.g. in SECURITY.md) are listed in the allowlist so they don't
#   re-open a tracking issue every release. A missing/empty allowlist counts all
#   HIGH findings.
high_unaccepted() {
  local sc="${1:?usage: high_unaccepted <scorecard.json> [allowlist]}"
  local allow="${2:-}"
  local titles
  titles="$(jq -r '(.high // [])[] | (.title // .description // "") | select(length > 0)' "$sc")"
  [ -z "$titles" ] && { echo 0; return 0; }

  if [ -n "$allow" ] && [ -f "$allow" ]; then
    local pats
    pats="$(grep -vE '^[[:space:]]*(#|$)' "$allow" 2>/dev/null || true)"
    if [ -n "$pats" ]; then
      # Keep only titles that match NO allowlist pattern.
      titles="$(printf '%s\n' "$titles" | grep -ivF -f <(printf '%s\n' "$pats") || true)"
    fi
  fi

  [ -z "$titles" ] && { echo 0; return 0; }
  printf '%s\n' "$titles" | grep -c .
}
