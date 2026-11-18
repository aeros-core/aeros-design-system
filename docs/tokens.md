<!-- Generated from packages/tokens/src/tokens.json by packages/tokens/src/emit/docs.ts. Do not edit. -->
<!-- Change tokens.json, then run `pnpm build:tokens`. CI fails when this file is stale. -->

# Tokens

Token reference for version 3.0.0. This file is generated — do not edit it. Change [`packages/tokens/src/tokens.json`](../packages/tokens/src/tokens.json) and run `pnpm build:tokens`.

Every token reaches three places: a CSS custom property (`@aeros-core/tokens/css`), a Tailwind v4 theme key and its utilities (`@aeros-core/tokens/theme.css`), and a Dart member in `aeros_design_system`. Each section gives the naming pattern for all three.

A value written as `{color.ink.900}` is a reference to another token; `{color.ink.900 / 0.05}` is that colour at 5% alpha. The tables show the reference as authored and the value it resolves to.

## Colour

### Ink ramp

The neutral ramp. Components use the aliases below, not ramp stops; the ramp is for the aliases to point at.

| Platform | Name |
|---|---|
| CSS variable | `--aeros-color-ink-<stop>` |
| Tailwind class | `bg-ink-<stop>`, `text-ink-<stop>`, `border-ink-<stop>` |
| Dart | `AerosColors.ink<stop>` |

| Stop | Value | CSS variable | Dart |
|---|---|---|---|
| `0` | `#FFFFFF` | `--aeros-color-ink-0` | `AerosColors.ink0` |
| `50` | `#FAFAFA` | `--aeros-color-ink-50` | `AerosColors.ink50` |
| `100` | `#F4F4F5` | `--aeros-color-ink-100` | `AerosColors.ink100` |
| `200` | `#E6E6E9` | `--aeros-color-ink-200` | `AerosColors.ink200` |
| `300` | `#D2D2D7` | `--aeros-color-ink-300` | `AerosColors.ink300` |
| `400` | `#9D9DA5` | `--aeros-color-ink-400` | `AerosColors.ink400` |
| `500` | `#6B6B73` | `--aeros-color-ink-500` | `AerosColors.ink500` |
| `600` | `#52525A` | `--aeros-color-ink-600` | `AerosColors.ink600` |
| `700` | `#3B3B42` | `--aeros-color-ink-700` | `AerosColors.ink700` |
| `800` | `#27272B` | `--aeros-color-ink-800` | `AerosColors.ink800` |
| `850` | `#1C1C20` | `--aeros-color-ink-850` | `AerosColors.ink850` |
| `900` | `#141417` | `--aeros-color-ink-900` | `AerosColors.ink900` |
| `950` | `#0B0B0D` | `--aeros-color-ink-950` | `AerosColors.ink950` |

### Aliases

Theme-aware colours. They change with `data-theme` on the web and with the `ThemeData` brightness in Flutter. Use these in product code.

| Platform | Name |
|---|---|
| CSS variable | `--aeros-<alias>` |
| Tailwind class | `bg-<alias>`, `text-<alias>`, `border-<alias>` (any colour utility) |
| Dart | `context.aerosColors.<aliasInCamelCase>` (`AerosAliasColors`) |

