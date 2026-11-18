# Aeros Design System

The visual language of Aeros for the web (React, Next.js) and for mobile and desktop (Flutter), from one set of tokens.

Version 3.0, "Crisp precision": flat surfaces separated by hairlines, shadows only on floating layers, tight radii, compact controls, one focus ring. Monochrome — black, white and a neutral grey ramp — with status colours used only for state.

## Packages

| Package | What it is |
|---|---|
| [`@aeros-core/tokens`](./packages/tokens) | The tokens. `tokens.json` is the only source; the build generates CSS custom properties, the Tailwind v4 theme, a typed JS module, Dart classes and the token reference |
| [`@aeros-core/react`](./packages/react) | React components on Radix primitives and Tailwind v4 |
| [`aeros_design_system`](./packages/flutter) | Flutter theme and widgets |
| [`@aeros-core/react-docs`](./packages/react-docs) | The showcase site and the visual and accessibility test fixtures. Private, not published |

## Quick start

### Web

The npm packages are on GitHub Packages. Add an `.npmrc` (auth details in [docs/consuming.md](./docs/consuming.md)):

```ini
@aeros-core:registry=https://npm.pkg.github.com
//npm.pkg.github.com/:_authToken=${NODE_AUTH_TOKEN}
```

```bash
pnpm add @aeros-core/react @aeros-core/tokens
```

```css
/* app/globals.css */
@import "@aeros-core/react/styles.css";
@import "@aeros-core/react/fonts.css";
```

```tsx
// app/layout.tsx
import "./globals.css";

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en" data-theme="light">
      <body>{children}</body>
    </html>
  );
}
```

```tsx
import { Button } from "@aeros-core/react";

<Button variant="primary">Create RFQ</Button>
```

### Flutter

```yaml
dependencies:
  aeros_design_system:
    git:
      url: https://github.com/aeros-core/aeros-design-system.git
      path: packages/flutter
      ref: v3.0.0
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

## Documentation

| | |
|---|---|
| [docs/principles.md](./docs/principles.md) | The design rules and the reason for each |
| [docs/tokens.md](./docs/tokens.md) | Every token, generated from `tokens.json` |
| [docs/components.md](./docs/components.md) | The inventory: React and Flutter side by side |
| [docs/consuming.md](./docs/consuming.md) | Installing and wiring the system in an app |
| [docs/migration.md](./docs/migration.md) | Upgrading to 3.0, and from 1.x |
| [docs/releasing.md](./docs/releasing.md) | Versioning, CI, gates and image baselines |

## Foundations

- **Colour:** monochrome. Aliases point into a cool neutral ink ramp and change with the theme. Status colours (success, warning, danger, info) mark state only. No accent hue.
- **Type:** Inter for the interface (body weight 450), IBM Plex Mono for data. The wordmark is Nunito Sans expanded, through the `aeros-logo` class or `AerosWordmark`.
- **Radius:** semantic — item 4, control 6, surface 8, modal 12, pill.
- **Elevation:** resting surfaces have a hairline; `raised`, `overlay` and `modal` are for floating layers.
- **Density:** one control ladder (24 / 28 / 32 / 36 / 40 at pointer, 32 / 36 / 40 / 44 / 48 at touch).
- **Themes:** light, dark and system, through `data-theme` on the web and `AerosTheme` in Flutter.
- **Breakpoints:** 640 / 768 / 1024 / 1280 / 1536 on both platforms.

## Repository layout

```
packages/
  tokens/      @aeros-core/tokens — tokens.json and the generators
  react/       @aeros-core/react
  react-docs/  the showcase and the Playwright suites
  flutter/     aeros_design_system
docs/          the written documentation
scripts/       the CI gates (contrast, hardcoded values, Flutter drift, versions)
.changeset/    pending release notes
```

## Develop

Requires Node 20 and pnpm; Flutter for the Flutter package.

```bash
pnpm install
pnpm build            # tokens, then react, then the showcase
pnpm build:tokens     # regenerate CSS, theme, JS, Dart and docs/tokens.md

pnpm test:tokens
pnpm test:react
pnpm lint:react
pnpm check:contrast
pnpm check:hardcoded
pnpm check:flutter-drift
pnpm check:versions
```

Visual and accessibility suites, and how image baselines are updated: [docs/releasing.md](./docs/releasing.md).

## License

Proprietary — © Aeros.
