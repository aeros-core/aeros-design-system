# @aeros-core/react

## 3.0.0

### Also in 3.0.0

- `@aeros-core/react/cn` — the `cn()` helper as its own entry without `"use client"`, so Server Components can call it.
- `AppHeaderTitle` takes `as` (`"h1"` default, `"h2"`, `"div"`) so a page with its own `h1` keeps a single one.
- `SidebarGroup` opens when it comes to hold the current page, not only on mount; a `Sidebar` inside a `SidebarProvider` is hidden below `md` in CSS, so a phone never paints the desktop column first.
- `Alert` accepts `role={undefined}` to opt out of the live region. `Field` no longer stretches a shorter control beside a taller field.
- Fixed: a `DatePicker` inside a `Field` could keep a dangling `aria-labelledby` after hydration.

### Major Changes

- b516f24: **3.0 — new token blocks, self-hosted fonts.** No existing token value changes here.

  - **Breaking:** `@aeros-core/react/styles.css` no longer fetches fonts from Google Fonts. Import the new `@aeros-core/react/fonts.css` (self-hosted Inter with its optical-size axis, Nunito Sans with its width axis, IBM Plex Mono 400/500) or load the faces yourself. The font tokens now lead with the variable family names (`'Inter Variable'`, `'Nunito Sans Variable'`) and fall back to the plain ones.
  - New tokens: control sizes and density (`size`, with `data-density="touch"`), elevation intents (`raised` / `overlay` / `modal`, light + dark), semantic radii (`item` / `control` / `surface` / `modal` / `pill`), focus ring metrics, opacity, border widths, layout widths, state colours (`state-hover` / `state-pressed` / `state-selected`), `scrim`, `fg-disabled`, `danger-hover`, and `enter` / `exit` easings.
  - New Tailwind utilities from those tokens: `text-<role>` (size + line height + tracking + weight in one class), `h-control-md`, `size-icon-md`, `rounded-control`, `shadow-overlay`, `z-modal`, `duration-fast`, `max-w-dialog-md`, `w-sidebar`, `bg-state-hover`, `bg-scrim`, `opacity-disabled`, `outline-offset-field`.
  - `cn()` understands the Aeros class names (tailwind-merge v3 configured from the tokens), so `text-body-sm text-fg-muted` keeps both and `rounded-md rounded-control` resolves to the latter.
  - The default transition timing is the token `fast` / `standard`, not Tailwind's 150ms.

- be3b3c5: **3.0 — the app shell.** The sidebar and header follow the theme (they were permanently dark) and are built for real app frames.

  - **Sidebar:** `SidebarProvider` + `useSidebar` (rail state, optional `storageKey` persistence, Cmd/Ctrl+B), a 56px icon rail with tooltips, one level of nesting (`SidebarGroup` / `SidebarSubItem`), and a left sheet at touch density below the `md` breakpoint. New parts: `SidebarHeader`, `SidebarContent`, `SidebarFooter`, `SidebarTrigger`. Width is 240 (was 228).
  - **Shell:** `AppShell`, `AppMain`, `AppHeader` (48px, full width, hairline), `AppHeaderBrand`, `AppHeaderTitle`, `AppHeaderNav`, `AppHeaderLink`, `AppHeaderActions`, `AppContent`, `AppFooter`.
  - **Breaking:** `TopNav` → `AppHeader`, `TopNavBrand` → `AppHeaderBrand`, `TopNavLinks` → `AppHeaderNav`, `TopNavLink` → `AppHeaderLink`, `TopNavRight` → `AppHeaderActions`. The header is no longer a rounded dark bar.
  - **Breaking:** put `SidebarBrand` inside `SidebarHeader` and the sections inside `SidebarContent`. For dark chrome in a light app, theme the subtree: `<Sidebar data-theme="dark">`.
  - Fixed: `SidebarItem asChild` threw, so a framework `<Link>` could not be used as a row.

