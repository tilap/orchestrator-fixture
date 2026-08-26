set -euo pipefail
mkdir -p src/report tests/report
cat > src/report/report.mjs <<'EOF'
/**
 * Turn parsed rows into a rendered summary table.
 *
 * It returns the string. It does not print, does not exit and does not read the
 * filesystem — how a result reaches the operator belongs to the CLI layer.
 */
import { sum, mean } from "../core/sum.mjs";
import { minimum, maximum } from "../core/stats.mjs";
import { numericColumns, column } from "../parse/parse.mjs";
import { table } from "../format/table.mjs";

const round = (value) => (value === null ? "—" : String(Math.round(value * 1000) / 1000));

export function summarise(headers, rows) {
  const numeric = numericColumns(headers, rows);

  const summary = headers.map((header, index) => {
    if (!numeric[index]) {
      // A text column is listed with its count and nothing else. A fabricated
      // total on a column of names is worse than an absent one.
      return [header, String(rows.length), "—", "—", "—", "—"];
    }
    const values = column(rows, index);
    return [
      header,
      String(values.length),
      round(sum(values)),
      round(mean(values)),
      round(minimum(values)),
      round(maximum(values)),
    ];
  });

  return table(["column", "count", "sum", "mean", "min", "max"], summary);
}
EOF
cat > tests/report/report.test.mjs <<'EOF'
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
EOF
