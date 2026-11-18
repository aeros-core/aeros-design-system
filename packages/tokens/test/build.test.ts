import { readFileSync } from "node:fs";
import { describe, expect, it } from "vitest";
import { composite, isRef, parseHex, resolveTokens, toHex, withAlpha } from "../src/resolve.mjs";
import { buildCss } from "../src/emit/css";
import { buildDartTheme, buildDartTokens, dartColor } from "../src/emit/dart";
import { buildTokenDocs } from "../src/emit/docs";
import { buildDts, buildJs } from "../src/emit/js";
import { parseShadow, splitTopLevel } from "../src/emit/shared";
import { buildTheme } from "../src/emit/theme";

const raw = JSON.parse(readFileSync(new URL("../src/tokens.json", import.meta.url), "utf8"));
const tokens = resolveTokens(raw);

describe("resolveTokens", () => {
  const base = {
    color: { ink: { 900: { $value: "#141417" }, 50: { $value: "#FAFAFA" } } },
    plain: { size: 4 }
  };

  it("replaces a reference with the target's $value", () => {
    const out = resolveTokens({ ...base, alias: { fg: "{color.ink.900}" } });
    expect(out.alias.fg).toBe("#141417");
  });

  it("applies an alpha as #RRGGBBAA", () => {
    const out = resolveTokens({ ...base, alias: { hover: "{color.ink.900 / 0.05}" } });
    expect(out.alias.hover).toBe("#1414170D");
  });

  it("follows chained references and multiplies alphas", () => {
    const out = resolveTokens({ ...base, alias: { a: "{color.ink.900 / 0.5}", b: "{alias.a}", c: "{alias.a / 0.5}" } });
    expect(out.alias.b).toBe("#14141780");
    expect(out.alias.c).toBe("#14141740");
  });

  it("resolves references to plain (non-DTCG) values and inside $value", () => {
    const out = resolveTokens({ ...base, r: { control: "{plain.size}" }, c: { x: { $value: "{color.ink.50}" } } });
    expect(out.r.control).toBe(4);
    expect(out.c.x.$value).toBe("#FAFAFA");
  });

  it("leaves non-reference strings alone and does not mutate the input", () => {
    const input = { ...base, shadow: "0 1px 2px rgba(0,0,0,0.1)", alias: { fg: "{color.ink.900}" } };
    const out = resolveTokens(input);
    expect(out.shadow).toBe(input.shadow);
    expect(input.alias.fg).toBe("{color.ink.900}");
  });

  it("throws on an unknown reference, a group reference and a cycle", () => {
    expect(() => resolveTokens({ a: "{nope.missing}" })).toThrow(/Unknown token reference/);
    expect(() => resolveTokens({ ...base, a: "{color.ink}" })).toThrow(/points at a group/);
    expect(() => resolveTokens({ a: "{b}", b: "{a}" })).toThrow(/Circular token reference/);
  });

  it("recognises reference syntax", () => {
    expect(isRef("{color.ink.900}")).toBe(true);
    expect(isRef("{color.ink.900 / 0.07}")).toBe(true);
    expect(isRef("#141417")).toBe(false);
    expect(isRef(12)).toBe(false);
  });
});

describe("colour helpers", () => {
  it("parses 3, 6 and 8 digit hex", () => {
    expect(parseHex("#fff")).toEqual({ r: 255, g: 255, b: 255, a: 1 });
    expect(parseHex("#141417")).toEqual({ r: 20, g: 20, b: 23, a: 1 });
    expect(parseHex("#14141780").a).toBeCloseTo(0.5, 2);
    expect(() => parseHex("rgb(0,0,0)")).toThrow();
  });

  it("round-trips and composites", () => {
    expect(toHex(parseHex("#DC2626"))).toBe("#DC2626");
    expect(withAlpha("#000000", 0.5)).toBe("#00000080");
    expect(composite("#00000080", "#FFFFFF")).toBe("#7F7F7F");
    expect(composite("#141417", "#FFFFFF")).toBe("#141417");
  });

  it("emits Dart colours with the alpha byte first", () => {
    expect(dartColor("#141417")).toBe("Color(0xFF141417)");
    expect(dartColor("#1414170D")).toBe("Color(0x0D141417)");
  });
});

