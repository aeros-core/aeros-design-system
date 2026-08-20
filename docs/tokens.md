# Tokens

All tokens live in [`packages/tokens/src/tokens.json`](../packages/tokens/src/tokens.json). Edit there → run `pnpm build:tokens` → CSS/TS/Tailwind/Dart all regenerate.

## Color ramps

### Ink (the only ramp — faint warm neutral, 12 even stops)
| Stop | Hex | Use |
|---|---|---|
| 0   | `#FFFFFF` | Pure white surface |
| 50  | `#FAFAF9` | Canvas, subtle tint |
| 100 | `#F4F4F2` | Subtle fills, hover, muted borders |
| 200 | `#E7E6E2` | Default hairline borders |
| 300 | `#D6D4CF` | Strong borders, dividers |
| 400 | `#A8A6A0` | Placeholder text, disabled |
| 500 | `#7C7A74` | Muted / tertiary text |
| 600 | `#57554F` | Secondary text |
| 700 | `#403E39` | Primary hover |
| 800 | `#272622` | Strong text |
| **900** ★ | **`#1A1916`** | **Primary — default brand, primary CTA, body text** |
| 950 | `#121110` | Deepest — dark canvas, sidebar, top nav |

> The ramp carries a **faint warmth** (hue ~45, near-zero chroma) — never beige, still strictly monochrome. The `royal` and `slate` legacy aliases were **deleted in 2.0** (they were byte-identical copies) — reach for `ink` directly.

### Semantic (light)
| Role | Base | Bg | Text | Border |
|---|---|---|---|---|
| success | `#16A34A` | `#DCFCE7` | `#15803D` | `#BBF7D0` |
| warning | `#CC6D04` | `#FEF3C7` | `#B45309` | `#FDE68A` |
| danger  | `#DC2626` | `#FEE2E2` | `#B91C1C` | `#FECACA` |
| info    | `#57554F` | `#F4F4F2` | `#272622` | `#E7E6E2` |

### Semantic (dark — emitted under `[data-theme='dark']`)
| Role | Base | Bg | Text | Border |
|---|---|---|---|---|
| success | `#4ADE80` | `#132B1D` | `#86EFAC` | `#235C36` |
| warning | `#FBBF24` | `#2E2410` | `#FCD34D` | `#6B4E16` |
| danger  | `#F87171` | `#331414` | `#FCA5A5` | `#7F2A2A` |
| info    | `#A8A6A0` | `#2A2723` | `#D6D4CF` | `#46423B` |

> Every text-on-bg pair holds WCAG AA 4.5:1 and every base-on-bg pair holds 3:1 — enforced by `pnpm check:contrast` in CI.

## Alias tokens (theme-aware)

Use these in components — they switch with theme.

Surfaces layer in tiers — `canvas → surface → elevated → subtle` — so depth reads without heavy shadows. In dark mode each tier steps *lighter*.

| Alias | Light | Dark |
|---|---|---|
| `bg.canvas` | `#F7F6F4` | `#1A1815` |
| `bg.surface` | `#FFFFFF` | `#221F1B` |
| `bg.elevated` | `#FFFFFF` | `#2A2723` |
| `bg.subtle` | `#F1F0ED` | `#2F2C27` |
| `bg.inverse` | `#1A1916` | `#FAFAF9` |
| `fg.primary` | `#1A1916` | `#F5F3EF` |
| `fg.secondary` | `#57554F` | `#C4C1BA` |
| `fg.muted` | `#6C6A63` | `#9A978F` |
| `fg.inverse` | `#FFFFFF` | `#1A1815` |
| `fg.brand` | `#1A1916` | `#F5F3EF` |
| `border.default` | `#E4E2DD` | `#332F2A` |
| `border.strong` | `#CECBC4` | `#46423B` |
| `border.subtle` | `#EEEDEA` | `#2A2723` |
| `border.focus` | `#1A1916` | `#F5F3EF` |
| `brand.primary` | `#1A1916` | `#F5F3EF` |
| `brand.primary-hover` | `#403E39` | `#C4C1BA` |
| `brand.primary-muted` | `#F1F0ED` | `#2F2C27` |
| `focus-ring` | `#1A1916` | `#F5F3EF` |
| `focus-ring-offset` | `#FFFFFF` | `#1A1815` |

