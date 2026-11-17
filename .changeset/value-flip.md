---
"@aeros-core/tokens": major
"@aeros-core/react": major
---

**3.0 — the "Crisp precision" values.** Everything shifts; review each app visually when upgrading.

- **Colour:** the warm stone ink ramp is replaced by a cool neutral one (`ink-0` … `ink-950`, plus a new `ink-850`). Aliases are now references into the ramp: canvas `ink-50`, surface white, text `ink-900`, borders `ink-200` / `ink-300`; dark mode is near-black (`ink-950` canvas, `ink-900` surface, `ink-850` elevated). `info` status colours are ramp references.
- **Radius:** the scale tightens — `xs` 2, `sm` 4, `md` 6, `lg` 8, `xl` 12 (were 4 / 6 / 8 / 12 / 16). `2xl` / `3xl` / `4xl` become 16 / 20 / 24 and will be removed; prefer the semantic radii (`rounded-control`, `rounded-surface`, `rounded-modal`).
- **Motion:** durations are `quick` 80, `fast` 120, `base` 180, `slow` 260 ms (were 90 / 120 / 200 / 320).
- **Type scale:** display 48 / 36 / 30, h1 24, h2 20, h3 16, h4 14 — all weight 600; body 16 / 14 / 13 at 450; labels 14 / 13 / 11 at 500; caption 12; mono 20 / 13 / 12 / 11. The `light` and `extrabold` weight tokens are removed.
- The contrast gate now also checks every text tier on every surface, the solid danger button, and text over the hover / pressed / selected overlays.
