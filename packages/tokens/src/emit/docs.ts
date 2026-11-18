import { camel, cap, layout, px, ramps, semantic, sizes, type Tokens } from "./shared";

/**
 * docs/tokens.md — the token reference, rendered from tokens.json so the
 * written reference can never disagree with the values that ship.
 *
 * `tokens` is the resolved tree, `raw` is tokens.json as authored: a value
 * that is a reference is shown as the reference and as what it resolves to.
 *
 * The output is deterministic (source order, no dates), so CI can rebuild it
 * and fail on a diff.
 */

const code = (s: unknown) => `\`${String(s)}\``;

function table(head: string[], rows: string[][]): string[] {
  return [
    `| ${head.join(" | ")} |`,
    `|${head.map(() => "---").join("|")}|`,
    ...rows.map((r) => `| ${r.join(" | ")} |`)
  ];
}

/** The authored value: a `{reference}` when it is one, otherwise a dash. */
const ref = (v: unknown) => (typeof v === "string" && /^\{.*\}$/.test(v) ? code(v) : "—");

/** DTCG leaf (`{ $value }`) or plain value → the value. */
const leaf = (v: unknown) => (v !== null && typeof v === "object" && "$value" in (v as object) ? (v as { $value: unknown }).$value : v);

/** Hand-written Dart names that do not follow the token key mechanically. */
const dartSpace = (k: string) => (k === "px" ? "sPx" : `s${k.replace(".", "_")}`);
const dartBreakpoint = (k: string) => (k === "2xl" ? "xxl" : k);
const cssSpace = (k: string) => k.replace(/\./g, "_");

function naming(css: string, tailwind: string, dart: string): string[] {
  return ["", ...table(["Platform", "Name"], [["CSS variable", css], ["Tailwind class", tailwind], ["Dart", dart]]), ""];
}

