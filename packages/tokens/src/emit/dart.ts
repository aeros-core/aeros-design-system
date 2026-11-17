import { parseHex } from "../resolve.mjs";
import { GENERATED, camel, cap, layout, parseShadow, ramps, semantic, sizes, type Tokens } from "./shared";

const FLUTTER_PACKAGE = "aeros_design_system";

/** #RRGGBB / #RRGGBBAA → `Color(0xAARRGGBB)`. */
export function dartColor(hex: string): string {
  const { r, g, b, a } = parseHex(hex);
  const byte = (n: number) => Math.round(n).toString(16).padStart(2, "0").toUpperCase();
  return `Color(0x${byte(a * 255)}${byte(r)}${byte(g)}${byte(b)})`;
}

const num = (n: number) => (Number.isInteger(n) ? n.toFixed(1) : String(n));
// `2xl` stays `2xl` (radius2xl, breakpoint2xl) — the names the Flutter layer already uses.
const sizeKey = (k: string) => cap(k);

/** FontWeight has only w100..w900 — the nearest step (ties round down, so 450 → w400). */
function dartFontWeight(w: number): string {
  const hundred = Math.min(900, Math.max(100, Math.ceil(w / 100 - 0.5) * 100));
  return `FontWeight.w${hundred}`;
}

/** CSS tracking is in em; Flutter letterSpacing is logical px = em × fontSize. */
function letterSpacing(tracking: string, size: number): number {
  if (!tracking || tracking === "0") return 0;
  return Math.round(parseFloat(String(tracking)) * size * 100) / 100;
}

/**
 * aeros_tokens.g.dart — raw constants (`AerosTokens`). The hand-written token
 * files (colors.dart, spacing.dart, …) alias these.
 */
export function buildDartTokens(tokens: Tokens): string {
  const L: string[] = [];
  L.push(`// ${GENERATED}`);
  L.push("// ignore_for_file: constant_identifier_names");
  L.push("");
  L.push("import 'package:flutter/material.dart';");
  L.push("");
  L.push("class AerosTokens {");
  L.push("  AerosTokens._();");
  L.push("");
  L.push("  // ─── Color ramps ───");
  for (const [group, ramp] of ramps(tokens)) {
    for (const [stop, v] of Object.entries(ramp)) L.push(`  static const Color ${group}${stop} = ${dartColor(v.$value)};`);
  }
  L.push("");
  L.push("  // ─── Semantic (light / dark) ───");
  for (const [k, v] of Object.entries(semantic(tokens, "semantic"))) L.push(`  static const Color ${camel(k)} = ${dartColor(v)};`);
  for (const [k, v] of Object.entries(semantic(tokens, "semanticDark"))) L.push(`  static const Color ${camel(k)}Dark = ${dartColor(v)};`);
  L.push("");
  L.push("  // ─── Breakpoints (logical px) ───");
  for (const [k, v] of Object.entries(tokens.breakpoint)) L.push(`  static const double breakpoint${sizeKey(k)} = ${Number(v).toFixed(1)};`);
  L.push("");
  L.push("  // ─── Motion (ms + curves) ───");
  for (const [k, v] of Object.entries(tokens.motion.duration)) L.push(`  static const Duration duration${cap(k)} = Duration(milliseconds: ${v});`);
  for (const [k, v] of Object.entries(tokens.motion.ease)) {
    const m = String(v).match(/cubic-bezier\(([^)]+)\)/);
    if (!m) throw new Error(`motion.ease.${k} is not a cubic-bezier(): "${v}"`);
    const args = m[1].split(",").map((n) => Number(n.trim())).join(", ");
    L.push(`  static const Cubic ease${cap(k)} = Cubic(${args});`);
  }
  L.push("");
  L.push("  // ─── Theme aliases (light / dark) ───");
  for (const theme of ["light", "dark"] as const) {
    for (const [k, v] of Object.entries(tokens.alias[theme] as Record<string, string>)) {
      L.push(`  static const Color alias${cap(theme)}${cap(camel(k))} = ${dartColor(v)};`);
    }
  }
  L.push("");
  L.push("  // ─── Spacing (dp) ───");
  for (const [k, v] of Object.entries(tokens.space)) L.push(`  static const double space${k.replace(".", "_")} = ${Number(v).toFixed(1)};`);
  L.push("");
  L.push("  // ─── Radii ───");
  for (const [k, v] of Object.entries(tokens.radius)) L.push(`  static const double radius${sizeKey(k)} = ${Number(v).toFixed(1)};`);
  L.push("");
  L.push("  // ─── Font families ───");
  L.push("  static const String fontSans = 'Inter';");
  L.push("  static const String fontMono = 'IBM Plex Mono';");
  L.push("}");
  return L.join("\n") + "\n";
}

