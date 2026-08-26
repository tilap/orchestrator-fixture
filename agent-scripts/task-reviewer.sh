#!/usr/bin/env bash
#
# A deterministic stand-in for the reviewer role. It modifies nothing; its only
# function is a verdict a machine can act on.

set -uo pipefail

control_file="$ORCH_WORKTREE/../../run/fixture-control"
mode="ok"
if [ -f "$control_file" ]; then
  found="$(grep -E "^$ORCH_TASK[[:space:]]+reviewer=" "$control_file" 2>/dev/null | head -1 || true)"
  [ -n "$found" ] && mode="${found##*=}"
fi

case "$mode" in
  fail)
    echo "FAIL"
    echo "1. The implementation contradicts docs/ARCHITECTURE.md: a lower layer decides how a failure is presented."
    echo "2. An acceptance criterion of the contract has no corresponding behaviour."
    exit 0
    ;;
  garbage)
    echo "Looks good to me overall, ship it."
    exit 0
    ;;
  both)
    echo "PASS"
    echo "FAIL"
    exit 0
    ;;
esac

echo "PASS"