- b594ca4: **3.0 — new components.**

  - **DataTable** — sorting, row selection with a selection bar, density (`compact` / `default` / `comfortable`), sticky header, loading and empty states, client or server pagination, clickable rows. Built on `@tanstack/react-table` v9 and the existing `Table` parts; `createDataTableColumnHelper` gives typed cells.
  - **Combobox** and **MultiCombobox** — a select with search (groups, descriptions, clear, async options).
  - **DatePicker** and **DateRangePicker** — field-styled triggers over `Calendar`, with min/max, presets and form posting.
  - **NumberInput** — keyboard stepping, clamping, precision, unit prefix/suffix.
  - **Toggle**, **ToggleGroup**, **SegmentedControl**.
  - **Collapsible**, **ScrollArea**, **CountBadge**, **FilterChip**, **Kbd**, **PageHeader**, **FileUpload**, **Stepper**.

  Changed: `Tr selected` no longer sets `aria-selected` (invalid on a plain table row) — it sets `data-selected`; `Th` aligns with `text-start`; `TableLoadingRow` takes `statusLabel`.

- 4ba5904: **3.0 — removals.** Everything the restyle replaced is gone.

  - Shadows: the `xs`–`xl`, `hairline` and `focus*` shadow tokens (`--aeros-shadow-*`, `shadow-sm` …) are removed. Use the elevation intents `shadow-raised` / `shadow-overlay` / `shadow-modal`; resting surfaces take a hairline border.
  - Radius: `2xl` / `3xl` / `4xl` are removed. Use `rounded-item|control|surface|modal|pill`.
  - Motion: the `emphasized`, `decelerate`, `entrance` and `spring` easings are removed. Use `ease-standard`, `ease-enter`, `ease-exit`.
  - Aliases: `focus-ring-offset` is removed (the focus ring has a transparent offset).
  - CSS: the `.aeros-text-<role>` classes are removed. Use the Tailwind utilities `text-<role>`.

- 535bfb2: **3.0 — every component except the app shell is restyled on shared recipes.** Resting surfaces are a hairline with no shadow; only floating layers have elevation; nothing lifts or scales on hover; one focus ring everywhere.

  Breaking changes to act on:

  - **Button:** `size="icon-sm|icon-md|icon-lg"` → `size="sm|md|lg" iconOnly`. `variant="danger"` is now solid; use `variant="danger-subtle"` for the old tinted look. Heights are 24 / 28 / 32 / 36 / 40 (were 28 / 32 / 36 / 40 / 48). `asChild` now works with `leadingIcon` / `trailingIcon`.
  - **Field:** no longer has a bottom margin — wrap fields in the new `FieldGroup`, or space them yourself. Inputs, textareas and select triggers are 28 / 32 / 36 high.
  - **Tabs:** `TabsContent` no longer has a top margin.
  - **Dialog:** default width is 520 (was 420); pass `size="sm"` for 400. `AlertDialog` defaults to 400 (was 420) and `Drawer` to 480 (was 448). New `size` prop on `DialogContent`, `AlertDialogContent` and `DrawerContent`. Modal footers have no fill.
  - **Card / StatCard:** no shadow. `interactive` cards change border and fill on hover instead of lifting.
  - **Toast:** tones colour the title; the surface is always the neutral elevated one.
  - **Avatar:** sizes are 20 / 24 / 32 / 40 / 56. **Checkbox / Radio:** 16px. **Switch:** 36×20.
  - **Focus:** components no longer draw a ring; the global `:focus-visible` outline does. Remove any `ring-offset-*` overrides you added to match the old ring.

  New: `DropdownMenuCheckboxItem`, `DropdownMenuRadioGroup` / `RadioItem`, `DropdownMenuSub` / `SubTrigger` / `SubContent`, `DropdownMenuShortcut`, `TooltipContent arrow`, `FieldGroup`, styled `DrawerTitle` / `DrawerDescription`.

  Fixed: `Button asChild` threw; toast success / warning text failed contrast in light mode; `StatCard` did not announce the delta direction; `CommandInput` had no focus indicator.

