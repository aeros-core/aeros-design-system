---
"@aeros-core/tokens": major
"@aeros-core/react": major
---

**3.0 — tokens.json is the only source.** The Tailwind v4 theme is now generated (`@aeros-core/tokens/theme.css`) instead of hand-copied into `@aeros-core/react/styles.css`.

- **Breaking:** the theme resets Tailwind's default palette, radii, shadows and easings. Classes such as `bg-blue-500`, `shadow-2xl` or `ease-out` no longer generate CSS in an app that imports `@aeros-core/react/styles.css` — use the Aeros alias classes (`bg-bg-surface`, `text-fg-muted`, `shadow-md`, `ease-standard`, …). `white`, `black` and the `ink-*` ramp remain.
- **Breaking:** the unused Tailwind v3 preset export `@aeros-core/tokens/tailwind` is removed.
- New: `data-theme="system"` follows the OS colour scheme; `data-theme` now works on any element, so a subtree can be themed on its own; a `dark:` variant is available.
- New: token references (`{color.ink.900}`, `{color.ink.900 / 0.05}`); the JS export is fully typed and adds `rawTokens`.
- Fix: `styles.css` scans the published `dist/`, so installed (non-monorepo) consumers get the component classes.