| Alias | Light reference | Light value | Dark reference | Dark value | Dart |
|---|---|---|---|---|---|
| `bg-canvas` | `{color.ink.50}` | `#FAFAFA` | `{color.ink.950}` | `#0B0B0D` | `bgCanvas` |
| `bg-surface` | `{color.ink.0}` | `#FFFFFF` | `{color.ink.900}` | `#141417` | `bgSurface` |
| `bg-elevated` | `{color.ink.0}` | `#FFFFFF` | `{color.ink.850}` | `#1C1C20` | `bgElevated` |
| `bg-subtle` | `{color.ink.100}` | `#F4F4F5` | `{color.ink.850}` | `#1C1C20` | `bgSubtle` |
| `bg-inset` | `{color.ink.100}` | `#F4F4F5` | `{color.ink.950}` | `#0B0B0D` | `bgInset` |
| `bg-inverse` | `{color.ink.900}` | `#141417` | `{color.ink.50}` | `#FAFAFA` | `bgInverse` |
| `fg-primary` | `{color.ink.900}` | `#141417` | `{color.ink.50}` | `#FAFAFA` | `fgPrimary` |
| `fg-secondary` | `{color.ink.600}` | `#52525A` | `{color.ink.300}` | `#D2D2D7` | `fgSecondary` |
| `fg-muted` | `{color.ink.500}` | `#6B6B73` | `{color.ink.400}` | `#9D9DA5` | `fgMuted` |
| `fg-disabled` | `{color.ink.400}` | `#9D9DA5` | `{color.ink.600}` | `#52525A` | `fgDisabled` |
| `fg-inverse` | `{color.ink.0}` | `#FFFFFF` | `{color.ink.950}` | `#0B0B0D` | `fgInverse` |
| `fg-brand` | `{color.ink.900}` | `#141417` | `{color.ink.50}` | `#FAFAFA` | `fgBrand` |
| `border-default` | `{color.ink.200}` | `#E6E6E9` | `{color.ink.800}` | `#27272B` | `borderDefault` |
| `border-strong` | `{color.ink.300}` | `#D2D2D7` | `{color.ink.700}` | `#3B3B42` | `borderStrong` |
| `border-subtle` | `{color.ink.100}` | `#F4F4F5` | `{color.ink.850}` | `#1C1C20` | `borderSubtle` |
| `border-focus` | `{color.ink.900}` | `#141417` | `{color.ink.50}` | `#FAFAFA` | `borderFocus` |
| `brand-primary` | `{color.ink.900}` | `#141417` | `{color.ink.50}` | `#FAFAFA` | `brandPrimary` |
| `brand-primary-hover` | `{color.ink.700}` | `#3B3B42` | `{color.ink.300}` | `#D2D2D7` | `brandPrimaryHover` |
| `brand-primary-muted` | `{color.ink.100}` | `#F4F4F5` | `{color.ink.850}` | `#1C1C20` | `brandPrimaryMuted` |
| `focus-ring` | `{color.ink.900}` | `#141417` | `{color.ink.50}` | `#FAFAFA` | `focusRing` |
| `state-hover` | `{color.ink.900 / 0.05}` | `#1414170D` | `{color.ink.50 / 0.07}` | `#FAFAFA12` | `stateHover` |
| `state-pressed` | `{color.ink.900 / 0.09}` | `#14141717` | `{color.ink.50 / 0.12}` | `#FAFAFA1F` | `statePressed` |
| `state-selected` | `{color.ink.900 / 0.07}` | `#14141712` | `{color.ink.50 / 0.1}` | `#FAFAFA1A` | `stateSelected` |
| `scrim` | `{color.ink.950 / 0.4}` | `#0B0B0D66` | `{color.ink.950 / 0.7}` | `#0B0B0DB3` | `scrim` |

### Status colours

The only hues in the system. They mark state — success, warning, danger, info — and nothing else. `info` is neutral: it points into the ink ramp.

| Platform | Name |
|---|---|
| CSS variable | `--aeros-color-semantic-<name>` |
| Tailwind class | `bg-<name>`, `text-<name>`, `border-<name>` (any colour utility) |
| Dart | `context.aerosSemantic.<nameInCamelCase>` (`AerosSemanticColors`) |