- 9e3525e: **3.0 — tokens.json is the only source.** The Tailwind v4 theme is now generated (`@aeros-core/tokens/theme.css`) instead of hand-copied into `@aeros-core/react/styles.css`.

  - **Breaking:** the theme resets Tailwind's default palette, radii, shadows and easings. Classes such as `bg-blue-500`, `shadow-2xl` or `ease-out` no longer generate CSS in an app that imports `@aeros-core/react/styles.css` — use the Aeros alias classes (`bg-bg-surface`, `text-fg-muted`, `shadow-overlay`, `ease-standard`, …). `white`, `black` and the `ink-*` ramp remain.
  - **Breaking:** the unused Tailwind v3 preset export `@aeros-core/tokens/tailwind` is removed.
  - New: `data-theme="system"` follows the OS colour scheme; `data-theme` now works on any element, so a subtree can be themed on its own; a `dark:` variant is available.
  - New: token references (`{color.ink.900}`, `{color.ink.900 / 0.05}`); the JS export is fully typed and adds `rawTokens`.
  - Fix: `styles.css` scans the published `dist/`, so installed (non-monorepo) consumers get the component classes.

- b71425a: **3.0 — the "Crisp precision" values.** Everything shifts; review each app visually when upgrading.

  - **Colour:** the warm stone ink ramp is replaced by a cool neutral one (`ink-0` … `ink-950`, plus a new `ink-850`). Aliases are now references into the ramp: canvas `ink-50`, surface white, text `ink-900`, borders `ink-200` / `ink-300`; dark mode is near-black (`ink-950` canvas, `ink-900` surface, `ink-850` elevated). `info` status colours are ramp references.
  - **Radius:** the scale tightens — `xs` 2, `sm` 4, `md` 6, `lg` 8, `xl` 12 (were 4 / 6 / 8 / 12 / 16). `2xl` / `3xl` / `4xl` are removed; use the semantic radii (`rounded-control`, `rounded-surface`, `rounded-modal`).
  - **Motion:** durations are `quick` 80, `fast` 120, `base` 180, `slow` 260 ms (were 90 / 120 / 200 / 320).
  - **Type scale:** display 48 / 36 / 30, h1 24, h2 20, h3 16, h4 14 — all weight 600; body 16 / 14 / 13 at 450; labels 14 / 13 / 11 at 500; caption 12; mono 20 / 13 / 12 / 11. The `light` and `extrabold` weight tokens are removed.
  - The contrast gate now also checks every text tier on every surface, the solid danger button, and text over the hover / pressed / selected overlays.

### Minor Changes

- 5350b28: The sidebar spec, shared by web and Flutter.

  **Sidebar (react)**: rows are a fixed 32px (`h-8`) with 16px icons; `SidebarSection` labels are sentence case, 12px medium (were 10px uppercase tracked); `SidebarItem` gains `count`, a pill announced with the label. (Superseded in 3.0: the sidebar now follows the theme — see the app-shell entry.)

  Flutter `AerosSidenav` moves to the same spec in `aeros_design_system` 2.3.0 (see `packages/flutter/CHANGELOG.md`).

### Patch Changes

- c60dd68: The `aeros-logo` wordmark class matches the reference logo artwork: Nunito Sans wdth-125 at weight 500 with +0.01em tracking (was weight 800, −0.02em). Flutter `AerosWordmark` moves to the same spec in `aeros_design_system` 2.5.0.
- Updated dependencies [b516f24]
- Updated dependencies [4ba5904]
- Updated dependencies [5350b28]
- Updated dependencies [9e3525e]
- Updated dependencies [b71425a]
  - @aeros-core/tokens@3.0.0

## 2.1.0

### Minor Changes

- 5f88bcd: 2.1.0 — audit P2/P3: component coverage + institutionalized quality gates.

  **New components (react)**: Toast (`Toast*`, `Toaster`, imperative `toast()`), AlertDialog, Popover, Drawer/Sheet (right/left/bottom), Accordion, Pagination, Command/Combobox surface (cmdk), Calendar (react-day-picker, token-styled), Label, Separator, Spinner, Skeleton. Table gains sortable `Th` (`aria-sort`), `selected` rows, and `TableLoadingRow`/`TableEmptyRow`. Dialog/Drawer bodies scroll; overlay enter/exit animations actually run now (`tw-animate-css` — the old `animate-in` classes silently compiled to nothing).

  **Tokens**: the Dart emission now includes theme aliases, easing curves, and semantic-dark sets, and is written into the Flutter package as `aeros_tokens.g.dart` — the Flutter token layer aliases it, making hand-drift structurally impossible (CI verifies freshness + completeness).

  **Process**: vitest + Testing Library + jest-axe suite (Field ARIA wiring, live-region roles, table semantics, overlay behavior — axe-clean), eslint + jsx-a11y, and a version-lockstep check, all wired into CI.

