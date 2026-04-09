/**
 * Aeros token builder — zero-dep.
 * Reads tokens.json, emits CSS vars, TypeScript, Tailwind v4 preset, Dart constants.
 * Run: `pnpm --filter @aeros/tokens build`
 */
import { readFileSync, mkdirSync, writeFileSync } from "node:fs";
import { dirname, resolve } from "node:path";
import { fileURLToPath } from "node:url";

const __dirname = dirname(fileURLToPath(import.meta.url));
const root = resolve(__dirname, "..");
const tokens = JSON.parse(readFileSync(resolve(__dirname, "tokens.json"), "utf8"));

function ensure(p: string) { mkdirSync(dirname(p), { recursive: true }); }
function write(p: string, body: string) { ensure(p); writeFileSync(p, body); console.log("✓", p.replace(root + "/", "")); }

// ── helpers ───────────────────────────────────────────────
const kebab = (s: string) => s.replace(/([A-Z])/g, "-$1").toLowerCase();

function flattenColor(): Record<string, string> {
  const out: Record<string, string> = {};
  for (const [group, ramp] of Object.entries(tokens.color)) {
    for (const [stop, v] of Object.entries(ramp as any)) {
      out[`${group}-${stop}`] = (v as any).$value;
    }
  }
  return out;
}

const COLOR = flattenColor();
const ALIAS_LIGHT = tokens.alias.light as Record<string, string>;
const ALIAS_DARK  = tokens.alias.dark  as Record<string, string>;

// ── CSS ───────────────────────────────────────────────────
function buildCss(): string {
  const lines: string[] = [];
  lines.push("/* Aeros Design Tokens — generated. Do not edit. */");
  lines.push(":root {");
  lines.push(`  --aeros-font-sans: ${tokens.font.family.sans};`);
  lines.push(`  --aeros-font-mono: ${tokens.font.family.mono};`);
  for (const [k, v] of Object.entries(COLOR)) lines.push(`  --aeros-color-${k}: ${v};`);
  for (const [k, v] of Object.entries(ALIAS_LIGHT)) lines.push(`  --aeros-${k}: ${v};`);
  for (const [k, v] of Object.entries(tokens.radius)) lines.push(`  --aeros-radius-${k}: ${typeof v === "number" ? v + "px" : v};`);
  for (const [k, v] of Object.entries(tokens.space)) {
    // CSS custom property idents can't contain '.' — lightningcss rejects it.
    const safe = String(k).replace(/\./g, "_");
    lines.push(`  --aeros-space-${safe}: ${typeof v === "number" ? v + "px" : v};`);
  }
  for (const [k, v] of Object.entries(tokens.shadow)) lines.push(`  --aeros-shadow-${k}: ${v};`);
  for (const [k, v] of Object.entries(tokens.motion.duration)) lines.push(`  --aeros-duration-${k}: ${v}ms;`);
  for (const [k, v] of Object.entries(tokens.motion.ease)) lines.push(`  --aeros-ease-${k}: ${v};`);
  for (const [k, v] of Object.entries(tokens.z)) lines.push(`  --aeros-z-${k}: ${v};`);
  lines.push("}");
  lines.push("");
  lines.push("[data-theme='dark'] {");
  for (const [k, v] of Object.entries(ALIAS_DARK)) lines.push(`  --aeros-${k}: ${v};`);
  lines.push("  --aeros-shadow-sm: 0 1px 3px rgba(0,0,0,0.4), 0 0 0 1px rgba(30,37,64,0.8);");
  lines.push("  --aeros-shadow-md: 0 4px 12px rgba(0,0,0,0.5);");
  lines.push("  --aeros-shadow-lg: 0 4px 16px rgba(0,0,0,0.55);");
  lines.push("  --aeros-shadow-xl: 0 20px 40px rgba(0,0,0,0.65);");
  lines.push("}");
  lines.push("");
  lines.push("@media (prefers-reduced-motion: reduce) {");
  lines.push("  *, *::before, *::after { animation-duration: 0.01ms !important; transition-duration: 0.01ms !important; }");
  lines.push("}");
  return lines.join("\n") + "\n";
}

// ── TS ────────────────────────────────────────────────────
function buildTs(): string {
  return `// Aeros Design Tokens — generated. Do not edit.\n\nexport const tokens = ${JSON.stringify(tokens, null, 2)} as const;\n\nexport type AerosTokens = typeof tokens;\nexport default tokens;\n`;
}