/** A value class with one `Color` field per key, light/dark instances and lerp. */
function colorSet(name: string, doc: string[], keys: string[], lightRef: (k: string) => string, darkRef: (k: string) => string): string[] {
  const fields = keys.map(camel);
  const L: string[] = [];
  for (const d of doc) L.push(`/// ${d}`);
  L.push("@immutable");
  L.push(`class ${name} {`);
  L.push(`  const ${name}({`);
  for (const f of fields) L.push(`    required this.${f},`);
  L.push("  });");
  L.push("");
  for (const f of fields) L.push(`  final Color ${f};`);
  L.push("");
  L.push(`  static const ${name} light = ${name}(`);
  keys.forEach((k, i) => L.push(`    ${fields[i]}: ${lightRef(k)},`));
  L.push("  );");
  L.push("");
  L.push(`  static const ${name} dark = ${name}(`);
  keys.forEach((k, i) => L.push(`    ${fields[i]}: ${darkRef(k)},`));
  L.push("  );");
  L.push("");
  L.push(`  static ${name} resolve(bool isDark) => isDark ? dark : light;`);
  L.push("");
  L.push(`  /// Interpolates every colour — theme changes animate instead of snapping.`);
  L.push(`  static ${name} lerp(${name} a, ${name} b, double t) => ${name}(`);
  for (const f of fields) L.push(`        ${f}: Color.lerp(a.${f}, b.${f}, t)!,`);
  L.push("      );");
  L.push("}");
  return L;
}

function shadowList(value: string, label: string): string {
  const layers = parseShadow(value, label);
  if (layers.length === 0) return "<BoxShadow>[]";
  const items = layers.map((s) => {
    if (s.inset) throw new Error(`${label}: inset shadows have no Flutter equivalent`);
    const alpha = Math.round(s.a * 255).toString(16).padStart(2, "0").toUpperCase();
    const rgb = [s.r, s.g, s.b].map((c) => Math.round(c).toString(16).padStart(2, "0").toUpperCase()).join("");
    const parts = [`color: Color(0x${alpha}${rgb})`, `blurRadius: ${num(s.blur)}`];
    if (s.spread !== 0) parts.push(`spreadRadius: ${num(s.spread)}`);
    if (s.x !== 0 || s.y !== 0) parts.push(`offset: Offset(${num(s.x)}, ${num(s.y)})`);
    return `    BoxShadow(${parts.join(", ")}),`;
  });
  return `<BoxShadow>[\n${items.join("\n")}\n  ]`;
}

/**
 * aeros_theme_tokens.g.dart — typed, theme-aware classes built on AerosTokens:
 * alias + status colour sets, the type scale and shadows. Generated whole, so a
 * token added to tokens.json appears in Dart without a hand edit.
 */
