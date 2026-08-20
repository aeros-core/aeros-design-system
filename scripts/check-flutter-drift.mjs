#!/usr/bin/env node
// Anti-drift gate: the Flutter token layer is hand-mirrored from tokens.json
// (the generated aeros_tokens.dart is not yet imported — audit A-13). This
// script fails CI when a value in tokens.json has no counterpart in
// packages/flutter/lib/src/tokens/*.dart, so the mirror can't rot silently.
// Run: `node scripts/check-flutter-drift.mjs`
import { readFileSync } from "node:fs";

const tokens = JSON.parse(
  readFileSync(new URL("../packages/tokens/src/tokens.json", import.meta.url), "utf8")
);
const read = (p) => readFileSync(new URL(`../packages/flutter/lib/src/tokens/${p}`, import.meta.url), "utf8");

const colorsDart = read("colors.dart");
const spacingDart = read("spacing.dart");
const radiiDart = read("radii.dart");
const breakpointsDart = read("breakpoints.dart");
const motionDart = read("motion.dart");

let failures = 0;
function expectIn(haystackName, haystack, needle, label) {
  if (!haystack.includes(needle)) {
    failures++;
    console.error(`✗ ${label} — expected "${needle}" in ${haystackName}`);
  }
}

const dartHex = (hex) => `Color(0xFF${hex.replace("#", "").toUpperCase()})`;

// Ink ramp + semantic sets (light and dark) must appear verbatim.
for (const [stop, v] of Object.entries(tokens.color.ink)) {
  expectIn("colors.dart", colorsDart, dartHex(v.$value), `ink-${stop}`);
}
for (const set of ["semantic", "semanticDark"]) {
  for (const [k, v] of Object.entries(tokens.color[set])) {
    expectIn("colors.dart", colorsDart, dartHex(v.$value), `${set}.${k}`);
  }
}
// Aliases (both themes).
for (const theme of ["light", "dark"]) {
  for (const [k, v] of Object.entries(tokens.alias[theme])) {
    expectIn("colors.dart", colorsDart, dartHex(v), `alias.${theme}.${k}`);
  }
}
// Spacing / radii values.
for (const [k, v] of Object.entries(tokens.space)) {
  expectIn("spacing.dart", spacingDart, `= ${v};`, `space.${k}`);
}
for (const [k, v] of Object.entries(tokens.radius)) {
  expectIn("radii.dart", radiiDart, `= ${v};`, `radius.${k}`);
}
// Breakpoints (0/xs is Flutter-only by design).
for (const [k, v] of Object.entries(tokens.breakpoint)) {
  expectIn("breakpoints.dart", breakpointsDart, `= ${v};`, `breakpoint.${k}`);
}
// Motion durations + curves.
for (const [k, v] of Object.entries(tokens.motion.duration)) {
  expectIn("motion.dart", motionDart, `Duration(milliseconds: ${v})`, `motion.duration.${k}`);
}
for (const [k, v] of Object.entries(tokens.motion.ease)) {
  const m = String(v).match(/cubic-bezier\(([^)]+)\)/);
  if (!m) continue;
  const args = m[1].split(",").map((n) => Number(n.trim())).join(", ");
  expectIn("motion.dart", motionDart, `Cubic(${args})`, `motion.ease.${k}`);
}

if (failures > 0) {
  console.error(`\n${failures} token(s) missing from the Flutter mirror — sync packages/flutter/lib/src/tokens/.`);
  process.exit(1);
}
console.log("✓ Flutter token mirror matches tokens.json.");
