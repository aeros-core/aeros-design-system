/**
 * Helpers shared by every emitter. Emitters receive the RESOLVED token tree
 * (references replaced by values — see ../resolve.mjs) and return file text.
 */
// eslint-disable-next-line @typescript-eslint/no-explicit-any
export type Tokens = Record<string, any>;

export const GENERATED = "Aeros Design Tokens — generated from packages/tokens/src/tokens.json. Do not edit.";

export const camel = (s: string) => s.replace(/-([a-z0-9])/g, (_m, c) => String(c).toUpperCase());
export const cap = (s: string) => s.charAt(0).toUpperCase() + s.slice(1);
export const px = (v: unknown) => (typeof v === "number" ? `${v}px` : String(v));

/** Colour groups that are ramps (everything except the status sets). */
export function ramps(tokens: Tokens): [string, Record<string, { $value: string }>][] {
  return Object.entries(tokens.color).filter(([g]) => g !== "semantic" && g !== "semanticDark") as never;
}

/** `{ "success-bg": "#…" }` for one status set. */
export function semantic(tokens: Tokens, set: "semantic" | "semanticDark"): Record<string, string> {
  return Object.fromEntries(
    Object.entries(tokens.color[set] as Record<string, { $value: string }>).map(([k, v]) => [k, v.$value])
  );
}

/** Splits a CSS list on top-level commas (commas inside parentheses are kept). */
export function splitTopLevel(value: string): string[] {
  const out: string[] = [];
  let depth = 0;
  let cur = "";
  for (const ch of value) {
    if (ch === "(") depth++;
    if (ch === ")") depth--;
    if (ch === "," && depth === 0) {
      out.push(cur.trim());
      cur = "";
    } else cur += ch;
  }
  if (cur.trim()) out.push(cur.trim());
  return out;
}

export interface ShadowLayer {
  x: number;
  y: number;
  blur: number;
  spread: number;
  r: number;
  g: number;
  b: number;
  a: number;
  inset: boolean;
}

/**
 * Parses a CSS box-shadow value restricted to the grammar the tokens use:
 *   [inset] <x> <y> <blur> [<spread>] rgba(r, g, b, a) | rgb(r g b / a)
 * Throws on anything else, so an unparsable shadow fails the build instead of
 * silently diverging between web and Flutter.
 */
export function parseShadow(value: string, label: string): ShadowLayer[] {
  if (value.trim() === "none") return [];
  return splitTopLevel(value).map((layer) => {
    const m = layer.match(/^(inset\s+)?(.*?)\s*(rgba?\([^)]*\))$/);
    if (!m) throw new Error(`Unparsable shadow layer in ${label}: "${layer}"`);
    const lengths = m[2].trim().split(/\s+/).map((n) => {
      const v = Number(n.replace(/px$/, ""));
      if (Number.isNaN(v)) throw new Error(`Unparsable shadow length "${n}" in ${label}`);
      return v;
    });
    if (lengths.length < 3 || lengths.length > 4) {
      throw new Error(`Shadow layer in ${label} needs x y blur [spread]: "${layer}"`);
    }
    const nums = m[3].replace(/^rgba?\(/, "").replace(/\)$/, "").split(/[\s,/]+/).filter(Boolean).map(Number);
    if (nums.length < 3 || nums.some(Number.isNaN)) {
      throw new Error(`Unparsable shadow colour in ${label}: "${m[3]}"`);
    }
    const [r, g, b, a = 1] = nums;
    const [x, y, blur, spread = 0] = lengths;
    return { x, y, blur, spread, r, g, b, a, inset: Boolean(m[1]) };
  });
}

/** A size entry that varies with density: `{ pointer, touch }`. */
export const isDensity = (v: unknown): v is { pointer: number; touch: number } =>
  v !== null && typeof v === "object" && "pointer" in (v as object) && "touch" in (v as object);

/**
 * Flattens the `size` block to `[name, value]` pairs — `control.md`, `header`,
 * `icon.md` → `control-md`, `header`, `icon-md`. `pick` chooses the density
 * (density-independent entries are returned only when `pick` is null).
 */
export function sizes(tokens: Tokens, pick: "pointer" | "touch" | null): [string, number][] {
  const out: [string, number][] = [];
  const walk = (node: Tokens, path: string[]) => {
    for (const [k, v] of Object.entries(node)) {
      if (isDensity(v)) {
        if (pick) out.push([[...path, k].join("-"), v[pick]]);
      } else if (typeof v === "number") {
        if (!pick) out.push([[...path, k].join("-"), v]);
      } else walk(v as Tokens, [...path, k]);
    }
  };
  walk(tokens.size, []);
  return out;
}

/** Flattens the `layout` block: `dialog.md` → `dialog-md`. */
export function layout(tokens: Tokens): [string, number][] {
  const out: [string, number][] = [];
  for (const [k, v] of Object.entries(tokens.layout as Tokens)) {
    if (typeof v === "number") out.push([k, v]);
    else for (const [k2, v2] of Object.entries(v as Tokens)) out.push([`${k}-${k2}`, Number(v2)]);
  }
  return out;
}