export function buildDartTheme(tokens: Tokens): string {
  const L: string[] = [];
  L.push(`// ${GENERATED}`);
  L.push("");
  L.push("import 'package:flutter/material.dart';");
  L.push("");
  L.push("import 'aeros_tokens.g.dart';");
  L.push("");

  L.push(
    ...colorSet(
      "AerosSemanticColors",
      [
        "Theme-aware status colors — light chips read wrong on dark surfaces, so",
        "each tone carries a true dark counterpart (`semantic` / `semanticDark` in",
        "tokens.json). Resolve via `context.aerosSemantic`."
      ],
      Object.keys(semantic(tokens, "semantic")),
      (k) => `AerosTokens.${camel(k)}`,
      (k) => `AerosTokens.${camel(k)}Dark`
    )
  );
  L.push("");
  L.push(
    ...colorSet(
      "AerosAliasColors",
      [
        "Theme-aware aliases (`alias.light` / `alias.dark` in tokens.json).",
        "Resolve via `context.aerosColors`."
      ],
      Object.keys(tokens.alias.light),
      (k) => `AerosTokens.aliasLight${cap(camel(k))}`,
      (k) => `AerosTokens.aliasDark${cap(camel(k))}`
    )
  );
  L.push("");

  L.push("/// The type scale (`text` in tokens.json) as const styles.");
  L.push("///");
  L.push("/// Inter is a variable font: the glyph weight follows the `wght` axis, not");
  L.push("/// `fontWeight`, so every sans style pins both (and the `opsz` optical cut).");
  L.push("/// `overline` is uppercased by the caller (TextStyle has no transform).");
  L.push("class AerosTypeScale {");
  L.push("  AerosTypeScale._();");
  L.push("");
  for (const [name, s] of Object.entries(tokens.text as Record<string, Tokens>)) {
    const mono = s.family === "mono";
    const opsz = s.opsz ?? (s.size >= 28 ? 32 : 14);
    L.push(`  static const TextStyle ${camel(name)} = TextStyle(`);
    // Both faces are bundled with the Flutter package, so every style names it.
    L.push(`    fontFamily: AerosTokens.${mono ? "fontMono" : "fontSans"},`);
    L.push(`    package: '${FLUTTER_PACKAGE}',`);
    L.push(`    fontSize: ${num(Number(s.size))},`);
    L.push(`    fontWeight: ${dartFontWeight(s.weight)},`);
    L.push(`    height: ${num(Number(s.lineHeight))},`);
    L.push(`    letterSpacing: ${num(letterSpacing(s.tracking, s.size))},`);
    if (!mono) {
      L.push(`    fontVariations: [FontVariation('wght', ${num(Number(s.weight))}), FontVariation('opsz', ${num(Number(opsz))})],`);
    }
    L.push("  );");
  }
  L.push("}");
  L.push("");

  L.push("/// Shadows (`shadow` / `shadowDark` in tokens.json), parsed from the CSS values.");
  L.push("class AerosShadowTokens {");
  L.push("  AerosShadowTokens._();");
  L.push("");
  for (const [k, v] of Object.entries(tokens.shadow as Record<string, string>)) {
    L.push(`  static const List<BoxShadow> ${camel(k)} = ${shadowList(v, `shadow.${k}`)};`);
  }
  L.push("");
  for (const [k, v] of Object.entries(tokens.shadowDark as Record<string, string>)) {
    L.push(`  static const List<BoxShadow> ${camel(k)}Dark = ${shadowList(v, `shadowDark.${k}`)};`);
  }
  L.push("}");
  L.push("");

  // Elevation intents — one value class with light/dark instances.
  const intents = Object.keys(tokens.elevation.light);
  L.push("/// Elevation intents (`elevation` in tokens.json). Resting surfaces carry a");
  L.push("/// hairline and no shadow; only these intents float. Overlay and modal draw");
  L.push("/// their own 1px edge inside the shadow, in both themes.");
  L.push("@immutable");
  L.push("class AerosElevation {");
  L.push(`  const AerosElevation({${intents.map((k) => `required this.${camel(k)}`).join(", ")}});`);
  L.push("");
  for (const k of intents) L.push(`  final List<BoxShadow> ${camel(k)};`);
  for (const theme of ["light", "dark"] as const) {
    L.push("");
    L.push(`  static const AerosElevation ${theme} = AerosElevation(`);
    for (const k of intents) L.push(`    ${camel(k)}: ${shadowList(tokens.elevation[theme][k], `elevation.${theme}.${k}`).replace(/\n {2}/g, "\n    ")},`);
    L.push("  );");
  }
  L.push("");
  L.push("  static AerosElevation resolve(bool isDark) => isDark ? dark : light;");
  L.push("");
  L.push("  static AerosElevation lerp(AerosElevation a, AerosElevation b, double t) => AerosElevation(");
  for (const k of intents) L.push(`        ${camel(k)}: BoxShadow.lerpList(a.${camel(k)}, b.${camel(k)}, t)!,`);
  L.push("      );");
  L.push("}");
  L.push("");

  // Density-dependent sizes.
  const dens = sizes(tokens, "pointer").map(([k]) => k);
  L.push("/// Sizes that change with input density (`size` in tokens.json): `pointer` for");
  L.push("/// a mouse, `touch` for fingers.");
  L.push("@immutable");
  L.push("class AerosSizeTokens {");
  L.push("  const AerosSizeTokens({");
  for (const k of dens) L.push(`    required this.${camel(k)},`);
  L.push("  });");
  L.push("");
  for (const k of dens) L.push(`  final double ${camel(k)};`);
  for (const d of ["pointer", "touch"] as const) {
    L.push("");
    L.push(`  static const AerosSizeTokens ${d} = AerosSizeTokens(`);
    for (const [k, v] of sizes(tokens, d)) L.push(`    ${camel(k)}: ${num(v)},`);
    L.push("  );");
  }
  L.push("");
  L.push("  // ─── Density-independent ───");
  for (const [k, v] of sizes(tokens, null)) L.push(`  static const double ${camel(k)} = ${num(v)};`);
  L.push("}");
  L.push("");

  L.push("/// Semantic radii (`shape` in tokens.json) — widgets use these, never a raw scale step.");
  L.push("class AerosShapeTokens {");
  L.push("  AerosShapeTokens._();");
  L.push("");
  for (const [k, v] of Object.entries(tokens.shape)) L.push(`  static const double ${camel(k)} = ${num(Number(v))};`);
  L.push("}");
  L.push("");

  L.push("/// Focus ring, opacity, border width and layout metrics.");
  L.push("class AerosMetricTokens {");
  L.push("  AerosMetricTokens._();");
  L.push("");
  for (const [k, v] of Object.entries(tokens.focus)) L.push(`  static const double focus${cap(camel(k))} = ${num(Number(v))};`);
  for (const [k, v] of Object.entries(tokens.opacity)) L.push(`  static const double opacity${cap(camel(k))} = ${num(Number(v))};`);
  for (const [k, v] of Object.entries(tokens.borderWidth)) L.push(`  static const double border${cap(camel(k))} = ${num(Number(v))};`);
  for (const [k, v] of layout(tokens)) L.push(`  static const double layout${cap(camel(k))} = ${num(v)};`);
  L.push("}");
  return L.join("\n") + "\n";
}
