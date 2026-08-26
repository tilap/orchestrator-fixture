set -euo pipefail
mkdir -p src/parse tests/parse
cat > src/parse/parse.mjs <<'EOF'
/**
 * Read delimited text into headers and rows.
 *
 * A blank cell in a numeric column is an error, never a zero: a silently
 * coerced blank is how a wrong total reaches a report nobody double-checks.
 */
export class ParseError extends Error {
  constructor(message, line) {
    super(message);
    this.name = "ParseError";
    this.line = line;
  }
}

export function parse(text, separator = ",") {
  const lines = text.split("\n").filter((line) => line.trim() !== "");
  if (lines.length === 0) return { headers: [], rows: [] };

  const headers = lines[0].split(separator).map((cell) => cell.trim());
  const rows = lines.slice(1).map((line, index) => {
    const cells = line.split(separator).map((cell) => cell.trim());
    if (cells.length !== headers.length) {
      throw new ParseError(`expected ${headers.length} cells, found ${cells.length}`, index + 2);
    }
    return cells;
  });

  return { headers, rows };
}

/** A column is numeric only when every one of its cells reads as a number. */
export function numericColumns(headers, rows) {
  return headers.map((_, index) =>
    rows.length > 0 && rows.every((row) => row[index] !== "" && Number.isFinite(Number(row[index]))));
}

/** Read one column as numbers, naming the offending line when a cell will not. */
export function column(rows, index, firstLine = 2) {
  return rows.map((row, offset) => {
    const value = Number(row[index]);
    if (row[index] === "" || !Number.isFinite(value)) {
      throw new ParseError(`cannot read ${JSON.stringify(row[index])} as a number`, offset + firstLine);
    }
    return value;
  });
}
EOF
cat > tests/parse/parse.test.mjs <<'EOF'
import { test } from "node:test";
import assert from "node:assert/strict";
import { parse, numericColumns, column, ParseError } from "../../src/parse/parse.mjs";

test("the first line is headers, never data", () => {
  const { headers, rows } = parse("a,b\n1,2\n3,4");
  assert.deepEqual(headers, ["a", "b"]);
  assert.deepEqual(rows, [["1", "2"], ["3", "4"]]);
});

test("an empty file gives an empty row list rather than throwing", () => {
  assert.deepEqual(parse(""), { headers: [], rows: [] });
});

test("a short row names its line number", () => {
  assert.throws(() => parse("a,b\n1"), (error) => error instanceof ParseError && error.line === 2);
});

test("a column is numeric only when every cell is", () => {
  const { headers, rows } = parse("n,s\n1,x\n2,y");
  assert.deepEqual(numericColumns(headers, rows), [true, false]);
});

test("a blank cell is an error carrying its line, not a zero", () => {
  const { rows } = parse("n\n1\n\n3");
  assert.deepEqual(column(rows, 0), [1, 3]);
  const bad = parse("n\n1\nx").rows;
  assert.throws(() => column(bad, 0), (error) => error instanceof ParseError && error.line === 3);
});
EOF
