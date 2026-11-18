#!/usr/bin/env node
// Anti-drift gate: component source must consume tokens, not literals.
//
// Fails on anything in packages/react/src that bypasses the token system:
// raw colours, arbitrary sizes, Tailwind's default (non-Aeros) scales, and
// per-component focus rings. The token-driven forms are the way — alias
// colours, text-<role>, rounded-<shape>, shadow-<elevation>, h-control-<size>,
// duration-<name>, z-<layer>.
//
// Run: `node scripts/check-hardcoded.mjs`
import { readFileSync, readdirSync, statSync } from "node:fs";
import { join } from "node:path";
import { fileURLToPath } from "node:url";

const root = fileURLToPath(new URL("../packages/react/src", import.meta.url));

const RULES = [
  { name: "raw hex colour", re: /#(?:[0-9A-Fa-f]{8}|[0-9A-Fa-f]{6}|[0-9A-Fa-f]{3,4})\b/g },
  { name: "raw rgb()/rgba() colour", re: /\brgba?\(/g },
  { name: "arbitrary text size (use text-<role>)", re: /\btext-\[\d/g },
  { name: "arbitrary tracking/leading (the type role sets it)", re: /\b(?:tracking|leading)-\[/g },
  { name: "arbitrary radius (use rounded-item|control|surface|modal|pill)", re: /\brounded(?:-[a-z]{1,2})?-\[/g },
  { name: "arbitrary shadow (use shadow-raised|overlay|modal)", re: /\bshadow-\[/g },
  { name: "arbitrary duration", re: /\bduration-\[/g },
  { name: "arbitrary z-index", re: /\bz-\[/g },
  { name: "old token form (use z-<layer> / duration-<name> / ease-<name>)", re: /\b(?:z|duration|ease)-\(--aeros-/g },
  { name: "raw ink stop (use an alias colour)", re: /\b(?:bg|text|border|ring|fill|stroke|outline|from|to|via)-ink-\d/g },
  { name: "raw white/black (use an alias colour)", re: /\b(?:bg|text|border|ring|fill|stroke|outline)-(?:white|black)\b/g },
  {
    name: "Tailwind default palette (off-brand)",
    re: /\b(?:bg|text|border|ring|fill|stroke|outline)-(?:slate|gray|zinc|neutral|stone|red|orange|amber|yellow|lime|green|emerald|teal|cyan|sky|blue|indigo|violet|purple|fuchsia|pink|rose)-\d/g
  },
  { name: "scale radius step (use a semantic radius)", re: /\brounded(?:-[a-z]{1,2})?-(?:xs|sm|md|lg|xl|2xl|3xl|4xl)\b/g },
  { name: "scale shadow step (use an elevation intent)", re: /\bshadow-(?:2xs|xs|sm|md|lg|xl|2xl)\b/g },
  { name: "default text size (use text-<role>)", re: /\btext-(?:xs|sm|base|lg|xl|[2-9]xl)\b/g },
  { name: "per-component focus ring (the global :focus-visible outline is the ring)", re: /\bring-offset-|focus(?:-visible)?:ring-/g },
  { name: "backdrop blur", re: /\bbackdrop-blur/g }
];

// Files not yet restyled. Their violations are reported but do not fail the
// gate; the list shrinks to nothing as the remaining PRs land.
const PENDING = new Set(["components/sidebar.tsx", "components/topnav.tsx"]);

// Deliberate literals, by file → rule name.
const ALLOW = {
  // Documentation of the syntax inside a comment.
  "internal/recipes.ts": []
};

function* walk(dir) {
  for (const entry of readdirSync(dir)) {
    const p = join(dir, entry);
    if (statSync(p).isDirectory()) yield* walk(p);
    else if (/\.(ts|tsx|css)$/.test(entry)) yield p;
  }
}

let failures = 0;
let pending = 0;
for (const file of walk(root)) {
  const rel = file.replace(root + "/", "");
  const lines = readFileSync(file, "utf8").split("\n");
  for (const rule of RULES) {
    if ((ALLOW[rel] ?? []).includes(rule.name)) continue;
    lines.forEach((line, i) => {
      // Comments may name a banned class when explaining what replaced it.
      const code = line.replace(/\/\/.*$/, "").replace(/\/\*.*?\*\//g, "");
      if (/^\s*(\*|\/\*)/.test(line)) return;
      rule.re.lastIndex = 0;
      if (!rule.re.test(code)) return;
      const where = `${rel}:${i + 1}  ${line.trim().slice(0, 110)}`;
      if (PENDING.has(rel)) {
        pending++;
        console.warn(`… pending — ${rule.name}: ${where}`);
      } else {
        failures++;
        console.error(`✗ ${rule.name}: ${where}`);
      }
    });
  }
}

if (failures > 0) {
  console.error(`\n${failures} hardcoded value(s) found — use tokens instead.`);
  process.exit(1);
}
console.log(
  `✓ packages/react/src consumes tokens only.${pending ? ` (${pending} pending in ${[...PENDING].join(", ")})` : ""}`
);
