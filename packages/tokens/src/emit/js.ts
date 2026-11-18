import { GENERATED, type Tokens } from "./shared";

/** A literal TypeScript type for a JSON value (objects become readonly maps). */
function typeOf(value: unknown, indent: string): string {
  if (Array.isArray(value)) return `readonly (${[...new Set(value.map((v) => typeOf(v, indent)))].join(" | ") || "never"})[]`;
  if (value !== null && typeof value === "object") {
    const inner = indent + "  ";
    const fields = Object.entries(value).map(([k, v]) => `${inner}readonly ${JSON.stringify(k)}: ${typeOf(v, inner)};`);
    return `{\n${fields.join("\n")}\n${indent}}`;
  }
  return value === null ? "null" : typeof value;
}

/**
 * dist/js/tokens.js — `tokens` holds resolved values (references replaced);
 * `rawTokens` is tokens.json as authored, references intact.
 */
export function buildJs(resolved: Tokens, raw: Tokens): string {
  return [
    `// ${GENERATED}`,
    "",
    `export const tokens = ${JSON.stringify(resolved, null, 2)};`,
    "",
    `export const rawTokens = ${JSON.stringify(raw, null, 2)};`,
    "",
    "export default tokens;",
    ""
  ].join("\n");
}

export function buildDts(resolved: Tokens, raw: Tokens): string {
  return [
    `// ${GENERATED}`,
    "",
    `export declare const tokens: ${typeOf(resolved, "")};`,
    "",
    `export declare const rawTokens: ${typeOf(raw, "")};`,
    "",
    "export type AerosTokens = typeof tokens;",
    "export default tokens;",
    ""
  ].join("\n");
}
