#!/usr/bin/env bash
set -euo pipefail
here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=/dev/null
source "$here/../lib/http.sh"

# "Server is up" = any 2xx/3xx (MobSF '/' is @login_required -> 302; '/login/' -> 200).
for up in 200 201 204 301 302 308; do
  http_up "$up" || { echo "expected UP for $up"; exit 1; }
done
# Not up: connection refused (000), server errors (5xx), client errors (4xx), empty.
for down in 000 400 401 403 404 500 502 503 ""; do
  if http_up "$down"; then echo "expected DOWN for '$down'"; exit 1; fi
done
echo "http_up predicate ok"
