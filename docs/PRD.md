# PRD — fixture-report

## What this is

A command-line tool that reads columns of numbers from a file and prints a
summary table: count, sum, mean, minimum and maximum per column.

It exists to be a bench for the orchestrator. It is deliberately small, has no
service, no port and no database, and is thrown away and rebuilt from a script
in a few seconds. Nothing here is a product decision anyone has to live with.

## Who uses it

One operator, at a terminal, on a file they already have. No configuration, no
persistence, no network.

## What it must do

- Read a delimited text file given as the single argument.
- Treat the first line as column headers.
- Compute count, sum, mean, minimum and maximum for every numeric column.
- Print the result as a fixed-width table on standard output.
- Exit non-zero, with the offending line number on standard error, when a cell
  in a numeric column cannot be read as a number.

## What it must not do

- Guess at a missing value. A blank cell in a numeric column is an error, not a
  zero — a silently coerced blank is how a wrong total reaches a report nobody
  double-checks.
- Write anything anywhere. Output goes to standard output and nowhere else.
- Reach the network, read an environment variable, or keep state between runs.

## Done

The operator runs the tool on a file with a bad cell and gets a message naming
the line, rather than a table containing a wrong number.
