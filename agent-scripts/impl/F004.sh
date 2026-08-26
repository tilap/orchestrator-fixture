set -euo pipefail
mkdir -p src/cli tests/cli
cat > src/cli/main.mjs <<'EOF'
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
EOF
cat > src/cli/bin.mjs <<'EOF'
#!/usr/bin/env node
import { main } from "./main.mjs";
process.exit(main(process.argv.slice(2), process.stdout, process.stderr));
EOF
cat > tests/cli/main.test.mjs <<'EOF'
import { test } from "node:test";
import assert from "node:assert/strict";
import { mkdtempSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { main } from "../../src/cli/main.mjs";

const collect = () => {
  const chunks = [];
  return { write: (chunk) => chunks.push(chunk), text: () => chunks.join("") };
};

const fileWith = (content) => {
  const path = join(mkdtempSync(join(tmpdir(), "report-")), "data.csv");
  writeFileSync(path, content);
  return path;
};

test("a missing or extra argument exits non-zero with a usage line", () => {
  for (const argv of [[], ["a", "b"]]) {
    const err = collect();
    assert.equal(main(argv, collect(), err), 2);
    assert.match(err.text(), /^usage: report/);
  }
});

test("a bad cell exits non-zero with the offending line number", () => {
  const err = collect();
  assert.equal(main([fileWith("n\n1\nx\n")], collect(), err), 1);
  assert.match(err.text(), /line 3/);
});

test("a good file prints the table and exits zero", () => {
  const out = collect();
  assert.equal(main([fileWith("n\n1\n2\n")], out, collect()), 0);
  assert.match(out.text(), /column\s+count/);
});
EOF
