# aeros_design_system

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
