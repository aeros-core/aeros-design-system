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
  ["brand-primary", "bg-surface"]
];

let fail = 0;
for (const theme of ["light", "dark"]) {
  console.log(`\n── ${theme.toUpperCase()} ──`);
  for (const [fg, bg] of pairs) {
    const fgHex = tokens.alias[theme][fg];
    const bgHex = tokens.alias[theme][bg];
    const r = ratio(fgHex, bgHex);
    const ok = r >= 4.5;
    if (!ok) fail++;
    console.log(`${ok ? "✓" : "✗"} ${fg} on ${bg} → ${r.toFixed(2)}${ok ? "" : "  <— below AA 4.5"}`);
  }
}

if (fail > 0) {
  console.error(`\n${fail} pair(s) below WCAG AA.`);
  process.exit(1);
}
console.log("\nAll pairs pass WCAG AA.");
