// A real lint, trivially small: no debug output left behind, no trailing space.
// Real matters more than clever — the point is a command that genuinely fails
// when the code is broken, so the preflight probe has something to prove.
import { readdirSync, readFileSync, statSync } from "node:fs";
import { join } from "node:path";

const findings = [];

function walk(dir) {
  for (const entry of readdirSync(dir)) {
    const path = join(dir, entry);
    if (statSync(path).isDirectory()) walk(path);
    else if (path.endsWith(".mjs")) inspect(path);
  }
}

function inspect(path) {
  const lines = readFileSync(path, "utf8").split("\n");
  lines.forEach((line, index) => {
    if (line.includes("console.log")) findings.push(`${path}:${index + 1} debug output`);
    if (/\s+$/.test(line)) findings.push(`${path}:${index + 1} trailing whitespace`);
  });
}

walk("src");
for (const finding of findings) console.error(`lint: ${finding}`);
process.exit(findings.length > 0 ? 1 : 0);
