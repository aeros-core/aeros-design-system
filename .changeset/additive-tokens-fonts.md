---
"@aeros-core/tokens": major
"@aeros-core/react": major
---

**3.0 — new token blocks, self-hosted fonts.** No existing token value changes here.

- **Breaking:** `@aeros-core/react/styles.css` no longer fetches fonts from Google Fonts. Import the new `@aeros-core/react/fonts.css` (self-hosted Inter with its optical-size axis, Nunito Sans with its width axis, IBM Plex Mono 400/500) or load the faces yourself. The font tokens now lead with the variable family names (`'Inter Variable'`, `'Nunito Sans Variable'`) and fall back to the plain ones.
- New tokens: control sizes and density (`size`, with `data-density="touch"`), elevation intents (`raised` / `overlay` / `modal`, light + dark), semantic radii (`item` / `control` / `surface` / `modal` / `pill`), focus ring metrics, opacity, border widths, layout widths, state colours (`state-hover` / `state-pressed` / `state-selected`), `scrim`, `fg-disabled`, `danger-hover`, and `enter` / `exit` easings.
- New Tailwind utilities from those tokens: `text-<role>` (size + line height + tracking + weight in one class), `h-control-md`, `size-icon-md`, `rounded-control`, `shadow-overlay`, `z-modal`, `duration-fast`, `max-w-dialog-md`, `w-sidebar`, `bg-state-hover`, `bg-scrim`, `opacity-disabled`, `outline-offset-field`.
- `cn()` understands the Aeros class names (tailwind-merge v3 configured from the tokens), so `text-body-sm text-fg-muted` keeps both and `rounded-md rounded-control` resolves to the latter.
- The default transition timing is the token `fast` / `standard`, not Tailwind's 150ms.
