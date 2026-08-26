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
