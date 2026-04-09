# Aeros Design System

Single source of truth for Aeros' visual language across **web (Next.js)** and **mobile (Flutter)**.

> Built for operators. Clarity over decoration. Authority through weight. Quiet color with decisive accents.

## Packages

| Package | What it is | For |
|---|---|---|
| [`@aeros/tokens`](./packages/tokens) | W3C design tokens → CSS vars, TypeScript, Tailwind preset, Dart constants | Everyone |
| [`@aeros/react`](./packages/react) | React 18+ components built with Radix primitives, Tailwind v4, CVA | Next.js website (aeros-x.com) |
| [`aeros_design_system`](./packages/flutter) | Flutter theme + widgets with `ThemeExtension` | Aeros mobile apps |

## Quick start

### Next.js

```bash
pnpm add @aeros/react @aeros/tokens
```

```tsx
// app/layout.tsx
import "@aeros/react/styles.css";

export default function RootLayout({ children }) {
  return <html lang="en" data-theme="light">{children}</html>;
}
```

```tsx
import { Button, Card, StatCard } from "@aeros/react";

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

- **Primary:** Royal Blue `#2347D9`
- **Type:** Plus Jakarta Sans (UI) + IBM Plex Mono (data)
- **Radius:** 6 / 8 / 12 / 16 / 20 / full
- **Spacing:** 4-based scale (4, 8, 12, 16, 20, 24, 32, 40, 48, 64, 80, 96)
- **Themes:** Light + Dark from day one

See [`docs/`](./docs) for the full reference.

## Repo layout

```
packages/
  tokens/   → source of truth, generates CSS/TS/Tailwind/Dart
  react/    → @aeros/react
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
