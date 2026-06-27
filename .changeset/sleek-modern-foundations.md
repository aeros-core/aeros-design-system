---
"@aeros-core/tokens": minor
"@aeros-core/react": minor
---

Modernize the design system toward a calmer, more layered register (ChatGPT/Figma) while staying strictly monochrome:

- 12-step faint-warm neutral ramp (fills the old 300/500/700 gaps)
- layered surfaces (canvas → surface → elevated → subtle) so cards lift; dark mode steps lighter
- two-layer soft shadows; visible two-tone focus ring
- 36px default controls; Bold-700 headings with relaxed tracking
- the token builder now emits the type scale as CSS classes + Dart `TextStyle`s
- theme-aware primary/checked/tooltip fills (fixes a dark-mode static-fill bug)