| Name | Light reference | Light value | Dark reference | Dark value | Dart |
|---|---|---|---|---|---|
| `success` | — | `#16A34A` | — | `#4ADE80` | `success` |
| `success-bg` | — | `#DCFCE7` | — | `#132B1D` | `successBg` |
| `success-text` | — | `#15803D` | — | `#86EFAC` | `successText` |
| `success-border` | — | `#BBF7D0` | — | `#235C36` | `successBorder` |
| `warning` | — | `#CC6D04` | — | `#FBBF24` | `warning` |
| `warning-bg` | — | `#FEF3C7` | — | `#2E2410` | `warningBg` |
| `warning-text` | — | `#B45309` | — | `#FCD34D` | `warningText` |
| `warning-border` | — | `#FDE68A` | — | `#6B4E16` | `warningBorder` |
| `danger` | — | `#DC2626` | — | `#F87171` | `danger` |
| `danger-bg` | — | `#FEE2E2` | — | `#331414` | `dangerBg` |
| `danger-text` | — | `#B91C1C` | — | `#FCA5A5` | `dangerText` |
| `danger-border` | — | `#FECACA` | — | `#7F2A2A` | `dangerBorder` |
| `info` | `{color.ink.600}` | `#52525A` | `{color.ink.400}` | `#9D9DA5` | `info` |
| `info-bg` | `{color.ink.100}` | `#F4F4F5` | `{color.ink.800}` | `#27272B` | `infoBg` |
| `info-text` | `{color.ink.800}` | `#27272B` | `{color.ink.300}` | `#D2D2D7` | `infoText` |
| `info-border` | `{color.ink.200}` | `#E6E6E9` | `{color.ink.700}` | `#3B3B42` | `infoBorder` |
| `danger-hover` | — | `#B91C1C` | — | `#FCA5A5` | `dangerHover` |

## Type

### Families

| Family | Stack | CSS variable | Use |
|---|---|---|---|
| sans | `'Inter Variable', 'Inter', ui-sans-serif, system-ui, sans-serif` | `--aeros-font-sans` | All interface text |
| mono | `'IBM Plex Mono', ui-monospace, SFMono-Regular, Menlo, monospace` | `--aeros-font-mono` | Data: IDs, amounts, timestamps |
| logo | `'Nunito Sans Variable', 'Nunito Sans', ui-sans-serif, system-ui, sans-serif` | `--aeros-font-logo` | The wordmark only |

Tailwind: `font-sans`, `font-mono`. The wordmark has no utility: use the `aeros-logo` class on the web and `AerosWordmark` in Flutter.

### Weights

| Name | Weight |
|---|---|
| `regular` | 400 |
| `book` | 450 |
| `medium` | 500 |
| `semibold` | 600 |
| `bold` | 700 |

### Type scale

A role sets size, line height, tracking and weight together.

| Platform | Name |
|---|---|
| CSS variable | `--text-<role>` (Tailwind theme key, with `--line-height`, `--letter-spacing` and `--font-weight` modifiers) |
| Tailwind class | `text-<role>` |
| Dart | `AerosTypography.<roleInCamelCase>()` |

| Role | Size (px) | Weight | Line height | Tracking | Family | Tailwind class | Dart |
|---|---|---|---|---|---|---|---|
| `display-xl` | 48 | 600 | 1.0833 | -0.03em | sans | `text-display-xl` | `AerosTypography.displayXl()` |
| `display-lg` | 36 | 600 | 1.1111 | -0.025em | sans | `text-display-lg` | `AerosTypography.displayLg()` |
| `display-md` | 30 | 600 | 1.2 | -0.02em | sans | `text-display-md` | `AerosTypography.displayMd()` |
| `h1` | 24 | 600 | 1.3333 | -0.02em | sans | `text-h1` | `AerosTypography.h1()` |
| `h2` | 20 | 600 | 1.4 | -0.015em | sans | `text-h2` | `AerosTypography.h2()` |
| `h3` | 16 | 600 | 1.5 | -0.01em | sans | `text-h3` | `AerosTypography.h3()` |
| `h4` | 14 | 600 | 1.4286 | -0.005em | sans | `text-h4` | `AerosTypography.h4()` |
| `title-lg` | 16 | 600 | 1.5 | -0.01em | sans | `text-title-lg` | `AerosTypography.titleLg()` |
| `body-lg` | 16 | 450 | 1.5 | 0 | sans | `text-body-lg` | `AerosTypography.bodyLg()` |
| `body-md` | 14 | 450 | 1.4286 | 0 | sans | `text-body-md` | `AerosTypography.bodyMd()` |
| `body-sm` | 13 | 450 | 1.5385 | 0 | sans | `text-body-sm` | `AerosTypography.bodySm()` |
| `label-md` | 14 | 500 | 1.4286 | 0 | sans | `text-label-md` | `AerosTypography.labelMd()` |
| `label-sm` | 13 | 500 | 1.2308 | 0 | sans | `text-label-sm` | `AerosTypography.labelSm()` |
| `label-xs` | 11 | 500 | 1.4545 | 0.01em | sans | `text-label-xs` | `AerosTypography.labelXs()` |
| `caption` | 12 | 450 | 1.3333 | 0 | sans | `text-caption` | `AerosTypography.caption()` |
| `overline` | 11 | 600 | 1.4545 | 0.06em | sans, uppercase | `text-overline` | `AerosTypography.overline()` |
| `mono-lg` | 20 | 400 | 1.4 | 0 | mono | `text-mono-lg` | `AerosTypography.monoLg()` |
| `mono-md` | 13 | 400 | 1.5385 | 0 | mono | `text-mono-md` | `AerosTypography.monoMd()` |
| `mono-sm` | 12 | 400 | 1.3333 | 0 | mono | `text-mono-sm` | `AerosTypography.monoSm()` |
| `mono-xs` | 11 | 400 | 1.4545 | 0 | mono | `text-mono-xs` | `AerosTypography.monoXs()` |

