import { test } from "node:test";
import assert from "node:assert/strict";
import { sum, mean } from "../src/core/sum.mjs";

test("sum adds a column", () => {
  assert.equal(sum([1, 2, 3]), 6);
});

test("sum refuses a non-number rather than coercing it", () => {
  assert.throws(() => sum([1, "2"]), TypeError);
});

test("mean is null on an empty column, never NaN", () => {
  assert.equal(mean([]), null);
  assert.equal(mean([2, 4]), 3);
});
