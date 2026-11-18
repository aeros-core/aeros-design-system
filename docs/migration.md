# Migration

- [Upgrading to 3.0](#upgrading-to-30) — from `@aeros-core/tokens` and `@aeros-core/react` 2.x, and `aeros_design_system` 2.x.
- [Upgrading from 1.x](#upgrading-from-1x) — read this first if the app is still on 1.x, then come back to the 3.0 guide.

# Upgrading to 3.0

3.0 is a breaking release of all three packages. The npm packages go from 2.1.0 to 3.0.0 and the Flutter package from 2.5.0 to 3.0.0.

## 1. What changed

### The look

3.0 is a redesign called "Crisp precision". The principles are in [principles.md](./principles.md).

| | 2.x | 3.0 |
|---|---|---|
| Resting surfaces | Border and shadow | A 1px hairline, no shadow |
| Shadows | A size scale `xs`–`xl` | Three intents, on floating layers only: `raised`, `overlay`, `modal` |
| Radius | 4 / 6 / 8 / 12 / 16 scale, cards at 16 | 2 / 4 / 6 / 8 / 12 scale; semantic radii: item 4, control 6, surface 8, modal 12 |
| Neutrals | Warm stone ink ramp | Cool neutral ink ramp, with a new `ink-850` |
| Dark mode | Warm dark greys | Near-black: `ink-950` canvas, `ink-900` surface, `ink-850` elevated |
| Hover and press | Lift, scale, shadow change, ripple (Flutter) | Colour only |
| Focus | Per-component rings with a surface-coloured gap | One token-driven ring with a transparent offset |
| Density | Larger controls | Compact controls with pointer and touch densities |
| Type | Headings 700–800, larger sizes | Headings 600, labels 500, body 450, smaller sizes |
| App chrome (web) | Sidebar and top bar always dark | Sidebar and header follow the theme |

### What will shift in layouts

Check these first. Nothing fails to compile because of them.

| Thing | 2.x | 3.0 |
|---|---|---|
| Web button heights `xs` / `sm` / `md` / `lg` / `xl` | 28 / 32 / 36 / 40 / 48 | 24 / 28 / 32 / 36 / 40 |
| Web field heights `sm` / `md` / `lg` | 32 / 36 / 40 | 28 / 32 / 36 |
| Web `Field` | 16px bottom margin | No margin |
| Web `TabsContent` | 16px top margin | No margin |
| Web default dialog width | 420 | 520 |
| Web sidebar width | 228 | 240 |
| Web avatar sizes | 24 / 30 / 38 / 48 / 60 | 20 / 24 / 32 / 40 / 56 |
| Type scale `h1` / `h2` / `h3` / `h4` | 28 / 22 / 20 / 16 | 24 / 20 / 16 / 14 |
| Type scale `display-xl` / `lg` / `md` | 56 / 42 / 32 | 48 / 36 / 30 |
| Type scale `mono-lg` / `mono-md` | 22 / 14 | 20 / 13 |
| Body text weight (Flutter) | Rendered at 400 | 450 |
| `rounded-xs` / `sm` / `md` / `lg` / `xl` and `AerosRadii.xs`–`xl` | 4 / 6 / 8 / 12 / 16 | 2 / 4 / 6 / 8 / 12 |
| Durations `quick` / `fast` / `base` / `slow` | 90 / 120 / 200 / 320 ms | 80 / 120 / 180 / 260 ms |
| Flutter button heights at touch | 28 / 32 / 40 / 46 / 52 | 32 / 36 / 40 / 44 / 48 |
| Flutter data table rows | 48–56, header 44 | 40 pointer / 48 touch, header the same |

The Flutter list continues in [section 4](#4-flutter).

## 2. Upgrade order

Do each platform in one pull request. Do not ship a half-migrated app: removed classes fail silently on the web.

### A web app

1. Bump `@aeros-core/react` and `@aeros-core/tokens` to `^3.0.0` and install.
2. Fix the CSS entry: fonts and the removed Tailwind preset. See [3.1](#31-css-setup-and-fonts).
3. Run the search-and-replace recipes in [section 6](#6-search-and-replace-recipes). They cover the mechanical renames.
4. Replace the classes the theme reset removed: palette, radius, shadow, easing. See [3.2](#32-classes).
5. Replace removed CSS variables in the app's own stylesheets. See [3.3](#33-css-variables-and-tokens).
6. Fix the TypeScript errors. They come from `TopNav*` and the Button `icon-*` sizes. See [3.4](#34-components).
7. Restructure the sidebar and decide whether it stays dark. See [3.4](#34-components).
8. Go through the remaining rows of the component table. These compile but look or behave differently.
9. Run the app and work through the [checklist](#7-verification-checklist).

### A Flutter app

1. Change the git `ref` to `v3.0.0` and run `flutter pub get`.
2. If the app imports `package:google_fonts`, add `google_fonts` to its own `pubspec.yaml`.
3. Run `dart analyze`. Fix the errors: removed `AerosShadows`, `AerosRadii.xl2`–`xl4`, the removed `AerosMotion` curves, the palette signatures, exhaustive switches over `AerosFieldSize`. See [4.2](#42-removed-and-renamed-api).
4. Fix the deprecation warnings: `AerosButtonSize`, `AerosFieldSize`, `AerosCardVariant.raised`, `padV`, `kAerosSidenavBlockHeight`.
5. Replace `copyWith(fontWeight:)` on Aeros text styles.
6. Wrap desktop and web surfaces in `AerosDensityScope(density: AerosDensity.pointer)` if they are not already.
7. Replace Material overlays with the package's. See [4.5](#45-overlays).
8. Go through the behaviour and size tables in [4.3](#43-widget-changes) and [4.4](#44-sizes-that-changed).
9. Re-record the app's golden images and work through the [checklist](#7-verification-checklist).

## 3. Web

### 3.1 CSS setup and fonts

**Fonts.** `@aeros-core/react/styles.css` no longer fetches Inter and Nunito Sans from Google Fonts. Without a change, text falls back to the system font. Do one of:

```css
@import "@aeros-core/react/styles.css";
@import "@aeros-core/react/fonts.css"; /* add this line */
```

or load the faces yourself (for example `next/font`). The font tokens lead with `'Inter Variable'` and `'Nunito Sans Variable'` and fall back to `Inter`, `Nunito Sans` and `IBM Plex Mono`. Details in [consuming.md](./consuming.md#4-fonts).

**Tailwind preset.** The export `@aeros-core/tokens/tailwind` (a Tailwind v3 preset) is removed. Delete the import and the `presets: [...]` entry. The Tailwind v4 theme comes from `@aeros-core/tokens/theme.css`, which `styles.css` already imports.

**Theme attribute.** `data-theme="light"` and `data-theme="dark"` work as before. New: `data-theme="system"`, `data-theme` on any element, and a `dark:` variant.

**Density.** New: `data-density="touch"` on any element.

### 3.2 Classes

The theme now resets Tailwind's default colour palette, radii, shadows, easings and font families. A class from a removed namespace generates no CSS and raises no error. This applies to the app's own code, not only to the components.

| Old class | 3.0 | Notes |
|---|---|---|
| `shadow-xs`, `shadow-sm` on a resting surface | Remove; use `border border-border-default` | Resting surfaces have a hairline, no shadow |
| `shadow-xs`, `shadow-sm` for a slight lift on part of a control | `shadow-raised` | |
| `shadow-md`, `shadow-lg` on a menu, popover or toast | `shadow-overlay`, and remove the border class | The shadow draws its own edge |
| `shadow-xl`, `shadow-2xl` on a dialog or drawer | `shadow-modal`, and remove the border class | |
| `shadow-hairline` | `border border-border-default` | |
| `shadow-focus`, `shadow-focus-danger`, `shadow-focus-success` | Remove | The global `:focus-visible` outline is the ring |
| `rounded-2xl`, `rounded-3xl`, `rounded-4xl` | `rounded-modal` for dialogs, `rounded-surface` for cards, `rounded-pill` for fully rounded | Removed. The largest radius is 12 |
| `rounded-xs`, `rounded-sm`, `rounded-md`, `rounded-lg`, `rounded-xl` | Prefer `rounded-item` (4), `rounded-control` (6), `rounded-surface` (8), `rounded-modal` (12) | Still compile, one step tighter: 2 / 4 / 6 / 8 / 12. To keep the old pixel value move up one step (`rounded-sm` → `rounded-md`); old `rounded-xl` (16) has no equivalent |
| `z-(--aeros-z-modal)` and the other `z-(--aeros-z-…)` forms | `z-modal`, `z-dropdown`, `z-sticky`, `z-overlay`, `z-popover`, `z-toast`, `z-tooltip` | The old form still resolves; the short form is the supported one |
| `duration-(--aeros-duration-fast)` and the other `duration-(--aeros-duration-…)` forms | `duration-quick`, `duration-fast`, `duration-base`, `duration-slow` | The old form still resolves |
| `ease-(--aeros-ease-entrance)`, `ease-entrance` | `ease-enter` | Same curve, renamed. The old variable is gone, so the old class has no effect |
| `ease-(--aeros-ease-decelerate)`, `ease-decelerate` | `ease-enter` | Removed |
| `ease-(--aeros-ease-emphasized)`, `ease-emphasized` | `ease-standard` | Removed |
| `ease-(--aeros-ease-spring)`, `ease-spring` | `ease-enter` | Removed. There is no overshoot curve |
| `ease-(--aeros-ease-standard)` | `ease-standard` | |
| `ease-in`, `ease-out`, `ease-in-out` | `ease-exit`, `ease-enter`, `ease-standard` | Tailwind's defaults are reset |
| `.aeros-text-<role>` (for example `aeros-text-body-sm`) | `text-<role>` (`text-body-sm`) | The CSS classes are removed. The utility sets size, line height, tracking and weight |
| Default palette: `bg-blue-500`, `text-gray-600`, `border-red-300`, `bg-slate-50` … | An alias: `bg-bg-surface`, `bg-bg-subtle`, `text-fg-primary`, `text-fg-secondary`, `text-fg-muted`, `border-border-default`; a status colour for state: `text-danger-text`, `bg-success-bg` | The default palette is reset. `white`, `black` and `ink-*` remain, but prefer aliases: they follow the theme |
| `ring-offset-*` and `focus-visible:ring-*` added to match the old focus ring | Remove | Components no longer draw a ring. Use `focus-ring-field` or `focus-ring-inset` only to move the global one |
| `ring-offset-focus-ring-offset`, `bg-focus-ring-offset` | Remove | The alias is removed |
| `font-serif` | `font-sans` or `font-mono` | Font families are reset |
| `active:scale-*`, `hover:-translate-y-*`, `hover:shadow-*` copied from 2.x components | Remove; use `transition-colors` with a hover colour or `hover:bg-state-hover` | Nothing lifts or scales in 3.0 |

New utilities worth adopting: `h-control-<size>`, `size-icon-<size>`, `h-header`, `h-row`, `w-sidebar`, `max-w-dialog-<size>`, `bg-state-hover`, `bg-state-pressed`, `bg-state-selected`, `bg-scrim`, `text-fg-disabled`, `opacity-disabled`. See [tokens.md](./tokens.md).

### 3.3 CSS variables and tokens

For apps that read `--aeros-*` variables or the JS tokens directly.

| Removed | Replacement |
|---|---|
| `--aeros-shadow-xs`, `-sm`, `-md`, `-lg`, `-xl` | `--aeros-elevation-raised`, `--aeros-elevation-overlay`, `--aeros-elevation-modal`; a hairline border for resting surfaces |
| `--aeros-shadow-hairline` | `border: 1px solid var(--aeros-border-default)` |
| `--aeros-shadow-focus`, `-focus-danger`, `-focus-success` | None. Focus is an outline: `--aeros-focus-width`, `--aeros-focus-offset`, colour `--aeros-focus-ring` |
| `--aeros-radius-2xl`, `-3xl`, `-4xl` | `--aeros-radius-modal`, `--aeros-radius-surface`, `--aeros-radius-pill` |
| `--aeros-ease-entrance` | `--aeros-ease-enter` |
| `--aeros-ease-emphasized`, `--aeros-ease-decelerate`, `--aeros-ease-spring` | `--aeros-ease-standard`, `--aeros-ease-enter`, `--aeros-ease-exit` |
| `--aeros-focus-ring-offset` | None. The focus ring's offset is transparent |
| `tokens.shadow`, `tokens.shadowDark` (JS) | `tokens.elevation.light`, `tokens.elevation.dark` |
| `tokens.font.weight.light`, `tokens.font.weight.extrabold` (JS) | `regular` 400, `book` 450, `medium` 500, `semibold` 600, `bold` 700 |

Variables that kept their name and changed value: every `--aeros-color-ink-*`, every alias, `--aeros-color-semantic-info*`, `--aeros-radius-xs` to `-xl`, and the durations. If the app hard-coded an old hex or pixel value beside a variable, it no longer matches.

New: the JS export is fully typed, and `rawTokens` gives tokens.json as authored, references intact.

### 3.4 Components

| Component | 2.x | 3.0 | What to do |
|---|---|---|---|
| `Button` sizes | `size="icon-sm"`, `"icon-md"`, `"icon-lg"` | `size="sm"`, `"md"`, `"lg"` with `iconOnly` | Rename. Type error until done. Give an icon-only button an `aria-label` |
| `Button` heights | 28 / 32 / 36 / 40 / 48 | 24 / 28 / 32 / 36 / 40 (larger under `data-density="touch"`) | Re-check toolbars and form rows. Use the next size up to keep an old height |
| `Button variant="danger"` | Tinted red | Solid red | For the old tinted look use `variant="danger-subtle"` |
| `Button` hover and press | Lift, shadow, press scale | Colour only | Nothing |
| `Button asChild` | Threw | Works, including with `leadingIcon` / `trailingIcon` | Remove workarounds |
| `Field` | 16px bottom margin | No margin | Wrap fields in `FieldGroup`, or space them yourself |
| `Input`, `Textarea`, `SelectTrigger` | 32 / 36 / 40 high | 28 / 32 / 36 high | Re-check form layouts |
| `TabsContent` | 16px top margin | No margin | Add spacing where it is needed (`className="pt-4"`) |
| `DialogContent` | 420 wide | 520 wide by default; new `size` prop: `sm` 400, `md` 520, `lg` 720, `xl` 960, `full` | Pass `size="sm"` for a narrow dialog. Remove `max-w-*` overrides |
| `AlertDialogContent` | 420 wide | 400 wide (`size="sm"` by default); takes `size` | Nothing, unless a width override was added |
| `DrawerContent` | 448 wide | New `size` prop: `sm` 360, `md` 480 (default), `lg` 640 | Remove width overrides; pass `size` |
| `DialogFooter`, `AlertDialogFooter`, `DrawerFooter` | Subtle fill | No fill; a hairline above | Remove code that relied on the fill |
| `DrawerTitle`, `DrawerDescription` | Unstyled | Styled like the dialog's | Remove your own classes |
| `Card`, `StatCard` | Shadow | No shadow; hairline only | Remove added `shadow-*`. Do not add one back |
| `Card interactive` | Lifts on hover | Changes border and fill on hover | Nothing |
| `Toast` | Tone tints the whole surface | Every toast is the neutral elevated surface; the tone colours the title | Nothing. Do not rely on a tinted background |
| `Avatar` sizes | 24 / 30 / 38 / 48 / 60 | 20 / 24 / 32 / 40 / 56 | Re-check lists; use the next size up to keep an old size |
| `Checkbox`, `RadioGroupItem` | 18px | 16px | Re-check alignment |
| `Switch` | 42×24 | 36×20 | Re-check alignment |
| `Tr selected` | Sets `aria-selected` | Sets `data-selected` | Change selectors and tests from `[aria-selected]` to `[data-selected]` |
| `Calendar` / date pickers | Day buttons named "Sunday, July 26th, 2026" | Named "26, Sunday, July 2026" (plus ", today" / ", selected"), so the name starts with the visible number | Update tests that find days by name; override with `labels.labelDayButton` |
| `Card interactive` with `onClick` | A `div` with hover styles; mouse only | `role="button"`, focusable, Enter and Space activate | Do not nest buttons or links inside such a card; use `Card asChild` with an `<a>` for a link card |
| `SidebarItem asChild` | Threw | The icon, a truncating label and `count` render inside the child; the label is hidden in the rail | Remove any label / count markup you added inside the child |
| `Button asChild`, `FilterChip asChild` | Rendered nothing when the child came from a Server Component | Works from Server Components | Remove client wrapper components added as a workaround |
| `CommandSeparator` | `role="separator"` inside the listbox | Decorative (`role="none"`) | Update tests that query `role="separator"` in a command list |
| `DataTable`, `FileUpload` | — | `labels` prop for every built-in string | Pass translations through `labels` |
| `Th` | `text-left` | `text-start` | Nothing in LTR |
| `TableLoadingRow` | Fixed status text | Takes `statusLabel` | Optional |
| Focus rings | Each component drew a `ring` | The global `:focus-visible` outline is the only ring | Remove `ring-offset-*` and `focus-visible:ring-*` overrides |
| `TopNav` | Rounded dark bar | Renamed `AppHeader`: 48px high, full width, a hairline below, follows the theme | Rename (table below) and re-check the page top |
| `Sidebar` | Always dark, 228 wide, children placed directly inside | Follows the theme, 240 wide, structured | Put `SidebarBrand` in `SidebarHeader` and the sections in `SidebarContent`. For dark chrome: `<Sidebar data-theme="dark">` |
| `SidebarItem asChild` | Threw | Works | Remove workarounds |
| `aeros-logo` class | Weight 800, −0.02em | Weight 500, +0.01em | Remove overrides. Do not restyle the wordmark |

**TopNav → AppHeader**

| 2.x | 3.0 |
|---|---|
| `TopNav` | `AppHeader` |
| `TopNavBrand` | `AppHeaderBrand` |
| `TopNavLinks` | `AppHeaderNav` |
| `TopNavLink` | `AppHeaderLink` |
| `TopNavRight` | `AppHeaderActions` |
| `TopNavBrandProps`, `TopNavLinkProps` | `AppHeaderBrandProps`, `AppHeaderLinkProps` |

**Sidebar structure**

```tsx
// 2.x
<Sidebar>
  <SidebarBrand mark="A" name="Aeros" />
  <SidebarSection label="Workspace">…</SidebarSection>
</Sidebar>

// 3.0
<SidebarProvider>
  <Sidebar>                       {/* add data-theme="dark" to keep dark chrome */}
    <SidebarHeader>
      <SidebarBrand mark="A" name="Aeros" />
    </SidebarHeader>
    <SidebarContent>
      <SidebarSection label="Workspace">…</SidebarSection>
    </SidebarContent>
  </Sidebar>
</SidebarProvider>
```

`SidebarProvider` is optional; without it the sidebar is simply expanded. With it you get the 56px rail, the mobile sheet, `SidebarTrigger` and Cmd/Ctrl+B. The full frame is in [consuming.md](./consuming.md#8-the-app-shell).

**Removed exports.** `TopNav`, `TopNavBrand`, `TopNavLinks`, `TopNavLink`, `TopNavRight`, `TopNavBrandProps`, `TopNavLinkProps`, and the package export `@aeros-core/tokens/tailwind`. Nothing else was removed from `@aeros-core/react`.

**New in 3.0** (no action needed): `DataTable`, `Combobox`, `MultiCombobox`, `DatePicker`, `DateRangePicker`, `NumberInput`, `Toggle`, `ToggleGroup`, `SegmentedControl`, `Collapsible`, `ScrollArea`, `CountBadge`, `FilterChip`, `Kbd`, `PageHeader`, `FileUpload`, `Stepper`, `FieldGroup`, the app shell, `DropdownMenuCheckboxItem`, `DropdownMenuRadioGroup`, `DropdownMenuRadioItem`, `DropdownMenuSub`, `DropdownMenuSubTrigger`, `DropdownMenuSubContent`, `DropdownMenuShortcut`, and `arrow` on `TooltipContent`. See [components.md](./components.md).

## 4. Flutter

### 4.1 Dependencies and fonts

- **`google_fonts` is no longer a dependency.** IBM Plex Mono (Regular 400 and Medium 500) is bundled as the `IBM Plex Mono` family. If the app imports `package:google_fonts` and was getting it through this package, add `google_fonts` to the app's own `pubspec.yaml`. To use the bundled mono face outside `AerosTypography`: `TextStyle(fontFamily: 'IBM Plex Mono', package: 'aeros_design_system')`.
- **Mono text is 400 or 500 only.** A request for w600 or w700 resolves to Medium.
- **Body text renders at weight 450.** `fontWeight` still reports `w400`; the `wght` axis carries 450.
- **Set weights with `weight:`.** `AerosTypography.bodySm(weight: FontWeight.w600)` or `style.withWeight(...)`. `copyWith(fontWeight:)` on an Aeros sans style does not change the glyphs. Inside the package these calls were fixed, so active tabs, field labels, table headings and totals are visibly heavier than in 2.x.
- **Tracking follows the tokens.** The hand-written values that had drifted are gone.

### 4.2 Removed and renamed API

| 2.x | 3.0 | What to do |
|---|---|---|
| `AerosShadows` (`xs`–`xl`, `focus`, `focusDanger`, `hairline`, `card()`, `menu()`, `dialog()`, `popover()`) | Removed | Wrap the content in `AerosSurface(level: …)`: `flat` for cards, `overlay` for menus and popovers, `modal` for dialogs. For the raw lists use `context.aerosElevation.raised` / `.overlay` / `.modal` |
| `AerosRadii.xl2`, `xl3`, `xl4`, `brXl2`, `brXl3`, `brXl4` | Removed | `AerosShapeTokens.modal` (12) for dialogs, `AerosShapeTokens.surface` (8) for cards, `AerosRadii.brFull` for fully rounded |
| `AerosRadii.xs`–`xl` | Kept, one step tighter: 2 / 4 / 6 / 8 / 12 | Prefer `AerosShapeTokens.item` / `control` / `surface` / `modal` |
| `AerosMotion.entrance` | `AerosMotion.enter` | Rename; same curve |
| `AerosMotion.decelerate` | Removed | `AerosMotion.enter` |
| `AerosMotion.emphasized` | Removed | `AerosMotion.standard` |
| `AerosMotion.spring` | Removed | `AerosMotion.enter`; there is no overshoot curve |
| `AerosButtonSize`, `AerosFieldSize` | Deprecated aliases of `AerosControlSize` | Rename to `AerosControlSize`. `AerosFieldSize` gains `xs` and `xl`: an exhaustive `switch` needs two more cases |
| `AerosFieldSizeMetrics` extension | Removed | Its members are on `AerosControlSize` (`padH`, `radius`, `valueStyle()`, `resolveHeight(context)`) |
| `AerosControlSize.padV` | Deprecated | Fields centre their content; use `resolveHeight(context)` |
| `AerosButton.size` | Non-null | Nullable; null means `AerosControlSize.of(context)` (default `md`) |
| `AerosSeverityPalette.of(severity, isDark: …)` | `AerosSeverityPalette.of(context, severity)` | Or `.resolve(severity, context.aerosSemantic)` |
| `AerosSelectionPalette.resolve(state, aliases, isDark: …)` | `AerosSelectionPalette.of(context, state)` | Or `.resolve(state, aliases, semantic)` |
| `AerosPricePalette.resolve(tone, aliases)` | `AerosPricePalette.of(context, tone)` | Or `.resolve(tone, aliases, semantic)` |
| `AerosCardVariant.raised` | Deprecated; renders flat | Remove `variant:` |
| `kAerosSidenavBlockHeight` | Deprecated; no longer a `const` | `AerosDensity.of(context).sizes.header` |
| `AerosSidenavDensity` `rowHeight` / `iconSize` / `labelSize` | Getters over the nav tokens; same values | Nothing, unless the enum was constructed with arguments |
| `AerosFilterChip.touchTargetHeight` | `const`, 44 | A getter, 48 | Do not use it in a `const` expression |
| `AerosTopnav.height` | 60 | Nullable; null is the density's header height (48 / 56) | Remove a hard-coded 60 |
| `AerosTopnav` inside `AerosScaffold` | No automatic leading | With no `leading`, shows a menu button when the sidenav is in a drawer, and a collapse / expand button when the scaffold has `onRailCollapsedChanged` | Remove your own menu button, or pass `automaticallyImplyLeading: false` |
| Opening the scaffold drawer | `Scaffold.of(context).openDrawer()` | `AerosScaffold.of(context).openDrawer()` / `closeDrawer()` / `toggleDrawer()`; `isSidenavInline` | Replace hand-rolled breakpoint checks and `Navigator.maybePop()` |
| `AerosSidenavHeader.title` | `String` | `String?` (a `.custom(child:)` constructor holds any widget, e.g. the wordmark) | Null-check if you read the field |
| `AerosSelect` `helper` / `error` | — | Deprecated aliases of `helperText` / `errorText` | Rename |
| `AerosPageHeader` | Title wrapped without limit; actions overflowed on phones | Title cuts at 2 lines, subtitle at 3; actions move under the title when they do not fit | Remove manual narrow-screen handling |
| `AerosPagination` numbered | Fixed width, overflowed on phones | Shrinks its page window, then falls back to compact; needs a bounded width | In a `Row`, wrap it in `Flexible` / `Expanded` |
| `AerosTabs` underline | A plain row, overflowed | Scrolls horizontally and fills its width; arrow keys move focus with selection | Remove your own scroll view |
| `AerosPriceBreakdown` amounts | Ungrouped ("₹6675.00") | Grouped by default (Indian grouping for ₹ / INR) | Pass `formatAmount` to keep another format |
| `AerosStatCard(mono: true)` | — | 4px taller, so delta lines align across a row | Check fixed-height layouts |
| `AerosThemeExtension` | `aliases`, `isDark` | Two more fields: `semantic`, `elevation` | A hand-built `AerosThemeExtension(aliases:, isDark:)` still compiles |

### 4.3 Widget changes

| Widget | 2.x | 3.0 | What to do |
|---|---|---|---|
| `AerosButton` variant `danger` | Tinted red | Solid red with an inverse label | For the old look use `AerosButtonVariant.dangerSubtle`. `AerosConfirmDialog(destructive: true)` uses the solid one |
| `AerosButton` `secondary`, `ghost` | `ghost` had a `borderDefault` hairline | `secondary` has a `borderStrong` hairline; `ghost` has no border | Nothing |
| `AerosButton` label | Overflowed | Truncates with an ellipsis | Check long labels |
| Every control's layout box | The painted size | At least the density's minimum target: 24 pointer, 48 touch | Tight rows may grow at touch density. `expandHitTarget: false` or `compact` opts out |
| `AerosTextField`, `AerosSearchField`, `AerosTagField` | Varied looks; disabled was a subtle fill | `bgSurface` fill, 1px `borderStrong` that stays 1px when focused, 6px radius, disabled is the whole field at 40% opacity | Nothing. `AerosSearchField` is no longer a borderless grey pill; `AerosTagField` fills its width |
| `AerosSearchField` | Escape with an empty query was swallowed | It propagates, so it closes the enclosing dialog or menu | Nothing |
| `AerosCheckbox`, `AerosRadio`, `AerosSwitch` | Material wrappers; 18px; Cupertino switch on iOS and macOS | Custom-drawn; checkbox and radio 16px; switch a 32×18 monochrome track on every platform; `onChanged` nullable; disabled state | Re-check alignment. Tests that looked for Material's `Checkbox` / `Switch` need updating |
| `AerosTheme` | Material ripple and hover tint | `NoSplash`, transparent splash / highlight / hover | Every Material `InkWell` in the app stops rippling. Dialogs have elevation 0 and a hairline; cards 8px, buttons and inputs 6px, dialogs 12px |
| Status colours in widgets | Some used the light set in dark mode | Every widget reads `context.aerosSemantic` | Nothing |
| `AerosCard`, `AerosStatCard`, `AerosIntentCard`, `AerosEmptyState` | Shadow | Flat hairline surface, 8px corners | Remove `variant: AerosCardVariant.raised`. A tappable `AerosCard` is one button: do not nest buttons in it |
| `AerosStatCard` | Upper-cased label; 26px mono value | Sentence-case `caption` label; `monoLg` (20px) value | Re-check |
| `AerosTag` removable | An unlabelled gesture | One button announced as "Remove <label>" | Update tests |
| `AerosSnackbar` | Inverse slab with a `SnackBarAction` | Elevated surface; the tone colours the icon and message; the action is a small secondary button | Update tests that looked for `SnackBarAction` |
| `AerosPageHeader` | 16px vertical padding | Horizontal padding only; the title row is at least one header high (48 / 56); subtitle is `bodySm` | Pass `padding:` to restore the old padding |
| `AerosScaffold.sidenavBreakpoint` | 720, from `MediaQuery` | The `md` breakpoint, 768; an `AerosViewportScope` wins over `MediaQuery` | Pass the old value to keep it |
| `AerosScaffold.sidenavWidth` | Default 240 | Default `AerosMetricTokens.layoutSidebar` (still 240); the drawer is 280 wide | Nothing |
| `AerosSidenavHeader`, `AerosSidenavFooter` | 56 high (`kAerosSidenavBlockHeight`) | The density's header height: 48 pointer, 56 touch | Re-check |
| Sidenav hover | A half-step fill | The `stateHover` overlay; the footer action is an icon button (32 / 44) | Nothing |
| `AerosConfirmDialog` | Material dialog, 440 wide | An `AerosDialog`, `sm`, 400 wide. `show(...)` is unchanged | Re-check long content |
| `AerosDropdownSearch` trigger | Taller; the same at both densities | A field frame, control `md` high (32 pointer / 40 touch); announced as a button | Re-check forms |
| `AerosDropdownSearch` `mode: dialog` | 70% × 60% of the screen | An `AerosDialog` (`md`, or `dialogMaxWidth`), as tall as its list, capped by `maxHeight` | Re-check |
| `AerosDropdownSearch` `mode: menu` | Ignored `showSearchBox` and `onFind` | Honours both; the menu is as wide as the field and ends on a whole row | Pass `showSearchBox: false` to keep a plain list |
| `AerosDropdownSearch` rows | Selected option bold on a tint | Selected option marked with a check; `itemBuilder` rows are wrapped in the shared menu row (8px horizontal padding, highlight) | Remove duplicate padding from `itemBuilder` |
| `AerosDataTable` | Wrapped Material `DataTable` | A custom grid; constructor unchanged apart from `emptyText` and `rowSemanticLabel` | Update tests that looked for `DataTable` |
| `AerosDataTable` rows and header | Rows 48–56, header 44, header fill | Both the `row` token: 40 pointer / 48 touch; plain header with `labelXs` muted labels | Re-check |
| `AerosDataTable` cells | `bodyMd` | `bodySm` in `fgSecondary`, as in the React table; `numeric` columns right-aligned in mono in `fgPrimary`; 12px cell padding | Mark the column a row is known by with `AerosDataColumn(emphasis: true)`: its cells are `fgPrimary` at w500 |
| `AerosDataTable` in a bounded height | Overflowed | Rows scroll under a header that stays in place | Remove your own scroll wrapper |
| `AerosDataTable` empty state | The widget you passed | Plain centred text inside the frame (`emptyText`, default "No data") | An `AerosEmptyState` passed as `emptyState` shows its dashed outline inside the frame; pass plain content |
| `AerosDataTable` loading | Veil covered the footer | Veil is `bgSurface` at the muted opacity and does not cover `footer` | Nothing |
| `AerosEnumDropdown` | Its own dropdown | An `AerosSelect`; same constructor; a disabled option shows its `disabledReason` | Nothing |
| `AerosMeasurementInput` | Two nested borders | One field frame at control `md` height; the unit is a button at the end | Re-check |
| `AerosRangeSlider`, `AerosNumericRangeBand` | Material defaults | 2px track, 14px thumb, no ticks, no halo; height is the minimum target | Re-check |
| `AerosPriceBreakdown`, `AerosRepeatingRows`, `AerosFileUploadButton` | Mixed | Flat surfaces with 8px corners; the header total is `monoLg` medium; the repeater's remove button is a neutral ghost icon button | Nothing |
| `AerosVariantPicker` | Own chips | The `AerosEnumChips` chip; swatches 56px with a 2px border when selected; keyboard-focusable | Re-check |
| `AerosEnumChips` | 2px selected border; a null `onChanged` looked enabled | Control-sized (`sm`), 6px corners, 1px selected border; `enabled: false` or a null `onChanged` dims the group and announces it as disabled | Re-check. A group passed a null `onChanged` as "read only" is now dimmed |
| `AerosAttributeSelector` | A locked BOOLEAN looked enabled | Shows a disabled switch | Nothing |
| `AerosHoverable` with `onTap` | Pointer only | A real button: focusable, Enter / Space, announced | Do not wrap it in another button |
| Material ink | `InkWell` inside widgets | None | Tests and themes that looked for `InkWell`, `Material` or `splashColor` inside Aeros widgets find nothing |

### 4.4 Sizes that changed

| Thing | 2.x | 3.0 |
|---|---|---|
| Button heights `xs`–`xl` | 28 / 32 / 40 / 46 / 52 everywhere | 24 / 28 / 32 / 36 / 40 at pointer; 32 / 36 / 40 / 44 / 48 at touch or with no scope |
| Button horizontal padding `xs`–`xl` | — | Tighter: 8 / 10 / 12 / 14 / 16 |
| Button radius | By size (the old `sm` / `md` / `lg` radii) | 6 at every size |
| Field heights `sm` / `md` / `lg` at touch | 32 / 40 / 46 | 36 / 40 / 44 |
| Checkbox, radio | 18 | 16 |
| Badges, tags, count badges | Per widget | One height: 18 pointer / 20 touch |
| Avatars `xs`–`xl` | 24 / 30 / 38 / 48 / 60 | 20 / 24 / 32 / 40 / 56 |
| `AerosTopnav` | 60 | 48 pointer / 56 touch |
| `AerosIntentCard` | — | `h4` / `bodySm`, 40px icon tile |
| `AerosFilterChip.touchTargetHeight` | 44 | 48 |
| Removable tag, tappable routing badge, enum chip, breadcrumb link, pagination arrows, alert buttons at touch | Glyph-sized | At least 48, the visual centred |
| `AerosScaffold.sidenavBreakpoint` | 720 | 768 |
| `AerosConfirmDialog` width | 440 | 400 |
| Data table rows / header | 48–56 / 44 | 40 pointer, 48 touch |
| `AerosStatCard` mono value | 26 | 20 |
| `AerosDensity.touch` body line height | 1.45 | 1.4 |
| Type: `h1` / `h2` / `h3` / `h4` | 28 / 22 / 20 / 16 | 24 / 20 / 16 / 14 |
| Type: display | 56 / 42 / 32 | 48 / 36 / 30 |
| Type: mono `lg` / `md` | 22 / 14 | 20 / 13 |
| Durations `quick` / `base` / `slow` | 90 / 200 / 320 ms | 80 / 180 / 260 ms |

### 4.5 Overlays

The package no longer uses Material's dialog, sheet, menu or table calls, and an app should not mix them in: they will not match.

| Material | Use |
|---|---|
| `showDialog` | `AerosDialog.show(context, builder: …)`; `AerosConfirmDialog.show(...)` for a yes / no |
| `showModalBottomSheet`, `Drawer` as a panel | `AerosSheet.show(context, builder: …, side: …, size: …)` |
| `showMenu`, `PopupMenuButton`, `PopupMenuItem` | `AerosMenu(items: …, trigger: …)` or `AerosMenu.show(...)` with `AerosMenuItem`, `AerosMenuCheckboxItem`, `AerosMenuRadioItem`, `AerosMenuSeparator`, `AerosMenuLabel` |
| `DropdownButton` | `AerosSelect(items: …, value: …, onChanged: …)` |
| A custom anchored overlay | `AerosPopover(trigger: …, content: …)` |
| `DataTable` | `AerosDataTable` |
| `InkWell` | `AerosPressable`, or `AerosHoverable` |
| A `Container` with a `BoxShadow` | `AerosSurface(level: …)` |

Dialog sizes are `AerosDialogSize.sm` 400, `md` 520 (default), `lg` 720, `xl` 960. Side sheets are 360 / 480 / 640.

## 5. Upgrading from 1.x

An app on 1.x should apply the [1.x → 2.0 section](#1x--200) below first, then this guide. The 3.0 guide assumes those changes are already made.

In short, from 1.x you also need to:

- **Rename the packages to the `@aeros-core` scope — required.** The packages were renamed from `@aeros/tokens` and `@aeros/react` to `@aeros-core/tokens` and `@aeros-core/react` at 1.1.0 (GitHub Packages scopes npm by the owning org). The old names do not exist at 3.0, so an app still on `@aeros/*` must:
  1. Rename both dependencies in `package.json` (keep `workspace:*` if the app consumes the `vendor/aeros-design-system` submodule; otherwise use `^3.0.0`).
  2. Rename every import and CSS `@import`: `@aeros/react` → `@aeros-core/react`, `@aeros/tokens` → `@aeros-core/tokens`.

     ```bash
     grep -rlE "@aeros/(react|tokens)" --include='*.ts' --include='*.tsx' --include='*.css' --include='*.json' --include='*.mjs' . \
       | grep -v node_modules | xargs perl -pi -e 's#\@aeros/(react|tokens)#\@aeros-core/$1#g'
     ```
  3. If the app uses the submodule, point it at the `aeros-core` org URL and update it to the 3.0 tag.
  4. If it installs from the registry, add the `.npmrc` from [consuming.md](./consuming.md#1-authenticate-to-github-packages).
- **Rename colour-word variants to intent.** `blue` → `info`, `green` → `success`, `amber` → `warning`, `red` → `danger`, `grey` → `neutral`, `dark` → `inverse`. `royal` and `slate` are gone; the only ramp is `ink`. There is no blue in the system.
- **Remove `Button variant="dark"`** (use `primary`) and the `accent` aliases.
- **Use the unified breakpoints**: 640 / 768 / 1024 / 1280 / 1536 on both platforms.

## 6. Search-and-replace recipes

Run from the app root on a clean working tree, then review the diff. Each recipe is a Perl substitution; apply it with:

```bash
grep -rlE '<pattern>' src | xargs perl -pi -e '<substitution>'
```

Every recipe below was run against the sample shown.

### Web: rewrites

| # | Substitution | Sample → result |
|---|---|---|
| 1 | `s/\bz-\(--aeros-z-([a-z]+)\)/z-$1/g` | `z-(--aeros-z-modal)` → `z-modal` |
| 2 | `s/\bduration-\(--aeros-duration-([a-z]+)\)/duration-$1/g` | `duration-(--aeros-duration-fast)` → `duration-fast` |
| 3 | `s/\bease-(?:\(--aeros-ease-(?:entrance\|decelerate\|spring)\)\|(?:entrance\|decelerate\|spring)\b)/ease-enter/g` | `ease-(--aeros-ease-entrance) ease-spring` → `ease-enter ease-enter` |
| 4 | `s/\bease-(?:\(--aeros-ease-(?:emphasized\|standard)\)\|emphasized\b)/ease-standard/g` | `ease-(--aeros-ease-emphasized) ease-(--aeros-ease-standard)` → `ease-standard ease-standard` |
| 5 | `s/\baeros-text-([a-z0-9]+(?:-[a-z0-9]+)*)/text-$1/g` | `aeros-text-body-sm aeros-text-h1` → `text-body-sm text-h1` |
| 6 | `s/\bsize="icon-(sm\|md\|lg)"/size="$1" iconOnly/g` | `<Button size="icon-sm" aria-label="Edit">` → `<Button size="sm" iconOnly aria-label="Edit">` |
| 7 | `s/\bTopNavLinks\b/AppHeaderNav/g; s/\bTopNavRight\b/AppHeaderActions/g; s/\bTopNav(?=Brand\|Link\|\b)/AppHeader/g` | `<TopNav><TopNavBrand/><TopNavLinks><TopNavLink/></TopNavLinks><TopNavRight/></TopNav>` → `<AppHeader><AppHeaderBrand/><AppHeaderNav><AppHeaderLink/></AppHeaderNav><AppHeaderActions/></AppHeader>` |
| 8 | `s/--aeros-ease-entrance\b/--aeros-ease-enter/g` | `var(--aeros-ease-entrance)` → `var(--aeros-ease-enter)` |

In the table, `\|` stands for `|`; Markdown needs the backslash, Perl does not.

Recipe 6 also matches a `size="icon-sm"` on a component other than `Button`; the design system has none.

### Web: find and fix by hand

These need a decision per use. Each pattern is for `grep -rnE`. A pattern that starts with `--` needs `-e` in front of it: `grep -rnE -e '--aeros-…' src`.

| Find | Pattern | Matches, for example |
|---|---|---|
| Removed shadows | `\bshadow-(2xs\|xs\|sm\|md\|lg\|xl\|2xl\|hairline\|focus(-danger\|-success)?)\b` | `shadow-sm`, `hover:shadow-md`, `shadow-focus-danger` |
| Removed radii | `\brounded(-[a-z]{1,2})?-(2xl\|3xl\|4xl)\b` | `rounded-2xl`, `rounded-t-3xl` |
| Radii that tightened | `\brounded(-[a-z]{1,2})?-(xs\|sm\|md\|lg\|xl)\b` | `rounded-lg`, `rounded-b-md` |
| Default palette | `\b(bg\|text\|border\|ring\|fill\|stroke\|outline\|from\|to\|via)-(slate\|gray\|zinc\|neutral\|stone\|red\|orange\|amber\|yellow\|lime\|green\|emerald\|teal\|cyan\|sky\|blue\|indigo\|violet\|purple\|fuchsia\|pink\|rose)-[0-9]+\b` | `bg-blue-500`, `text-gray-600` |
| Default easings | `\bease-(in\|out\|in-out)\b` | `ease-out`, `ease-in-out` |
| Focus ring overrides | `\bring-offset-\|focus(-visible)?:ring-` | `focus-visible:ring-2`, `ring-offset-bg-canvas` |
| Lift and scale | `(hover\|active):(-?translate-\|scale-\|shadow-)` | `hover:-translate-y-px`, `active:scale-[0.985]` |
| Removed variables | `--aeros-(shadow-\|radius-[234]xl\|ease-(emphasized\|decelerate\|spring)\|focus-ring-offset)` | `var(--aeros-shadow-sm)`, `var(--aeros-radius-2xl)` |
| Danger buttons to review | `variant="danger"` | `<Button variant="danger">` |
| Row selection selectors | `aria-selected` | `tr[aria-selected="true"]` |
| The removed preset | `@aeros-core/tokens/tailwind` | `import aeros from "@aeros-core/tokens/tailwind"` |

### Flutter: rewrites

| # | Substitution | Sample → result |
|---|---|---|
| 9 | `s/\bAerosMotion\.(?:entrance\|decelerate\|spring)\b/AerosMotion.enter/g` | `curve: AerosMotion.entrance` → `curve: AerosMotion.enter` |
| 10 | `s/\bAerosMotion\.emphasized\b/AerosMotion.standard/g` | `AerosMotion.emphasized` → `AerosMotion.standard` |
| 11 | `s/\bAeros(?:Button\|Field)Size\b(?!Metrics)/AerosControlSize/g` | `size: AerosButtonSize.sm, AerosFieldSize.md` → `size: AerosControlSize.sm, AerosControlSize.md` |
| 12 | `s/\bAerosSeverityPalette\.of\(\s*([^,()]+),\s*isDark:\s*[^)]+\)/AerosSeverityPalette.of(context, $1)/g` | `AerosSeverityPalette.of(severity, isDark: context.aeros.isDark)` → `AerosSeverityPalette.of(context, severity)` |
| 13 | `s/\b(AerosTypography\.\w+)\(\)\.copyWith\(fontWeight:\s*([\w.]+)\)/$1(weight: $2)/g` | `AerosTypography.bodySm().copyWith(fontWeight: FontWeight.w600)` → `AerosTypography.bodySm(weight: FontWeight.w600)` |

Recipe 12 assumes a `BuildContext` named `context` is in scope. Recipe 13 handles only the no-argument form; find the rest with the pattern below.

### Flutter: find and fix by hand

| Find | Pattern | Matches, for example |
|---|---|---|
| Removed shadows | `\bAerosShadows\b` | `boxShadow: AerosShadows.card(isDark)` |
| Removed radii | `\bAerosRadii\.(br)?[xX]l[234]\b` | `AerosRadii.xl2`, `AerosRadii.brXl3` |
| Weights that do not render | `copyWith\([^)]*fontWeight:` | `.copyWith(color: c, fontWeight: FontWeight.w600)` |
| Palette calls | `Aeros(Selection\|Price)Palette\.resolve\(` | `AerosSelectionPalette.resolve(state, aliases, isDark: true)` |
| Raised cards | `AerosCardVariant\.raised` | `variant: AerosCardVariant.raised` |
| Material overlays | `\b(showDialog\|showModalBottomSheet\|showMenu\|PopupMenuButton\|DropdownButton)\b` | `showDialog(context: context, …)` |
| Material ink | `\bInkWell\b` | `InkWell(onTap: …)` |
| Google Fonts | `google_fonts\|GoogleFonts\.` | `GoogleFonts.ibmPlexMono()` |
| Danger buttons to review | `AerosButton\.danger\|AerosButtonVariant\.danger\b` | `AerosButton.danger(label: 'Delete', …)` |

## 7. Verification checklist

Web and Flutter, unless marked.

**Dark mode**
- [ ] Every screen in light and dark. No light island, no dark-on-dark text.
- [ ] (Web) No element lost its background or text colour to a removed palette class.
- [ ] (Web) The sidebar: themed, or deliberately dark with `data-theme="dark"`.
- [ ] Status colours appear only where they mean state.

**Touch density**
- [ ] (Web) Mobile layouts under `data-density="touch"`: controls 40 high by default, rows 48.
- [ ] (Web) The sidebar below 768px opens as a sheet and closes on choosing a destination.
- [ ] (Flutter) Desktop and web surfaces are inside `AerosDensityScope(density: AerosDensity.pointer)`; phone screens are not.
- [ ] (Flutter) Tight rows at touch density after the 48px minimum target.

**Focus ring**
- [ ] Tab through each screen. One ring, the same everywhere, never clipped by `overflow-hidden`.
- [ ] Fields show the ring on their border; invalid fields show it in the danger colour.
- [ ] No doubled ring from a leftover `ring-*` class.

**Forms**
- [ ] Vertical spacing between fields, now that `Field` has no margin.
- [ ] A button and a field of the same size line up.
- [ ] Error, hint and disabled states.
- [ ] Selects, comboboxes and date pickers open, scroll and close with the keyboard.

**Tables**
- [ ] Row and header heights; numeric columns.
- [ ] Selected rows; (web) selectors and tests use `data-selected`.
- [ ] Empty and loading states.
- [ ] (Flutter) A table in a bounded height scrolls under its header.

**Dialogs and overlays**
- [ ] Dialog widths: default 520, confirmations 400.
- [ ] Footers with no fill; long bodies scroll.
- [ ] Escape and a scrim click close; focus returns to the trigger.
- [ ] Menus, popovers and toasts have a shadow and no doubled border.
- [ ] (Flutter) No Material dialog, bottom sheet or popup menu remains.

**Type and brand**
- [ ] Fonts load: Inter for the interface, IBM Plex Mono for data. No system-font fallback.
- [ ] The wordmark renders in Nunito Sans expanded, unstyled.
- [ ] Headings and truncation after the smaller type scale.
- [ ] No blue or other accent hue anywhere.

**Tests**
- [ ] Screenshot or golden baselines re-recorded and reviewed.
- [ ] Tests that queried `aria-selected`, `InkWell`, `DataTable`, `SnackBarAction` or Material controls updated.

---

# Upgrading from 1.x

## 1.x → 2.0.0

2.0.0 (August 2026) was one coordinated major across `@aeros-core/tokens`, `@aeros-core/react` and `aeros_design_system`. Apply it before the 3.0 guide above. Where a row below was changed again by 3.0, the note says so.

### Variant renames (both platforms)

Colour-word variants were renamed to intent. The old names advertised colours the monochrome system does not have (`blue` rendered grey).

| Component | Old | New |
|---|---|---|
| Badge / `AerosBadge` | `green` / `amber` / `red` / `blue` / `grey` / `dark` | `success` / `warning` / `danger` / `info` / `neutral` / `inverse` |
| Alert / `AerosAlert` | `blue` / `green` / `amber` / `red` | `info` / `success` / `warning` / `danger` |
| Tag / `AerosTag` | `blue` / `grey` / `dark` | `info` / `neutral` / `inverse` |
| Avatar | `tone="ink\|dark\|royal\|green\|amber"` | `variant="neutral\|inverse\|info\|success\|warning"` |
| Progress | `color="royal\|success\|warning\|danger"` | `variant="brand\|success\|warning\|danger"` |
| Button | `variant="dark"` | Removed; use `primary` (they were identical) |

### Tokens

- `royal-*` and `slate-*` ramps deleted. Use `ink-*`, or better, an alias.
- `accent` / `accent-muted` aliases removed.
- `warning` base is `#CC6D04` (was `#D97706`, which failed 3:1 on the warning chip).
- Status colours flip in dark mode. If you hard-coded light status hexes, switch to the `success-*` / `warning-*` / `danger-*` / `info-*` classes (web) or `context.aerosSemantic` (Flutter).
- Breakpoints unified to 640 / 768 / 1024 / 1280 / 1536 on both platforms. Flutter's old 600 / 900 / 1200 / 1600 scale is gone; `AerosBreakpoint.xxl` was added, and desktop switches keyed off `md = 900` fire at 768.

### Web behaviour changes

- `Field` generates ids and wires `aria-describedby` / `aria-invalid`. Remove manual `htmlFor` / `id` pairs unless you need a specific id.
- `Alert` defaults to `role="status"`; pass `role="alert"` for an assertive announcement outside the `danger` variant.
- `SidebarItem` and the header link render a `<button>` when no `href` is given, and accept `asChild`. (The header link is `AppHeaderLink` in 3.0.)
- `Input`, `Textarea` and `SelectTrigger` accept `size="sm|md|lg"`; disabled opacity is 40%.

### Flutter behaviour changes

- `AerosTypography` role styles inherit the ambient colour unless `color:` is passed.
- `AerosCheckbox`, `AerosRadio` and `AerosSwitch` default to a padded touch target; pass `compact: true` for the dense layout. (Custom-drawn in 3.0; `compact` still applies.)
- `AerosSeverityPalette.of` took `isDark:` in 2.x. In 3.0 it takes the context: `AerosSeverityPalette.of(context, severity)`.

## From the HTML kit

The single-file `index.html` kit that preceded the packages has been deleted from the repository, and its class-to-component table with it. For a component's current name, see [components.md](./components.md).
