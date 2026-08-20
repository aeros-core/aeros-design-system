#!/usr/bin/env node
// Verifies WCAG AA contrast for core foreground/background pairs in both themes.
// Run: `node scripts/check-contrast.mjs`
import { readFileSync } from "node:fs";

const tokens = JSON.parse(readFileSync(new URL("../packages/tokens/src/tokens.json", import.meta.url)));

function hexToRgb(hex) {
  const h = hex.replace("#", "");
  return [parseInt(h.slice(0, 2), 16), parseInt(h.slice(2, 4), 16), parseInt(h.slice(4, 6), 16)];
}
function lum([r, g, b]) {
  const c = [r, g, b].map(v => {
    v /= 255;
    return v <= 0.03928 ? v / 12.92 : Math.pow((v + 0.055) / 1.055, 2.4);
  });
  return 0.2126 * c[0] + 0.7152 * c[1] + 0.0722 * c[2];
}
function ratio(fg, bg) {
  const l1 = lum(hexToRgb(fg));
  const l2 = lum(hexToRgb(bg));
  const [a, b] = l1 > l2 ? [l1, l2] : [l2, l1];
  return (a + 0.05) / (b + 0.05);
}

const pairs = [
  ["fg-primary", "bg-surface"],
  ["fg-secondary", "bg-surface"],
  ["fg-muted", "bg-surface"],
  ["fg-primary", "bg-canvas"],
  ["fg-muted", "bg-subtle"],
  ["brand-primary", "bg-surface"],
  // Button primary label — must stay readable in both themes.
  ["fg-inverse", "brand-primary"]
];

let fail = 0;
function check(label, fgHex, bgHex, min) {
  const r = ratio(fgHex, bgHex);
  const ok = r >= min;
  if (!ok) fail++;
  console.log(`${ok ? "✓" : "✗"} ${label} → ${r.toFixed(2)}${ok ? "" : `  <— below ${min}`}`);
}

for (const theme of ["light", "dark"]) {
  console.log(`\n── ${theme.toUpperCase()} · aliases ──`);
  for (const [fg, bg] of pairs) {
    check(`${fg} on ${bg}`, tokens.alias[theme][fg], tokens.alias[theme][bg], 4.5);
  }

  // Status chips (Badge/Tag/Alert): text on tinted bg must pass AA text (4.5),
  // the base color on the tinted bg must pass non-text 3:1 (icons, dots).
  const sem = theme === "light" ? tokens.color.semantic : tokens.color.semanticDark;
  const surface = tokens.alias[theme]["bg-surface"];
  console.log(`\n── ${theme.toUpperCase()} · status ──`);
  for (const tone of ["success", "warning", "danger", "info"]) {
    const base = sem[tone].$value;
    const bg = sem[`${tone}-bg`].$value;
    const text = sem[`${tone}-text`].$value;
    check(`${tone}-text on ${tone}-bg`, text, bg, 4.5);
    check(`${tone}-text on bg-surface`, text, surface, 4.5);
    check(`${tone} (icon) on ${tone}-bg`, base, bg, 3);
    check(`${tone} (icon) on bg-surface`, base, surface, 3);
  }
}

if (fail > 0) {
  console.error(`\n${fail} pair(s) below WCAG AA.`);
  process.exit(1);
}
console.log("\nAll pairs pass WCAG AA.");
