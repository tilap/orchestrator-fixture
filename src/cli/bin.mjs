#!/usr/bin/env node
import { pathToFileURL } from "node:url";
import { main } from "./main.mjs";

// Only when this file is what was run. Imported — by the build, by a test — it
// must do nothing: a module with a side effect at import time turns any tool
// that walks the source tree into an accidental invocation.
if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href) {
  process.exit(main(process.argv.slice(2), process.stdout, process.stderr));
}
