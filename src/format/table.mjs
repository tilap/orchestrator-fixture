/** Render rows as a fixed-width table. Column widths come from the content. */
export function table(headers, rows) {
  const widths = headers.map((header, index) =>
    Math.max(header.length, ...rows.map((row) => String(row[index] ?? "").length)));

  const line = (cells) =>
    cells.map((cell, index) => String(cell ?? "").padEnd(widths[index])).join("  ").trimEnd();

  return [line(headers), line(widths.map((width) => "-".repeat(width))), ...rows.map(line)].join("\n");
}
