# aeros-design-system

Scope: this repo. Workspace context: @../AGENTS.md.
Last updated: 2026-04-30

## Purpose

The Aeros design system: tokens (W3C DTCG) → CSS, TS, Tailwind v4 preset, and Dart from a single `tokens.json`. Ships `@aeros/react`, `@aeros/tokens`, and the `aeros_design_system` Flutter package consumed by every Aeros web and mobile app.

## Stack

pnpm workspace · TypeScript · React (Radix + Tailwind v4) · Dart/Flutter · Next.js (`packages/react-docs`, `packages/landing`).

Remote: github.com/aeros-main/aeros-design-system

## Repo layout

```
packages/
  tokens/      — source of truth (tokens.json), generates CSS/TS/Tailwind/Dart, ships fonts + brand SVGs
  react/       — @aeros/react (Radix + Tailwind v4)
  react-docs/  — internal Next.js component playground
  landing/     — aeros-x.com marketing site
  flutter/     — aeros_design_system (Material 3 theme + widgets)
docs/          — voice.md, components.md, principles.md, migration.md, tokens.md
scripts/       — build/check helpers
```

## Conventions specific to this repo

- Token values come from `packages/tokens/src/tokens.json` only. Never hardcode hex / radius / spacing in components — add a token first.
- Semantic aliases (`bg-canvas`, `fg-primary`, `border-default`, `brand-primary`, `accent`, …) are theme-aware via `[data-theme="dark"]`. Components consume aliases, not raw ramps.
- Radii defaults: badges/pills/avatars → `full`; buttons → `md`; landing CTAs → `full`; inputs → `md`; cards → `3xl` (24); modals → `xl` (16).
- Wordmark "Aeros" must use Nunito Sans (wdth axis 125), self-hosted via `@aeros/tokens/fonts.css`.
- WCAG AA contrast is enforced by `pnpm check:contrast` — keep semantic color pairs passing.

## Runbook

```
pnpm install
pnpm build              # tokens → react (flutter is built separately by `flutter pub get`)
pnpm check:contrast     # WCAG AA validation of semantic color pairs

pnpm --filter @aeros/tokens build
pnpm --filter @aeros/react  build
pnpm --filter @aeros/react-docs dev
pnpm --filter @aeros/landing dev

cd packages/flutter && flutter analyze && flutter test
```

## Do NOT

- Do NOT introduce raw hex colors in any component. Use tokens.
- Do NOT change `@aeros/react` / `@aeros/tokens` deps to `file:` paths or fixed versions in consumers — they must stay `workspace:*`.
- Do NOT publish breaking token changes without a migration note in `docs/migration.md`.
- Do NOT add a new accent color without explicit brand-owner approval.

## Data / external deps

None — this repo is the source of truth for design assets and ships fonts + brand SVGs from `packages/tokens/`. No backend dependency.

## Playbooks

Repo-specific procedures live in `memory/playbooks/` (none yet). Workspace-wide procedures: @../memory/playbooks/. Add one via @../memory/playbooks/capture-new-skill-or-method.md.

## Open ADRs

(none yet — record token / API breaks here as they happen)