// ── Tailwind v4 preset ────────────────────────────────────
function buildTailwind(): string {
  // Tailwind v4 uses CSS-first config via @theme, but we also expose a JS preset
  // for v3 users or programmatic access. Keep it minimal.
  const colors: Record<string, any> = {};
  for (const [group, ramp] of Object.entries(tokens.color)) {
    if (group === "semantic") continue;
    const obj: Record<string, string> = {};
    for (const [stop, v] of Object.entries(ramp as any)) obj[stop] = (v as any).$value;
    colors[group] = obj;
  }
  // semantic flat
  for (const [k, v] of Object.entries((tokens.color as any).semantic)) {
    colors[k] = (v as any).$value;
  }
  // alias via CSS vars (theme-aware)
  for (const k of Object.keys(tokens.alias.light)) {
    colors[k] = `var(--aeros-${k})`;
  }

  const spacing: Record<string, string> = {};
  for (const [k, v] of Object.entries(tokens.space)) spacing[k] = typeof v === "number" ? `${v}px` : String(v);

  const radius: Record<string, string> = {};
  for (const [k, v] of Object.entries(tokens.radius)) radius[k] = typeof v === "number" ? `${v}px` : String(v);

  const shadow: Record<string, string> = {};
  for (const [k, v] of Object.entries(tokens.shadow)) shadow[k] = String(v);

  const preset = {
    theme: {
      extend: {
        colors,
        spacing,
        borderRadius: radius,
        boxShadow: shadow,
        fontFamily: {
          sans: ["Plus Jakarta Sans", "ui-sans-serif", "system-ui", "sans-serif"],
          mono: ["IBM Plex Mono", "ui-monospace", "SFMono-Regular", "Menlo", "monospace"]
        },
        transitionDuration: {
          fast: `${tokens.motion.duration.fast}ms`,
          base: `${tokens.motion.duration.base}ms`,
          slow: `${tokens.motion.duration.slow}ms`
        }
      }
    }
  };

  return `// Aeros Tailwind preset — generated. Do not edit.\n/** @type {import('tailwindcss').Config} */\nconst preset = ${JSON.stringify(preset, null, 2)};\nexport default preset;\n`;
}

// ── Dart ──────────────────────────────────────────────────
function hexToDartColor(hex: string): string {
  const h = hex.replace("#", "");
  return `Color(0xFF${h.toUpperCase()})`;
}

function buildDart(): string {
  const lines: string[] = [];
  lines.push("// Aeros Design Tokens — generated. Do not edit.");
  lines.push("// ignore_for_file: constant_identifier_names");
  lines.push("");
  lines.push("import 'package:flutter/material.dart';");
  lines.push("");
  lines.push("class AerosTokens {");
  lines.push("  AerosTokens._();");
  lines.push("");
  lines.push("  // ─── Color ramps ───");
  for (const [group, ramp] of Object.entries(tokens.color)) {
    if (group === "semantic") continue;
    for (const [stop, v] of Object.entries(ramp as any)) {
      lines.push(`  static const Color ${group}${stop} = ${hexToDartColor((v as any).$value)};`);
    }
  }
  lines.push("");
  lines.push("  // ─── Semantic ───");
  for (const [k, v] of Object.entries((tokens.color as any).semantic)) {
    const name = k.replace(/-([a-z])/g, (_m, c) => c.toUpperCase());
    lines.push(`  static const Color ${name} = ${hexToDartColor((v as any).$value)};`);
  }
  lines.push("");
  lines.push("  // ─── Spacing (dp) ───");
  for (const [k, v] of Object.entries(tokens.space)) {
    const key = `space${k.replace(".", "_")}`;
    lines.push(`  static const double ${key} = ${Number(v).toFixed(1)};`);
  }
  lines.push("");
  lines.push("  // ─── Radii ───");
  for (const [k, v] of Object.entries(tokens.radius)) {
    const key = `radius${k.charAt(0).toUpperCase() + k.slice(1).replace("2xl", "2Xl")}`;
    lines.push(`  static const double ${key} = ${Number(v).toFixed(1)};`);
  }
  lines.push("");
  lines.push("  // ─── Font families ───");
  lines.push(`  static const String fontSans = 'Plus Jakarta Sans';`);
  lines.push(`  static const String fontMono = 'IBM Plex Mono';`);
  lines.push("}");
  return lines.join("\n") + "\n";
}

// ── emit ─────────────────────────────────────────────────
write(resolve(root, "dist/css/tokens.css"),           buildCss());
write(resolve(root, "dist/js/tokens.js"),             buildTs().replace("export type AerosTokens = typeof tokens;\n", ""));
write(resolve(root, "dist/js/tokens.d.ts"),           `declare const tokens: any;\nexport type AerosTokens = typeof tokens;\nexport { tokens };\nexport default tokens;\n`);
write(resolve(root, "dist/tailwind/preset.js"),       buildTailwind());
write(resolve(root, "dist/tailwind/preset.d.ts"),     `declare const preset: any;\nexport default preset;\n`);
write(resolve(root, "dist/dart/aeros_tokens.dart"),   buildDart());

console.log("\n✨ Aeros tokens built.");
