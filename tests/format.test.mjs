import { test } from "node:test";
import assert from "node:assert/strict";
import { table } from "../src/format/table.mjs";

test("table sizes columns from their content", () => {
  const rendered = table(["id", "label"], [["F1", "short"], ["F22", "a longer label"]]);
  const [header, rule, first] = rendered.split("\n");
  assert.equal(header, "id   label");
  assert.equal(rule, "---  --------------");
  assert.equal(first, "F1   short");
});
