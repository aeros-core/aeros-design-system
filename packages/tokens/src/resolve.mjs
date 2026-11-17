// Token reference resolver — plain ESM so the build (tsx) and the repo gate
// scripts (node) share one implementation.
//
// A string value may be a reference to another token:
//   "{color.ink.900}"         → that token's value
//   "{color.ink.900 / 0.05}"  → that colour at 5% alpha (#RRGGBBAA)
// A reference target is either a plain value or a DTCG object ({ "$value": … }).
// References may chain; cycles throw.

const REF = /^\{\s*([^}/]+?)\s*(?:\/\s*([0-9]*\.?[0-9]+)\s*)?\}$/;

export const isRef = (v) => typeof v === "string" && REF.test(v);

function lookup(root, path) {
  let node = root;
  for (const key of path.split(".")) {
    if (node === null || typeof node !== "object" || !(key in node)) return undefined;
    node = node[key];
  }
  return node;
}

/** Parses #RGB, #RRGGBB or #RRGGBBAA into { r, g, b, a } (a in 0..1). */
export function parseHex(hex) {
  let h = String(hex).trim().replace(/^#/, "");
  if (h.length === 3) h = h.split("").map((c) => c + c).join("");
  if (!/^[0-9a-fA-F]{6}([0-9a-fA-F]{2})?$/.test(h)) throw new Error(`Not a hex colour: "${hex}"`);
  return {
    r: parseInt(h.slice(0, 2), 16),
    g: parseInt(h.slice(2, 4), 16),
    b: parseInt(h.slice(4, 6), 16),
    a: h.length === 8 ? parseInt(h.slice(6, 8), 16) / 255 : 1
  };
}

const byte = (n) => Math.round(n).toString(16).padStart(2, "0").toUpperCase();

/** { r, g, b, a } → #RRGGBB, or #RRGGBBAA when translucent. */
export function toHex({ r, g, b, a = 1 }) {
  return `#${byte(r)}${byte(g)}${byte(b)}${a >= 1 ? "" : byte(a * 255)}`;
}

/** Applies an alpha (0..1) to a hex colour. */
export function withAlpha(hex, alpha) {
  const c = parseHex(hex);
  return toHex({ ...c, a: c.a * alpha });
}

/** Flattens a (possibly translucent) foreground over an opaque background. */
export function composite(fgHex, bgHex) {
  const f = parseHex(fgHex);
  const b = parseHex(bgHex);
  return toHex({
    r: f.r * f.a + b.r * (1 - f.a),
    g: f.g * f.a + b.g * (1 - f.a),
    b: f.b * f.a + b.b * (1 - f.a),
    a: 1
  });
}

function resolveValue(root, value, trail) {
  if (!isRef(value)) return value;
  const [, path, alpha] = value.match(REF);
  if (trail.includes(path)) {
    throw new Error(`Circular token reference: ${[...trail, path].join(" → ")}`);
  }
  let target = lookup(root, path);
  if (target !== null && typeof target === "object" && "$value" in target) target = target.$value;
  if (target === undefined) {
    throw new Error(`Unknown token reference "{${path}}"${trail.length ? ` (via ${trail.join(" → ")})` : ""}`);
  }
  if (target !== null && typeof target === "object") {
    throw new Error(`Token reference "{${path}}" points at a group, not a value`);
  }
  const resolved = resolveValue(root, target, [...trail, path]);
  return alpha === undefined ? resolved : withAlpha(resolved, Number(alpha));
}

/** Returns a deep copy of `raw` with every reference replaced by its value. */
export function resolveTokens(raw) {
  const walk = (node) => {
    if (Array.isArray(node)) return node.map(walk);
    if (node !== null && typeof node === "object") {
      return Object.fromEntries(Object.entries(node).map(([k, v]) => [k, walk(v)]));
    }
    return resolveValue(raw, node, []);
  };
  return walk(raw);
}
