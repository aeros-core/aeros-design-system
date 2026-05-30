# Tokens

All tokens live in [`packages/tokens/src/tokens.json`](../packages/tokens/src/tokens.json). Edit there → run `pnpm build:tokens` → CSS/TS/Tailwind/Dart all regenerate.

## Color ramps

### Ink (the only ramp)
| Stop | Hex | Use |
|---|---|---|
| 50  | `#F5F5F5` | Subtle tint, hover states |
| 100 | `#E5E5E5` | Borders, ghost button border |
| 200 | `#C2C2C2` | Placeholder text |
| 400 | `#737373` | Muted / secondary text |
| 600 | `#404040` | Body text, primary hover |
| 800 | `#1A1A1A` | Headings |
| **900** ★ | **`#0A0A0A`** | **Primary — default brand, primary CTA** |

> `royal` and `slate` ramps remain as legacy aliases for backwards compatibility — every stop resolves to the matching `ink` stop. New code should reach for `ink` directly.

### Semantic
| Role | Base | Bg | Text | Border |
|---|---|---|---|---|
| success | `#16A34A` | `#DCFCE7` | `#15803D` | `#BBF7D0` |
| warning | `#D97706` | `#FEF3C7` | `#B45309` | `#FDE68A` |
| danger  | `#DC2626` | `#FEE2E2` | `#B91C1C` | `#FECACA` |
| info    | `#404040` | `#F5F5F5` | `#1A1A1A` | `#E5E5E5` |

## Alias tokens (theme-aware)

Use these in components — they switch with theme.

| Alias | Light | Dark |
|---|---|---|
| `bg.canvas` | white | ink-900 |
| `bg.surface` | white | ink-900 |
| `bg.subtle` | ink-50 | ink-800 |
| `bg.inverse` | ink-900 | white |
| `fg.primary` | ink-900 | white |
| `fg.secondary` | ink-600 | ink-100 |
| `fg.muted` | ink-400 | ink-400 |
| `fg.brand` | ink-900 | white |
| `border.default` | ink-100 | ink-800 |
| `border.strong` | ink-200 | ink-600 |
| `border.focus` | ink-900 | white |
| `brand.primary` | ink-900 | white |
| `brand.primary-hover` | ink-600 | ink-100 |
| `brand.primary-muted` | ink-50 | ink-800 |
| `accent` | ink-900 | white |
| `accent-muted` | ink-50 | ink-800 |

> **Brand is black and white — full stop.** No blue, no accent hue. Reach for weight, size, or contrast for emphasis, not colour.

## Typography

**Font:** Plus Jakarta Sans (UI) + IBM Plex Mono (data).

| Scale | Size | Weight | Line | Tracking |
|---|---|---|---|---|
| `display-xl` | 56 | 800 | 1.0  | −0.04em |
| `display-lg` | 42 | 800 | 1.0  | −0.04em |
| `display-md` | 32 | 800 | 1.05 | −0.03em |
| `h1` | 28 | 800 | 1.1  | −0.03em |
| `h2` | 22 | 800 | 1.15 | −0.02em |
| `h3` | 20 | 700 | 1.2  | −0.02em |
| `h4` | 16 | 700 | 1.3  | −0.01em |
| `body-lg` | 16 | 500 | 1.5 | 0 |
| `body-md` | 14 | 500 | 1.55 | 0 |
| `body-sm` | 13 | 500 | 1.55 | 0 |
| `caption` | 12 | 500 | 1.5 | 0 |
| `overline` | 11 | 600 | 1.3 | +0.08em, uppercase |
| `mono-lg` | 22 | 500 | 1.2  | −0.01em |
| `mono-md` | 14 | 500 | 1.5  | 0 |
| `mono-sm` | 12 | 400 | 1.5  | 0 |
| `mono-xs` | 11 | 400 | 1.5  | 0 |

## Spacing (4-based)

`0, 1→4, 2→8, 3→12, 4→16, 5→20, 6→24, 7→28, 8→32, 10→40, 12→48, 14→56, 16→64, 20→80, 24→96, 32→128`

## Radii

| Token | px | Used for |
|---|---|---|
| `sm`  | 6  | Badges, dense controls |
| `md`  | 8  | Buttons, inputs |
| `lg`  | 12 | Menus, smaller cards |
| `xl`  | 16 | Cards, modals |
| `2xl` | 20 | Hero surfaces |
| `full`| ∞  | Avatars, pills |

## Shadows

| Token | Use |
|---|---|
| `xs` | Very subtle lift |
| `sm` | Cards (hairline + 1px) |
| `md` | Popovers, tooltips |
| `lg` | Dropdowns |
| `xl` | Modals |
| `focus` | Focus ring on inputs |

## Motion

| Token | ms | Use |
|---|---|---|
| `duration.fast` | 120 | Button press, tab switch |
| `duration.base` | 200 | Panel open, hover |
| `duration.slow` | 320 | Dialog, drawer |

Easings: `standard`, `emphasized`, `decelerate` — use `emphasized` for element-entering-view, `standard` for everything else.
