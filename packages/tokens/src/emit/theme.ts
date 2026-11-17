import { GENERATED, px, ramps, semantic, type Tokens } from "./shared";

/**
 * dist/css/theme.css — the Tailwind v4 theme, generated so the utility names
 * can never drift from tokens.json. Import it after "tailwindcss":
 *
 *   @import "tailwindcss";
 *   @import "@aeros-core/tokens/css";
 *   @import "@aeros-core/tokens/theme.css";
 *
 * Two blocks:
 *   @theme         — namespace resets + static values. The resets remove
 *                    Tailwind's default palette, radii, shadows and easings, so
 *                    an off-brand class (bg-blue-500) generates nothing.
 *   @theme inline  — everything that points at an --aeros-* variable. `inline`
 *                    makes utilities reference the --aeros-* variable directly,
 *                    so a nested [data-theme] re-themes its subtree (a plain
 *                    @theme would resolve once at :root).
 */
export function buildTheme(tokens: Tokens): string {
  const L: string[] = [];
  L.push(`/* ${GENERATED} */`);
  L.push("");
  L.push("/* dark: variant — matches data-theme=\"dark\" and, under a dark OS setting, data-theme=\"system\". */");
  L.push("@custom-variant dark {");
  L.push("  &:where([data-theme='dark'], [data-theme='dark'] *) {");
  L.push("    @slot;");
  L.push("  }");
  L.push("  @media (prefers-color-scheme: dark) {");
  L.push("    &:where([data-theme='system'], [data-theme='system'] *) {");
  L.push("      @slot;");
  L.push("    }");
  L.push("  }");
  L.push("}");
  L.push("");

  L.push("@theme {");
  L.push("  /* Resets — only Aeros tokens compile. */");
  L.push("  --color-*: initial;");
  L.push("  --radius-*: initial;");
  L.push("  --shadow-*: initial;");
  L.push("  --ease-*: initial;");
  L.push("  --font-*: initial;");
  L.push("");
  L.push("  --color-white: #FFFFFF;");
  L.push("  --color-black: #000000;");
  for (const [group, ramp] of ramps(tokens)) {
    for (const [stop, v] of Object.entries(ramp)) L.push(`  --color-${group}-${stop}: ${v.$value};`);
  }
  L.push("");
  L.push(`  --font-sans: ${tokens.font.family.sans};`);
  L.push(`  --font-mono: ${tokens.font.family.mono};`);
  L.push("");
  for (const [k, v] of Object.entries(tokens.radius)) L.push(`  --radius-${k}: ${px(v)};`);
  L.push("");
  for (const [k, v] of Object.entries(tokens.breakpoint)) L.push(`  --breakpoint-${k}: ${Number(v) / 16}rem;`);
  L.push("}");
  L.push("");

  L.push("@theme inline {");
  L.push("  /* Status colours */");
  for (const k of Object.keys(semantic(tokens, "semantic"))) L.push(`  --color-${k}: var(--aeros-color-semantic-${k});`);
  L.push("");
  L.push("  /* Aliases */");
  for (const k of Object.keys(tokens.alias.light)) L.push(`  --color-${k}: var(--aeros-${k});`);
  L.push("");
  for (const k of Object.keys(tokens.shadow)) L.push(`  --shadow-${k}: var(--aeros-shadow-${k});`);
  L.push("");
  for (const k of Object.keys(tokens.motion.ease)) L.push(`  --ease-${k}: var(--aeros-ease-${k});`);
  L.push("}");
  return L.join("\n") + "\n";
}