describe("parseShadow", () => {
  it("splits layers on top-level commas only", () => {
    expect(splitTopLevel("0 1px 2px rgba(0,0,0,0.1), 0 0 0 1px rgb(0 0 0 / 0.08)")).toHaveLength(2);
  });

  it("parses offsets, blur, optional spread and both colour syntaxes", () => {
    const [a, b] = parseShadow("0 4px 12px -2px rgb(0 0 0 / 0.10), 0 0 0 1px rgba(255,255,255,0.08)", "t");
    expect(a).toMatchObject({ x: 0, y: 4, blur: 12, spread: -2, r: 0, a: 0.1, inset: false });
    expect(b).toMatchObject({ blur: 0, spread: 1, r: 255, a: 0.08 });
  });

  it("returns no layers for `none` and throws on anything it cannot read", () => {
    expect(parseShadow("none", "t")).toEqual([]);
    expect(() => parseShadow("0 1px red", "t")).toThrow(/Unparsable shadow/);
    expect(() => parseShadow("1px rgba(0,0,0,1)", "t")).toThrow(/x y blur/);
  });
});

describe("emitters (real tokens.json)", () => {
  it("resolves every reference", () => {
    expect(JSON.stringify(tokens)).not.toMatch(/"\{[^"]+\}"/);
  });

  it("CSS carries light, dark and opt-in system themes", () => {
    const css = buildCss(tokens);
    expect(css).toContain(":root, [data-theme='light'] {");
    expect(css).toContain("[data-theme='dark'] {");
    expect(css).toMatch(/@media \(prefers-color-scheme: dark\) \{\s+\[data-theme='system'\] \{/);
    for (const k of Object.keys(tokens.alias.light)) {
      // once for light, twice for dark (attribute + system media query)
      expect(css.split(`--aeros-${k}: `).length - 1, k).toBe(3);
    }
    expect(Object.keys(tokens.alias.dark).sort()).toEqual(Object.keys(tokens.alias.light).sort());
  });

  it("Tailwind theme resets the default palette and maps every alias inline", () => {
    const theme = buildTheme(tokens);
    expect(theme).toContain("--color-*: initial;");
    expect(theme).toContain("@theme inline {");
    expect(theme).toContain("@custom-variant dark {");
    for (const k of Object.keys(tokens.alias.light)) expect(theme).toContain(`--color-${k}: var(--aeros-${k});`);
    for (const k of Object.keys(tokens.color.semantic)) expect(theme).toContain(`--color-${k}: var(--aeros-color-semantic-${k});`);
    // no hue other than the neutral ramp and black/white is defined statically
    const staticColours = [...theme.matchAll(/--color-([a-z]+)[-:]/g)].map((m) => m[1]);
    expect(new Set(staticColours)).toEqual(
      new Set(["white", "black", "ink", "success", "warning", "danger", "info", "bg", "fg", "border", "brand", "focus", "state", "scrim"])
    );
  });

  it("Tailwind theme carries the type scale, semantic radii, elevation and density-aware sizes", () => {
    const theme = buildTheme(tokens);
    for (const role of Object.keys(tokens.text)) {
      expect(theme).toContain(`--text-${role}: `);
      expect(theme).toContain(`--text-${role}--line-height: `);
      expect(theme).toContain(`--text-${role}--font-weight: `);
    }
    for (const k of Object.keys(tokens.shape)) expect(theme).toContain(`--radius-${k}: var(--aeros-radius-${k});`);
    for (const k of Object.keys(tokens.elevation.light)) expect(theme).toContain(`--shadow-${k}: var(--aeros-elevation-${k});`);
    for (const k of Object.keys(tokens.size.control)) expect(theme).toContain(`--spacing-control-${k}: var(--aeros-size-control-${k});`);
    for (const k of Object.keys(tokens.z)) expect(theme).toContain(`--z-index-${k}: ${tokens.z[k]};`);
    expect(theme).toContain("--container-dialog-md: var(--aeros-layout-dialog-md);");
    expect(theme).toContain("--outline-offset-field: var(--aeros-focus-offset-field);");
  });

  it("CSS switches density-dependent sizes under data-density and themes elevation", () => {
    const css = buildCss(tokens);
    const touch = css.slice(css.indexOf("[data-density='touch'] {"));
    for (const [k, v] of Object.entries(tokens.size.control as Record<string, { pointer: number; touch: number }>)) {
      expect(css).toContain(`--aeros-size-control-${k}: ${v.pointer}px;`);
      expect(touch).toContain(`--aeros-size-control-${k}: ${v.touch}px;`);
      expect(v.touch).toBeGreaterThanOrEqual(v.pointer);
    }
    expect(Object.keys(tokens.elevation.dark)).toEqual(Object.keys(tokens.elevation.light));
    for (const k of Object.keys(tokens.elevation.light)) expect(css.split(`--aeros-elevation-${k}: `).length - 1).toBe(3);
    // translucent aliases resolve to 8-digit hex
    expect(css).toMatch(/--aeros-state-hover: #[0-9A-F]{8};/);
  });

  it("Dart carries elevation, sizes for both densities, shape and metrics", () => {
    const theme = buildDartTheme(tokens);
    expect(theme).toContain("static const AerosElevation light = AerosElevation(");
    expect(theme).toContain("static const AerosSizeTokens touch = AerosSizeTokens(");
    expect(theme).toContain(`controlMd: ${tokens.size.control.md.pointer.toFixed(1)},`);
    expect(theme).toContain(`static const double control = ${Number(tokens.shape.control).toFixed(1)};`);
    expect(theme).toContain(`static const double focusWidth = ${tokens.focus.width.toFixed(1)};`);
  });

  it("JS module exposes resolved and raw trees with a real type", () => {
    const js = buildJs(tokens, raw);
    expect(js).toContain("export const tokens =");
    expect(js).toContain("export const rawTokens =");
    const dts = buildDts(tokens, raw);
    expect(dts).toContain("export declare const tokens: {");
    expect(dts).not.toContain(": any");
  });

  it("Dart output covers every alias, status colour and text role", () => {
    const base = buildDartTokens(tokens);
    const theme = buildDartTheme(tokens);
    for (const k of Object.keys(tokens.alias.light)) {
      const field = k.replace(/-([a-z0-9])/g, (_m: string, c: string) => c.toUpperCase());
      expect(theme).toContain(`required this.${field},`);
      expect(base).toContain(`aliasLight${field.charAt(0).toUpperCase()}${field.slice(1)} =`);
    }
    for (const role of Object.keys(tokens.text)) {
      const name = role.replace(/-([a-z0-9])/g, (_m: string, c: string) => c.toUpperCase());
      expect(theme).toContain(`static const TextStyle ${name} = TextStyle(`);
    }
    // sans styles pin the variable-font axes and resolve the bundled family
    expect(theme).toMatch(/package: 'aeros_design_system',\n\s+fontSize: 14\.0,/);
    expect(theme).toContain("FontVariation('wght', 450.0)");
  });
});

describe("token docs (docs/tokens.md)", () => {
  const docs = buildTokenDocs(tokens, raw);
  const row = (first: string) => docs.split("\n").find((l) => l.startsWith(`| \`${first}\` |`));

  it("is marked as generated and is deterministic", () => {
    expect(docs.split("\n")[0]).toMatch(/^<!-- Generated from .*tokens\.json.* Do not edit\. -->$/);
    expect(buildTokenDocs(tokens, raw)).toBe(docs);
    expect(docs.endsWith("\n")).toBe(true);
    expect(docs).not.toMatch(/\n\n\n/);
    // no date or other run-dependent text
    expect(docs).not.toMatch(/\b20\d\d-\d\d-\d\d\b/);
  });

  it("is the committed file (run `pnpm build:tokens` after changing tokens.json)", () => {
    const committed = readFileSync(new URL("../../../docs/tokens.md", import.meta.url), "utf8");
    expect(committed).toBe(docs);
  });

  it("has a section for every token group", () => {
    for (const heading of [
      "## Colour", "### Ink ramp", "### Aliases", "### Status colours", "## Type", "### Type scale", "## Spacing",
      "## Radius", "### Semantic radii", "## Elevation", "## Sizes", "## Motion", "## Focus ring", "## Opacity",
      "## Border width", "## Layout", "## Z-index", "## Breakpoints"
    ]) {
      expect(docs, heading).toContain(`\n${heading}\n`);
    }
  });

  it("lists every ramp stop, alias and status colour with its resolved value", () => {
    for (const [stop, v] of Object.entries(tokens.color.ink as Record<string, { $value: string }>)) {
      expect(docs).toContain(`| \`${stop}\` | \`${v.$value}\` | \`--aeros-color-ink-${stop}\` |`);
    }
    for (const k of Object.keys(tokens.alias.light)) {
      const line = row(k);
      expect(line, k).toBeDefined();
      // reference as authored + resolved value, for both themes
      expect(line).toContain(`\`${raw.alias.light[k]}\` | \`${tokens.alias.light[k]}\``);
      expect(line).toContain(`\`${raw.alias.dark[k]}\` | \`${tokens.alias.dark[k]}\``);
    }
    for (const k of Object.keys(tokens.color.semantic)) {
      const line = row(k);
      expect(line, k).toContain(`\`${tokens.color.semantic[k].$value}\``);
      expect(line, k).toContain(`\`${tokens.color.semanticDark[k].$value}\``);
    }
    // a status colour that is a reference shows the reference; a literal shows a dash
    expect(row("info")).toContain(`\`${raw.color.semantic.info.$value}\``);
    expect(row("success")).toContain("| — |");
  });

  it("lists every type role, size, radius, elevation, duration, layer and breakpoint", () => {
    for (const [role, s] of Object.entries(tokens.text as Record<string, { size: number; weight: number }>)) {
      expect(docs).toContain(`| \`${role}\` | ${s.size} | ${s.weight} |`);
      expect(docs).toContain(`\`text-${role}\``);
    }
    for (const [k, v] of Object.entries(tokens.size.control as Record<string, { pointer: number; touch: number }>)) {
      expect(docs).toContain(`| \`control-${k}\` | ${v.pointer}px | ${v.touch}px |`);
    }
    for (const [k, v] of Object.entries(tokens.shape)) expect(docs).toContain(`| \`${k}\` | \`${raw.shape[k]}\` | ${v}px | \`rounded-${k}\` |`);
    for (const k of Object.keys(tokens.radius)) expect(docs).toContain(`\`AerosRadii.${k}\``);
    for (const k of Object.keys(tokens.elevation.light)) {
      expect(docs).toContain(`| \`${k}\` | \`${tokens.elevation.light[k]}\` | \`${tokens.elevation.dark[k]}\` |`);
    }
    for (const [k, v] of Object.entries(tokens.motion.duration)) expect(docs).toContain(`| \`${k}\` | ${v}ms | \`duration-${k}\` |`);
    for (const k of Object.keys(tokens.motion.ease)) expect(docs).toContain(`\`ease-${k}\``);
    for (const [k, v] of Object.entries(tokens.z)) expect(docs).toContain(`| \`${k}\` | ${v} | \`z-${k}\` |`);
    for (const [k, v] of Object.entries(tokens.breakpoint)) expect(docs).toContain(`| \`${k}\` | ${v}px | \`${k}:\` |`);
    for (const k of Object.keys(tokens.space)) expect(docs).toContain(`\`--aeros-space-${k.replace(".", "_")}\``);
    for (const k of Object.keys(tokens.focus)) expect(docs).toContain(`\`--aeros-focus-${k}\``);
    for (const k of Object.keys(tokens.opacity)) expect(docs).toContain(`\`opacity-${k}\``);
    for (const k of Object.keys(tokens.borderWidth)) expect(docs).toContain(`\`border-${k}\``);
    expect(docs).toContain("| `dialog-md` | 520px | `max-w-dialog-md` | `AerosMetricTokens.layoutDialogMd` |");
    expect(docs).toContain("| `sidebar` | 240px | `w-sidebar` | `AerosMetricTokens.layoutSidebar` |");
  });

  it("names only CSS variables that tokens.css defines", () => {
    const css = buildCss(tokens);
    const named = [...docs.matchAll(/`(--aeros-[a-z0-9_-]+)`/g)].map((m) => m[1]).filter((n) => !n.endsWith("-"));
    expect(named.length).toBeGreaterThan(50);
    for (const name of new Set(named)) expect(css, name).toContain(`${name}:`);
  });
});
