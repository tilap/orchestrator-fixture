/** Add a column of numbers, ignoring nothing — a blank entry is an error. */
export function sum(values) {
  return values.reduce((total, value) => {
    if (typeof value !== "number" || Number.isNaN(value)) {
      throw new TypeError(`not a number: ${String(value)}`);
    }
    return total + value;
  }, 0);
}

/** The arithmetic mean, or null on an empty column rather than NaN. */
export function mean(values) {
  return values.length === 0 ? null : sum(values) / values.length;
}
