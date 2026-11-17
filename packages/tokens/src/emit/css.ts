import { GENERATED, layout, px, ramps, semantic, sizes, type Tokens } from "./shared";

/**
 * dist/css/tokens.css — every token as an `--aeros-*` custom property.
 *
 * Theme model:
 *   - no attribute, or [data-theme="light"]  → light
 *   - [data-theme="dark"]                     → dark
 *   - [data-theme="system"]                   → follows prefers-color-scheme
 * The attribute may sit on any element, so a subtree can be themed on its own
 * (e.g. dark chrome inside a light app).
 */
export function buildCss(tokens: Tokens): string {
  const L: string[] = [];
  const light = tokens.alias.light as Record<string, string>;
  const dark = tokens.alias.dark as Record<string, string>;

  const themed = (indent: string, aliases: Record<string, string>, set: "semantic" | "semanticDark", shadows: Record<string, string>, scheme: "light" | "dark") => {
    L.push(`${indent}color-scheme: ${scheme};`);
    for (const [k, v] of Object.entries(aliases)) L.push(`${indent}--aeros-${k}: ${v};`);
    for (const [k, v] of Object.entries(semantic(tokens, set))) L.push(`${indent}--aeros-color-semantic-${k}: ${v};`);
    for (const [k, v] of Object.entries(shadows)) L.push(`${indent}--aeros-shadow-${k}: ${v};`);
    for (const [k, v] of Object.entries(tokens.elevation[scheme])) L.push(`${indent}--aeros-elevation-${k}: ${v};`);
  };

  L.push(`/* ${GENERATED} */`);
  L.push(":root {");
  L.push(`  --aeros-font-sans: ${tokens.font.family.sans};`);
  L.push(`  --aeros-font-mono: ${tokens.font.family.mono};`);
  L.push(`  --aeros-font-logo: ${tokens.font.family.logo};`);
  for (const [group, ramp] of ramps(tokens)) {
    for (const [stop, v] of Object.entries(ramp)) L.push(`  --aeros-color-${group}-${stop}: ${v.$value};`);
  }
  for (const [k, v] of Object.entries(tokens.radius)) L.push(`  --aeros-radius-${k}: ${px(v)};`);
  for (const [k, v] of Object.entries(tokens.space)) {
    // Custom property idents can't contain '.' — lightningcss rejects it.
    L.push(`  --aeros-space-${String(k).replace(/\./g, "_")}: ${px(v)};`);
  }
  for (const [k, v] of Object.entries(tokens.motion.duration)) L.push(`  --aeros-duration-${k}: ${v}ms;`);
  for (const [k, v] of Object.entries(tokens.motion.ease)) L.push(`  --aeros-ease-${k}: ${v};`);
  for (const [k, v] of Object.entries(tokens.z)) L.push(`  --aeros-z-${k}: ${v};`);
  for (const [k, v] of Object.entries(tokens.breakpoint)) L.push(`  --aeros-breakpoint-${k}: ${v}px;`);
  // Semantic radii — components use these, never a raw scale step.
  for (const [k, v] of Object.entries(tokens.shape)) L.push(`  --aeros-radius-${k}: ${px(v)};`);
  for (const [k, v] of sizes(tokens, null)) L.push(`  --aeros-size-${k}: ${v}px;`);
  for (const [k, v] of Object.entries(tokens.focus)) L.push(`  --aeros-focus-${k}: ${px(v)};`);
  for (const [k, v] of Object.entries(tokens.opacity)) L.push(`  --aeros-opacity-${k}: ${v};`);
  for (const [k, v] of Object.entries(tokens.borderWidth)) L.push(`  --aeros-border-width-${k}: ${px(v)};`);
  for (const [k, v] of layout(tokens)) L.push(`  --aeros-layout-${k}: ${v}px;`);
  L.push("}");
  L.push("");

  // Density — pointer (mouse) sizes by default; data-density="touch" on any
  // element switches its subtree to the touch sizes.
  L.push("/* Density: pointer (default) */");
  L.push(":root, [data-density='pointer'] {");
  for (const [k, v] of sizes(tokens, "pointer")) L.push(`  --aeros-size-${k}: ${v}px;`);
  L.push("}");
  L.push("");
  L.push("/* Density: touch */");
  L.push("[data-density='touch'] {");
  for (const [k, v] of sizes(tokens, "touch")) L.push(`  --aeros-size-${k}: ${v}px;`);
  L.push("}");
  L.push("");

  L.push("/* Light (default) */");
  L.push(":root, [data-theme='light'] {");
  themed("  ", light, "semantic", tokens.shadow, "light");
  L.push("}");
  L.push("");

  // Dark surfaces: rgba-black shadows vanish on near-black, so dark elevation
  // values carry their own light hairline.
  L.push("/* Dark */");
  L.push("[data-theme='dark'] {");
  themed("  ", dark, "semanticDark", tokens.shadowDark, "dark");
  L.push("}");
  L.push("");

  L.push("/* System — opt in with data-theme=\"system\"; follows the OS setting. */");
  L.push("@media (prefers-color-scheme: dark) {");
  L.push("  [data-theme='system'] {");
  themed("    ", dark, "semanticDark", tokens.shadowDark, "dark");
  L.push("  }");
  L.push("}");
  L.push("");

  L.push("@media (prefers-reduced-motion: reduce) {");
  L.push("  *, *::before, *::after { animation-duration: 0.01ms !important; transition-duration: 0.01ms !important; }");
  L.push("}");
  L.push("");

  // Type scale utility classes (.aeros-text-<role>) — kept for 2.x consumers.
  L.push("/* Type scale — utility classes (.aeros-text-<role>) */");
  for (const [name, s] of Object.entries(tokens.text as Record<string, Tokens>)) {
    L.push(`.aeros-text-${name} {`);
    L.push(`  font-family: ${s.family === "mono" ? "var(--aeros-font-mono)" : "var(--aeros-font-sans)"};`);
    L.push(`  font-size: ${s.size}px;`);
    L.push(`  font-weight: ${s.weight};`);
    L.push(`  line-height: ${s.lineHeight};`);
    L.push(`  letter-spacing: ${s.tracking};`);
    if (s.transform) L.push(`  text-transform: ${s.transform};`);
    L.push("}");
  }
  return L.join("\n") + "\n";
}
