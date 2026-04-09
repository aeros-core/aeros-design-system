# @aeros/tokens

Single source of truth for the Aeros design language.

## What you get

Run `pnpm build` (or `pnpm --filter @aeros/tokens build`) and this package emits:

| Output | Path | For |
|---|---|---|
| CSS custom properties | `dist/css/tokens.css` | Any web app |
| TypeScript constants | `dist/js/tokens.js` + `.d.ts` | JS/TS consumers |
| Tailwind v4 preset | `dist/tailwind/preset.js` | `@aeros/react` & Next.js |
| Dart constants | `dist/dart/aeros_tokens.dart` | Flutter package |

The source lives in [`src/tokens.json`](./src/tokens.json) — edit there, rebuild, everything flows.

## Token categories

- **Color ramps** — `royal`, `ink`, `slate` (each with 7 stops)
- **Semantic** — `success`, `warning`, `danger`, `info` with `base`/`bg`/`text`/`border`
- **Aliases** — theme-aware tokens like `bg.surface`, `fg.primary`, `border.default`, `brand.primary` — defined for light and dark
- **Typography** — `display-xl` … `mono-xs` (17 named scales)
- **Spacing** — 4-based scale (4, 8, 12, 16 … 128)
- **Radii** — `sm` 6 / `md` 8 / `lg` 12 / `xl` 16 / `2xl` 20 / `full`
- **Shadows** — `xs`…`xl` + `focus` + `focus-danger`
- **Motion** — `duration.{fast,base,slow}`, `ease.{standard,emphasized,decelerate}`
- **Z-index, breakpoints**

## CSS usage

```css
@import "@aeros/tokens/css";

.card {
  background: var(--aeros-bg-surface);
  color: var(--aeros-fg-primary);
  border: 1px solid var(--aeros-border-default);
  border-radius: var(--aeros-radius-lg);
  box-shadow: var(--aeros-shadow-sm);
}
```

Dark mode: set `data-theme="dark"` on `<html>`.

## Tailwind v4

```ts
// tailwind.config.ts
import aeros from "@aeros/tokens/tailwind";
export default { presets: [aeros], content: ["./app/**/*.{ts,tsx}"] };
```

## Dart usage

Imported by `aeros_design_system` — you don't use this directly from Flutter apps.
