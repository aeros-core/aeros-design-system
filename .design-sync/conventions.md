# Aeros Design System 3.0: how to build with it

`@aeros-core/react` 3.0 ("Crisp precision") is a **monochrome, operator-focused** UI kit for information-dense operations software (dashboards, tables, RFQ and order flows), not marketing pages. Components are exposed on `window.Aeros.*`. Build with the real components; style your own layout with the token classes below.

## The look in one paragraph
Black, white and a cool neutral ramp. **No blue, no accent hue**: the only colours are the four status colours, and `info` is neutral grey. Resting surfaces are flat: a fill and a 1px hairline, **no shadow**. Shadows exist only on floating layers (menus, popovers, dialogs). Hover and press change colour only; nothing lifts, scales or glows. Controls are compact (32px default). Headings are weight 600, labels 500, body 450.

## Setup
- **No provider wrapper is required.** Theming is CSS-token based.
- **Theme:** `data-theme="light" | "dark" | "system"` on `<html>` or on any element (it scopes). Dark is near-black. App chrome follows the theme; for dark chrome on a light page put `data-theme="dark"` on `<Sidebar>` or `<AppHeader>`.
- **Density:** `data-density="touch"` on any element enlarges controls and rows; the default is pointer density.
- **Tooltips:** wrap the tree once in `<TooltipProvider>`. **Toasts:** mount `<Toaster />` once and call `toast()`.
- **Fonts** load with the stylesheet: **Inter** for UI text, **IBM Plex Mono** for anything a computer produced (IDs, timestamps, currency, counts). **Nunito Sans** is for the wordmark only.
- **Wordmark:** the word "Aeros" as a logo uses the `aeros-logo` class (`SidebarBrand` and `AppHeaderBrand` apply it for you). Never restyle it.

## Styling idiom: token classes only (Tailwind v4)
The theme **resets** Tailwind's default palette, radii, shadows, easings and font families. A class such as `bg-blue-500`, `text-gray-600`, `rounded-2xl`, `shadow-md` or `font-serif` generates **no CSS and no error**. Use the families below. Layout utilities (`flex`, `grid`, `grid-cols-2`, `gap-4`, `p-6`, `space-y-4`, `max-w-*`, `md:` variants) work as usual on a 4px base.

| Purpose | Classes |
|---|---|
| Surfaces | `bg-bg-canvas` (page) · `bg-bg-surface` (cards) · `bg-bg-elevated` (floating) · `bg-bg-subtle` · `bg-bg-inset` · `bg-bg-inverse` |
| Text | `text-fg-primary` · `text-fg-secondary` · `text-fg-muted` · `text-fg-disabled` · `text-fg-inverse` |
| Borders | `border border-border-default` (the hairline) · `border-border-strong` · `border-border-subtle` |
| Primary action | `bg-brand-primary` + `hover:bg-brand-primary-hover` with `text-fg-inverse` (ink, never a hue) |
| Interaction fills | `hover:bg-state-hover` · `bg-state-pressed` · `bg-state-selected` · `bg-scrim` |
| Status (state only) | `bg-success-bg` / `text-success-text` / `border-success-border` / `bg-success`; the same four for `warning`, `danger`, `info` |
| Type roles | `text-display-xl/lg/md` · `text-h1`…`text-h4` · `text-title-lg` · `text-body-lg/md/sm` · `text-label-md/sm/xs` · `text-caption` · `text-overline` · `text-mono-lg/md/sm/xs`. Each sets size, line height, tracking and weight |
| Radius | `rounded-item` (4) · `rounded-control` (6) · `rounded-surface` (8, cards) · `rounded-modal` (12) · `rounded-pill` |
| Elevation | `shadow-raised` · `shadow-overlay` (menus, popovers, toasts) · `shadow-modal` (dialogs, drawers). Floating layers take a shadow and **no border** |
| Sizes | `h-control-xs`…`h-control-xl` (24 / 28 / 32 / 36 / 40) · `size-icon-xs`…`size-icon-xl` (12 / 14 / 16 / 20 / 24) · `h-header` (48) · `h-row` (40) · `w-sidebar` (240) · `max-w-dialog-sm/md/lg/xl` · `max-w-content-max` |
| Motion | `transition-colors` with `duration-quick/fast/base/slow` and `ease-standard/enter/exit` |
| Layers | `z-dropdown` · `z-sticky` · `z-overlay` · `z-modal` · `z-popover` · `z-toast` · `z-tooltip` |
| Data | `font-mono` (or a `text-mono-*` role) on any computer-produced value |

