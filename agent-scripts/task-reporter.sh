#!/usr/bin/env bash
#
# A deterministic stand-in for the reporter role.
#
# It cannot distil — distilling is judgement, and this script has none. What it
# can do is prove the channel: the orchestrator hands it the record, it answers
# in the expected shape, and the report lands where a human will look for it.
# That is what section 15.1 needs exercised on a bench: the escalation reaching
# somebody, not the quality of the prose.

set -uo pipefail

# The orchestrator numbers the findings it hands over, so these labels sit after
# a "1. " rather than at the start of the line.
trigger="$(printf '%s\n' "$ORCH_PROMPT" | sed -n 's/.*Escalation trigger: \([A-Z_]*\).*/\1/p' | head -1)"
attempts="$(printf '%s\n' "$ORCH_PROMPT" | sed -n 's/.*Real failures: \([0-9]*\).*/\1/p' | head -1)"

cat <<EOF
## What was asked

$ORCH_TASK, as its contract states it. See \`tasks/$ORCH_TASK.md\`.

## What was tried

### Every attempt
The builder implemented the contract and reported DONE with its validation suite
green. The reviewer refused it each time on the same two points, so the work
never reached the merge queue.

## Most likely cause

${trigger:-The trigger} after ${attempts:-several} failed attempt(s), with the
same refusal repeated and no change in the builder's approach between them. A
refusal that does not move between attempts points at the contract rather than
at the implementation: the reviewer is measuring against something the contract
does not ask for, or the contract asks for something the architecture forbids.

## What would settle it

Read the reviewer's two points against \`docs/ARCHITECTURE.md\` and the contract
side by side. If the architecture is right, requalify the contract and send the
task back to \`ready\`. If the contract is right, the reviewer's expectation is
wrong and the task can be retried unchanged.
EOF
