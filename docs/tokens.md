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

> The ramp carries a **faint warmth** (hue ~45, near-zero chroma) — never beige, still strictly monochrome. `royal` and `slate` remain as legacy aliases — every stop resolves to the matching `ink` stop. New code should reach for `ink` directly.

### Semantic
| Role | Base | Bg | Text | Border |
|---|---|---|---|---|
| success | `#16A34A` | `#DCFCE7` | `#15803D` | `#BBF7D0` |
| warning | `#D97706` | `#FEF3C7` | `#B45309` | `#FDE68A` |
| danger  | `#DC2626` | `#FEE2E2` | `#B91C1C` | `#FECACA` |
| info    | `#57554F` | `#F4F4F2` | `#272622` | `#E7E6E2` |

## Alias tokens (theme-aware)

Use these in components — they switch with theme.

Surfaces layer in tiers — `canvas → surface → elevated → subtle` — so depth reads without heavy shadows. In dark mode each tier steps *lighter*.

| Alias | Light | Dark |
|---|---|---|
| `bg.canvas` | `#FAFAF9` (ink-50) | `#121110` (ink-950) |
| `bg.surface` | `#FFFFFF` (ink-0) | `#1A1916` (ink-900) |
| `bg.elevated` | `#FFFFFF` (ink-0) | `#222220` |
| `bg.subtle` | `#F4F4F2` (ink-100) | `#272622` (ink-800) |
| `bg.inverse` | ink-900 | ink-50 |
| `fg.primary` | ink-900 | ink-50 |
| `fg.secondary` | ink-600 | `#C9C7C1` |
| `fg.muted` | `#6E6C66` | ink-400 |
| `fg.brand` | ink-900 | ink-50 |
| `border.default` | ink-200 | ink-800 |
| `border.strong` | ink-300 | ink-700 |
| `border.subtle` | ink-100 | `#232220` |
| `border.focus` | ink-900 | ink-50 |
| `brand.primary` | ink-900 | ink-50 |
| `brand.primary-hover` | ink-700 | `#C9C7C1` |
| `brand.primary-muted` | ink-100 | ink-800 |
| `focus-ring` | ink-900 | ink-50 |
| `focus-ring-offset` | ink-0 | ink-900 |

> **Brand is black and white — full stop.** No blue, no accent hue (the ramp's faint warmth is a designed neutral, not an accent). Reach for depth, weight, size, or contrast for emphasis, not colour. The primary button and other filled controls use `brand.primary` / `fg.inverse` so they invert correctly in dark mode.

## Typography

**Font:** Plus Jakarta Sans (UI) + IBM Plex Mono (data).

Headings are **Bold (700)** with relaxed tracking; body uses the **`book` (450)** weight (rounds to 400 on Flutter). Labels stay 500 for crispness. Mono is unchanged.

| Scale | Size | Weight | Line | Tracking |
|---|---|---|---|---|
| `display-xl` | 56 | 700 | 1.0  | −0.025em |
| `display-lg` | 42 | 700 | 1.0  | −0.025em |
| `display-md` | 32 | 700 | 1.05 | −0.02em |
| `h1` | 28 | 700 | 1.1  | −0.02em |
| `h2` | 22 | 700 | 1.15 | −0.015em |
| `h3` | 20 | 600 | 1.2  | −0.012em |
| `h4` | 16 | 600 | 1.3  | −0.008em |
| `title-lg` | 18 | 600 | 1.35 | −0.01em |
| `body-lg` | 16 | 450 | 1.5 | 0 |
| `body-md` | 14 | 450 | 1.55 | 0 |
| `body-sm` | 13 | 450 | 1.55 | +0.003em |
| `label-md` | 14 | 500 | 1.4 | 0 |
| `label-sm` | 13 | 500 | 1.4 | +0.002em |
| `caption` | 12 | 450 | 1.5 | +0.004em |
| `overline` | 11 | 600 | 1.3 | +0.06em, uppercase |
| `mono-lg` | 22 | 500 | 1.2  | −0.01em |
| `mono-md` | 14 | 500 | 1.5  | 0 |
| `mono-sm` | 12 | 400 | 1.5  | 0 |
| `mono-xs` | 11 | 400 | 1.5  | 0 |

> The build emits this scale as CSS utility classes (`.aeros-text-<role>`) and a Dart `AerosTextStyles` map.
> Control heights unify to **sm 32 / md 36 (default) / lg 40**, so a Button and an Input of the same size align.

## Spacing (4-based)

`0, 1→4, 2→8, 3→12, 4→16, 5→20, 6→24, 7→28, 8→32, 10→40, 12→48, 14→56, 16→64, 20→80, 24→96, 32→128`

## Radii

| Token | px | Used for |
|---|---|---|
| `xs`  | 4  | Chips, checkboxes, tags |
| `sm`  | 6  | Badges, sidebar active pill, dense controls |
| `md`  | 8  | Buttons, inputs |
| `lg`  | 12 | Menus, dropdowns, popovers |
| `xl`  | 16 | Cards, modals |
| `2xl` | 20 | Hero surfaces |
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
| `hairline` | Composable 1px separator |

## Motion

| Token | ms | Use |
|---|---|---|
| `duration.quick` | 90 | Hover/press flips, menu-item hover |
| `duration.fast` | 120 | Button press, tab switch |
| `duration.base` | 200 | Panel open, hover, dialog |
| `duration.slow` | 320 | Drawer, progress |

Easings: `standard`, `emphasized`, `decelerate`, plus `entrance` (snappy settle) and `spring` (gentle ~6% overshoot) for overlays entering — dropdowns and dialogs. All transitions animate `transform`/`opacity`/`box-shadow` only, and collapse to instant opacity crossfades under `prefers-reduced-motion`.
