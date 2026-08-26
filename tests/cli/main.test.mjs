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
