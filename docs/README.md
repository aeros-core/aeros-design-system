# Aeros Design System — documentation

For version 3.0 of `@aeros-core/tokens`, `@aeros-core/react` and `aeros_design_system`.

## Start here

| If you want to | Read |
|---|---|
| Add the system to an app | [consuming.md](./consuming.md) |
| Upgrade an app to 3.0 | [migration.md](./migration.md) |
| Find a component and its counterpart on the other platform | [components.md](./components.md) |
| Look up a token, its value and its name on each platform | [tokens.md](./tokens.md) |
| Understand why the system looks the way it does | [principles.md](./principles.md) |
| Change the system and ship the change | [releasing.md](./releasing.md) |

## All documents

- **[principles.md](./principles.md)** — the design rules of 3.0, each with its reason: surfaces and elevation, radius, colour, type, density, motion, focus, accessibility, platform parity.
- **[tokens.md](./tokens.md)** — the token reference. Generated from `packages/tokens/src/tokens.json`; do not edit it by hand.
- **[components.md](./components.md)** — every React export and every Flutter widget, by family, and how components are built from shared recipes and the foundation layer.
- **[consuming.md](./consuming.md)** — GitHub Packages auth, install, CSS and fonts, the Tailwind theme reset, `data-theme`, `data-density`, the app shell, Flutter pinning, `AerosTheme`, `AerosDensityScope`, Renovate.
- **[migration.md](./migration.md)** — upgrading to 3.0 step by step, with replacement tables and search-and-replace recipes; the older 1.x → 2.0 notes.
- **[releasing.md](./releasing.md)** — Changesets, the `next/3.0` integration branch, CI jobs and gates, how image baselines are updated, Flutter tagging.
- **[configurable-mto.md](./configurable-mto.md)** — the Flutter widgets for configurable made-to-order listings.
- **[audit-2026-08.md](./audit-2026-08.md)** — the August 2026 audit that led to 2.0 and 2.1. A historical record.

## Package READMEs

- [`packages/tokens`](../packages/tokens/README.md) — exports, adding a token, the generators.
- [`packages/react`](../packages/react/README.md) — install, a minimal example, contributing rules, tests.
- [`packages/flutter`](../packages/flutter/README.md) — install, theme, density, the foundation layer, goldens.
- [`packages/react-docs`](../packages/react-docs/README.md) — the showcase and the visual and accessibility suites.
