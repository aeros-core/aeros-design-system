# Aeros Design System — how to build with it

`@aeros-core/react` is a **black-and-white, operator-focused** UI kit for information-dense operations software (dashboards, tables, RFQ/order flows) — not marketing pages. Components are exposed on `window.Aeros.*`. Build with the real components below; style with the DS's semantic Tailwind classes.

## Setup
- **No provider wrapper is required.** Theming is CSS-token based — just render components and they're styled by the shipped stylesheet.
- **Dark mode:** set `data-theme="dark"` on a root ancestor (e.g. `<html>`); every semantic color flips automatically.
- **One exception:** wrap any Tooltip usage in `<TooltipProvider>` once, high in the tree.
- Fonts load automatically: **Inter** for UI text, **IBM Plex Mono** for anything a computer produced (IDs, timestamps, currency, counts).

## Styling idiom — semantic Tailwind utilities (Tailwind v4)
Style with the DS's **semantic** classes (mapped to design tokens), never raw hex or arbitrary color scales. Compose layout with normal Tailwind (`flex`, `grid`, `grid-cols-2`, `gap-4`, `p-6`, `space-y-4`, `max-w-xl`, responsive `md:` variants — all shipped). The semantic families:

| Purpose | Classes |
|---|---|
| Surfaces (layered) | `bg-bg-canvas` (app bg) · `bg-bg-surface` (cards) · `bg-bg-elevated` (popovers) · `bg-bg-subtle` |
| Text | `text-fg-primary` · `text-fg-secondary` · `text-fg-muted` · `text-fg-inverse` (on dark) |
| Borders | `border-border-default` · `border-border-strong` · `border-border-subtle` |
| Brand / primary action | `bg-brand-primary` + `hover:bg-brand-primary-hover` (near-black; text uses `text-fg-inverse`) |
| Status (use only when an operator must act) | `bg-success` / `bg-success-bg` / `text-success-text` · same for `warning` · `danger` · `info` |
| Radius | `rounded-md` (chips/controls) · `rounded-lg` / `rounded-xl` (cards, modals) |
| Elevation | `shadow-xs` · `shadow-sm` · `shadow-lg` · `shadow-xl` (soft multi-layer; never one heavy drop) |
| Data / mono | `font-mono` on any computer-produced value; weights `font-medium` / `font-semibold` / `font-bold` |

Every component also accepts `className` to extend it. For inline CSS use the token vars directly: `var(--aeros-fg-primary)`, `var(--aeros-bg-surface)`, `var(--aeros-font-mono)`, `var(--aeros-border-default)`.

## Where the truth lives (read before styling)
- **Compiled tokens + every available utility:** `styles.css` and its `@import`ed `_ds_bundle.css` — the authoritative class/token set. If a utility isn't in there, it won't render (designs get only this pre-compiled CSS).
- **Per-component API + usage:** each component's `<Name>.d.ts` (props) and `<Name>.prompt.md` (how to compose it).
- **Design principles (READ THIS):** `guidelines/principles.md` — operators-first, black-and-white (reach for weight/spacing/depth before color), monospace-for-data, layered surfaces.

## Idiomatic example
```tsx
<Card>
  <CardHeader>
    <div>
      <CardTitle>Today's production</CardTitle>
      <CardSubtitle>Line 3 · updated 3 min ago</CardSubtitle>
    </div>
    <Badge variant="green" dot>Live</Badge>
  </CardHeader>
  <CardBody>
    <Progress value={64} />
    <p className="mt-3 font-mono text-xs text-fg-muted">4,820 units · 8% above yesterday</p>
  </CardBody>
  <CardFooter>
    <Button variant="secondary" size="sm">View</Button>
  </CardFooter>
</Card>
```
Use library components for controls and surfaces; use plain Tailwind (shipped) for your own layout glue. The system is **monochrome** — semantic green/amber/red appear only where an operator needs to act.
