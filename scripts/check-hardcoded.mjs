#!/usr/bin/env node
// Anti-drift gate: component source must consume tokens, not literals.
// Fails on raw hex colors, arbitrary durations (duration-[…]) and arbitrary
// z-indexes (z-[…]) in packages/react/src. Token-driven forms — semantic
// classes, duration-(--aeros-duration-*), z-(--aeros-z-*) — are the way.
// Run: `node scripts/check-hardcoded.mjs`
import { readFileSync, readdirSync, statSync } from "node:fs";
import { join } from "node:path";
import { fileURLToPath } from "node:url";

const root = fileURLToPath(new URL("../packages/react/src", import.meta.url));

const RULES = [
  { name: "raw hex color", re: /#[0-9A-Fa-f]{6}\b/g },
  { name: "arbitrary duration", re: /duration-\[/g },
  { name: "arbitrary z-index", re: /z-\[/g }
];

function* walk(dir) {
  for (const entry of readdirSync(dir)) {
    const p = join(dir, entry);
    if (statSync(p).isDirectory()) yield* walk(p);
    else if (/\.(ts|tsx)$/.test(entry)) yield p;
  }
}

let failures = 0;
for (const file of walk(root)) {
  const src = readFileSync(file, "utf8");
  const lines = src.split("\n");
  for (const rule of RULES) {
    lines.forEach((line, i) => {
      if (rule.re.test(line)) {
        failures++;
        console.error(`✗ ${rule.name}: ${file.replace(root + "/", "")}:${i + 1}  ${line.trim().slice(0, 100)}`);
      }
      rule.re.lastIndex = 0;
    });
  }
}

if (failures > 0) {
  console.error(`\n${failures} hardcoded value(s) found — use tokens instead.`);
  process.exit(1);
}
console.log("✓ No hardcoded hex/duration/z-index values in packages/react/src.");
