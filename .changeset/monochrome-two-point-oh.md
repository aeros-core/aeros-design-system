---
"@aeros-core/tokens": major
"@aeros-core/react": major
---

2.0.0 — audit remediation: truthful monochrome API, working dark mode, accessible forms/nav, token-driven motion/z-index.

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