## Spacing

A 4px base with half steps.

| Platform | Name |
|---|---|
| CSS variable | `--aeros-space-<step>` (a `.` in the step is written `_`) |
| Tailwind class | Tailwind's numeric spacing utilities use the same 4px base: `p-4` is 16px, `gap-1.5` is 6px |
| Dart | `AerosSpacing.s<step>` |

| Step | Value | CSS variable | Dart |
|---|---|---|---|
| `0` | 0px | `--aeros-space-0` | `AerosSpacing.s0` |
| `1` | 4px | `--aeros-space-1` | `AerosSpacing.s1` |
| `2` | 8px | `--aeros-space-2` | `AerosSpacing.s2` |
| `3` | 12px | `--aeros-space-3` | `AerosSpacing.s3` |
| `4` | 16px | `--aeros-space-4` | `AerosSpacing.s4` |
| `5` | 20px | `--aeros-space-5` | `AerosSpacing.s5` |
| `6` | 24px | `--aeros-space-6` | `AerosSpacing.s6` |
| `7` | 28px | `--aeros-space-7` | `AerosSpacing.s7` |
| `8` | 32px | `--aeros-space-8` | `AerosSpacing.s8` |
| `10` | 40px | `--aeros-space-10` | `AerosSpacing.s10` |
| `12` | 48px | `--aeros-space-12` | `AerosSpacing.s12` |
| `14` | 56px | `--aeros-space-14` | `AerosSpacing.s14` |
| `16` | 64px | `--aeros-space-16` | `AerosSpacing.s16` |
| `20` | 80px | `--aeros-space-20` | `AerosSpacing.s20` |
| `24` | 96px | `--aeros-space-24` | `AerosSpacing.s24` |
| `32` | 128px | `--aeros-space-32` | `AerosSpacing.s32` |
| `px` | 1px | `--aeros-space-px` | `AerosSpacing.sPx` |
| `0.5` | 2px | `--aeros-space-0_5` | `AerosSpacing.s0_5` |
| `1.5` | 6px | `--aeros-space-1_5` | `AerosSpacing.s1_5` |
| `2.5` | 10px | `--aeros-space-2_5` | `AerosSpacing.s2_5` |
| `3.5` | 14px | `--aeros-space-3_5` | `AerosSpacing.s3_5` |

## Radius

### Semantic radii

Components use these. A semantic radius names what the corner belongs to, so nested corners stay concentric.

| Platform | Name |
|---|---|
| CSS variable | `--aeros-radius-<name>` |
| Tailwind class | `rounded-<name>` |
| Dart | `AerosShapeTokens.<name>` |

| Name | Reference | Value | Tailwind class | Dart |
|---|---|---|---|---|
| `item` | `{radius.sm}` | 4px | `rounded-item` | `AerosShapeTokens.item` |
| `control` | `{radius.md}` | 6px | `rounded-control` | `AerosShapeTokens.control` |
| `surface` | `{radius.lg}` | 8px | `rounded-surface` | `AerosShapeTokens.surface` |
| `modal` | `{radius.xl}` | 12px | `rounded-modal` | `AerosShapeTokens.modal` |
| `pill` | `{radius.full}` | 9999px | `rounded-pill` | `AerosShapeTokens.pill` |

### Scale

