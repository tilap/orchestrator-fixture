// A real build: it imports every module, so a syntax error anywhere fails it.
import { readdirSync, statSync, mkdirSync, writeFileSync } from "node:fs";
import { join } from "node:path";
import { pathToFileURL } from "node:url";

const modules = [];
function walk(dir) {
  for (const entry of readdirSync(dir)) {
    const path = join(dir, entry);
    if (statSync(path).isDirectory()) walk(path);
    else if (path.endsWith(".mjs")) modules.push(path);
  }
}
walk("src");

for (const path of modules) {
  await import(pathToFileURL(join(process.cwd(), path)).href);
}

mkdirSync("dist", { recursive: true });
writeFileSync("dist/manifest.json", JSON.stringify({ modules }, null, 2));
