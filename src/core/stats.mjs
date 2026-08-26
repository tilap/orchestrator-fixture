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
