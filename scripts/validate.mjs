// Run the validation suite defined in orchestrator.toml.
//
// One definition, read by the builder locally and by CI remotely. Two parallel
// definitions diverge, and it is always the builder that believes it validated.
import { readFileSync } from "node:fs";
import { execSync } from "node:child_process";

const toml = readFileSync("orchestrator.toml", "utf8");
const section = toml.split(/^\[/m).find((block) => block.startsWith("validation]"));
if (!section) {
  process.stderr.write("orchestrator.toml has no [validation] section\n");
  process.exit(1);
}

const commands = [...section.matchAll(/^(\w+)\s*=\s*"([^"]+)"/gm)].map(([, name, command]) => [name, command]);
if (commands.length === 0) {
  process.stderr.write("[validation] is empty — nothing would run\n");
  process.exit(1);
}

let failed = 0;
for (const [name, command] of commands) {
  process.stdout.write(`── ${name}: ${command}\n`);
  try {
    execSync(command, { stdio: "inherit" });
  } catch {
    process.stderr.write(`── ${name} FAILED\n`);
    failed++;
  }
}
process.exit(failed === 0 ? 0 : 1);
