# aeros_design_system

## 3.1.0

### The uniform sidebar (`docs/sidebar/spec.md`)

`AerosScaffold` now presents the sidenav three ways by viewport width, like the web `Sidebar`.

- **Rail between `md` and `lg`.** From 768 to 1023 the sidenav rests as the 56px rail, and the top
  bar's button floats the full sidenav over the page (closes on a tap outside, Escape, or choosing
  a destination). It was the full 240 there. `railBreakpoint` sets the upper bound; set it to
  `sidenavBreakpoint` for the old behaviour.
- **`AerosSidebarController`** (new) owns and remembers the wide-window choice through `load` /
  `save` callbacks. Pass it as `AerosScaffold.sidebarController`. Without one the app still owns
  the rail through `AerosSidenav.collapsed` and `onRailCollapsedChanged`.
- **Animated width**, at `AerosMotion.base`; instant when animations are disabled.
- **Cmd/Ctrl+B** toggles the sidenav, except in a text field (`keyboardShortcut: false` to opt out).
- **The drawer** uses touch rows whatever the app density, sits inside the safe area, and closes
  when a destination is chosen.
- New on `AerosScaffoldState`: `isSidenavRailOnly`, `isSidenavFloating`, `closeFloatingSidenav()`,
  `dismissSidenav()`. `canToggleRail` is now also true in the rail-only range and with a controller.

`AerosSidenav`:

- **Icons never move.** Icons, the header mark and the footer avatar are centred 28px from the
  edge, expanded and collapsed (the mark and avatar were 20px in; 20px touch icons move 2px).
- **Selected row:** the `stateSelected` overlay at the label's normal weight (was `bgSubtle`, w600).
- **Counts** are a quiet number; `AerosNavItem(countEmphasis: true)` keeps the pill. In the rail a
  count is a dot on the icon.
- **In the rail** a row shows its name beside it on hover or keyboard focus, with no delay, and a
  parent opens its children in a menu instead of calling `onExpandRequested` (still called when
  there is no Navigator to open a menu in).
- **Children** hang from a hairline guide under the parent's icon; child labels are `bodySm`.
- A parent opens when the selection moves into it, not only on first build.
- `density` is nullable and follows an `AerosDensityScope` above it (pointer with none, as before).
- New: `onNavigate`, `semanticLabel` (the sidenav is a navigation landmark), `copyWith`.

## 3.0.0

### The "Crisp precision" values

Every colour, radius, duration and text size moves with the tokens — nothing in an app needs
renaming, but every screen looks different. Review visually when upgrading.

- **Colour:** cool neutral ink ramp (was warm stone), plus `AerosColors.ink850`. Dark mode is
  near-black: canvas `ink950`, surface `ink900`, elevated `ink850`.
- **Radius:** `AerosRadii` tightens — xs 2, sm 4, md 6, lg 8, xl 12 (were 4 / 6 / 8 / 12 / 16).
- **Motion:** quick 80, fast 120, base 180, slow 260 ms.
- **Type:** h1 24, h2 20, h3 16, h4 14, display 48 / 36 / 30 (all w600); labels w500; mono 20 /
  13 / 12 / 11. `AerosDensity.touch` body line height is 1.4 (was 1.45).

Typography now comes straight from the tokens, weights render, and the package has no runtime dependencies besides Flutter.

### Controls rebuilt on a foundation layer ("Crisp precision", structure)

Buttons, fields and the selection controls are now built on five shared primitives, so they agree on
height, radius, state and focus. Resting controls are a fill and a 1px hairline with **no shadow**;
hover and press change **colour only** (no ripple, no lift); there is **one focus ring**.

**Added — foundation (`lib/src/foundation/`, all exported)**

- `AerosPressable` — the one interaction primitive. Reports `AerosInteraction` (`hovered`, `pressed`,
  `focused` = keyboard focus only, `enabled`) to a builder; hand cursor; Enter / Space activation;
  semantics (`button`, `checked`, `mixed`, `toggled`, `selected`, `inMutuallyExclusiveGroup`,
  `semanticLabel`). Its tappable box is at least `AerosSizeTokens.minTarget` for the density (24
  pointer, 48 touch) without changing the visual's size; `expandHitTarget: false` opts out.
- `AerosStateLayer.resolve(aliases, base, hovered:, pressed:, selected:, enabled:)` — composites the
  `stateHover` / `statePressed` / `stateSelected` aliases over a base colour — and `AerosStateFill`,
  a hairline box that animates between state colours in `AerosMotion.quick`.
- `AerosFocusRing(focused:, radius:, tone:, placement:)` — a 2px ring painted outside the child by a
  foreground painter, so focus never shifts layout. `placement`: `outside` (buttons, toggles),
  `field` (straddles the border), `inset`. `tone: danger` uses the theme's danger colour.
- `AerosSurface(level: flat | raised | overlay | modal)` — flat = fill + hairline, no shadow;
  overlay / modal = `bgElevated` + the `AerosElevation` shadow and no border. The only place a
  `BoxShadow` should be attached.
- `AerosControlSize { xs, sm, md, lg, xl }` — one size ladder for buttons and fields:
  `resolveHeight(context)` / `heightFor(density)` (24 / 28 / 32 / 36 / 40 pointer, 32 / 36 / 40 / 44 /
  48 touch), `padH`, `gap`, `iconSize`, `labelStyle()`, `valueStyle()`, `radius`. `AerosControlSize.of(context)`
  reads an `AerosControlSizeScope` (default `md`).
- `AerosFieldFrame` — the shared field look, for composite inputs that should match the text field.
- Theme access: `AerosThemeExtension.semantic` and `.elevation` (both lerped on a theme change),
  `context.aerosElevation`; `AerosDensity.sizes` (the `AerosSizeTokens` for a density). The generated
  `AerosElevation`, `AerosSizeTokens`, `AerosShapeTokens` and `AerosMetricTokens` are exported.
- `AerosButtonVariant.dangerSubtle`, `AerosButton.icon(icon:, semanticLabel:, …)` (square, icon-only;
  the label is required for screen readers).
