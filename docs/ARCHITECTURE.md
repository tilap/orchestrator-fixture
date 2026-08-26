# Architecture — fixture-report

## Shape

Four modules, one direction of dependency, no cycles.

    cli/main      argument handling, exit codes, standard streams
      -> report/report    orchestrates: read, compute, render
           -> core/sum         arithmetic over one column
           -> format/table     fixed-width rendering

`core` knows nothing about files or output. `format` knows nothing about
numbers beyond how wide they print. `report` is the only module that knows both
exist, and `cli` is the only module that touches the process.

## Contracts between modules

- `core/sum` takes an array of numbers and throws `TypeError` on anything else.
  It never coerces and never returns `NaN`; an empty column gives `null`.
- `format/table` takes headers and rows of already-rendered values. It formats,
  it does not compute.
- `report/report` takes parsed rows and returns a string. It does not print.
- `cli/main` is the only place `process.exit`, `process.argv` and `console`
  appear. Everything below returns values or throws.

## Errors

A bad cell throws from the parsing layer carrying its line number. `cli/main`
turns that into a message on standard error and a non-zero exit. No module
below `cli` decides how a failure is presented.

## Validation

`lint`, `test` and `build` are defined once, in `orchestrator.toml`, and run
identically for a builder locally and for CI remotely. `build` imports every
module, so a syntax error anywhere fails it.
