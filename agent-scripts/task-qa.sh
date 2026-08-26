#!/usr/bin/env bash
#
# A deterministic stand-in for QA: it runs the suite and answers on the
# functional axis, where the reviewer answers on conformity to the PRD and the
# architecture.

set -uo pipefail

control_file="$ORCH_WORKTREE/../../run/fixture-control"
mode="ok"
if [ -f "$control_file" ]; then
  found="$(grep -E "^$ORCH_TASK[[:space:]]+qa=" "$control_file" 2>/dev/null | head -1 || true)"
  [ -n "$found" ] && mode="${found##*=}"
fi

if [ "$mode" = "fail" ]; then
  echo "FAIL"
  echo "1. An acceptance criterion of the contract is not covered by any test."
  exit 0
fi

if npm run test --silent >/dev/null 2>&1 && npm run lint --silent >/dev/null 2>&1; then
  echo "PASS"
else
  echo "FAIL"
  echo "1. The validation suite does not pass on this branch."
fi
