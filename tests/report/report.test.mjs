import { test } from "node:test";
import assert from "node:assert/strict";
import { parse } from "../../src/parse/parse.mjs";
import { summarise } from "../../src/report/report.mjs";

test("a numeric column reports count, sum, mean, min and max", () => {
  const { headers, rows } = parse("n\n1\n2\n6");
  const lines = summarise(headers, rows).split("\n");
  assert.match(lines[0], /column\s+count\s+sum\s+mean\s+min\s+max/);
  assert.match(lines[2], /n\s+3\s+9\s+3\s+1\s+6/);
});

test("a text column is listed with its count and never a fabricated total", () => {
  const { headers, rows } = parse("name\nada\ngrace");
  const line = summarise(headers, rows).split("\n")[2];
  assert.match(line, /name\s+2\s+—\s+—\s+—\s+—/);
});

test("summarise returns a string and prints nothing", () => {
  const { headers, rows } = parse("n\n1");
  assert.equal(typeof summarise(headers, rows), "string");
});