Every component accepts `className`. For inline CSS use the variables: `var(--aeros-fg-primary)`, `var(--aeros-bg-surface)`, `var(--aeros-border-default)`, `var(--aeros-font-mono)`, `var(--aeros-radius-surface)`, `var(--aeros-elevation-overlay)`.

**Do not** draw focus rings (`ring-*`, `ring-offset-*`): the global `:focus-visible` outline is the only ring. **Do not** add a shadow to a card or any resting surface. **Do not** use `active:scale-*` or hover translate effects.

## Component vocabulary
- **Variants are intent-named:** `Badge`, `Tag`, `Avatar`, `Alert` take `variant="neutral" | "info" | "success" | "warning" | "danger" | "inverse"` (each supports a subset). There are no colour names (`green`, `blue`, `grey`).
- **Button:** `variant="primary" | "secondary" | "ghost" | "danger" | "danger-subtle" | "link"`, `size="xs"`…`"xl"`. One primary per view. Icon-only is `iconOnly` plus an `aria-label`. Pass icons through `leadingIcon` / `trailingIcon` and let the button size them.
- **Forms:** wrap a control in `Field` (label, hint, error) and stack fields in `FieldGroup`; `Field` has no margin of its own. Field-styled controls: `Input`, `Textarea`, `Select`, `Combobox`, `MultiCombobox`, `DatePicker`, `DateRangePicker`, `NumberInput`.
- **App frame:** `AppShell` > (`SidebarProvider` > `Sidebar`) + `AppMain` > `AppHeader` + `AppContent`. Sidebar structure is `SidebarHeader` (holds `SidebarBrand`), `SidebarContent` (holds `SidebarSection` > `SidebarItem` / `SidebarGroup` > `SidebarSubItem`), `SidebarFooter`. Start a page with `PageHeader`.
- **Tables:** `DataTable` (sorting, selection, pagination, density) for real data; the `Table` parts for a simple presentational table.
- **Overlays:** `Dialog` (`size="sm" | "md" | "lg" | "xl" | "full"`), `AlertDialog` for a confirmation, `Drawer` (`size`, side), `Popover`, `DropdownMenu`, `Tooltip`.
- **Removed in 3.0, do not use:** `TopNav*` (now `AppHeader*`), Button `size="icon-*"` and `variant="dark"`, `shadow-xs…xl`, `rounded-2xl/3xl`, `.aeros-text-*` classes.

## Where the truth lives (read before styling)
- **Compiled tokens and every available utility:** `styles.css` and its `@import`ed `_ds_bundle.css`. If a utility is not in there, it will not render (designs get only this pre-compiled CSS).
- **Per-component API and usage:** each component's `<Name>.d.ts` (props) and `<Name>.prompt.md` (how to compose it).
- **Design principles:** `guidelines/principles.md`. Token reference: `guidelines/tokens.md`. Inventory: `guidelines/components.md` (React column).

## Idiomatic example
```tsx
<Card>
  <CardHeader>
    <div>
      <CardTitle>Today's production</CardTitle>
      <CardSubtitle>Line 3 · updated 3 min ago</CardSubtitle>
    </div>
    <Badge variant="success" dot>Live</Badge>
  </CardHeader>
  <CardBody>
    <Progress value={64} />
    <p className="mt-3 text-mono-sm text-fg-muted">4,820 units · 8% above yesterday</p>
  </CardBody>
  <CardFooter>
    <Button variant="secondary" size="sm">View</Button>
  </CardFooter>
</Card>
```
Use library components for controls and surfaces; use token classes for your own layout glue. Reach for weight, size and spacing before colour: status green, amber and red appear only where an operator needs to act.
