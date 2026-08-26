#!/usr/bin/env bash
#
# A deterministic stand-in for the builder role.
#
# It does everything the real builder does except judge: it writes the code,
# runs the whole validation suite, commits, and answers in the rigid format of
# section 5.2. What it adds is a knob — run/fixture-control lets any run be
# turned into an escalation, a hang, a red suite reported green, or a scope
# violation, on demand and for free.
#
# Nothing downstream can tell its commits from an agent's. That is the point.

set -uo pipefail

control_file="$ORCH_WORKTREE/../../run/fixture-control"
mode="ok"
if [ -f "$control_file" ]; then
  found="$(grep -E "^$ORCH_TASK[[:space:]]+builder=" "$control_file" 2>/dev/null | head -1 || true)"
  [ -n "$found" ] && mode="${found##*=}"
fi

case "$mode" in
  escalate)
    echo "ESCALATE: AMBIGUOUS"
    echo "WHY: the contract asks for behaviour the architecture forbids, and no higher source resolves it."
    exit 0
    ;;
  hang)
    sleep 100000
    ;;
  no-commit)
    echo "DONE"
    echo "ACCEPTANCE"
    echo "- everything → trust me"
    exit 0
    ;;
  garbage)
    echo "I have finished the task, I think it went well overall."
    exit 0
    ;;
esac

impl="$(dirname "${BASH_SOURCE[0]}")/impl/$ORCH_TASK.sh"
if [ ! -f "$impl" ]; then
  echo "ESCALATE: BLOCKED"
  echo "WHY: no implementation is known for $ORCH_TASK in this bench."
  exit 0
fi

bash "$impl" || {
  echo "ESCALATE: BLOCKED"
  echo "WHY: the implementation step failed before any validation ran."
  exit 0
}

# A task that writes outside its declared scope. The mechanical check of section
# 9.1 closes on it before a reviewer is ever asked for an opinion.
if [ "$mode" = "out-of-scope" ]; then
  echo "// written by a task that had no business here" >> AGENTS.md
fi

# The same entry point CI runs, reading the same orchestrator.toml.
validation_failed=0
failed_name=""
if ! node scripts/validate.mjs >/dev/null 2>&1; then
  validation_failed=1
  failed_name="the validation suite"
fi

git add -A
git commit -q -m "$ORCH_TASK: implement the contract" || true
sha="$(git rev-parse HEAD)"

# Reporting DONE on a red suite is the builder failure that costs the most: it
# reaches review, gets rejected, and comes back with the real failure buried
# under a review cycle. The bench needs to be able to produce it on purpose.
if [ "$validation_failed" -eq 1 ] && [ "$mode" != "dirty" ]; then
  echo "ESCALATE: BLOCKED"
  echo "WHY: $failed_name does not pass and the contract gives nothing that would fix it."
  exit 0
fi

echo "DONE"
echo "COMMIT: $sha"
echo "ACCEPTANCE"
echo "- every criterion of $ORCH_TASK → verified by the validation suite"
echo "VALIDATION"
echo "- the full suite from orchestrator.toml → pass"