- A **disabled state** on `AerosCheckbox`, `AerosRadio` and `AerosSwitch`: pass `onChanged: null` or
  `enabled: false`. Each also takes a `semanticLabel`.
- `AerosSeverityPalette.of(context, …)`, `AerosSelectionPalette.of(context, …)`,
  `AerosPricePalette.of(context, …)`.

**Breaking — what an app has to change or re-check**

- **Button heights follow the density tokens**: 24 / 28 / 32 / 36 / 40 inside an
  `AerosDensityScope(density: pointer)`, 32 / 36 / 40 / 44 / 48 at touch or with no scope (were 28 /
  32 / 40 / 46 / 52 everywhere). Labels are `labelSm` (xs, sm) / `labelMd`; every size has the 6px
  control radius; horizontal padding is tighter (8 / 10 / 12 / 14 / 16). A long label now truncates
  with an ellipsis instead of overflowing.
- **A control's layout box is at least the density's minimum target** — at touch, a 40px `md` button
  or a checkbox occupies 44px. The painted control is unchanged; tight rows may grow by a few px.
- **`AerosButtonVariant.danger` is now solid red** with an inverse label (hover `dangerHover`). For the
  old tinted look use `AerosButtonVariant.dangerSubtle`. `AerosConfirmDialog(destructive: true)` uses
  the solid one.
- **`secondary` has a `borderStrong` hairline; `ghost` has no border** (it had `borderDefault`).
- **`AerosButtonSize` and `AerosFieldSize` are deprecated aliases of `AerosControlSize`** —
  `AerosButtonSize.md` still compiles. `AerosFieldSize` therefore gains `xs` and `xl` (an exhaustive
  `switch` over it needs two more cases), and `sm` / `md` / `lg` are 36 / 40 / 44 at touch (were 32 /
  40 / 46). The `AerosFieldSizeMetrics` extension is gone (its members are on the enum); `padV` is
  deprecated; `radius` is the control radius at every size.
- `AerosButton.size` is nullable (null = `AerosControlSize.of(context)`); the named constructors take
  `AerosControlSize? size`.
- **Fields** (`AerosTextField`, `AerosSearchField`, `AerosTagField`): `bgSurface` fill, 1px
  `borderStrong` that stays 1px when focused (focus is the ring), 6px radius at every size, error
  colours from the theme (legible in dark mode now), disabled = the whole field at 40% opacity (was a
  `bgSubtle` fill). `AerosSearchField` is no longer a borderless grey pill. `AerosTagField` fills the
  width it is given (it used to shrink to its chips). Helper and error text are drawn by the field,
  not by `InputDecoration`. `AerosTextField` is now a `StatefulWidget` (constructor unchanged).
- **Selection controls are custom-drawn, not Material wrappers**: checkbox and radio are 16px (were
  18), the switch is a 32×18 monochrome track on every platform (no Cupertino switch on iOS/macOS).
  The default hit area is the density minimum target — **48px at touch**, as Material padded
  before — and `compact` shrinks it to the glyph. `onChanged` is nullable on all three.
- **Status palettes no longer default to light.** `AerosSeverityPalette.of(severity, {isDark})` →
  `AerosSeverityPalette.of(context, severity)` or `.resolve(severity, context.aerosSemantic)`;
  `AerosSelectionPalette.resolve(state, aliases, {isDark})` → `.of(context, state)` or
  `.resolve(state, aliases, semantic)`; `AerosPricePalette.resolve(tone, aliases)` → `.of(context,
  tone)` or `.resolve(tone, aliases, semantic)`.
- **Every widget reads status colours from the theme** (`context.aerosSemantic`) — required markers,
  error text and error borders in the configurable-MTO widgets were the light reds in dark mode.
- **`AerosTheme` (ThemeData)**: `NoSplash` and transparent splash / highlight / hover colours — every
  Material `InkWell` in your app stops rippling and loses the default hover tint; `surfaceTint`
  transparent; `onError` / `onSecondary` / `onTertiary` are `fgInverse`; `secondary` / `tertiary`
  come from the aliases; `scrim` is the alias. Input borders are 1px in every state and
  `borderStrong` at rest; cards 8px, buttons / inputs 6px, dialogs 12px with **elevation 0** and a
  hairline. New token-driven themes for divider, icon button, checkbox, radio, switch, popup menu,
  bottom sheet, tooltip, scrollbar, list tile, progress indicator and text selection.
- `AerosThemeExtension` has two new fields; a hand-built `AerosThemeExtension(aliases:, isDark:)`
  still compiles and takes the status colours and elevation for its brightness.

**Not in this release step** (later PRs): cards, badges, tabs, dialogs, data table, sidenav / scaffold
and the configurable-MTO widgets keep their structure — they only picked up the status-colour fix and
the theme changes above.

### Cards, badges, feedback, navigation and the app shell restyled

The rest of the everyday widgets move onto the foundation layer: flat hairline surfaces, semantic
radii, token sizes per density, colour-only hover and press, the one focus ring, no ripple.

**Changed — look**

- **Cards** (`AerosCard`, `AerosStatCard`, `AerosIntentCard`, `AerosEmptyState`): `bgSurface` + 1px
  hairline, 8px corners, **no shadow**. Card header and footer are divided by hairlines and the
  footer has no fill. A tappable card / intent card tints and strengthens its hairline on hover and
  draws the focus ring. The empty state is a 1px dashed outline; its title is a semantic heading.
- **Badge family** (`AerosBadge`, `AerosTag`, `AerosCountBadge`, dense `AerosRoutingSignalBadge`):
  one height — `AerosSizeTokens.badge`, 18 pointer / 20 touch — tinted fill, 1px border in the
  tone's border colour, `labelXs`. A badge is a pill, a tag has 4px corners (`pill: true` still
  rounds it). `info` tones use the neutral `info*` status colours.
- **Chips**: `AerosFilterChip` gains a hairline and a focus ring; `AerosEnumChips` are control-sized
  (`AerosControlSize.sm`) with 6px corners and a 1px selected border (was 2px).
