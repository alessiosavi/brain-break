#!/usr/bin/env bash
# http_up <curl-http-code> -> 0 if the server is responding, else 1.
# A web server that is up answers with a real HTTP status. We treat any 2xx/3xx
# as "up": MobSF's '/' is @login_required and returns 302, and '/login/' returns
# 200 — so requiring a strict 200 on '/' would wait forever on the redirect.
# 000 (connection refused), 4xx and 5xx are treated as "not ready yet".
http_up() {
  case "${1:-}" in
    2??|3??) return 0 ;;
    *)       return 1 ;;
  esac
}
