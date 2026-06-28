# @aeros-core/tokens

## 1.2.0

### Minor Changes

- 6065a07: Apple-level design refresh (matches Flutter DS v1.3.0): switch the UI typeface to **Inter** (loaded via the stylesheet; `--font-sans` updated), warm layered neutrals with real elevation in both light and dark, sturdier interactive type weights (labels/buttons → 600, display → 800, overline → 700), and a new `label-xs` text token. Light `fg-muted` darkened slightly to clear WCAG AA on the subtle fill.

## 1.1.0

### Minor Changes

- 7cec0a2: Modernize the design system toward a calmer, more layered register (ChatGPT/Figma) while staying strictly monochrome:

  - 12-step faint-warm neutral ramp (fills the old 300/500/700 gaps)
  - layered surfaces (canvas → surface → elevated → subtle) so cards lift; dark mode steps lighter
  - two-layer soft shadows; visible two-tone focus ring
  - 36px default controls; Bold-700 headings with relaxed tracking
  - the token builder now emits the type scale as CSS classes + Dart `TextStyle`s
  - theme-aware primary/checked/tooltip fills (fixes a dark-mode static-fill bug)
