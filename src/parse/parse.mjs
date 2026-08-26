/**
 * Read delimited text into headers and rows.
 *
 * A blank cell in a numeric column is an error, never a zero: a silently
 * coerced blank is how a wrong total reaches a report nobody double-checks.
 */
export class ParseError extends Error {
  constructor(message, line) {
    super(message);
    this.name = "ParseError";
    this.line = line;
  }
}

export function parse(text, separator = ",") {
  const lines = text.split("\n").filter((line) => line.trim() !== "");
  if (lines.length === 0) return { headers: [], rows: [] };

  const headers = lines[0].split(separator).map((cell) => cell.trim());
  const rows = lines.slice(1).map((line, index) => {
    const cells = line.split(separator).map((cell) => cell.trim());
    if (cells.length !== headers.length) {
      throw new ParseError(`expected ${headers.length} cells, found ${cells.length}`, index + 2);
    }
    return cells;
  });

  return { headers, rows };
}

/**
 * A column is numeric when at least one of its cells reads as a number.
 *
 * Not "when every cell does" — that rule quietly cancels the one in the PRD.
 * A column of numbers with one bad cell would stop being numeric, the bad cell
 * would never be read as a number, and the run would end with a clean table
 * instead of the error the operator needs.
 */
export function numericColumns(headers, rows) {
  return headers.map((_, index) =>
    rows.length > 0 && rows.some((row) => row[index] !== "" && Number.isFinite(Number(row[index]))));
}

/** Read one column as numbers, naming the offending line when a cell will not. */
export function column(rows, index, firstLine = 2) {
  return rows.map((row, offset) => {
    const value = Number(row[index]);
    if (row[index] === "" || !Number.isFinite(value)) {
      throw new ParseError(`cannot read ${JSON.stringify(row[index])} as a number`, offset + firstLine);
    }
    return value;
  });
}