- **Feedback**: `AerosAlert` / `AerosConstraintErrorAlert` — tint + hairline, 8px corners, `labelSm`
  title, `bodySm` body. `AerosProgress` / `AerosStepper` — a 4px pill track. `AerosSnackbar` — an
  elevated surface (`bgElevated` + overlay shadow) like the web toast; the tone colours the icon
  and the message only. `AerosTheme.snackBarTheme` is no longer an inverse slab either.
  `AerosTooltip` sets its inverse / 4px / caption look itself.
- **Tabs**: underline = 1px baseline + 2px indicator, one row high; pill = a compact segmented
  track one control high whose active segment is lifted with `AerosElevation.raised`.
- **Breadcrumb, pagination, avatar**: breadcrumb links are real buttons; pagination buttons are
  control-sized squares with chevrons; avatars carry a 1px border.
- **Shell**: `AerosTopnav` is `bgSurface` with an `h4` title. Nav rows have 4px corners, hover is
  the shared `stateHover` overlay, selected stays `bgSubtle` + `fgPrimary` w600. The sidenav header
  and footer sit on `borderDefault` hairlines; an inline sidenav has a hairline on its trailing
  edge; the drawer is square and flat.

**Added**

- `AerosSidenav(collapsed: true)` — the 56px icon rail (`AerosMetricTokens.layoutSidebarRail`):
  labels become tooltips, group labels become hairlines, the header / footer keep the mark / avatar.
  `onExpandRequested` fires when a parent row is tapped in the rail. `AerosScaffold` sizes the rail
  from the sidenav and always shows the full sidenav in its drawer (`AerosSidenavExpanded`).
