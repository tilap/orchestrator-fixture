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

import { minimum, maximum } from "../src/core/stats.mjs";

test("minimum and maximum are null on an empty column, never Infinity", () => {
  assert.equal(minimum([]), null);
  assert.equal(maximum([]), null);
});

test("minimum and maximum refuse a non-number the way sum does", () => {
  assert.throws(() => minimum([1, "2"]), TypeError);
  assert.throws(() => maximum([1, null]), TypeError);
});

test("minimum and maximum over a real column", () => {
  assert.equal(minimum([3, -1, 7]), -1);
  assert.equal(maximum([3, -1, 7]), 7);
});
