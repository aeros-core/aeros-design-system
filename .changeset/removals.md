---
"@aeros-core/tokens": major
"@aeros-core/react": major
---

**3.0 — removals.** Everything the restyle replaced is gone.

- Shadows: the `xs`–`xl`, `hairline` and `focus*` shadow tokens (`--aeros-shadow-*`, `shadow-sm` …) are removed. Use the elevation intents `shadow-raised` / `shadow-overlay` / `shadow-modal`; resting surfaces take a hairline border.
- Radius: `2xl` / `3xl` / `4xl` are removed. Use `rounded-item|control|surface|modal|pill`.
- Motion: the `emphasized`, `decelerate`, `entrance` and `spring` easings are removed. Use `ease-standard`, `ease-enter`, `ease-exit`.
- Aliases: `focus-ring-offset` is removed (the focus ring has a transparent offset).
- CSS: the `.aeros-text-<role>` classes are removed. Use the Tailwind utilities `text-<role>`.
