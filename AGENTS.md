# Global rules — fixture-report

## Priority of sources

1. `docs/PRD.md`
2. `docs/ARCHITECTURE.md`
3. The task contract under `tasks/`
4. The existing code
5. Your own assumptions

Where two levels disagree, the higher one wins. Do not arbitrate any other way.

## What never goes to a human

Implementation details, local refactoring, tests, installing a dependency,
fixing a bug found on the way. Those are the job.

## Validation

A task is not finished until every acceptance criterion holds and the whole
validation list passes — not part of it. What each name runs is defined once,
in `orchestrator.toml`.

## Git

One task, one branch. Never modify another agent's branch. Never commit a
generated secret. Never push to the integration branch: open nothing, push
nothing — the commit is where your work ends.
// written by a task that had no business here