### Patch Changes

- Updated dependencies [5f88bcd]
  - @aeros-core/tokens@2.1.0

## 2.0.0

### Major Changes

- 9a14088: 2.0.0 — audit remediation: truthful monochrome API, working dark mode, accessible forms/nav, token-driven motion/z-index.

  **Breaking**

  - Variant renames (color-words → intent): Badge/Alert `green/amber/red/blue/grey/dark` → `success/warning/danger/info/neutral/inverse`; Tag `blue/grey/dark` → `info/neutral/inverse`; Avatar `tone` → `variant` (`neutral/inverse/info/success/warning`); Progress `color` → `variant` (`brand/success/warning/danger`); Button `dark` variant removed (identical to `primary`).
  - Tokens: `royal` and `slate` ramps deleted (byte-identical copies of `ink`); `accent`/`accent-muted` aliases removed (consumed by nothing); `warning` base is now `#CC6D04` (WCAG 3:1 on its chip background); Tailwind preset font corrected to Inter and now exports screens/z-index/easings.
  - `Alert` defaults to `role="status"`; only `variant="danger"` is `role="alert"`.

  **Fixed / added**

  - Published bundle keeps `"use client"` (Next.js App Router imports no longer crash); CI asserts it.
  - Dark mode: status colors and shadows now have true dark values (`semanticDark`, `shadowDark` in tokens.json) and Tailwind utilities pick them up; Field labels/hints/placeholders use theme-aware aliases.
  - Forms: `Field` auto-wires `id`/`aria-describedby`/`aria-invalid`/`aria-required` to Input/Textarea/SelectTrigger via context; error state cascades; success focus ring is a token.
  - Select/DropdownMenu content scrolls within the viewport (scroll buttons included); `SelectLabel`, size + state props on field controls (`sm/md/lg`).
  - Sidebar/TopNav items are real links/buttons (keyboard-operable), support `asChild`, and set `aria-current="page"`; `Button variant="link"` box-reset actually wins; `Th` sets `scope="col"`; last-row border fix; Checkbox indeterminate works uncontrolled.
  - Motion/z-index consumed from tokens everywhere (no more `duration-[120ms]` / `z-[1400]` literals) — CI greps for regressions; breakpoints emitted to CSS/JS/Tailwind/Dart.

### Patch Changes

- Updated dependencies [9a14088]
  - @aeros-core/tokens@2.0.0

## 1.2.0

### Minor Changes

- 6065a07: Apple-level design refresh (matches Flutter DS v1.3.0): switch the UI typeface to **Inter** (loaded via the stylesheet; `--font-sans` updated), warm layered neutrals with real elevation in both light and dark, sturdier interactive type weights (labels/buttons → 600, display → 800, overline → 700), and a new `label-xs` text token. Light `fg-muted` darkened slightly to clear WCAG AA on the subtle fill.

### Patch Changes

- Updated dependencies [6065a07]
  - @aeros-core/tokens@1.2.0

## 1.1.0

### Minor Changes

- 7cec0a2: Modernize the design system toward a calmer, more layered register (ChatGPT/Figma) while staying strictly monochrome:

  - 12-step faint-warm neutral ramp (fills the old 300/500/700 gaps)
  - layered surfaces (canvas → surface → elevated → subtle) so cards lift; dark mode steps lighter
  - two-layer soft shadows; visible two-tone focus ring
  - 36px default controls; Bold-700 headings with relaxed tracking
  - the token builder now emits the type scale as CSS classes + Dart `TextStyle`s
  - theme-aware primary/checked/tooltip fills (fixes a dark-mode static-fill bug)

### Patch Changes

- Updated dependencies [7cec0a2]
  - @aeros-core/tokens@1.1.0
