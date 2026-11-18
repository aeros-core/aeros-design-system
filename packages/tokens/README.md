# @aeros-core/tokens

The Aeros design tokens. [`src/tokens.json`](./src/tokens.json) is the only source: every other token file in this repository is generated from it.

The values and their names on each platform are in [docs/tokens.md](../../docs/tokens.md).

## Exports

| Import | File | Contents |
|---|---|---|
| `@aeros-core/tokens` | `dist/js/tokens.js`, `.d.ts` | `tokens` (references resolved), `rawTokens` (as authored), the `AerosTokens` type |
| `@aeros-core/tokens/css` | `dist/css/tokens.css` | Every token as an `--aeros-*` custom property, for light, dark and system themes and both densities |
| `@aeros-core/tokens/theme.css` | `dist/css/theme.css` | The Tailwind v4 theme: resets Tailwind's default palette, radii, shadows, easings and font families, and maps the tokens to utilities |
| `@aeros-core/tokens/dart` | `dist/dart/aeros_tokens.dart` | Dart constants (`AerosTokens`) |
| `@aeros-core/tokens/dart-theme` | `dist/dart/aeros_theme_tokens.dart` | Typed Dart classes: colour sets, the type scale, elevation, sizes, metrics |
| `@aeros-core/tokens/source` | `src/tokens.json` | The source |

The Tailwind v3 preset (`@aeros-core/tokens/tailwind`) was removed in 3.0.

## Use

Apps that use `@aeros-core/react` import its `styles.css`, which already includes both stylesheets. Without the React package:

```css
@import "tailwindcss";
@import "@aeros-core/tokens/css";
@import "@aeros-core/tokens/theme.css";
```

```css
.panel {
  background: var(--aeros-bg-surface);
  color: var(--aeros-fg-primary);
  border: 1px solid var(--aeros-border-default);
  border-radius: var(--aeros-radius-surface);
}
```

```ts
import { tokens, rawTokens } from "@aeros-core/tokens";

tokens.alias.light["fg-primary"];    // "#141417"
rawTokens.alias.light["fg-primary"]; // "{color.ink.900}"
```

Theme: `data-theme="light" | "dark" | "system"` on any element. Density: `data-density="touch"` on any element. See [docs/consuming.md](../../docs/consuming.md).

Flutter apps do not use this package directly. The generated Dart is committed inside `aeros_design_system`.

## Token groups

`color.ink` (the neutral ramp), `color.semantic` / `color.semanticDark` (status colours), `alias.light` / `alias.dark` (theme-aware colours), `font`, `text` (the type scale), `space`, `radius` and `shape` (semantic radii), `elevation.light` / `elevation.dark`, `size` (density-dependent and fixed sizes), `motion`, `focus`, `opacity`, `borderWidth`, `layout`, `z`, `breakpoint`.

## References

A string value may point at another token:

| Syntax | Meaning |
|---|---|
| `"{color.ink.900}"` | That token's value |
| `"{color.ink.900 / 0.05}"` | That colour at 5% alpha, emitted as `#RRGGBBAA` |

A reference may point at a plain value or at a `{ "$value": … }` leaf. References may chain. A reference to an unknown token, to a group, or in a cycle fails the build. The resolver is [`src/resolve.mjs`](./src/resolve.mjs); the gate scripts in `scripts/` share it.

Aliases should be references into the ramp, not hex values.

## Adding or changing a token

1. Edit `src/tokens.json`.
   - A new value in an existing group (a ramp stop, an alias, a type role, a size, a duration) needs nothing else: every emitter iterates the group.
   - An alias must be added to both `alias.light` and `alias.dark`. A size that varies with density is `{ "pointer": n, "touch": n }`.
   - A new top-level group needs a loop in each emitter under `src/emit/`, and a section in `docs.ts`.
2. Run `pnpm build:tokens` from the repository root.
3. Commit the generated files with the change: `packages/flutter/lib/src/tokens/aeros_tokens.g.dart`, `aeros_theme_tokens.g.dart` and `docs/tokens.md`. CI rebuilds and fails on a diff.
4. A new text or surface colour: add its pairs to `scripts/check-contrast.mjs`.
5. A new Tailwind theme name: `cn()` in `@aeros-core/react` reads the token groups, so most additions need no change there. Check `packages/react/src/lib/cn.ts` for a new group.
6. Run `pnpm test:tokens`, `pnpm check:contrast` and `pnpm check:flutter-drift`.
7. Add a changeset. Removing or renaming a token is a major change; changing a value that shifts layouts is too.

## The emitters

`src/build.ts` resolves the references and calls one emitter per output. Each emitter is a pure function from the token tree to file text, so each is unit-tested.

| Emitter | Output |
|---|---|
| `emit/css.ts` | `dist/css/tokens.css` |
| `emit/theme.ts` | `dist/css/theme.css` |
| `emit/js.ts` | `dist/js/tokens.js`, `dist/js/tokens.d.ts` |
| `emit/dart.ts` | `dist/dart/*.dart` and the committed copies in `packages/flutter/lib/src/tokens/*.g.dart` |
| `emit/docs.ts` | `docs/tokens.md` |
| `emit/shared.ts` | Helpers: the shadow parser, size and layout flattening |

Generated and committed: the two `.g.dart` files and `docs/tokens.md`. Generated and not committed: `dist/`.

## Scripts

```bash
pnpm build   # tsx src/build.ts
pnpm dev     # rebuild on change
pnpm test    # vitest
```
