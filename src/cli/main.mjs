/**
 * The only module that touches the process: argv, exit codes and the standard
 * streams. Everything below returns values or throws.
 */
import { readFileSync } from "node:fs";
import { parse } from "../parse/parse.mjs";
import { summarise } from "../report/report.mjs";

const USAGE = "usage: report <file>\n";

export function main(argv, out, err) {
  if (argv.length !== 1) {
    err.write(USAGE);
    return 2;
  }
  let text;
  try {
    text = readFileSync(argv[0], "utf8");
  } catch (error) {
    err.write(`report: cannot read ${argv[0]}: ${error.code ?? error.message}\n`);
    return 1;
  }
  try {
    const { headers, rows } = parse(text);
    out.write(`${summarise(headers, rows)}\n`);
    return 0;
  } catch (error) {
    const where = error.line === undefined ? "" : ` on line ${error.line}`;
    err.write(`report: ${error.message}${where}\n`);
    return 1;
  }
}
