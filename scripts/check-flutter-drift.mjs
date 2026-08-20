#!/usr/bin/env node
// Anti-drift gate, generated-file era: the Flutter token layer aliases the
// generated `aeros_tokens.g.dart` (emitted by `pnpm build:tokens`). This
// script verifies (a) the generator emitted every tokens.json value, and
// (b) the hand-written token files actually reference AerosTokens instead of
// literals. Freshness of the committed .g.dart is enforced separately in CI
// (build + `git diff --exit-code`).
// Run: `node scripts/check-flutter-drift.mjs`
import { readFileSync } from "node:fs";

const tokens = JSON.parse(
  readFileSync(new URL("../packages/tokens/src/tokens.json", import.meta.url), "utf8")
);
const read = (p) => readFileSync(new URL(`../packages/flutter/lib/src/tokens/${p}`, import.meta.url), "utf8");

const gen = read("aeros_tokens.g.dart");

let failures = 0;
function expectIn(haystackName, haystack, needle, label) {
  if (!haystack.includes(needle)) {
    failures++;
    console.error(`✗ ${label} — expected "${needle}" in ${haystackName}`);
  }
}

const dartHex = (hex) => `Color(0xFF${hex.replace("#", "").toUpperCase()})`;

// (a) generator completeness — every token value appears in the generated file.
for (const [stop, v] of Object.entries(tokens.color.ink)) {
  expectIn("aeros_tokens.g.dart", gen, dartHex(v.$value), `ink-${stop}`);
}
for (const set of ["semantic", "semanticDark"]) {
  for (const [k, v] of Object.entries(tokens.color[set])) {
    expectIn("aeros_tokens.g.dart", gen, dartHex(v.$value), `${set}.${k}`);
  }
}
for (const theme of ["light", "dark"]) {
  for (const [k, v] of Object.entries(tokens.alias[theme])) {
    expectIn("aeros_tokens.g.dart", gen, dartHex(v), `alias.${theme}.${k}`);
  }
}
for (const [k, v] of Object.entries(tokens.space)) {
  expectIn("aeros_tokens.g.dart", gen, `= ${Number(v).toFixed(1)};`, `space.${k}`);
}
for (const [k, v] of Object.entries(tokens.radius)) {
  expectIn("aeros_tokens.g.dart", gen, `= ${Number(v).toFixed(1)};`, `radius.${k}`);
}
for (const [k, v] of Object.entries(tokens.breakpoint)) {
  expectIn("aeros_tokens.g.dart", gen, `= ${Number(v).toFixed(1)};`, `breakpoint.${k}`);
}
for (const [k, v] of Object.entries(tokens.motion.duration)) {
  expectIn("aeros_tokens.g.dart", gen, `Duration(milliseconds: ${v})`, `motion.duration.${k}`);
}
for (const [k, v] of Object.entries(tokens.motion.ease)) {
  const m = String(v).match(/cubic-bezier\(([^)]+)\)/);
  if (!m) continue;
  const args = m[1].split(",").map((n) => Number(n.trim())).join(", ");
  expectIn("aeros_tokens.g.dart", gen, `Cubic(${args})`, `motion.ease.${k}`);
}

// (b) adoption — hand token files must alias the generated constants.
for (const file of ["colors.dart", "spacing.dart", "radii.dart", "breakpoints.dart", "motion.dart"]) {
  const src = read(file);
  expectIn(file, src, "aeros_tokens.g.dart", `${file} imports the generated tokens`);
  expectIn(file, src, "AerosTokens.", `${file} references AerosTokens`);
  if (/Color\(0xFF/.test(src)) {
    failures++;
    console.error(`✗ ${file} still contains a literal Color(0xFF…) — alias AerosTokens instead.`);
  }
}

if (failures > 0) {
  console.error(`\n${failures} drift issue(s) found.`);
  process.exit(1);
}
console.log("✓ Generated Dart tokens complete; Flutter token layer aliases them (no literals).");
