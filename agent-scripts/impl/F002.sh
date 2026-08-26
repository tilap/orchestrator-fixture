set -euo pipefail
cat > src/core/stats.mjs <<'EOF'
/**
 * Extremes of a column, on the same terms as sum and mean: a non-number is a
 * TypeError, and an empty column is null rather than Infinity.
 */
function check(values) {
  for (const value of values) {
    if (typeof value !== "number" || Number.isNaN(value)) {
      throw new TypeError(`not a number: ${String(value)}`);
    }
  }
}

export function minimum(values) {
  check(values);
  return values.length === 0 ? null : values.reduce((low, value) => (value < low ? value : low));
}

export function maximum(values) {
  check(values);
  return values.length === 0 ? null : values.reduce((high, value) => (value > high ? value : high));
}
EOF
cat >> tests/core.test.mjs <<'EOF'

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
EOF
