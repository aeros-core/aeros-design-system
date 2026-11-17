# Consuming the design system

The DS publishes two private npm packages to **GitHub Packages** under the `aeros-core` org, and ships Flutter via a git dependency. Updates are **not** automatic — a release publishes a new version, and each app bumps it (manually or via Renovate) and redeploys.

## Web (React / Next.js)

### 1. Authenticate to GitHub Packages

The `@aeros-core` scope resolves from GitHub Packages, so each consuming repo needs an `.npmrc`:

```ini
# .npmrc
@aeros-core:registry=https://npm.pkg.github.com
//npm.pkg.github.com/:_authToken=${NODE_AUTH_TOKEN}
```

- **Local dev:** export `NODE_AUTH_TOKEN` = a GitHub Personal Access Token with `read:packages`.
- **CI:** set `NODE_AUTH_TOKEN` from a token with `read:packages` (the built-in `GITHUB_TOKEN` works for repos in the `aeros-core` org).

### 2. Install

```bash
pnpm add @aeros-core/react @aeros-core/tokens
```

Use a caret range (`^1.1.0`) so minor/patch DS releases are pickable by `pnpm update` / Renovate.

### 3. Wire up styles

In the app's global stylesheet (Tailwind v4):

```css
@import "@aeros-core/react/styles.css"; /* Tailwind + tokens + the Aeros theme */
@import "@aeros-core/react/fonts.css";  /* optional: self-hosted Inter, Nunito Sans, IBM Plex Mono */
```

- **Fonts (3.0):** `styles.css` no longer fetches fonts from Google. Import `fonts.css`, or load the faces yourself (e.g. `next/font`) — the font tokens fall back to the plain names `Inter`, `Nunito Sans` and `IBM Plex Mono`.
- **Only Aeros tokens compile (3.0):** the theme resets Tailwind's default palette, radii, shadows and easings. `bg-blue-500`, `shadow-2xl` or `ease-out` generate nothing — use the alias classes (`bg-bg-surface`, `text-fg-muted`, `border-border-default`, `shadow-overlay`, `ease-standard`, …). `white`, `black` and `ink-*` remain.
- **Theme:** set `data-theme` to `light`, `dark` or `system` (follows the OS) on `<html>`. It also works on any element, so a subtree can be themed on its own — e.g. `<aside data-theme="dark">`. A `dark:` variant is available.
- **Density:** sizes default to pointer (mouse). Put `data-density="touch"` on `<html>` or any subtree for the larger touch sizes.

The theme itself is generated from `tokens.json` and lives in `@aeros-core/tokens/theme.css`; `styles.css` already imports it.

## Mobile (Flutter)

`aeros_design_system` is `publish_to: none`, so pin it by **git tag** in your app's `pubspec.yaml`:

```yaml
dependencies:
  aeros_design_system:
    git:
      url: https://github.com/aeros-core/aeros-design-system.git
      path: packages/flutter
      ref: v1.1.0   # bump to the latest DS release tag
```

Then `flutter pub get`. Seed the theme with `AerosTheme.light()` / `AerosTheme.dark()`.

## Keeping apps up to date with Renovate (recommended)

Drop this `renovate.json` into each **consuming** repo. It bumps the npm packages and the Flutter git `ref` whenever a new DS version ships, opening a PR you review + merge + deploy:

```json
{
  "$schema": "https://docs.renovatebot.com/renovate-schema.json",
  "extends": ["config:recommended"],
  "npmrc": "@aeros-core:registry=https://npm.pkg.github.com",
  "hostRules": [
    {
      "matchHost": "npm.pkg.github.com",
      "hostType": "npm",
      "token": "{{ secrets.GITHUB_PACKAGES_TOKEN }}"
    }
  ],
  "packageRules": [
    {
      "matchPackageNames": ["@aeros-core/react", "@aeros-core/tokens"],
      "groupName": "Aeros DS"
    }
  ],
  "customManagers": [
    {
      "customType": "regex",
      "managerFilePatterns": ["/(^|/)pubspec\\.yaml$/"],
      "matchStrings": ["ref:\\s*(?<currentValue>v[0-9]+\\.[0-9]+\\.[0-9]+)"],
      "depNameTemplate": "aeros-core/aeros-design-system",
      "datasourceTemplate": "github-tags"
    }
  ]
}
```

> Because DS releases are **visual** (heights, colours, radii), keep the bump behind a reviewed PR + a quick visual check — don't auto-merge into production.
