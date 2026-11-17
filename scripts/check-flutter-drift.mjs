#!/usr/bin/env node
// Anti-drift gate, generated-file era: the Flutter token layer aliases the
// generated `aeros_tokens.g.dart` (emitted by `pnpm build:tokens`). This
// script verifies (a) the generator emitted every tokens.json value, and
// (b) the hand-written token files actually reference AerosTokens instead of
// literals. Freshness of the committed .g.dart is enforced separately in CI
// (build + `git diff --exit-code`).
// Run: `node scripts/check-flutter-drift.mjs`
import { readFileSync } from "node:fs";

import { parseHex, resolveTokens } from "../packages/tokens/src/resolve.mjs";

// Aliases may be references ({color.ink.900}) — compare resolved values.
const tokens = resolveTokens(
  JSON.parse(readFileSync(new URL("../packages/tokens/src/tokens.json", import.meta.url), "utf8"))
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

const byte = (n) => Math.round(n).toString(16).padStart(2, "0").toUpperCase();
const dartHex = (hex) => {
  const { r, g, b, a } = parseHex(hex);
  return `Color(0x${byte(a * 255)}${byte(r)}${byte(g)}${byte(b)})`;
};
const camel = (s) => s.replace(/-([a-z0-9])/g, (_m, c) => c.toUpperCase());

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

// (a2) the typed theme file — colour sets, type scale and shadows are
// generated whole, so every key in tokens.json must have a member.
const theme = read("aeros_theme_tokens.g.dart");
const THEME = "aeros_theme_tokens.g.dart";
for (const k of Object.keys(tokens.alias.light)) {
  expectIn(THEME, theme, `required this.${camel(k)},`, `AerosAliasColors.${camel(k)}`);
}
for (const k of Object.keys(tokens.color.semantic)) {
  expectIn(THEME, theme, `required this.${camel(k)},`, `AerosSemanticColors.${camel(k)}`);
}
for (const [role, s] of Object.entries(tokens.text)) {
  const start = theme.indexOf(`static const TextStyle ${camel(role)} = TextStyle(`);
  if (start < 0) {
    failures++;
    console.error(`✗ text.${role} — no AerosTypeScale.${camel(role)} in ${THEME}`);
    continue;
  }
  const block = theme.slice(start, theme.indexOf(");", start));
  const size = Number(s.size);
  expectIn(THEME, block, `fontSize: ${Number.isInteger(size) ? size.toFixed(1) : size},`, `text.${role} size`);
  if (s.family !== "mono") {
    // Inter is a variable font: the glyph weight follows the wght axis.
    expectIn(THEME, block, `FontVariation('wght', ${Number(s.weight).toFixed(1)})`, `text.${role} weight axis`);
  }
  expectIn(THEME, block, "package: 'aeros_design_system'", `text.${role} resolves the bundled font`);
}
for (const [set, suffix] of [["shadow", ""], ["shadowDark", "Dark"]]) {
  for (const k of Object.keys(tokens[set])) {
    expectIn(THEME, theme, `static const List<BoxShadow> ${camel(k)}${suffix} =`, `${set}.${k}`);
  }
}

// (b) adoption — hand token files must alias the generated constants.
const ADOPT = {
  "typography.dart": "AerosTypeScale.",
  "colors.dart": "AerosTokens.",
  "spacing.dart": "AerosTokens.",
  "radii.dart": "AerosTokens.",
  "breakpoints.dart": "AerosTokens.",
  "motion.dart": "AerosTokens.",
  "shadows.dart": "AerosShadowTokens."
};
for (const [file, ref] of Object.entries(ADOPT)) {
  const src = read(file);
  expectIn(file, src, ".g.dart", `${file} imports the generated tokens`);
  expectIn(file, src, ref, `${file} references ${ref.slice(0, -1)}`);
  if (file === "typography.dart" && /(fontSize|height|letterSpacing):\s*-?[0-9]/.test(src)) {
    failures++;
    console.error("✗ typography.dart carries its own size/height/tracking — read AerosTypeScale instead.");
  }
  if (/Color\(0x/.test(src) || /BoxShadow\(/.test(src)) {
    failures++;
    console.error(`✗ ${file} still contains a literal Color(0x…)/BoxShadow(…) — alias the generated tokens instead.`);
  }
}

if (failures > 0) {
  console.error(`\n${failures} drift issue(s) found.`);
  process.exit(1);
}
console.log("✓ Generated Dart tokens complete; Flutter token layer aliases them (no literals).");
