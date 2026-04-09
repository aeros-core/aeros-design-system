# Aeros Design System — Docs

- **[principles.md](./principles.md)** — the design point of view
- **[tokens.md](./tokens.md)** — colors, type, spacing, radii, shadows, motion
- **[components.md](./components.md)** — component inventory with React + Flutter usage
- **[migration.md](./migration.md)** — how to move from the v2 `index.html` kit

## Getting started — Next.js (aeros-x.com)

```bash
pnpm add @aeros/react @aeros/tokens
```

Add to your app root (`app/layout.tsx`):

```tsx
import "@aeros/react/styles.css";

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en" data-theme="light" suppressHydrationWarning>
      <body>{children}</body>
    </html>
  );
}
```

Use a component:

```tsx
import { Button, Card, CardHeader, CardTitle, CardBody, StatCard } from "@aeros/react";

export default function Page() {
  return (
    <main className="p-8 space-y-6">
      <StatCard label="Output" value="4,820" delta={{ value: "+8%", direction: "up" }} />
      <Button variant="primary">Create RFQ</Button>
    </main>
  );
}
```

**Dark mode**: toggle `data-theme="dark"` on `<html>`. We recommend [`next-themes`](https://github.com/pacocoursey/next-themes) with `attribute="data-theme"`.

## Getting started — Flutter

```yaml
dependencies:
  aeros_design_system:
    path: ../aeros-design-system/packages/flutter
```

```dart
import 'package:flutter/material.dart';
import 'package:aeros_design_system/aeros_design_system.dart';

void main() => runApp(MaterialApp(
  theme: AerosTheme.light(),
  darkTheme: AerosTheme.dark(),
  themeMode: ThemeMode.system,
  home: Scaffold(body: AerosButton.primary(label: 'Go', onPressed: () {})),
));
```
