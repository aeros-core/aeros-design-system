# @aeros-core/react-docs

The showcase site of the Aeros Design System: foundations generated from the tokens, a page per component, and whole-screen patterns. It is built from the system's own app shell and components, and is exported as a static site (`output: "export"`, served from `out/`).

## Run it

```bash
# from the monorepo root
pnpm install
pnpm build:tokens
pnpm build:react
pnpm --filter @aeros-core/react-docs dev      # http://localhost:3000
pnpm --filter @aeros-core/react-docs build    # static export in out/
```

## What is where

| Path | What |
|---|---|
| `app/layout.tsx` | Root layout. Minimal on purpose — the chrome-less previews render straight into it. |
| `app/(site)/layout.tsx` | The documentation shell: `SidebarProvider` + `AppShell`, theme and density switches. |
| `app/(site)/page.tsx` | Overview. |
| `app/(site)/foundations/*` | Color, typography, spacing and radius, elevation, motion, density and sizing. Every value is read from `@aeros-core/tokens` at build time. |
| `app/(site)/components/` | The index and `[slug]`, one page per entry in the registry. |
| `app/(site)/patterns/*` | App shell, data table screen, form, settings. |
| `app/(site)/migration/` | Headline 3.0 breaking changes; links to `docs/migration.md`. |
| `app/_registry.ts` | The component catalogue: slug → title, family, description, imports, usage, fixtures. |
| `app/_site/` | The site's own parts: shell, routes, code block, page furniture, fixture frame. |
| `app/preview/` | Chrome-less fixtures at `/preview/<slug>` — what the tests screenshot and scan. |

The site follows the same token rules as the library (`scripts/check-hardcoded.mjs`): alias colours, type roles, semantic radii, elevation intents. No hex, no `text-sm`, no `rounded-md`.

## Adding a component

1. Add the fixture: the slug in `app/preview/_fixtures/slugs.ts`, the component in `app/preview/_fixtures/index.ts`.
2. Add (or extend) its entry in `app/_registry.ts`, naming the fixture in `fixtures`.

Step 2 cannot be forgotten: a fixture slug that no registry entry shows — and that is not in `NON_COMPONENT_FIXTURES` — is a type error, so `next build` fails and names the slug. An entry naming a fixture that does not exist is a type error too, and a fixture shown by two entries throws while the build prerenders.

The component page renders the fixture itself, so the documentation shows exactly what is tested. Forced-open overlays and viewport-sized chrome are listed in `FRAMED_FIXTURES` and shown in a frame instead of inline.

## Theme and density

The header switches set `data-theme` (`light` / `dark` / `system`) and `data-density` (`pointer` / `touch`) on `<html>` and remember the choice in `localStorage`. An inline script in the site layout applies the saved values before first paint.

## Visual regression + accessibility tests

Every component family has a chrome-less fixture page at `/preview/<slug>` (`app/preview/_fixtures/`, one file per fixture, all variants/sizes/states, overlays rendered open). Playwright screenshots each fixture in light + dark at 1280×800 and 390×844, and runs axe (WCAG 2.1 A/AA) on each fixture in light + dark.

The tests run against the static export in `out/`, so build first:

```bash
# from the monorepo root
pnpm build:tokens
pnpm build:react
pnpm --filter @aeros-core/react-docs build
pnpm --filter @aeros-core/react-docs exec playwright install chromium   # once

pnpm test:visual          # compare against the baselines
pnpm test:visual:update   # rewrite baselines after an intended visual change
pnpm test:a11y            # axe on every fixture
pnpm --filter @aeros-core/react-docs test:site   # smoke + axe on every page of the site
```

- **Baselines** live in `e2e/__screenshots__/{platform}/{desktop|mobile}/{slug}-{theme}.png`. Linux is the canonical platform — only `linux/` is committed; `darwin/` is git-ignored, so on a Mac run `test:visual:update` on the base commit first, then `test:visual` on your change.
- **Adding a fixture**: add the slug to `app/preview/_fixtures/slugs.ts` and the component to `app/preview/_fixtures/index.ts`. The registry is typed against the slug list (a mismatch fails `next build`) and both specs iterate it, so a new fixture is screenshotted and scanned automatically. Keep fixtures deterministic: no `new Date()`, no random data, no network images.
- **Accessibility debt** is listed in `KNOWN_VIOLATIONS` in `e2e/a11y.spec.ts`. A violation not listed fails the suite; a listed one that no longer occurs also fails, so delete the entry when you fix the component.
- Failure diffs and the HTML report land in `test-results/` and `playwright-report/` (both git-ignored): `pnpm --filter @aeros-core/react-docs exec playwright show-report`.

## Site tests

`e2e/site.spec.ts` (Playwright project `site`) loads every route — the static list in `app/_site/routes.ts` plus one page per registry entry — in light and dark, and requires: no console error, exactly one `<h1>`, the sidebar row of the page marked `aria-current="page"`, and a clean axe run (WCAG 2.1 A/AA). It also checks every route at 390px for horizontal overflow, the mobile sheet, the rail, and the theme and density switches.

A component page inherits the known violations of the fixtures it renders inline (`e2e/known-violations.ts`, shared with the fixture suite); the spec lists those pages explicitly. Framed fixtures are the `/preview` documents the fixture suite already scans.
