#!/usr/bin/env bash
set -euo pipefail

IMAGE="${1:-xtide:test}"

# Run CLI tests inside a single container
docker run --rm "$IMAGE" sh -c '
  pass=0
  fail=0

  run_test() {
    name="$1"; shift
    printf "%-40s" "$name"
    if "$@" >/dev/null 2>&1; then
      echo "PASS"
      pass=$((pass + 1))
      return
    fi
    echo "FAIL"
    fail=$((fail + 1))
  }

  run_test "tide -v prints version" \
    tide -v

  run_test "tide produces predictions" \
    sh -c "tide -l \"San Francisco\" -pi 1 | grep -q \"High Tide\""

  run_test "tide outputs PNG graph" \
    sh -c "tide -l \"San Francisco\" -m g -f p -pi 1 > /tmp/graph.png && test -s /tmp/graph.png"

  run_test "restore_tide_db runs" \
    sh -c "restore_tide_db 2>&1 | grep -q tcd-utils"

  run_test "build_tide_db runs" \
    sh -c "build_tide_db 2>&1 | grep -q tcd-utils"

  [ "$fail" -eq 0 ]
'

# xttpd needs network testing from the host (no curl/wget in the image)
CONTAINER=""
cleanup() { [ -n "$CONTAINER" ] && docker rm -f "$CONTAINER" >/dev/null 2>&1 || true; }
trap cleanup EXIT

printf "%-40s" "xttpd serves HTTP"
CONTAINER=$(docker run -d -p 8080:8080 "$IMAGE" xttpd 8080 2>/dev/null)
sleep 3
if curl -sf http://localhost:8080/ | grep -q "XTide Tide Prediction Server"; then
  echo "PASS"
else
  echo "FAIL"
  exit 1
fi