The steps the semantic radii point at. Prefer a semantic radius.

| Platform | Name |
|---|---|
| CSS variable | `--aeros-radius-<step>` |
| Tailwind class | `rounded-<step>` |
| Dart | `AerosRadii.<step>` |

| Step | Value | Tailwind class | Dart |
|---|---|---|---|
| `none` | 0px | `rounded-none` | `AerosRadii.none` |
| `xs` | 2px | `rounded-xs` | `AerosRadii.xs` |
| `sm` | 4px | `rounded-sm` | `AerosRadii.sm` |
| `md` | 6px | `rounded-md` | `AerosRadii.md` |
| `lg` | 8px | `rounded-lg` | `AerosRadii.lg` |
| `xl` | 12px | `rounded-xl` | `AerosRadii.xl` |
| `full` | 9999px | `rounded-full` | `AerosRadii.full` |

## Elevation

Three intents. Resting surfaces take a hairline border and no shadow; only floating layers take an elevation. `overlay` and `modal` draw their own 1px edge inside the shadow, so a floating surface takes no border.

| Platform | Name |
|---|---|
| CSS variable | `--aeros-elevation-<intent>` |
| Tailwind class | `shadow-<intent>` |
| Dart | `context.aerosElevation.<intent>` (`AerosElevation`), or `AerosSurface(level: …)` |

| Intent | Light | Dark |
|---|---|---|
| `raised` | `0 1px 2px rgb(0 0 0 / 0.06)` | `0 1px 2px rgb(0 0 0 / 0.5)` |
| `overlay` | `0 0 0 1px rgb(0 0 0 / 0.08), 0 4px 12px -2px rgb(0 0 0 / 0.1), 0 2px 4px -2px rgb(0 0 0 / 0.06)` | `0 0 0 1px rgb(255 255 255 / 0.1), 0 8px 24px -4px rgb(0 0 0 / 0.6)` |
| `modal` | `0 0 0 1px rgb(0 0 0 / 0.08), 0 16px 40px -8px rgb(0 0 0 / 0.16), 0 4px 12px -4px rgb(0 0 0 / 0.08)` | `0 0 0 1px rgb(255 255 255 / 0.1), 0 24px 56px -12px rgb(0 0 0 / 0.7)` |

## Sizes

### Density-dependent

Each size has a pointer (mouse) value and a touch value. The web defaults to pointer and switches a subtree with `data-density="touch"`. Flutter defaults to touch and switches a subtree with `AerosDensityScope`.

| Platform | Name |
|---|---|
| CSS variable | `--aeros-size-<name>` |
| Tailwind class | `h-<name>`, `w-<name>`, `size-<name>`, `min-h-<name>` (spacing utilities) |
| Dart | `AerosDensity.of(context).sizes.<nameInCamelCase>` (`AerosSizeTokens.pointer` / `AerosSizeTokens.touch`) |

| Name | Pointer | Touch | CSS variable | Dart |
|---|---|---|---|---|
| `control-xs` | 24px | 32px | `--aeros-size-control-xs` | `controlXs` |
| `control-sm` | 28px | 36px | `--aeros-size-control-sm` | `controlSm` |
| `control-md` | 32px | 40px | `--aeros-size-control-md` | `controlMd` |
| `control-lg` | 36px | 44px | `--aeros-size-control-lg` | `controlLg` |
| `control-xl` | 40px | 48px | `--aeros-size-control-xl` | `controlXl` |
| `header` | 48px | 56px | `--aeros-size-header` | `header` |
| `row` | 40px | 48px | `--aeros-size-row` | `row` |
| `icon-button` | 32px | 44px | `--aeros-size-icon-button` | `iconButton` |
| `badge` | 18px | 20px | `--aeros-size-badge` | `badge` |
| `list-avatar` | 40px | 48px | `--aeros-size-list-avatar` | `listAvatar` |
| `inline-avatar` | 26px | 30px | `--aeros-size-inline-avatar` | `inlineAvatar` |
| `nav-row` | 32px | 48px | `--aeros-size-nav-row` | `navRow` |
| `nav-icon` | 16px | 20px | `--aeros-size-nav-icon` | `navIcon` |
| `nav-label` | 13px | 14px | `--aeros-size-nav-label` | `navLabel` |
| `min-target` | 24px | 48px | `--aeros-size-min-target` | `minTarget` |

