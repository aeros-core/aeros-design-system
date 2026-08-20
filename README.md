# Aeros Design System

Single source of truth for Aeros' visual language across **web (Next.js)** and **mobile (Flutter)**.

> Built for operators. Clarity over decoration. Authority through weight. Black on white — no accent hue.

## Packages

| Package | What it is | For |
|---|---|---|
| [`@aeros-core/tokens`](./packages/tokens) | W3C design tokens → CSS vars, TypeScript, Tailwind preset, Dart constants | Everyone |
| [`@aeros-core/react`](./packages/react) | React 18+ components built with Radix primitives, Tailwind v4, CVA | Next.js website (aeros-x.com) |
| [`aeros_design_system`](./packages/flutter) | Flutter theme + widgets with `ThemeExtension` | Aeros mobile apps |

## Quick start

### Next.js

The `@aeros-core` packages are published to **GitHub Packages**, so add an `.npmrc` first (see [docs/consuming.md](./docs/consuming.md) for auth):

```ini
# .npmrc
@aeros-core:registry=https://npm.pkg.github.com
//npm.pkg.github.com/:_authToken=${NODE_AUTH_TOKEN}
```

```bash
pnpm add @aeros-core/react @aeros-core/tokens
```

```tsx
// app/layout.tsx
import "@aeros-core/react/styles.css";

export default function RootLayout({ children }) {
  return <html lang="en" data-theme="light">{children}</html>;
}
```

```tsx
import { Button, Card, StatCard } from "@aeros-core/react";

<Button variant="primary" size="md">Create RFQ</Button>
```

### Flutter

```yaml
dependencies:
  aeros_design_system:
    path: ../aeros-design-system/packages/flutter
```

```dart
import 'package:aeros_design_system/aeros_design_system.dart';

MaterialApp(
  theme: AerosTheme.light(),
  darkTheme: AerosTheme.dark(),
  home: Scaffold(
    body: AerosButton.primary(label: 'Create RFQ', onPressed: () {}),
  ),
);
```

## Foundations

- **Color:** Monochrome — ink (warm near-black) on white. Status tints (success/warning/danger/info) are the only color, reserved for state. No brand accent hue.
- **Type:** Inter (UI) + IBM Plex Mono (data); Nunito Sans (wdth 125) for the wordmark only
- **Radius:** 0 / 4 / 6 / 8 / 12 / 16 / 20 / 24 / 32 / full
- **Spacing:** 4-based scale with half-steps (1, 2, 4, 6, 8, 10, 12, 14, 16 … 128)
- **Breakpoints:** 640 / 768 / 1024 / 1280 / 1536 — the same on web and Flutter
- **Themes:** Light + Dark from day one (status colors and shadows included)

See [`docs/`](./docs) for the full reference.

## Repo layout

```
packages/
  tokens/   → source of truth, generates CSS/TS/Tailwind/Dart
  react/    → @aeros-core/react
  flutter/  → aeros_design_system
docs/       → tokens, components, principles, migration
index.html  → original v2 visual reference (kept for parity)
```

## Build

```bash
pnpm install
pnpm build          # tokens → react (flutter is built by `flutter pub get`)
```

## License

Proprietary — © Aeros.
