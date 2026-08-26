# Decisions — fixture-report

## D1 · A blank cell in a numeric column is an error

Coercing a blank to zero produces a total that is wrong and looks right. The
tool exists to summarise numbers; a summary nobody can trust is worse than no
summary. Rejected alternative: skip blank cells, which changes the count
silently and makes the mean disagree with the sum.

## D2 · No dependencies

The bench is rebuilt from scratch constantly. An install step would make that
take minutes instead of seconds, and would make the validation commands fail
for reasons that have nothing to do with the code under test.

## D3 · ESM modules with the .mjs extension

Explicit at the file level rather than inherited from a field in the manifest.
A file that says what it is survives being moved, copied into a worktree, or
read on its own.

## D4 · Output goes to standard output only

No file writing anywhere in the tool. It composes with a shell redirect, and it
cannot damage anything it was pointed at by mistake.