### Fixed

| Platform | Name |
|---|---|
| CSS variable | `--aeros-size-<name>` |
| Tailwind class | `size-<name>`, `h-<name>`, `w-<name>` |
| Dart | `AerosSizeTokens.<nameInCamelCase>` |

| Name | Value | CSS variable | Dart |
|---|---|---|---|
| `icon-xs` | 12px | `--aeros-size-icon-xs` | `AerosSizeTokens.iconXs` |
| `icon-sm` | 14px | `--aeros-size-icon-sm` | `AerosSizeTokens.iconSm` |
| `icon-md` | 16px | `--aeros-size-icon-md` | `AerosSizeTokens.iconMd` |
| `icon-lg` | 20px | `--aeros-size-icon-lg` | `AerosSizeTokens.iconLg` |
| `icon-xl` | 24px | `--aeros-size-icon-xl` | `AerosSizeTokens.iconXl` |
| `avatar-xs` | 20px | `--aeros-size-avatar-xs` | `AerosSizeTokens.avatarXs` |
| `avatar-sm` | 24px | `--aeros-size-avatar-sm` | `AerosSizeTokens.avatarSm` |
| `avatar-md` | 32px | `--aeros-size-avatar-md` | `AerosSizeTokens.avatarMd` |
| `avatar-lg` | 40px | `--aeros-size-avatar-lg` | `AerosSizeTokens.avatarLg` |
| `avatar-xl` | 56px | `--aeros-size-avatar-xl` | `AerosSizeTokens.avatarXl` |

## Motion

### Durations

| Platform | Name |
|---|---|
| CSS variable | `--aeros-duration-<name>` |
| Tailwind class | `duration-<name>` |
| Dart | `AerosMotion.<name>` |

| Name | Value | Tailwind class | Dart |
|---|---|---|---|
| `quick` | 80ms | `duration-quick` | `AerosMotion.quick` |
| `fast` | 120ms | `duration-fast` | `AerosMotion.fast` |
| `base` | 180ms | `duration-base` | `AerosMotion.base` |
| `slow` | 260ms | `duration-slow` | `AerosMotion.slow` |

### Easings

| Platform | Name |
|---|---|
| CSS variable | `--aeros-ease-<name>` |
| Tailwind class | `ease-<name>` |
| Dart | `AerosMotion.<name>` |

| Name | Value | Tailwind class | Dart |
|---|---|---|---|
| `standard` | `cubic-bezier(0.2, 0, 0, 1)` | `ease-standard` | `AerosMotion.standard` |
| `enter` | `cubic-bezier(0.16, 1, 0.3, 1)` | `ease-enter` | `AerosMotion.enter` |
| `exit` | `cubic-bezier(0.4, 0, 1, 1)` | `ease-exit` | `AerosMotion.exit` |

A `transition-*` utility with no duration or easing class uses `fast` and `standard`. Under `prefers-reduced-motion: reduce` the token stylesheet shortens every animation and transition to 0.01ms; in Flutter wrap a duration in `AerosMotion.resolve(context, …)`.

## Focus ring

The metrics of the one focus ring. Its colour is the `focus-ring` alias.

| Platform | Name |
|---|---|
| CSS variable | `--aeros-focus-<name>` |
| Tailwind class | `outline-focus` (width), `outline-offset-focus`, `outline-offset-field`, `outline-offset-inset` |
| Dart | `AerosMetricTokens.focus<NameInPascalCase>` |

| Name | Value | CSS variable | Dart |
|---|---|---|---|
| `width` | 2px | `--aeros-focus-width` | `AerosMetricTokens.focusWidth` |
| `offset` | 2px | `--aeros-focus-offset` | `AerosMetricTokens.focusOffset` |
| `offset-field` | -1px | `--aeros-focus-offset-field` | `AerosMetricTokens.focusOffsetField` |
| `offset-inset` | -2px | `--aeros-focus-offset-inset` | `AerosMetricTokens.focusOffsetInset` |

## Opacity

