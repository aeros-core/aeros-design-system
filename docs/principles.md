# Design principles

Aeros is built for operators: people running factories, buying teams, warehouses and stores. They read a screen the way they read an instrument. The 3.0 look, "Crisp precision", follows from that: flat surfaces separated by hairlines, tight corners, compact controls, and no colour that does not mean something.

Each principle below is a rule and the reason for it. Values are in [tokens.md](./tokens.md).

## 1. Surfaces and elevation

**Rule.** A resting surface is a fill and a 1px hairline border, with no shadow. A shadow means the layer floats above the page.

| Intent | Used by | Web | Flutter |
|---|---|---|---|
| Resting | Cards, panels, tables, fields, the sidebar, the header | `border border-border-default bg-bg-surface` | `AerosSurface(level: AerosSurfaceLevel.flat)` |
| `raised` | The lifted part of a control: a switch thumb, the active segment of pill tabs | `shadow-raised` | `AerosSurfaceLevel.raised` |
| `overlay` | Menus, popovers, select lists, toasts | `bg-bg-elevated shadow-overlay` | `AerosSurfaceLevel.overlay` |
| `modal` | Dialogs, drawers, sheets, over the `scrim` | `bg-bg-elevated shadow-modal` | `AerosSurfaceLevel.modal` |

A floating layer never takes a border class. The `overlay` and `modal` shadows draw their own 1px edge, so a border would double it.

In Flutter, `AerosSurface` is the only place a `BoxShadow` is attached.

**Why.** A shadow on everything says nothing. Kept for floating layers, it tells the operator what is in front.

## 2. Radius

**Rule.** Use the semantic radii, not scale steps.

| Name | Value | For |
|---|---|---|
| `item` | 4px | Rows inside a menu, tags, checkboxes, nav rows |
| `control` | 6px | Buttons, fields, select triggers, every size of control |
| `surface` | 8px | Cards, alerts, popovers, menus |
| `modal` | 12px | Dialogs, the top of a bottom sheet |
| `pill` | full | Badges and other fully rounded shapes |

Nesting rule: an inner corner is the outer corner minus the padding between them. A menu is `surface` (8px) with 4px padding, so its rows are `item` (4px). Pick the pair so the corners stay concentric.

**Why.** A name says what the corner belongs to, so two components of the same kind cannot drift apart, and nested corners line up.

## 3. Colour

**Rule.** The system is monochrome: black, white and the ink ramp. There is no accent hue and no blue.

- Use aliases (`bg-surface`, `fg-muted`, `border-default`), not ramp stops. Aliases change with the theme; a ramp stop does not.
- State is an overlay, not a new colour. Hover, pressed and selected composite `state-hover`, `state-pressed` and `state-selected` over whatever is underneath.
- Status colours (success, warning, danger, info) mark state and nothing else. `info` is neutral grey. The one place a status colour fills a control is the solid danger button.
- When something needs emphasis, use weight, size or contrast.
- Dark mode is near-black: `ink-950` canvas, `ink-900` surface, `ink-850` elevated. Each tier up is lighter.

**Why.** If colour only ever means state, an operator can trust it at a glance. Aliases keep dark mode correct without per-component work.

## 4. Type

**Rule.** Text uses a role from the type scale. A role sets size, line height, tracking and weight together.

- **Inter** is the interface face. Body text is weight 450, labels 500, headings 600.
- **IBM Plex Mono** is for data only: IDs, amounts, timestamps, counts. It ships in weights 400 and 500.
- The wordmark is Nunito Sans expanded, through the `aeros-logo` class on the web and `AerosWordmark` in Flutter. Do not restyle it, and do not use that face for anything else.
- Roles: `display-*` for marketing-scale headings, `h1`–`h4` and `title-lg` for headings, `body-*` for reading text, `label-*` for controls, `caption` for secondary lines, `overline` for small uppercase labels, `mono-*` for data.

On the web a role is one class (`text-body-sm`). In Flutter it is one call (`AerosTypography.bodySm()`); change the weight with the `weight:` argument or `withWeight`, never `copyWith(fontWeight:)`, which does not move Inter's weight axis.

**Why.** Hierarchy comes from a small, fixed set of sizes and weights. Mono is a promise: if it is in mono, a system produced it.

## 5. Density and sizing

**Rule.** Controls come from one ladder, and the ladder has two densities.