- `AerosSidenavDensity.sizes`, `.density`, `.labelStyle()`.
- `AerosCard.semanticLabel`; `AerosStatCard.deltaSemanticLabel` and
  `AerosStatCard.directionLabel()` — the delta is announced with its direction in words ("up
  +12.4%"); pass a localised sentence to override.
- `AerosTag.expandHitTarget`, `AerosTag.removeSemanticLabel`.
- `AerosSnackbar.show(description:)`.
- `AerosAvatar.semanticLabel`, `AerosAvatarSize.dimension`.
- `AerosPagination.previousLabel` / `nextLabel`; `AerosConstraintErrorAlert.dismissLabel`.
- `AerosProgress.trackHeight`.

**Fixed**

- `AerosProgress` with a value threw "Progress bar value, minValue, and maxValue must be valid
  numbers" in debug builds with semantics on (it passed "35%" as the value). It now reports a bare
  0–100 number, and out-of-range values are clamped.
- `AerosCountBadge` stretched to the full width inside a `Wrap` or a stretching `Column`; it now
  shrink-wraps everywhere.
- `AerosTabs` arrow keys follow the reading direction; chevrons in breadcrumb, pagination and the
  intent card mirror in right-to-left.

**Breaking — what an app has to change or re-check**

- **`AerosCardVariant.raised` is deprecated and renders flat.** Remove `variant:`; nothing in a
  resting layout carries a shadow. `AerosStatCard` lost its shadow too.
- **`AerosStatCard`**: the label is a sentence-case `caption` (no longer upper-cased); the mono
  value is `monoLg` (20px, was 26px).
- **Sizes changed** — re-check tight layouts: badges / tags are 18 / 20 high; avatars are
  20 / 24 / 32 / 40 / 56 (were 24 / 30 / 38 / 48 / 60); `AerosTopnav` is 48 / 56 by density (was 60)
  and `AerosTopnav.height` is now nullable (null = the density's header height); `AerosIntentCard`
  uses `h4` / `bodySm` and a 40px icon tile; `AerosEmptyState` has less vertical padding.
- **Touch targets grow at touch density** (and with no `AerosDensityScope`): a removable `AerosTag`,
  a tappable `AerosRoutingSignalBadge`, an `AerosEnumChips` chip, a breadcrumb link, the pagination
  arrows and the alert's resolve / dismiss buttons occupy at least 48px, with the visual centred in
  that box. Inside an `AerosDensityScope(density: pointer)` the minimum is 24px.
  `AerosFilterChip.touchTargetHeight` is now 48 (was 44) and is a getter, not a `const`.
- **A removable `AerosTag` is one button** announced as "Remove <label>" (was an unlabelled
  gesture). A tappable `AerosCard` announces its content as one button — do not nest buttons in it.
- **`AerosPageHeader`**: the default padding is horizontal only and the title row is at least one
  header high (48 / 56), so it lines up with the sidenav header. Pass `padding:` to restore the old
  16px vertical padding. The subtitle is `bodySm`.
- **`AerosScaffold.sidenavBreakpoint` defaults to the `md` breakpoint (768, was 720)** and is
  compared with the real viewport width — an `AerosViewportScope` wins over `MediaQuery`.
  `sidenavWidth` defaults to `AerosMetricTokens.layoutSidebar`; the drawer is 280 wide.
- **Sidenav blocks follow the ambient density**: `AerosSidenavHeader` / `AerosSidenavFooter` are
  `AerosDensity.of(context).sizes.header` high — 48 inside a pointer `AerosDensityScope`, 56
  otherwise. `kAerosSidenavBlockHeight` is deprecated and no longer a `const`.
- **`AerosSidenavDensity`'s `rowHeight` / `iconSize` / `labelSize` are getters** over the `navRow` /
  `navIcon` / `navLabel` tokens (same values); the enum constructor arguments are gone.
- **Sidenav hover** is the `stateHover` overlay (was a half-step between the rail and the selected
  fill). The footer action is an icon button sized by density (32 / 44).
- **`AerosSnackbar`**: the action is a small secondary button inside the surface, not a
  `SnackBarAction`; the message colour follows the tone.
- **Material ink is gone** from every widget above: anything that looked for an `InkWell` /
  `Material` inside them (tests, custom themes' `splashColor`) no longer finds one.

### Overlays, the data table and the configurable-MTO widgets restyled — the package is now all on the foundation

Every floating layer is built on five new primitives, the data table no longer wraps Material's, and the
last widgets leave `InkWell`. Nothing in `lib` uses `InkWell`, `showDialog`, `showModalBottomSheet`,
`showMenu`, `PopupMenuItem`, `DropdownButton` or `DataTable` any more.

**Added — overlay primitives (all exported)**

- `AerosDialog({title, description, content, actions, size, maxWidth, showClose, scrollable, contentPadding,
  semanticLabel})` and `AerosDialog.show<T>(context, builder:, barrierDismissible:, useRootNavigator:)`.
  `bgElevated` + the modal elevation + `shape.modal` corners over the `scrim` alias; a header (title,
  description, close button), a body that scrolls, a footer with a top hairline and no fill.
  `AerosDialogSize { sm, md, lg, xl }` is `layout.dialog*` (400 / 520 / 720 / 960), default `md`. Fades in
  with a slight scale (`AerosMotion.base`; instantly under reduced motion), keeps focus inside, closes on
  Escape and a scrim tap (neither with `barrierDismissible: false`), and is announced by its title.
- `AerosSheet({title, description, content, actions, …})` and `AerosSheet.show<T>(context, builder:,
  side: bottom | right | left, size: sm | md | lg)`. The same header / body / footer. A bottom sheet is full
  width with a drag handle (drag down to dismiss); a side sheet is full height and `layout.drawer*` wide
  (360 / 480 / 640).
- `AerosPopover(trigger:, content:, controller:, side:, align:, matchAnchorWidth:, padding:, constraints:)`
  and `AerosPopover.show<T>(context, builder:, anchorRect:, …)` — an anchored surface (`bgElevated`, the
  overlay elevation, `shape.surface`) with any content. Opens below its anchor, flips when there is no
  room, is clamped to the screen; Escape and an outside tap close it and focus returns to the trigger.
  `AerosPopoverController` has `open()`, `close()`, `toggle()` and `isOpen`.
- `AerosMenu(items:, trigger:, …)` and `AerosMenu.show<T>(context, items:, …)` with `AerosMenuItem<T>`
  (`label`, `onSelected`, `value`, `leading`, `shortcut`, `enabled`, `destructive`),
  `AerosMenuCheckboxItem`, `AerosMenuRadioItem<T>`, `AerosMenuSeparator` and `AerosMenuLabel`. 4px padding,
  rows `shape.item` at control-sm height, one highlight shared by mouse and keyboard (the hover state
  layer; the danger tint for a destructive row). Arrow keys, Home and End move (skipping disabled rows),
  Enter / Space choose. Callbacks run after the menu has closed. `AerosMenuRow` and `AerosMenuList` are the
  row and the list on their own; `AerosWholeRows` cuts a scrolling list of equal rows at a whole row.
- `AerosSelect<T>({items, value, onChanged, placeholder, label, helper, error, enabled, required, size})`
  with `AerosSelectItem<T>(value:, label:, leading:, detail:, enabled:)` — a field-styled trigger (the
  shared field frame, so it is the same height as `AerosTextField`) that opens the options with the chosen
  one checked. `AerosSelect.showOptions<T>(context, …)` opens the same list from any trigger.
- `AerosPressable.hover(builder:)` — hover tracking only: no taps, no focus, no semantics.
- `AerosFormField.labelGap` (default unchanged, 8); the field-like widgets use 6, like `AerosTextField`.
- `AerosDataTable.emptyText` (default `'No data'`) and `rowSemanticLabel`; `AerosMeasurementInput.size`.

**Breaking — what an app has to change or re-check**

- **`AerosConfirmDialog`** is an `AerosDialog` (`size: sm`, 400 wide — was 440): elevated surface, 12px
  corners, `h3` title, `bodySm` body, buttons in a footer under a hairline. `show(...)` is unchanged and
  still returns `false` when dismissed.
- **`AerosDropdownSearch`**: the trigger is a field frame (control `md` high — 32 pointer / 40 touch; it
  was taller, and the same at both densities) and announces itself as a button. `mode: dialog` opens an `AerosDialog` (`md`, or
  `dialogMaxWidth`; as tall as its list, capped by `maxHeight` — it was 70% × 60% of the screen),
  `mode: sheet` an `AerosSheet`, `mode: menu` an anchored surface exactly as wide as the field. **The menu
  presentation now honours `showSearchBox` and `onFind`** (it ignored both): pass `showSearchBox: false` to
  keep a plain list. Its viewport ends on a whole row — the last visible row is no longer cut through its
  text. The chosen option is marked with a check (was bold on a tint). `itemBuilder` rows are wrapped in the
  shared menu row, which adds 8px horizontal padding and the highlight.
- **`AerosDataTable`** no longer wraps Material `DataTable` (it is a `StatefulWidget` now; the constructor
  is unchanged apart from the two additions above).
  - Header and rows are the `row` token: 40 pointer / 48 touch (header was 44, rows 48–56). A row grows
    with a taller cell.
  - The header is plain — no fill — with `labelXs` muted labels; cells default to `bodySm` in `fgPrimary`
    (was `bodyMd`), and **`numeric` columns are right-aligned in mono**. Cell padding is 12px.
  - Hover tints a row with the state layer; a selected row takes `stateSelected`. Selection uses
    `AerosCheckbox`, and the header checkbox is mixed when some rows are selected.
  - Sortable headers are buttons with a caret, a focus ring and an announced sort state
    (`"Order, sorted ascending"`). `AerosDataSort.columnIndex` still counts your columns.
  - **Inside a bounded height the rows now scroll under a header that stays in place** (it used to
    overflow). In an unbounded height it is as tall as its rows, as before.
  - The empty state is plain centred text under the header, inside the one frame. If you pass
    `emptyState: AerosEmptyState(...)` you get its dashed outline inside the frame again — pass plain
    content, or `emptyText`.
  - The loading veil is `bgSurface` at `opacity.muted` and no longer covers the `footer`.
  - Screen readers: header cells are headers, each row checkbox is named for its row
    (`rowSemanticLabel`), a tappable row is a button that reports `selected`. Flutter's table roles are not
    used — they need a row / cell tree this layout does not have.
- **`AerosEnumDropdown`** is an `AerosSelect`: same constructor, the options open in the menu surface, and a
  disabled option shows its `disabledReason` at the end of its row.
- **`AerosMeasurementInput`** is one field frame (the inner second border is gone) at control `md` height.
  The unit is a button at the end of the field that opens the list of units — plain text when there is only
  one. Disabled dims the whole field. Without `helperText`, the "Allowed: …" line still shows.
- **`AerosRangeSlider` / `AerosNumericRangeBand`** keep Material's `Slider` / `RangeSlider` under one
  token-driven theme: 2px track, 14px thumb (`bgSurface` with a `brandPrimary` hairline), no tick marks, no
  halo; the slider's height is the density's minimum target (24 pointer / 48 touch). Keyboard focus draws
  the focus ring around the thumb of `AerosRangeSlider`; Material's `RangeSlider` takes no keyboard focus,
  so the band has none. Disabled dims the whole control.
- **Mono amounts are 400 / 500 only.** The slider and band values and every `AerosPriceBreakdown` amount
  no longer ask for w600 / w700 (IBM Plex Mono ships Regular and Medium). The breakdown's header total is
  `monoLg` (20px) medium; the total row is a hairline above, no fill.
- **`AerosPriceBreakdown`**, **`AerosRepeatingRows`** rows and the attached-file row of
  **`AerosFileUploadButton`** are flat surfaces with 8px corners. The upload drop zone is a button (hover
  tint, focus ring, Enter / Space) with a 1px dashed outline; "Replace" and "Remove" are `AerosButton`s.
  The repeater's remove button is a neutral ghost icon button (was a red `IconButton`).
- **`AerosVariantPicker`** chips are the `AerosEnumChips` chip (control `sm`, a hairline that stays 1px, a
  check on the selected one); stock badges are `AerosBadge`s. Swatch tiles are 56px with a 2px `fgPrimary`
  border when selected. Both are keyboard-focusable and announce `selected`.
- **`AerosAttributeSelector`**: a locked BOOLEAN attribute now shows a disabled switch (it looked enabled
  and ignored taps).
- **`AerosHoverable`** with `onTap` is now a real button — focusable, Enter / Space, announced, with the
  focus ring around what the builder returns. Without `onTap` it only tracks the pointer, as before.
- **`AerosSearchField`**: Escape with an empty query is no longer swallowed, so it closes the dialog or
  menu the field sits in.
- **`AerosShadows`** is **removed** (the class and its `card` / `menu` / `dialog` /
  `popover(bool isDark)` functions): use `AerosSurface(level: …)`, or `context.aerosElevation` for
  the raw shadow lists.

### Breaking

- **`google_fonts` is no longer a dependency.** IBM Plex Mono (Regular 400 + Medium 500, SIL OFL — `assets/fonts/OFL-IBMPlexMono.txt`) is bundled as the `IBM Plex Mono` family, like Inter, so mono text needs no network on first paint and renders in widget/golden tests. **If your app imports `package:google_fonts` itself and was getting it transitively through this package, add `google_fonts` to your own `pubspec.yaml`.** To use the bundled face outside `AerosTypography`, write `TextStyle(fontFamily: 'IBM Plex Mono', package: 'aeros_design_system')`.
- **Body text is weight 450** (`bodyLg` / `bodyMd` / `bodySm`), the brand text weight — it rendered at 400. `fontWeight` still reports `w400` (Flutter has no 450); the `wght` axis carries the 450. Expect body copy a touch sturdier and a hair wider.
- **Tracking follows the tokens.** `AerosTypography` is now a thin wrapper over the generated scale (`tokens.json`), so the hand-written values that had drifted are gone: `h4` −0.16 → −0.13, `bodySm` 0.01 → 0.04, `labelSm` 0.01 → 0.03, `caption` 0.02 → 0.05. Sizes, line heights and the other weights are unchanged.
- **Weights inside the widgets now render.** 36 `copyWith(fontWeight:)` calls on Inter styles in the widget layer changed nothing on screen (Inter is a variable font and the glyphs follow the pinned `wght` axis — see 2.3.0); they now go through `withWeight`. Visibly heavier, and slightly wider, than before: the active tab (`AerosTabs`, w600 vs w500 inactive), the current breadcrumb, field labels (`AerosEnumChips`, `AerosEnumDropdown`, `AerosDropdownSearch`, `AerosMeasurementInput`, `AerosRangeSlider`, `AerosNumericRangeBand`, `AerosVariantPicker`, `AerosFileUploadButton`, `AerosAttributeSelector`), field values (w500), `AerosDataTable` headings, pagination numbers, chip and variant labels, the selected option in `AerosDropdownSearch` (w700), `AerosStepper` / `AerosProgress` labels, `AerosStatCard` deltas, `AerosIntentCard` badges, `AerosPriceBreakdown` titles, step names and total, `AerosConstraintErrorAlert` titles and `AerosRoutingSignalBadge`. Re-check tight layouts and re-record your goldens.
- Mono amounts that ask for w600/w700 (`AerosPriceBreakdown`, `AerosRangeSlider`, `AerosNumericRangeBand`) resolve to the heaviest bundled face, Medium (the engine may embolden it synthetically); through `google_fonts` each weight was a separate download.

### Added

- **`weight:` on every `AerosTypography` role** — `AerosTypography.bodySm(color: c, weight: FontWeight.w600)`. It moves the `wght` axis with `fontWeight` and keeps the optical size, exactly like `style.withWeight(...)` (still public). Never `copyWith(fontWeight:)` an Aeros sans style: it renders at the style's original weight.

### Migration

1. Using `GoogleFonts.*` in your app? Add `google_fonts` to your own dependencies.
2. Replace `AerosTypography.x().copyWith(fontWeight: w)` with `AerosTypography.x(weight: w)` (or `.withWeight(w)`); keep other `copyWith` arguments in a `copyWith` before it.
3. Re-record golden images: body weight, tracking, widget weights and mono glyphs all change.

### Review fixes — modal headers, menus, disabled states, table emphasis

Six rough edges from the 3.0 review. Two of them change what an app sees.

- **`AerosDataTable` body text is now `fgSecondary`** (it was `fgPrimary`), as in the React table.
  Mark the column a row is known by — a name, an order number — with the new
  `AerosDataColumn(emphasis: true)`: its cells are `fgPrimary` at w500. `numeric` columns stay mono in
  `fgPrimary`. `fgSecondary` on a row is 7.7:1 in light and 12.2:1 in dark (5.6:1 and 6.4:1 at worst,
  on a selected row being pressed), so cells stay above WCAG AA. A cell that sets its own text style
  is untouched; to keep a column in `fgPrimary`, mark it `emphasis: true` or style the cell's text.
  `AerosDataColumn.cellStyle(aliases)` returns the style a column's cells get.
- **`AerosEnumChips` has a disabled state**: `enabled: false`, or a null `onChanged`, dims the group to
  `AerosMetricTokens.opacityDisabled`; the chips take no hover, no keyboard focus, and are announced
  as disabled. A group you passed a null `onChanged` to as "read only" is now dimmed.
  `AerosAttributeSelector` uses it for an attribute that is `lockedByAdmin`.
- `AerosDialog` / `AerosSheet`: at touch density the close button keeps its 48dp target but no longer
  makes the header taller — a title-only header is 60 high (was 72), and a header with a description
  is the same height as at pointer density.
- `AerosMenu`, `AerosSelect`, `AerosDropdownSearch` (menu): a list too long for the screen keeps the
  panel's 4px padding above the first row and below the last at every scroll offset; rows are clipped
  at the padding, not at the edge of the surface.
- `AerosRangeSlider` / `AerosNumericRangeBand`: a disabled slider dims its value readout with the
  track and thumb.
- `AerosVariantPicker` swatches, and the colour dot in a variant or enum chip, have a `borderStrong`
  hairline (was `borderDefault`), so a dark sample keeps an edge in dark mode. A hovered swatch's
  hairline is `fgMuted`.

### Removals — the tokens the restyle replaced

- **`AerosRadii.xl2` / `xl3` / `xl4`** and **`brXl2` / `brXl3` / `brXl4`** are removed (the token
  scale now ends at `xl` = 12). Use `AerosShapeTokens` (`item`, `control`, `surface`, `modal`,
  `pill`).
- **`AerosMotion.emphasized` / `decelerate` / `entrance` / `spring`** are removed. Use
  `AerosMotion.standard`, and the new `AerosMotion.enter` / `exit` for overlays (`enter` has the
  value `entrance` had).
- **`AerosAliasColors.focusRingOffset`** is removed — the focus ring has a transparent offset.
- **`AerosShadows`** is removed (see above).

### API gaps closed before release

What building the example gallery showed was missing. All additive, except where "changes" is
written.

- **`AerosPageHeader` fits its width.** The actions sit beside the title while the title block
  fits whole or keeps a readable measure (240), and move to a wrapping row under it when it cannot
  — no page has to move them itself. Changes: the title is cut after two lines and the subtitle
  after three (they wrapped without limit); a long breadcrumb trail scrolls sideways; the trail
  has 6px more air above the title.
- **`AerosPagination` numbered fits its width.** It shows up to `maxVisiblePages` numbers and
  fewer when they do not fit — first, last, current and the "…" always stay — and the compact form
  ("6 / 12") when even those do not. Give it a bounded width: in a `Row`, wrap it in `Flexible` /
  `Expanded`. The numbered variant reads its constraints, so it cannot be measured by
  `IntrinsicWidth` / `IntrinsicHeight`.
- **`AerosTabs`.** Underline tabs scroll sideways when they do not fit, fade at a clipped edge and
  bring the active tab into view (first build and on selection change). Pill segments that do not
  fit share the width equally and truncate. Arrow keys now move the focus with the selection, and
  Home / End select the first / last tab. Changes: an underline strip now fills the width it is
  given even under loose constraints (the baseline runs edge to edge); in a `Row` give it an
  `Expanded`.
- **`AerosScaffold.of(context)` / `maybeOf`** return the new `AerosScaffoldState`: `hasSidenav`,
  `isSidenavInline`, `isSidenavInDrawer`, `isDrawerOpen`, `openDrawer()`, `closeDrawer()`,
  `toggleDrawer()`, `isRailCollapsed`, `canToggleRail`, `toggleRail()`. From above the scaffold use
  a `GlobalKey<AerosScaffoldState>`. New `AerosScaffold.onDrawerChanged` and
  `onRailCollapsedChanged`. **The app still owns the rail** (`AerosSidenav.collapsed`);
  `toggleRail()` only asks for the change through `onRailCollapsedChanged`.
- **`AerosTopnav` shows the sidenav's button itself.** Changes: inside an `AerosScaffold`, with no
  `leading`, the bar now shows a menu button ("Open navigation") while the sidenav is in a drawer,
  and a collapse / expand button when the scaffold has `onRailCollapsedChanged`. Remove your own
  menu button, or pass `automaticallyImplyLeading: false`. Labels: `openNavigationLabel`,
  `collapseSidebarLabel`, `expandSidebarLabel`.
- **`AerosSidenavHeader.custom(child:, onTap:, semanticLabel:)`** — the header block around any
  widget (a wordmark, a logo). **`AerosSidenavScope.of(context)`** (`collapsed`, `density`) tells a
  custom header or footer whether the sidenav is the icon rail. `AerosSidenavHeader.title` is now
  `String?` (null for `.custom`).
- **`AerosButton`**: `.primary` / `.secondary` / `.ghost` / `.danger` take every option of the
  default constructor (`leading`, `trailing`, `size`, `loading`, `fullWidth`, `semanticLabel`);
  new `.dangerSubtle` and `.link`; new `semanticLabel` on the default constructor (announced in
  place of the visible label).
- **`AerosResponsiveGrid.auto`** — equal-width tiles that take the height of their content, each
  row as tall as its tallest tile; `equalHeights: true` stretches a row's tiles. The default
  constructor is unchanged.
- **Field naming.** `AerosSelect` takes `helperText` / `errorText`; `helper` / `error` still work
  and are deprecated. `AerosDropdownSearch` gains `helperText` / `errorText` (danger frame
  included). `AerosFormField` gains `expand` (false hugs its content). `AerosEnumChips` and the
  attribute switch row now draw their label / message through `AerosFormField` — no pixel changes.
- **`AerosPriceBreakdown` groups its amounts** — changes: `₹6675.00` is now `₹6,675.00`, Indian
  grouping for the rupee (`₹12,34,567.00`), thousands otherwise. `formatAmount:` replaces it. The
  formatter is public: `AerosAmountFormat.group` / `.money`, `AerosDigitGrouping`.
- **Small visual fixes** (re-record goldens): `AerosStatCard`'s value block is one `h1` line high
  for `mono` too, so the delta lines of a row are level (a mono card is 4px taller);
  `AerosVariantPicker` swatches and their names are start-aligned, flush with the label (were
  inset 8px); `AerosRepeatingRows`' Add button has a plus and starts on the rows' leading edge.

## 2.5.0 — 2026-10-09 (wordmark + pulse orb)

### Changed

- **`AerosWordmark` matches the reference logo artwork**: Nunito Sans Expanded (wdth 125) **Medium (500)** with **+0.01em tracking** — was weight 800 at −0.5px. Matched against the logo artwork by pixel overlap (0.93). Same change on the web `aeros-logo` class (`@aeros-core/react`).
- **The wordmark face is now bundled** (`AerosWordmark` family, `assets/fonts/AerosWordmark-NunitoSansExpanded-Medium.ttf`, a 2.4 KB OFL subset with only A e r o s). Through `google_fonts` it was never expanded: that package serves static normal-width cuts, so the `wdth 125` variation was silently ignored. No runtime font fetch any more; `AerosWordmark.fontFamily` is public for HTML/canvas twins.
- **`AerosThinkingOrb` is now the Pulse sphere**: ~560 evenly spread dots (Fibonacci lattice, scaled with size) on a tilted, turning sphere, depth-shaded, with a soft pulse sweeping back and forth along a slanted axis — the dots it passes swell, brighten and lift. Default `period` 10 s (was 8). API unchanged. Designed for the dark splash (pearl dots on `bgCanvas` dark), reads equally well on light.
- Also back-ported as **v1.3.6** (on `release/1.3.x`).

## 2.4.0 — 2026-10-08 (density)

### Added

- `AerosDensity { pointer, touch }` + `AerosDensityScope` — size a surface by the pointer that will use it: **pointer on desktop web, touch on phones and tablets**. With no scope it resolves to `touch`, so nothing shifts until a screen opts in. Metrics: `controlHeight` 28/32, `headerHeight` 48/56, `rowPadding`, `listAvatar` 40/48, `inlineAvatar` 26/30, `iconButton` 32/44, `iconSize` 18/22, `badgeHeight` 18/20; and a density type ramp — `titleStyle` (14/1.3 or 16/1.25), `bodyStyle` (14/1.4 or 1.45), `secondaryStyle` (13/1.35), `metaStyle` (12/1.25 or 1.3), `labelStyle` (12 or 13, w600), `microStyle` (11/1.2) — each taking a `weight:` that moves the `wght` axis (`withWeight`). Reference for pointer: WhatsApp Desktop and Apple Mail.
- `AerosCountBadge` — the public count pill (`99+` cap, `N+` with `floor`, grey when `muted`), 18px pointer / 20px touch.
- `AerosFilterChip` — one filter in a chip row: optional count (`countIsFloor` → `N+`), leading icon, dropdown caret, clear ✕ while selected (`onClear`), and a `warning` tone (`aerosSemantic` amber, so it follows the theme). 28px at pointer; 32px at touch with a 44px tap target.
- Also back-ported as **v1.3.5** (on `release/1.3.x`) for apps still pinned to 1.3.x — the Aeros app's Messages screens are the first consumer.

## 2.3.0 — 2026-10-08 (sidebar spec)

### Added

- `TextStyle.withWeight(FontWeight)` (`AerosTextStyleWeight`). Inter is a variable font and every Aeros sans style pins its `wght` axis, which is what the glyphs follow — so `style.copyWith(fontWeight: FontWeight.w600)` rendered at the style's original weight (measured: identical advance widths). `withWeight` moves the axis too and keeps `opsz`. Audit consumer `copyWith(fontWeight:)` calls on Aeros styles: none of them have been changing anything.
- `AerosSidenav`: `AerosNavItem.section` (sentence-case group labels, drawn where the section changes), `AerosNavItem.count` (a pill, announced with the label), `AerosNavItem.key`, and `density: AerosSidenavDensity.pointer | touch` (32px rows / 16px icons / 13px labels, or 48 / 20 / 14 for fingers and gloves).
- The rail's top and bottom blocks, both `kAerosSidenavBlockHeight` (56px — an app header bar's height, so the first block sits level with the page title): `AerosSidenavHeader` (the workspace — mark, title, subtitle — and, with `onTap`, the way to switch it, signalled by an unfold chevron), `AerosSidenavMark` (the 24px brand-square mark: an icon or a letter), and `AerosSidenavFooter` (the signed-in person — avatar, name, subtitle — under a `borderSubtle` rule, with one icon action such as Sign out). Mark, icons, group labels and avatar all sit on one line 20px in.

### Changed

- `AerosSidenav` follows the shared sidebar spec: rows are 6px-radius pills inset 12px with a 2px gap; rest = `fgSecondary` label + `fgMuted` icon; hover = a fill halfway between `bgSurface` and `bgSubtle`, a step lighter than selection in both themes (no single alias token is: `borderSubtle` is *darker* than `bgSubtle` in light); selected = `bgSubtle` fill + `fgPrimary` at w600 (now actually rendered bold); keyboard focus = a `borderFocus` ring. Children align with their parent's label; a parent holding the selection starts open; the expand chevron rotates with `AerosMotion.resolve`. Rows were 34px edge-to-edge with no hover, no selected tint and no focus indication.
- `AerosNavItem` and `AerosSidenav` now live in `aeros_sidenav.dart` (still exported from the package barrel — no import changes).
- Also back-ported as **v1.3.4** (on `release/1.3.x`) for apps still pinned to 1.3.x.

## 2.2.0 — 2026-10-08

### Added

- `AerosThinkingOrb` — a turning sphere of depth-shaded dots with a wave folding through it, for "the app is working" moments (startup splash, an agent composing a reply). CustomPainter only, no new dependencies; `fgPrimary` dots by default (ink on light, pearl on dark), overridable via `color`; seamless loop; renders one static frame under reduce-motion. Also back-ported as **v1.3.3** (on `release/1.3.x`) for apps still pinned to 1.3.x.

## 2.1.0 — 2026-08-20 (audit P2/P3)

### Added

- **Generated tokens adopted**: `aeros_tokens.g.dart` is emitted by `pnpm build:tokens` and the whole token layer (colors, aliases, semantic sets, spacing, radii, breakpoints, motion) now aliases it — hand-drift is structurally impossible; CI checks freshness and completeness.
- `AerosTooltip` and `AerosSnackbar.show(context, message, tone: …)` (neutral/success/warning/danger).
- `AerosMotion.resolve(context, duration)` — honors the platform reduce-motion setting (WCAG 2.3.3); adopted by Button, Tabs, SearchField, TagField.
- `AerosTabs` is keyboard-operable: tabs are focusable (Enter/Space activates), ←/→ move the selection, focus highlight included.
- `AerosProgress` supports indeterminate (`value: null`) and exposes semantics.
- `AerosConfirmDialog`: scrollable body, `barrierDismissible: false` for must-answer confirmations.
- `AerosAvatar` degrades to initials when the network image fails (no more broken-URL throw).
- `AerosSelectionPalette.resolve(..., isDark:)` — `requiredButMissing` reads correctly on dark surfaces.

### Changed

- `DottedDashedBorder` privatized (it was an implementation detail of `AerosFileUploadButton`).

## 2.0.0 — 2026-08-20 (coordinated with @aeros-core/tokens & @aeros-core/react 2.0.0)

Breaking, from the 2026-08 design-system audit. Migration notes in `docs/migration.md`.

### Breaking

- **Tone enums renamed to intent** (the old names advertised colors that don't exist in the monochrome system):
  - `AerosBadgeTone`: `green/amber/red/blue/grey/dark` → `success/warning/danger/info/neutral/inverse`
  - `AerosTagTone`: `blue/grey/dark` → `info/neutral/inverse`
  - `AerosAlertTone`: `blue/green/amber/red` → `info/success/warning/danger`
  - `AerosAvatarTone`: `ink/dark/royal/green/amber` → `neutral/inverse/info/success/warning`
  - `AerosButtonVariant.dark` removed (it was byte-identical to `primary`)
- **`AerosColors.royal*` / `AerosColors.slate*` removed** — they were byte-identical copies of the `ink` ramp.
- **Breakpoints unified with the web token scale**: `sm 640 / md 768 / lg 1024 / xl 1280 / xxl 1536` (was `600/900/1200/1600`). `AerosBreakpoint.xxl` added; shells that keyed a desktop switch off `md = 900` now switch at 768. `AerosResponsiveValue` gains an `xxl` slot.
- **`AerosTypography` role styles no longer carry hardcoded light-mode colors** — they inherit the ambient `DefaultTextStyle` unless `color:` is passed. Bare `AerosTypography.bodyMd()` on a dark theme previously rendered near-black on near-black.
- **`AerosCheckbox` / `AerosRadio` / `AerosSwitch` default to Material's padded 48dp touch target** (they previously shrink-wrapped to an 18dp glyph). Pass `compact: true` to restore the dense layout in mouse-first tables.
- `AerosSeverityPalette.of` takes `{bool isDark}`; `AerosPriceTone.nonDiscountable` now resolves `fgMuted` from the theme.

### Added

- `AerosSemanticColors` — theme-aware status sets (`context.aerosSemantic`) with true dark counterparts for success/warning/danger/info; adopted by `AerosBadge`, `AerosAlert`, `AerosAvatar`, `AerosButton.danger`, input error borders, and severity palettes.
- Semantics: `AerosButton` announces button/disabled/loading; `AerosTabs` announces selected state; `AerosSearchField`'s clear affix is a labeled ≥36dp button and Escape clears the query.
- Token backfill: `AerosRadii.none/xl3/xl4`, spacing half-steps (`sPx`, `s0_5`, `s1_5`, `s2_5`, `s3_5`).
- Accessibility test suite (`test/aeros_a11y_test.dart`) using Flutter's tap-target guideline matchers; `flutter test` and `flutter_lints` now run in CI.

### Fixed

- Stale `#6E6C66` muted text (pre-a11y-fix value) removed from typography.
- `warning` base → `#CC6D04` (the old `#D97706` failed WCAG 3:1 on the warning chip background).
- `AerosSearchField.didUpdateWidget` leaked a listener on the internal controller when swapping to an external one.
- `AerosTabs` uses `AerosMotion` durations/curves and theme-aware shadows (was hardcoded 120ms + literal shadow).

## 1.4.1 — 2026-07-29

- fix: `AerosDataTable` loading scrim was a white veil in dark mode.

## 1.4.0 — 2026-07-28

- feat: field size ladder (`AerosFieldSize`), `AerosSearchField`, `AerosTagField`.

## 1.3.1 — 2026-06-28

- a11y + micro-polish pass (fgMuted contrast fix, focus rings).

## 1.3.0 — 2026-06-27

- "Apple-level" overhaul: Inter, layered neutrals, motion tokens.