| Platform | Name |
|---|---|
| CSS variable | `--aeros-opacity-<name>` |
| Tailwind class | `opacity-<name>` |
| Dart | `AerosMetricTokens.opacity<NameInPascalCase>` |

| Name | Value | Tailwind class | Dart |
|---|---|---|---|
| `disabled` | 0.4 | `opacity-disabled` | `AerosMetricTokens.opacityDisabled` |
| `muted` | 0.6 | `opacity-muted` | `AerosMetricTokens.opacityMuted` |

## Border width

| Platform | Name |
|---|---|
| CSS variable | `--aeros-border-width-<name>` |
| Tailwind class | `border-<name>` |
| Dart | `AerosMetricTokens.border<NameInPascalCase>` |

| Name | Value | Tailwind class | Dart |
|---|---|---|---|
| `hairline` | 1px | `border-hairline` | `AerosMetricTokens.borderHairline` |
| `thick` | 2px | `border-thick` | `AerosMetricTokens.borderThick` |

## Layout

Widths of the app frame and of modal surfaces.

| Platform | Name |
|---|---|
| CSS variable | `--aeros-layout-<name>` |
| Tailwind class | `w-<name>` for the sidebar widths (spacing utilities); `max-w-<name>` for the rest (container utilities) |
| Dart | `AerosMetricTokens.layout<NameInPascalCase>` |

| Name | Value | Tailwind class | Dart |
|---|---|---|---|
| `sidebar` | 240px | `w-sidebar` | `AerosMetricTokens.layoutSidebar` |
| `sidebar-rail` | 56px | `w-sidebar-rail` | `AerosMetricTokens.layoutSidebarRail` |
| `sidebar-mobile` | 280px | `w-sidebar-mobile` | `AerosMetricTokens.layoutSidebarMobile` |
| `content-max` | 1200px | `max-w-content-max` | `AerosMetricTokens.layoutContentMax` |
| `dialog-sm` | 400px | `max-w-dialog-sm` | `AerosMetricTokens.layoutDialogSm` |
| `dialog-md` | 520px | `max-w-dialog-md` | `AerosMetricTokens.layoutDialogMd` |
| `dialog-lg` | 720px | `max-w-dialog-lg` | `AerosMetricTokens.layoutDialogLg` |
| `dialog-xl` | 960px | `max-w-dialog-xl` | `AerosMetricTokens.layoutDialogXl` |
| `drawer-sm` | 360px | `max-w-drawer-sm` | `AerosMetricTokens.layoutDrawerSm` |
| `drawer-md` | 480px | `max-w-drawer-md` | `AerosMetricTokens.layoutDrawerMd` |
| `drawer-lg` | 640px | `max-w-drawer-lg` | `AerosMetricTokens.layoutDrawerLg` |

## Z-index

Web only. Flutter stacks with its own overlay and navigator layers.

| Platform | Name |
|---|---|
| CSS variable | `--aeros-z-<layer>` |
| Tailwind class | `z-<layer>` |
| Dart | — |

| Layer | Value | Tailwind class |
|---|---|---|
| `base` | 0 | `z-base` |
| `dropdown` | 1000 | `z-dropdown` |
| `sticky` | 1100 | `z-sticky` |
| `overlay` | 1300 | `z-overlay` |
| `modal` | 1400 | `z-modal` |
| `popover` | 1500 | `z-popover` |
| `toast` | 1600 | `z-toast` |
| `tooltip` | 1700 | `z-tooltip` |
| `raised` | 1 | `z-raised` |

## Breakpoints

The same widths on both platforms.

| Platform | Name |
|---|---|
| CSS variable | `--aeros-breakpoint-<name>` |
| Tailwind class | the `<name>:` variant |
| Dart | `AerosBreakpoints.<name>` |

| Name | Min width | Tailwind variant | Dart |
|---|---|---|---|
| `sm` | 640px | `sm:` | `AerosBreakpoints.sm` |
| `md` | 768px | `md:` | `AerosBreakpoints.md` |
| `lg` | 1024px | `lg:` | `AerosBreakpoints.lg` |
| `xl` | 1280px | `xl:` | `AerosBreakpoints.xl` |
| `2xl` | 1536px | `2xl:` | `AerosBreakpoints.xxl` |