| Size | Pointer | Touch |
|---|---|---|
| `xs` | 24 | 32 |
| `sm` | 28 | 36 |
| `md` (default) | 32 | 40 |
| `lg` | 36 | 44 |
| `xl` | 40 | 48 |

- Buttons and fields share the ladder, so a button and a field of the same size sit on one line.
- Pointer density is for a mouse; touch density is for fingers. The web defaults to pointer and switches a subtree with `data-density="touch"`. Flutter defaults to touch and switches a subtree with `AerosDensityScope(density: AerosDensity.pointer)`.
- In Flutter a control's tappable box is at least the density's minimum target: 24 at pointer, 48 at touch. The painted control keeps its size; the hit area grows around it.
- Use a size token for anything that should change with density (`h-control-md`, `h-row`, `h-header`), not a fixed number.

**Why.** A desktop window should show as much as a desktop mail client does. A phone needs targets a thumb can hit. One ladder with two densities gives both without two sets of components.

## 6. Motion

**Rule.** Hover and press change colour only. Nothing lifts, scales or gains a shadow.

- State changes use `duration-fast` (120ms) and `ease-standard`. The web recipe is `transition-colors duration-fast ease-standard`.
- A floating layer enters with `ease-enter` and leaves with `ease-exit`, and leaves faster than it enters: menus and popovers 120ms in, 80ms out; dialogs 180ms in, 120ms out; drawers and sheets 260ms in, 180ms out.
- Reduced motion is honoured. On the web the token stylesheet shortens every animation and transition under `prefers-reduced-motion: reduce`. In Flutter, wrap a duration in `AerosMotion.resolve(context, …)`, which returns zero when the platform asks for reduced motion.
- Flutter has no ripple: the theme sets `NoSplash`.

**Why.** Movement on hover makes a dense screen shimmer as the pointer crosses it. Motion is kept for layers that appear and disappear, where it explains where they came from.

## 7. Focus

**Rule.** There is one focus ring, and it is driven by tokens: 2px, in the `focus-ring` colour, 2px outside the element.

- On the web it is the global `:focus-visible` outline in `styles.css`. Components do not draw their own ring.
- A component may only move the ring: `focus-ring-field` puts it on a field's border, `focus-ring-inset` puts it inside the element (table headers, flush rows).
- An invalid control's ring is the danger colour.
- In Flutter it is `AerosFocusRing`, painted outside the child so focus never shifts layout, with the same three placements: `outside`, `field` and `inset`.

**Why.** One ring that looks the same everywhere is easier to find than several that each look slightly different. An outline with a transparent offset reads correctly on any surface.

## 8. Accessibility

**Rule.** The bar is WCAG 2.1 AA, and it is enforced, not reviewed.

- `pnpm check:contrast` fails the build if any text tier on any surface, any status pair, the solid danger button, or text over a state overlay falls below AA, in either theme.
- `pnpm test:a11y` runs axe on every component fixture in light and dark. A new violation fails. Known violations are listed in `KNOWN_VIOLATIONS`, and the list can only shrink.
- React unit tests run `jest-axe`; Flutter tests check tap-target guidelines.
- Radix primitives keep their keyboard and screen-reader behaviour. Flutter controls are built on `AerosPressable`, which gives every control keyboard activation and semantics.

**Why.** A check that runs on every pull request does not depend on someone remembering to look.

## 9. Platform parity

**Rule.** A component on the web and its Flutter counterpart share tokens, sizes, radii, states and names. `tokens.json` is the only source: it generates the CSS variables, the Tailwind theme and the Dart classes.

Where the platforms differ, the difference is deliberate and written down in [components.md](./components.md). The default density is the main one: pointer on the web, touch in Flutter.

**Why.** An operator moves between the web app and the phone app. The two should feel like one product.

## 10. Right-to-left

**Rule.** Aeros ships left-to-right. Right-to-left is not a supported target and is not tested.

New code uses logical properties where they cost nothing (`text-start` on the web, `EdgeInsetsDirectional` in Flutter), and Flutter chevrons and tab arrow keys already follow the reading direction. Existing components still contain physical left and right.

**Why.** The products are for an LTR market today. Logical properties in new code keep a later retrofit from growing.

## 11. Boring is fine

**Rule.** Prefer the consistent choice over the clever one. Before adding something new, ask whether the operator would notice it missing.

**Why.** A system that is predictable is one people can build on without reading its source.
