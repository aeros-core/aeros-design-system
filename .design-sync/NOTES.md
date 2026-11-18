# design-sync notes: Aeros React DS

Repo-specific gotchas for syncing `@aeros-core/react` to Claude Design. Read this before a re-sync.

Inputs were brought up to **Design System 3.0.0** on 2026-11-18. The section "3.0 re-sync" at the end lists what changed and what the first 3.0 sync has to do in the project.

## Shape & scope
- Shape: **package** (no Storybook). 3.0 exports **176 PascalCase symbols**: about 56 primary components and their compound sub-parts (Card, Table, Dialog, AlertDialog, Drawer, Popover, DropdownMenu, Select, Command, Tabs, Accordion, Collapsible, Toast, Sidebar, AppShell / AppHeader, Tooltip families). The inventory is `docs/components.md` (React column), written from `packages/react/src/index.ts`.
- Preview scope: **rich authored previews for the primaries** (`.design-sync/previews/<Export>.tsx`, 56 files); pure sub-parts ship the floor card, since they only render meaningfully inside their parent, which the primary card already shows. Sub-parts are authorable later: drop a `.design-sync/previews/<SubPart>.tsx`.
- A preview file is named after the export it documents and exports 1 to 4 named, zero-argument components. It imports only from `@aeros-core/react` and `lucide-react`.

## Build (this is `cfg.buildCmd`)
- `pnpm build:tokens && pnpm build:react && node .design-sync/compile-css.mjs`
- Tokens MUST build before react: react's `src/styles.css` imports `@aeros-core/tokens/css` and `@aeros-core/tokens/theme.css`, both generated into `packages/tokens/dist/css`.
- `pnpm install` prints "Ignored build scripts: esbuild, sharp". Harmless.

## Type-check the previews before a sync
- `npx tsc -p .design-sync/tsconfig.json` (after the build). It resolves `@aeros-core/react` to `packages/react/dist/index.d.ts`, so a renamed prop or removed export shows up as a type error here instead of as a broken card. It must print nothing.

## CSS is Tailwind v4 and must be compiled (the crux)
- `packages/react/src/styles.css` is shipped as **source** (`@import "tailwindcss"`, `tw-animate-css`, the generated token theme, `@source` lines). The DS expects the host app to run Tailwind; `dist/` contains **no** stylesheet.
- `.design-sync/compile-css.mjs` compiles it to `packages/react/dist/aeros.css` via `@tailwindcss/postcss` + `postcss`, resolved from the repo's react-docs devDeps (fallback: `.ds-sync`). `cfg.cssEntry` points at `dist/aeros.css`.
- The compile also scans `packages/react-docs/app/**` and `.design-sync/previews/**`, so token utilities used there are generated and available to designs. Anything else is absent: designs get only this pre-compiled CSS.
- **The 3.0 theme resets Tailwind's defaults.** Default-palette colours (`bg-blue-500`), the old shadow scale (`shadow-sm`…`shadow-xl`), `rounded-2xl`+, default easings and `font-serif` generate nothing and raise no error. Previews and `conventions.md` must use token classes only (`bg-bg-surface`, `rounded-surface`, `shadow-overlay`, `text-body-sm`, …). `docs/tokens.md` is the reference.
- Existing previews use inline styles for simple flex / grid glue and `var(--aeros-*)` for colour; newer ones also use token classes. Both render.

## Fonts
- Since 3.0 `styles.css` loads **no fonts**. Apps opt in with `@aeros-core/react/fonts.css`, which imports `@fontsource` packages whose woff2 files are addressed by relative `url()`. Those files are not in the bundle.
- So `compile-css.mjs` **prepends a Google Fonts `@import`** for Inter (with the optical-size axis), Nunito Sans (with the width axis the `aeros-logo` wordmark needs at 125) and IBM Plex Mono 400 / 500. The font tokens lead with `'Inter Variable'` / `'Nunito Sans Variable'` and fall back to the plain names Google serves, so the families resolve. This closes the 2.x gap where IBM Plex Mono fell back to a system monospace.
- `[FONT_REMOTE]` for these three families is expected and non-blocking.
- If the sync tooling gains a way to ship font files, switch to `fonts.css` and drop the remote import.

## Render browser
- No chromium was cached on the first sync. Used the installed **Google Chrome** via `DS_CHROMIUM_PATH="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"`. Playwright npm is installed in `.ds-sync` WITHOUT a browser (`PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=1 npm i playwright`). Set `DS_CHROMIUM_PATH` for every `package-validate.mjs` / `package-capture.mjs` run.

## Overlays & layout components (cfg.overrides)
- Overlays render their open state statically: authored with `defaultOpen` (Dialog, AlertDialog, Drawer, Popover, DropdownMenu, Select) or `open` (Tooltip, the open Combobox / DatePicker story), plus `cfg.overrides.<Name> = {cardMode: "single", viewport: "WxH"}`. Radix static-open works in headless Chrome.
- 3.0 widths drive the viewports: default dialog 520, alert dialog 400, drawer 480, sidebar 240.
- Full-width chrome and wide tables use `{cardMode: "column"}`: `AppHeader`, `Tabs`, `DataTable`, `PageHeader`, `Stepper`. `AppShell` and `Sidebar` are fixed-viewport single cards.
- `AppHeader` is sticky in a real shell; its previews pass `className="static"` so the bar stays in the card's flow.
- The viewports for the components added in 3.0 are **estimates that have not been through a render check yet**. Adjust them on the first 3.0 sync.

