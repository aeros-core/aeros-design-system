# @aeros-core/react-docs

Live playground for `@aeros-core/react`. One Next.js app that renders every component with its props, on a single scrollable page — the React equivalent of the repo's `index.html` reference kit.

## Run it

```bash
# from the monorepo root
pnpm install
pnpm --filter @aeros-core/tokens build
pnpm --filter @aeros-core/react build
pnpm --filter @aeros-core/react-docs dev
```

Opens at **http://localhost:3000**.

## What you'll see

- Black sidebar navigation matching the new palette
- Every React component: Button, Input/Field, Textarea, Checkbox, RadioGroup, Switch, Badge, Tag, Card, StatCard, Alert, Progress, Avatar, AvatarStack, Tabs (underline + pill), Breadcrumb, DropdownMenu, Dialog, Tooltip, Table, EmptyState, TopNav, Sidebar
- Light theme by default (`data-theme="light"` on `<html>`)

## Extend it

Just edit [`app/page.tsx`](./app/page.tsx). Add a new `<Section>` and drop components inside. Hot-reload works.

## Dark mode

Toggle the theme by setting `data-theme="dark"` on `<html>`. A dev-mode theme switcher can be added later — the tokens are already there.

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
```

- **Baselines** live in `e2e/__screenshots__/{platform}/{desktop|mobile}/{slug}-{theme}.png`. Linux is the canonical platform — only `linux/` is committed; `darwin/` is git-ignored, so on a Mac run `test:visual:update` on the base commit first, then `test:visual` on your change.
- **Adding a fixture**: add the slug to `app/preview/_fixtures/slugs.ts` and the component to `app/preview/_fixtures/index.ts`. The registry is typed against the slug list (a mismatch fails `next build`) and both specs iterate it, so a new fixture is screenshotted and scanned automatically. Keep fixtures deterministic: no `new Date()`, no random data, no network images.
- **Accessibility debt** is listed in `KNOWN_VIOLATIONS` in `e2e/a11y.spec.ts`. A violation not listed fails the suite; a listed one that no longer occurs also fails, so delete the entry when you fix the component.
- Failure diffs and the HTML report land in `test-results/` and `playwright-report/` (both git-ignored): `pnpm --filter @aeros-core/react-docs exec playwright show-report`.