> **Brand is black and white — full stop.** No blue, no accent hue (the ramp's faint warmth is a designed neutral, not an accent). Reach for depth, weight, size, or contrast for emphasis, not colour. The primary button and other filled controls use `brand.primary` / `fg.inverse` so they invert correctly in dark mode.

## Typography

**Font:** Inter (UI) + IBM Plex Mono (data). Nunito Sans (wdth 125) is reserved for the wordmark.

Headings are **Bold (700–800)** with tight tracking; body uses the **`book` (450)** weight (rounds to 400 on Flutter). Interactive labels are 600 so UI text never looks thin.

| Scale | Size | Weight | Line | Tracking |
|---|---|---|---|---|
| `display-xl` | 56 | 800 | 1.0  | −0.03em |
| `display-lg` | 42 | 800 | 1.0  | −0.03em |
| `display-md` | 32 | 700 | 1.05 | −0.025em |
| `h1` | 28 | 700 | 1.1  | −0.022em |
| `h2` | 22 | 700 | 1.15 | −0.018em |
| `h3` | 20 | 700 | 1.2  | −0.015em |
| `h4` | 16 | 600 | 1.3  | −0.008em |
| `title-lg` | 18 | 600 | 1.35 | −0.01em |
| `body-lg` | 16 | 450 | 1.5 | 0 |
| `body-md` | 14 | 450 | 1.55 | 0 |
| `body-sm` | 13 | 450 | 1.55 | +0.003em |
| `label-md` | 14 | 600 | 1.4 | 0 |
| `label-sm` | 13 | 600 | 1.4 | +0.002em |
| `label-xs` | 11 | 600 | 1.0 | +0.002em |
| `caption` | 12 | 500 | 1.5 | +0.004em |
| `overline` | 11 | 700 | 1.3 | +0.05em, uppercase |
| `mono-lg` | 22 | 500 | 1.2  | −0.01em |
| `mono-md` | 14 | 500 | 1.5  | 0 |
| `mono-sm` | 12 | 400 | 1.5  | 0 |
| `mono-xs` | 11 | 400 | 1.5  | 0 |

> The build emits this scale as CSS utility classes (`.aeros-text-<role>`) and a Dart `AerosTextStyles` map.
> Web control heights unify to **sm 32 / md 36 (default) / lg 40** (Button, Input, Textarea, Select share the ladder). Flutter's ladder is sm 32 / md 40 / lg 46 — same names/roles, taller values for touch.

## Spacing (4-based, half-steps included)

`0, px→1, 0.5→2, 1→4, 1.5→6, 2→8, 2.5→10, 3→12, 3.5→14, 4→16, 5→20, 6→24, 7→28, 8→32, 10→40, 12→48, 14→56, 16→64, 20→80, 24→96, 32→128`

## Radii

| Token | px | Used for |
|---|---|---|
| `none`| 0  | Flush panels |
| `xs`  | 4  | Chips, checkboxes, tags |
| `sm`  | 6  | Badges, sidebar active pill, dense controls |
| `md`  | 8  | Buttons, inputs |
| `lg`  | 12 | Menus, dropdowns, popovers |
| `xl`  | 16 | Cards, modals |
| `2xl` | 20 | Hero surfaces |
| `3xl` | 24 | Marketing surfaces |
| `4xl` | 32 | Oversized hero panels |
| `full`| ∞  | Avatars, pills |

## Shadows

Two-layer soft shadows (ambient + key) on neutral black — depth reads as softness, not a hard drop. In dark mode a faint light hairline ring replaces the (invisible) black shadow.

| Token | Use |
|---|---|
| `xs` | Very subtle lift |
| `sm` | Resting cards, secondary buttons |
| `md` | Card hover-lift, primary buttons |
| `lg` | Dropdowns, popovers |
| `xl` | Modals (far softer than before) |
| `focus` | Soft halo on focused inputs |
| `focus-danger` / `focus-success` | Halo for error / success focus states |
| `hairline` | Composable 1px separator |

Dark-mode counterparts live in `shadowDark` in `tokens.json` (deeper keys + a faint light hairline ring) and are emitted under `[data-theme='dark']`, so Tailwind's `shadow-*` utilities flip automatically.

## Motion

| Token | ms | Use |
|---|---|---|
| `duration.quick` | 90 | Hover/press flips, menu-item hover |
| `duration.fast` | 120 | Button press, tab switch |
| `duration.base` | 200 | Panel open, hover, dialog |
| `duration.slow` | 320 | Drawer, progress |

Easings: `standard`, `emphasized`, `decelerate`, plus `entrance` (snappy settle) and `spring` (gentle ~6% overshoot) for overlays entering — dropdowns and dialogs. All transitions animate `transform`/`opacity`/`box-shadow` only, and collapse to instant opacity crossfades under `prefers-reduced-motion`.

Components consume these via `duration-(--aeros-duration-*)` and the `ease-*` utilities — arbitrary literals (`duration-[120ms]`, `z-[1400]`, raw hex) fail CI (`pnpm check:hardcoded`).

## Z-index

`base 0 · dropdown 1000 · sticky 1100 · overlay 1300 · modal 1400 · popover 1500 · toast 1600 · tooltip 1700` — consumed as `z-(--aeros-z-*)`.

## Breakpoints

`sm 640 · md 768 · lg 1024 · xl 1280 · 2xl 1536` — one scale for web (Tailwind defaults match) **and** Flutter (`AerosBreakpoints`, with an `xs = 0` floor). Emitted as `--aeros-breakpoint-*` CSS vars, in the Tailwind preset (`screens`), and as Dart constants.
