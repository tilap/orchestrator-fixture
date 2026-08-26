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

test("a column with one number in it is numeric, and its bad cells are errors", () => {
  const { headers, rows } = parse("n,s\n1,x\n2,y");
  assert.deepEqual(numericColumns(headers, rows), [true, false]);
  const mixed = parse("n\n1\nx").rows;
  assert.deepEqual(numericColumns(["n"], mixed), [true]);
});

test("a blank cell is an error carrying its line, not a zero", () => {
  const { rows } = parse("n\n1\n\n3");
  assert.deepEqual(column(rows, 0), [1, 3]);
  const bad = parse("n\n1\nx").rows;
  assert.throws(() => column(bad, 0), (error) => error instanceof ParseError && error.line === 3);
});
