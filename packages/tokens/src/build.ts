/**
 * Aeros token builder — zero-dep.
 *
 * tokens.json is the only source. This script resolves its references and
 * emits every platform artefact from the result:
 *
 *   dist/css/tokens.css              --aeros-* custom properties (light/dark/system)
 *   dist/css/theme.css               the Tailwind v4 theme (@theme + @theme inline)
 *   dist/js/tokens.{js,d.ts}         resolved + raw trees, typed
 *   dist/dart/*.dart                 Dart constants + typed theme classes
 *   ../flutter/lib/src/tokens/*.g.dart   the same Dart, committed (CI checks freshness)
 *
 * Run: `pnpm --filter @aeros-core/tokens build`
 */
import { mkdirSync, readFileSync, writeFileSync } from "node:fs";
import { dirname, resolve } from "node:path";
import { fileURLToPath } from "node:url";
import { buildCss } from "./emit/css";
import { buildDartTheme, buildDartTokens } from "./emit/dart";
import { buildDts, buildJs } from "./emit/js";
import { buildTheme } from "./emit/theme";
import { resolveTokens } from "./resolve.mjs";

const here = dirname(fileURLToPath(import.meta.url));
const root = resolve(here, "..");
const raw = JSON.parse(readFileSync(resolve(here, "tokens.json"), "utf8"));
const tokens = resolveTokens(raw);

function write(path: string, body: string) {
  const file = resolve(root, path);
  mkdirSync(dirname(file), { recursive: true });
  writeFileSync(file, body);
  console.log("✓", path);
}

const dartTokens = buildDartTokens(tokens);
const dartTheme = buildDartTheme(tokens);

write("dist/css/tokens.css", buildCss(tokens));
write("dist/css/theme.css", buildTheme(tokens));
write("dist/js/tokens.js", buildJs(tokens, raw));
write("dist/js/tokens.d.ts", buildDts(tokens, raw));
write("dist/dart/aeros_tokens.dart", dartTokens);
write("dist/dart/aeros_theme_tokens.dart", dartTheme.replace("import 'aeros_tokens.g.dart';", "import 'aeros_tokens.dart';"));
// The Flutter package consumes the generated Dart directly — these copies are
// committed, and CI fails if they go stale (build + git diff).
write("../flutter/lib/src/tokens/aeros_tokens.g.dart", dartTokens);
write("../flutter/lib/src/tokens/aeros_theme_tokens.g.dart", dartTheme);

console.log("\n✨ Aeros tokens built.");
