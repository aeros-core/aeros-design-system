# @aeros-core/react

Aeros React component library — Radix primitives, Tailwind v4, CVA. Built for Next.js (App Router safe: the published bundle carries `"use client"`).

## Install

Published to GitHub Packages — auth setup in [docs/consuming.md](../../docs/consuming.md).

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

Set `data-theme="dark"` on `<html>` to flip the theme — aliases, status colors, and shadows all follow.

## Use

```tsx
import { Button, Field, Input, toast, Toaster } from "@aeros-core/react";

<Field label="Company" hint="As registered" required>
  <Input placeholder="Aeros Pvt Ltd" />
</Field>
<Button onClick={() => toast({ title: "Saved", variant: "success" })}>Save</Button>
<Toaster /> {/* once, near the root */}
```

- `Field` wires label / hint / error to its control (`aria-describedby`, `aria-invalid`) automatically.
- Variants are intent-named everywhere: `success | warning | danger | info | neutral | inverse`.
- Style with the token classes (`bg-bg-surface`, `text-fg-primary`, `duration-(--aeros-duration-fast)`) — raw hex and arbitrary duration/z values fail CI.

## Inventory

Buttons · Fields (Input/Textarea/Select with `size`/`state`) · Checkbox/Radio/Switch · Badge/Tag/Avatar · Card/StatCard · Alert · Toast (`toast()` + `<Toaster/>`) · Progress/Spinner/Skeleton · Dialog/AlertDialog/Drawer/Popover/Tooltip · DropdownMenu/Command (cmdk) · Tabs/Breadcrumb/Pagination · Table (sortable/selected/loading/empty) · Accordion · Calendar (react-day-picker) · Label/Separator · TopNav/Sidebar · EmptyState · DotMatrix.

Full inventory + usage: [docs/components.md](../../docs/components.md). Live playground: `packages/react-docs` (light/dark toggle top-right).

## Develop

```bash
pnpm build   # tsup + "use client" guard + d.ts
pnpm test    # vitest + Testing Library + jest-axe
pnpm lint    # eslint + jsx-a11y
```