## Composition source
- `packages/react-docs/app/preview/_fixtures/<slug>.tsx` is the canonical usage of every component (one fixture per component, grouped by state), and `packages/react-docs/app/_registry.ts` has a description and usage snippet for each. Previews are ported from the fixtures: one named export per meaningful group. (The 2.x single-page gallery `react-docs/app/page.tsx` no longer exists.)
- Fixtures import a local `./kit` (`Group`, `FIXED_TODAY`); previews inline what they need and never call `new Date()` without arguments.

## Component prop notes (3.0)
- Variants are intent-named: `neutral | info | success | warning | danger | inverse` on Badge, Tag (neutral / info / inverse only), Avatar, Alert (no neutral / inverse). The 2.x colour names and `Avatar.tone` are gone. `info` is neutral grey: nothing in the system is blue.
- `Button`: no `variant="dark"`, no `size="icon-*"`; icon-only is `iconOnly` + `aria-label`. `danger` is solid, `danger-subtle` is the tinted one.
- `Sidebar` and `AppHeader` follow the theme. Dark chrome is `data-theme="dark"` on the element.
- `Sidebar` works without `SidebarProvider` (static, expanded). With it: 56px rail, mobile sheet, `SidebarTrigger`, Cmd/Ctrl+B.
- `Field` and `TabsContent` have no margin; previews space their own content.
- `Toast`: the app form (`toast()` + `<Toaster />`) only renders after mount, so the preview uses the static parts: `ToastProvider duration={Infinity}` > `Toast open` + `ToastViewport`. The viewport is `fixed` to the bottom right of the card's viewport.
- `AppShell` is `min-h-dvh` and `Sidebar` is `sticky h-dvh`: the card is as tall as its viewport, and below the mobile breakpoint the sidebar is a closed sheet. Keep the `AppShell` viewport wide (1040).
- `Combobox`, `MultiCombobox`, `DatePicker`, `DateRangePicker` take `open` directly; their open stories reserve space with a `minHeight` wrapper because the popup is portalled.
- `FileUpload` is controlled (`value: File[]`); its "with files" story builds `File` objects at render, so it needs the browser `File` global.
- `SegmentedControl` is exported from `toggle.tsx`.

## cfg.overrides & [CONFIG_STALE]
- Adding or changing a **graded** override slice (for example `viewport`) after a full build makes a scoped `preview-rebuild --components X` abort with `[CONFIG_STALE]` for that component. Fix: run a full `package-build.mjs` (re-stamps `.stories-map.json`), then the scoped rebuild. `cardMode` / `primaryStory` are presentation-only and never trigger this; `viewport` does.

## Re-sync risks (what can silently go stale)
- **CSS compile toolchain**: `compile-css.mjs` needs `@tailwindcss/postcss` + `postcss` resolvable (react-docs devDeps after `pnpm install`).
- **Reset theme**: a class from a removed namespace renders as nothing, silently. After a token change, grep the previews and `conventions.md` for classes that no longer exist in `packages/tokens/dist/css/theme.css`.
- The compiled `packages/react/dist/aeros.css` is gitignored (under `dist`); a re-sync must run `buildCmd`, not just the converter.
- `conventions.md` is hand-written from `docs/tokens.md`, `docs/components.md` and `docs/migration.md`. Re-read it when any of those change.

## 3.0 re-sync (first sync after these inputs changed)
What changed in the inputs, so the incremental sync knows what to expect in the project:
- **Renamed:** `TopNav`, `TopNavBrand`, `TopNavLinks`, `TopNavLink`, `TopNavRight` are gone; the replacements are `AppHeader`, `AppHeaderBrand`, `AppHeaderNav`, `AppHeaderLink`, `AppHeaderActions`, plus the new `AppHeaderTitle`. The five `TopNav*` component folders in the project must be **deleted**, not left beside the new ones.
- **Added:** about 100 exports across the new families: AppShell, DataTable, Combobox / MultiCombobox, DatePicker / DateRangePicker / Calendar, NumberInput, FileUpload, Command, AlertDialog, Drawer, Popover, Toast, Accordion, Collapsible, Pagination, Stepper, PageHeader, Toggle / ToggleGroup / SegmentedControl, FilterChip, CountBadge, Kbd, Label, Separator, Spinner, Skeleton, ScrollArea, and the new Sidebar parts.
- **Changed everywhere:** every existing card re-renders (new ramp, radii, flat surfaces, sizes, type scale), so expect the whole project to be rewritten, not a small diff. `styles.css` / `_ds_bundle.css`, the README header (`conventions.md`) and the three guidelines files all change.
- The previews type-check against the 3.0 build and the CSS compiles, but the 3.0 inputs **have not been through the render check or uploaded** as of 2026-11-18. Treat every card as unverified until `/design-sync` has run.