export function buildTokenDocs(tokens: Tokens, raw: Tokens): string {
  const L: string[] = [];
  const h2 = (t: string) => L.push("", `## ${t}`, "");
  const h3 = (t: string) => L.push("", `### ${t}`, "");
  const p = (...t: string[]) => L.push(...t);

  p(
    "<!-- Generated from packages/tokens/src/tokens.json by packages/tokens/src/emit/docs.ts. Do not edit. -->",
    "<!-- Change tokens.json, then run `pnpm build:tokens`. CI fails when this file is stale. -->",
    "",
    "# Tokens",
    "",
    `Token reference for version ${tokens.meta.version}. This file is generated — do not edit it. Change [\`packages/tokens/src/tokens.json\`](../packages/tokens/src/tokens.json) and run \`pnpm build:tokens\`.`,
    "",
    "Every token reaches three places: a CSS custom property (`@aeros-core/tokens/css`), a Tailwind v4 theme key and its utilities (`@aeros-core/tokens/theme.css`), and a Dart member in `aeros_design_system`. Each section gives the naming pattern for all three.",
    "",
    "A value written as `{color.ink.900}` is a reference to another token; `{color.ink.900 / 0.05}` is that colour at 5% alpha. The tables show the reference as authored and the value it resolves to."
  );

  // ── Colour ─────────────────────────────────────────────
  h2("Colour");
  for (const [group, ramp] of ramps(tokens)) {
    h3(`${cap(group)} ramp`);
    p(`The neutral ramp. Components use the aliases below, not ramp stops; the ramp is for the aliases to point at.`);
    p(
      ...naming(
        code(`--aeros-color-${group}-<stop>`),
        `${code(`bg-${group}-<stop>`)}, ${code(`text-${group}-<stop>`)}, ${code(`border-${group}-<stop>`)}`,
        code(`AerosColors.${group}<stop>`)
      )
    );
    p(
      ...table(
        ["Stop", "Value", "CSS variable", "Dart"],
        Object.entries(ramp).map(([stop, v]) => [
          code(stop),
          code(v.$value),
          code(`--aeros-color-${group}-${stop}`),
          code(`AerosColors.${group}${stop}`)
        ])
      )
    );
  }

  h3("Aliases");
  p("Theme-aware colours. They change with `data-theme` on the web and with the `ThemeData` brightness in Flutter. Use these in product code.");
  p(
    ...naming(
      code("--aeros-<alias>"),
      `${code("bg-<alias>")}, ${code("text-<alias>")}, ${code("border-<alias>")} (any colour utility)`,
      `${code("context.aerosColors.<aliasInCamelCase>")} (${code("AerosAliasColors")})`
    )
  );
  const rawLight = raw.alias.light as Record<string, string>;
  const rawDark = raw.alias.dark as Record<string, string>;
  p(
    ...table(
      ["Alias", "Light reference", "Light value", "Dark reference", "Dark value", "Dart"],
      Object.keys(tokens.alias.light).map((k) => [
        code(k),
        ref(rawLight[k]),
        code(tokens.alias.light[k]),
        ref(rawDark[k]),
        code(tokens.alias.dark[k]),
        code(camel(k))
      ])
    )
  );

  h3("Status colours");
  p("The only hues in the system. They mark state — success, warning, danger, info — and nothing else. `info` is neutral: it points into the ink ramp.");
  p(
    ...naming(
      code("--aeros-color-semantic-<name>"),
      `${code("bg-<name>")}, ${code("text-<name>")}, ${code("border-<name>")} (any colour utility)`,
      `${code("context.aerosSemantic.<nameInCamelCase>")} (${code("AerosSemanticColors")})`
    )
  );
  const light = semantic(tokens, "semantic");
  const dark = semantic(tokens, "semanticDark");
  p(
    ...table(
      ["Name", "Light reference", "Light value", "Dark reference", "Dark value", "Dart"],
      Object.keys(light).map((k) => [
        code(k),
        ref(leaf(raw.color.semantic[k])),
        code(light[k]),
        ref(leaf(raw.color.semanticDark[k])),
        code(dark[k]),
        code(camel(k))
      ])
    )
  );

  // ── Type ───────────────────────────────────────────────
  h2("Type");
  h3("Families");
  p(
    ...table(
      ["Family", "Stack", "CSS variable", "Use"],
      [
        ["sans", code(tokens.font.family.sans), code("--aeros-font-sans"), "All interface text"],
        ["mono", code(tokens.font.family.mono), code("--aeros-font-mono"), "Data: IDs, amounts, timestamps"],
        ["logo", code(tokens.font.family.logo), code("--aeros-font-logo"), "The wordmark only"]
      ]
    )
  );
  p("", "Tailwind: `font-sans`, `font-mono`. The wordmark has no utility: use the `aeros-logo` class on the web and `AerosWordmark` in Flutter.");

  h3("Weights");
  p(...table(["Name", "Weight"], Object.entries(tokens.font.weight).map(([k, v]) => [code(k), String(v)])));

  h3("Type scale");
  p("A role sets size, line height, tracking and weight together.");
  p(
    ...naming(
      `${code("--text-<role>")} (Tailwind theme key, with ${code("--line-height")}, ${code("--letter-spacing")} and ${code("--font-weight")} modifiers)`,
      code("text-<role>"),
      `${code("AerosTypography.<roleInCamelCase>()")}`
    )
  );
  p(
    ...table(
      ["Role", "Size (px)", "Weight", "Line height", "Tracking", "Family", "Tailwind class", "Dart"],
      Object.entries(tokens.text as Record<string, Tokens>).map(([name, s]) => [
        code(name),
        String(s.size),
        String(s.weight),
        String(s.lineHeight),
        String(s.tracking),
        (s.family ?? "sans") + (s.transform ? `, ${s.transform}` : ""),
        code(`text-${name}`),
        code(`AerosTypography.${camel(name)}()`)
      ])
    )
  );

  // ── Spacing ────────────────────────────────────────────
  h2("Spacing");
  p("A 4px base with half steps.");
  p(
    ...naming(
      `${code("--aeros-space-<step>")} (a ${code(".")} in the step is written ${code("_")})`,
      `Tailwind's numeric spacing utilities use the same 4px base: ${code("p-4")} is 16px, ${code("gap-1.5")} is 6px`,
      code("AerosSpacing.s<step>")
    )
  );
  p(
    ...table(
      ["Step", "Value", "CSS variable", "Dart"],
      Object.entries(tokens.space).map(([k, v]) => [code(k), px(v), code(`--aeros-space-${cssSpace(k)}`), code(`AerosSpacing.${dartSpace(k)}`)])
    )
  );

  // ── Radius ─────────────────────────────────────────────
  h2("Radius");
  h3("Semantic radii");
  p("Components use these. A semantic radius names what the corner belongs to, so nested corners stay concentric.");
  p(...naming(code("--aeros-radius-<name>"), code("rounded-<name>"), code("AerosShapeTokens.<name>")));
  p(
    ...table(
      ["Name", "Reference", "Value", "Tailwind class", "Dart"],
      Object.entries(tokens.shape).map(([k, v]) => [code(k), ref(raw.shape[k]), px(v), code(`rounded-${k}`), code(`AerosShapeTokens.${camel(k)}`)])
    )
  );
  h3("Scale");
  p("The steps the semantic radii point at. Prefer a semantic radius.");
  p(...naming(code("--aeros-radius-<step>"), code("rounded-<step>"), code("AerosRadii.<step>")));
  p(
    ...table(
      ["Step", "Value", "Tailwind class", "Dart"],
      Object.entries(tokens.radius).map(([k, v]) => [code(k), px(v), code(`rounded-${k}`), code(`AerosRadii.${camel(k)}`)])
    )
  );

  // ── Elevation ──────────────────────────────────────────
  h2("Elevation");
  p("Three intents. Resting surfaces take a hairline border and no shadow; only floating layers take an elevation. `overlay` and `modal` draw their own 1px edge inside the shadow, so a floating surface takes no border.");
  p(
    ...naming(
      code("--aeros-elevation-<intent>"),
      code("shadow-<intent>"),
      `${code("context.aerosElevation.<intent>")} (${code("AerosElevation")}), or ${code("AerosSurface(level: …)")}`
    )
  );
  p(
    ...table(
      ["Intent", "Light", "Dark"],
      Object.keys(tokens.elevation.light).map((k) => [code(k), code(tokens.elevation.light[k]), code(tokens.elevation.dark[k])])
    )
  );

  // ── Sizes ──────────────────────────────────────────────
  h2("Sizes");
  h3("Density-dependent");
  p("Each size has a pointer (mouse) value and a touch value. The web defaults to pointer and switches a subtree with `data-density=\"touch\"`. Flutter defaults to touch and switches a subtree with `AerosDensityScope`.");
  p(
    ...naming(
      code("--aeros-size-<name>"),
      `${code("h-<name>")}, ${code("w-<name>")}, ${code("size-<name>")}, ${code("min-h-<name>")} (spacing utilities)`,
      `${code("AerosDensity.of(context).sizes.<nameInCamelCase>")} (${code("AerosSizeTokens.pointer")} / ${code("AerosSizeTokens.touch")})`
    )
  );
  const touch = new Map(sizes(tokens, "touch"));
  p(
    ...table(
      ["Name", "Pointer", "Touch", "CSS variable", "Dart"],
      sizes(tokens, "pointer").map(([k, v]) => [code(k), px(v), px(touch.get(k)), code(`--aeros-size-${k}`), code(camel(k))])
    )
  );
  h3("Fixed");
  p(...naming(code("--aeros-size-<name>"), `${code("size-<name>")}, ${code("h-<name>")}, ${code("w-<name>")}`, code("AerosSizeTokens.<nameInCamelCase>")));
  p(
    ...table(
      ["Name", "Value", "CSS variable", "Dart"],
      sizes(tokens, null).map(([k, v]) => [code(k), px(v), code(`--aeros-size-${k}`), code(`AerosSizeTokens.${camel(k)}`)])
    )
  );

  // ── Motion ─────────────────────────────────────────────
  h2("Motion");
  h3("Durations");
  p(...naming(code("--aeros-duration-<name>"), code("duration-<name>"), code("AerosMotion.<name>")));
  p(
    ...table(
      ["Name", "Value", "Tailwind class", "Dart"],
      Object.entries(tokens.motion.duration).map(([k, v]) => [code(k), `${v}ms`, code(`duration-${k}`), code(`AerosMotion.${camel(k)}`)])
    )
  );
  h3("Easings");
  p(...naming(code("--aeros-ease-<name>"), code("ease-<name>"), code("AerosMotion.<name>")));
  p(
    ...table(
      ["Name", "Value", "Tailwind class", "Dart"],
      Object.entries(tokens.motion.ease).map(([k, v]) => [code(k), code(v), code(`ease-${k}`), code(`AerosMotion.${camel(k)}`)])
    )
  );
  p("", "A `transition-*` utility with no duration or easing class uses `fast` and `standard`. Under `prefers-reduced-motion: reduce` the token stylesheet shortens every animation and transition to 0.01ms; in Flutter wrap a duration in `AerosMotion.resolve(context, …)`.");

  // ── Focus, opacity, border width ───────────────────────
  h2("Focus ring");
  p("The metrics of the one focus ring. Its colour is the `focus-ring` alias.");
  p(
    ...naming(
      code("--aeros-focus-<name>"),
      `${code("outline-focus")} (width), ${code("outline-offset-focus")}, ${code("outline-offset-field")}, ${code("outline-offset-inset")}`,
      code("AerosMetricTokens.focus<NameInPascalCase>")
    )
  );
  p(
    ...table(
      ["Name", "Value", "CSS variable", "Dart"],
      Object.entries(tokens.focus).map(([k, v]) => [code(k), px(v), code(`--aeros-focus-${k}`), code(`AerosMetricTokens.focus${cap(camel(k))}`)])
    )
  );

  h2("Opacity");
  p(...naming(code("--aeros-opacity-<name>"), code("opacity-<name>"), code("AerosMetricTokens.opacity<NameInPascalCase>")));
  p(
    ...table(
      ["Name", "Value", "Tailwind class", "Dart"],
      Object.entries(tokens.opacity).map(([k, v]) => [code(k), String(v), code(`opacity-${k}`), code(`AerosMetricTokens.opacity${cap(camel(k))}`)])
    )
  );

  h2("Border width");
  p(...naming(code("--aeros-border-width-<name>"), code("border-<name>"), code("AerosMetricTokens.border<NameInPascalCase>")));
  p(
    ...table(
      ["Name", "Value", "Tailwind class", "Dart"],
      Object.entries(tokens.borderWidth).map(([k, v]) => [code(k), px(v), code(`border-${k}`), code(`AerosMetricTokens.border${cap(camel(k))}`)])
    )
  );

  // ── Layout ─────────────────────────────────────────────
  h2("Layout");
  p("Widths of the app frame and of modal surfaces.");
  p(
    ...naming(
      code("--aeros-layout-<name>"),
      `${code("w-<name>")} for the sidebar widths (spacing utilities); ${code("max-w-<name>")} for the rest (container utilities)`,
      code("AerosMetricTokens.layout<NameInPascalCase>")
    )
  );
  p(
    ...table(
      ["Name", "Value", "Tailwind class", "Dart"],
      layout(tokens).map(([k, v]) => [
        code(k),
        px(v),
        code(k.startsWith("sidebar") ? `w-${k}` : `max-w-${k}`),
        code(`AerosMetricTokens.layout${cap(camel(k))}`)
      ])
    )
  );

  // ── Z-index, breakpoints ───────────────────────────────
  h2("Z-index");
  p("Web only. Flutter stacks with its own overlay and navigator layers.");
  p(...naming(code("--aeros-z-<layer>"), code("z-<layer>"), "—"));
  p(...table(["Layer", "Value", "Tailwind class"], Object.entries(tokens.z).map(([k, v]) => [code(k), String(v), code(`z-${k}`)])));

  h2("Breakpoints");
  p("The same widths on both platforms.");
  p(...naming(code("--aeros-breakpoint-<name>"), `the ${code("<name>:")} variant`, code("AerosBreakpoints.<name>")));
  p(
    ...table(
      ["Name", "Min width", "Tailwind variant", "Dart"],
      Object.entries(tokens.breakpoint).map(([k, v]) => [code(k), px(v), code(`${k}:`), code(`AerosBreakpoints.${dartBreakpoint(k)}`)])
    )
  );

  // Collapse runs of blank lines so section helpers can pad freely.
  const out: string[] = [];
  for (const line of L) {
    if (line === "" && out[out.length - 1] === "") continue;
    out.push(line);
  }
  return out.join("\n").replace(/\n+$/, "") + "\n";
}
