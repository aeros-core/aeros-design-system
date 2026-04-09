# Tokens

All tokens live in [`packages/tokens/src/tokens.json`](../packages/tokens/src/tokens.json). Edit there → run `pnpm build:tokens` → CSS/TS/Tailwind/Dart all regenerate.

## Color ramps

### Royal (brand)
| Stop | Hex | Use |
|---|---|---|
| 50  | `#EEF1FD` | Subtle tint, hover states |
| 100 | `#C5CEFA` | Ghost button border |
| 200 | `#9DAAED` | Decorative |
| 400 | `#5B78E8` | Focus ring, dark-mode brand |
| **600** ★ | **`#2347D9`** | **Primary — default brand** |
| 800 | `#1A2F8A` | Primary hover, mono text |
| 900 | `#0B1B6B` | Max contrast brand |

### Ink (pure grey)
| 50 | 100 | 200 | 400 | 600 | 800 | 900 |
|---|---|---|---|---|---|---|
| `#F5F5F5` | `#E5E5E5` | `#C2C2C2` | `#737373` | `#404040` | `#1A1A1A` | `#0A0A0A` |

### Slate (blue-grey)
| 50 | 100 | 200 | 400 | 600 | 800 | 900 |
|---|---|---|---|---|---|---|
| `#F5F6FA` | `#E2E5F0` | `#BCC2D8` | `#7A85A8` | `#4A5278` | `#1E2540` | `#0A0F2E` |

### Semantic
| Role | Base | Bg | Text | Border |
|---|---|---|---|---|
| success | `#16A34A` | `#DCFCE7` | `#15803D` | `#BBF7D0` |
| warning | `#D97706` | `#FEF3C7` | `#B45309` | `#FDE68A` |
| danger  | `#DC2626` | `#FEE2E2` | `#B91C1C` | `#FECACA` |
| info    | `#2347D9` | `#EEF1FD` | `#1A2F8A` | `#C5CEFA` |

## Alias tokens (theme-aware)

Use these in components — they switch with theme.

| Alias | Light | Dark |
|---|---|---|
| `bg.canvas` | slate-50 | ink-900 |
| `bg.surface` | white | slate-900 |
| `bg.subtle` | slate-50 | slate-800 |
| `bg.inverse` | slate-900 | white |
| `fg.primary` | ink-900 | white |
| `fg.secondary` | ink-600 | slate-100 |
| `fg.muted` | ink-400 | slate-400 |
| `fg.brand` | royal-600 | royal-400 |
| `border.default` | slate-100 | slate-800 |
| `border.strong` | slate-200 | slate-600 |
| `border.focus` | royal-400 | royal-400 |
| `brand.primary` | royal-600 | royal-400 |
| `brand.primary-hover` | royal-800 | royal-200 |
| `brand.primary-muted` | royal-50 | royal-800 |

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
