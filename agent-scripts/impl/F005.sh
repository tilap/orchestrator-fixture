set -euo pipefail
cat > src/format/table.mjs <<'EOF'
/**
 * Render rows as a fixed-width table. Column widths come from the content.
 *
 * A numeric column is right-aligned, which is the only way a column of numbers
 * can be compared by eye. It formats; it computes nothing about the values
 * beyond how wide they print.
 */
function isNumeric(cell) {
  const text = String(cell ?? "").trim();
  return text !== "" && Number.isFinite(Number(text));
}

export function table(headers, rows) {
  const widths = headers.map((header, index) =>
    Math.max(header.length, ...rows.map((row) => String(row[index] ?? "").length)));

  const numeric = headers.map((_, index) =>
    rows.length > 0 && rows.every((row) => isNumeric(row[index])));

  const line = (cells, align = true) =>
    cells
      .map((cell, index) => {
        const text = String(cell ?? "");
        return align && numeric[index] ? text.padStart(widths[index]) : text.padEnd(widths[index]);
      })
      .join("  ")
      .trimEnd();

  return [
    line(headers, false),
    line(widths.map((width) => "-".repeat(width)), false),
    ...rows.map((row) => line(row)),
  ].join("\n");
}
EOF
