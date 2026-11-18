# Consuming the design system

How an app installs and wires version 3.0. Upgrading an existing app? Read [migration.md](./migration.md) first.

The system ships as two private npm packages on GitHub Packages (`@aeros-core/tokens`, `@aeros-core/react`) and one Flutter package pinned by git tag (`aeros_design_system`). A release does not reach an app on its own: each app bumps the version and redeploys.

## Web (React, Next.js)

Requirements: React 18.2 or 19, Tailwind CSS 4.

### 1. Authenticate to GitHub Packages

The `@aeros-core` scope resolves from GitHub Packages. Add an `.npmrc` to the app repo:

```ini
# .npmrc
@aeros-core:registry=https://npm.pkg.github.com
//npm.pkg.github.com/:_authToken=${NODE_AUTH_TOKEN}
```

- **Local:** export `NODE_AUTH_TOKEN` as a GitHub personal access token with `read:packages`.
- **CI:** set `NODE_AUTH_TOKEN` from a token with `read:packages`. The built-in `GITHUB_TOKEN` works for repos in the `aeros-core` org.

### 2. Install

```bash
pnpm add @aeros-core/react @aeros-core/tokens
```

Use a caret range (`^3.0.0`). The two packages are versioned together; keep them on the same version.

### 3. CSS setup

In the app's global stylesheet:

```css
@import "@aeros-core/react/styles.css"; /* Tailwind, the tokens, the Aeros theme, base styles */
@import "@aeros-core/react/fonts.css";  /* optional: the self-hosted fonts */
```

`styles.css` imports Tailwind itself, so the app does not also write `@import "tailwindcss"`. The app needs Tailwind's build plugin as usual (`@tailwindcss/postcss` or `@tailwindcss/vite`).

`styles.css` brings in:

- `@aeros-core/tokens/css` — every token as an `--aeros-*` custom property, for light, dark and system themes and for both densities;
- `@aeros-core/tokens/theme.css` — the Tailwind theme generated from the tokens;
- base styles: the body font and weight (450), the canvas background, the global focus ring, and the `aeros-logo` and `aeros-mono` classes.

### 4. Fonts

`styles.css` does not load fonts. Choose one:

- **Import `fonts.css`.** It self-hosts Inter (variable, with the optical-size axis), Nunito Sans (variable, with the width axis) and IBM Plex Mono 400 / 500. No request goes to a font CDN.
- **Load the faces yourself**, for example with `next/font`. The font tokens name the variable families first (`'Inter Variable'`, `'Nunito Sans Variable'`) and fall back to the plain names `Inter`, `Nunito Sans` and `IBM Plex Mono`, so a face registered under a plain name is picked up. Nunito Sans needs its width axis: the wordmark is set at width 125.

If neither is done, text falls back to the system sans-serif.

### 5. The theme reset

The Aeros theme clears Tailwind's default colour palette, radii, shadows, easings and font families, then defines its own. In an app that imports `styles.css`, this applies to the app's own classes too:

| Namespace | What compiles | What generates nothing |
|---|---|---|
| Colour | Aliases (`bg-bg-surface`, `text-fg-muted`, `border-border-default`), status colours (`text-danger-text`, `bg-success-bg`), `white`, `black`, `ink-*`, `transparent`, `current` | The default palette: `bg-blue-500`, `text-gray-600`, `border-red-300` |
| Radius | `rounded-item`, `rounded-control`, `rounded-surface`, `rounded-modal`, `rounded-pill`, and the scale `rounded-none` / `xs` / `sm` / `md` / `lg` / `xl` / `full` | `rounded-2xl`, `rounded-3xl`, `rounded-4xl` |
| Shadow | `shadow-raised`, `shadow-overlay`, `shadow-modal`, `shadow-none` | `shadow-sm`, `shadow-md`, `shadow-lg`, `shadow-xl`, `shadow-2xl` |
| Easing | `ease-standard`, `ease-enter`, `ease-exit`, `ease-linear` | `ease-in`, `ease-out`, `ease-in-out` |
| Font family | `font-sans`, `font-mono` | `font-serif` |

A class that generates nothing does not fail the build. The element simply loses that style, so search for these classes when adopting the system.

Not reset: spacing (`p-4`, `gap-2`), Tailwind's default text sizes (`text-sm`), font weights (`font-medium`), and numeric durations and z-indexes. Prefer the token forms anyway: `text-<role>`, `h-control-md`, `duration-fast`, `z-modal`. The full list is in [tokens.md](./tokens.md).

`text-<role>` (for example `text-body-sm`, `text-h2`) sets size, line height, tracking and weight in one class.

A `transition-*` class with no duration or easing uses the token defaults, 120ms and `ease-standard`, not Tailwind's 150ms.

### 6. Theme: `data-theme`

```tsx
// app/layout.tsx
import "./globals.css";

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en" data-theme="light" suppressHydrationWarning>
      <body>{children}</body>
    </html>
  );
}
```

| Value | Result |
|---|---|
| no attribute, or `light` | Light |
| `dark` | Dark |
| `system` | Follows the operating system setting |

The attribute works on any element, so a subtree can be themed on its own:

```tsx
<Sidebar data-theme="dark">…</Sidebar>   {/* dark chrome in a light app */}
<section data-theme="light">…</section>  {/* a light island in a dark page */}
```

A `dark:` variant is available. It matches inside `data-theme="dark"` and, under a dark OS setting, inside `data-theme="system"`. Most code does not need it: alias classes already change with the theme.

To let the user switch themes, set the attribute on `<html>`. `next-themes` with `attribute="data-theme"` does this.

### 7. Density: `data-density`

Sizes default to pointer (mouse) density. Put `data-density="touch"` on `<html>` or on any subtree for the touch sizes: controls 32 / 36 / 40 / 44 / 48 instead of 24 / 28 / 32 / 36 / 40, rows 48 instead of 40, the header 56 instead of 48.

```tsx
<div data-density="touch">…</div>
```

Only classes built on the size tokens respond (`h-control-md`, `h-row`, `h-header`, `size-icon-button`). The components use them throughout.

### 8. The app shell

```tsx
import {
  AppShell, AppMain, AppHeader, AppHeaderTitle, AppHeaderActions, AppContent, AppFooter,
  Sidebar, SidebarProvider, SidebarHeader, SidebarBrand, SidebarContent, SidebarSection,
  SidebarItem, SidebarGroup, SidebarSubItem, SidebarFooter, SidebarTrigger,
  Toaster, TooltipProvider
} from "@aeros-core/react";

export function Frame({ children }: { children: React.ReactNode }) {
  return (
    <TooltipProvider>
      <SidebarProvider storageKey="app.sidebar">
        <AppShell>
          <Sidebar>
            <SidebarHeader>
              <SidebarBrand mark="A" name="Aeros" />
            </SidebarHeader>
            <SidebarContent>
              <SidebarSection label="Workspace">
                <SidebarItem href="/orders" icon={<OrdersIcon />} active count={4}>Orders</SidebarItem>
                <SidebarGroup label="Catalog" icon={<CatalogIcon />}>
                  <SidebarSubItem href="/catalog/items">Items</SidebarSubItem>
                  <SidebarSubItem href="/catalog/categories">Categories</SidebarSubItem>
                </SidebarGroup>
              </SidebarSection>
            </SidebarContent>
            <SidebarFooter>{/* account */}</SidebarFooter>
          </Sidebar>
          <AppMain>
            <AppHeader>
              <SidebarTrigger />
              <AppHeaderTitle>Orders</AppHeaderTitle>
              <AppHeaderActions>{/* search, account menu */}</AppHeaderActions>
            </AppHeader>
            <AppContent>{children}</AppContent>
            <AppFooter>© Aeros</AppFooter>
          </AppMain>
        </AppShell>
      </SidebarProvider>
      <Toaster />
    </TooltipProvider>
  );
}
```

- `SidebarProvider` owns the sidebar state, and the window width picks the presentation (full design: `docs/sidebar/spec.md`):
  - below `md` (768): a left sheet at touch density, with a close button;
  - `md` to `lg`: a 56px icon rail. The trigger floats the full sidebar over the page without reflowing it; it closes on Escape, a press outside, or choosing a destination;
  - `lg` (1024) and up: 240 wide. The trigger collapses it to the rail and the choice is remembered.
- Icons sit 28px from the edge in every state, so collapsing only fades the labels. In the rail every row has a tooltip, a count becomes a dot, and a `SidebarGroup` opens its children in a menu beside it.
- `storageKey` remembers the choice in `localStorage` and in a cookie of the same name (`"1"` collapsed, `"0"` expanded). Use a cookie-safe key (letters, digits, `.`, `_`, `-`). In a server-rendered app read the cookie and pass it in, so the first paint is already right:
  ```tsx
  const collapsed = (await cookies()).get("app.sidebar")?.value === "1";
  <SidebarProvider storageKey="app.sidebar" defaultCollapsed={collapsed}>
  ```
- Cmd/Ctrl+B toggles the sidebar, except while typing in a field; pass `keyboardShortcut={false}` to turn it off. `useSidebar()` reads and sets the state.
- `SidebarTrigger` is the one control at every width. The sidebar's edge is also clickable with a pointer (`<Sidebar edgeToggle={false}>` turns that off).
- `SidebarItem` takes `count` (a quiet number; `countTone="solid"` for a pill that needs attention) and `trailing` (for example a `<Kbd>` hint).
- `SidebarGroup` can hold another `SidebarGroup`. Two levels is the design target.
- `SidebarMenuButton` is the header or footer block that opens a menu (workspace switcher, account): `<DropdownMenuTrigger asChild><SidebarMenuButton leading={<Avatar … />} name="Meera Shah" sub="meera@example.com" /></DropdownMenuTrigger>`.
- `SidebarItem` and `AppHeaderLink` take `asChild`, so a framework `<Link>` can be the row: `<SidebarItem asChild active><Link href="/orders">Orders</Link></SidebarItem>`.
- The shell follows the theme. For dark chrome in a light app, use `<Sidebar data-theme="dark">`.
- For a layout without a sidebar, put `AppHeaderBrand` and `AppHeaderNav` with `AppHeaderLink`s in the `AppHeader`.
- `AppContent contained` centres the content at the 1200px content width.
- The sidebar and the components are client components. `AppShell`, `AppMain`, `AppHeader*`, `AppContent` and `AppFooter` are plain layout elements.

### 9. Use components

```tsx
import { Button, Field, FieldGroup, Input, toast } from "@aeros-core/react";

<FieldGroup>
  <Field label="Company" hint="As registered" required>
    <Input placeholder="Aeros Pvt Ltd" />
  </Field>
  <Button onClick={() => toast({ title: "Saved", variant: "success" })}>Save</Button>
</FieldGroup>
```

The inventory is in [components.md](./components.md).

### Tokens without React

A web app that does not use the React package can import the tokens alone:

```css
@import "tailwindcss";
@import "@aeros-core/tokens/css";
@import "@aeros-core/tokens/theme.css";
```

Or only `@aeros-core/tokens/css` for the custom properties with no Tailwind. In JavaScript, `import { tokens, rawTokens } from "@aeros-core/tokens"` gives the resolved values and the tree as authored.

## Mobile (Flutter)

Requirements: Dart SDK 3.3 or later, Flutter 3.19 or later.

### 1. Pin the package by git tag

`aeros_design_system` is `publish_to: none`. Pin it by tag in the app's `pubspec.yaml`:

```yaml
dependencies:
  aeros_design_system:
    git:
      url: https://github.com/aeros-core/aeros-design-system.git
      path: packages/flutter
      ref: v3.0.0
```

Then run `flutter pub get`. The package has no runtime dependencies besides Flutter. Inter, IBM Plex Mono and the wordmark face are bundled, so there is no font download at run time.

### 2. Theme: `AerosTheme`

```dart
import 'package:flutter/material.dart';
import 'package:aeros_design_system/aeros_design_system.dart';

void main() => runApp(MaterialApp(
      theme: AerosTheme.light(),
      darkTheme: AerosTheme.dark(),
      themeMode: ThemeMode.system,
      home: const HomeScreen(),
    ));
```

Read theme values from the build context:

```dart
final colors = context.aerosColors;     // AerosAliasColors: bgSurface, fgPrimary, borderDefault …
final status = context.aerosSemantic;   // AerosSemanticColors: dangerText, successBg …
final shadows = context.aerosElevation; // AerosElevation: raised, overlay, modal
```

`AerosTheme` turns off Material's ripple and hover tint for the whole app, including the app's own `InkWell`s.

### 3. Density: `AerosDensityScope`

With no scope, everything is touch density. Wrap desktop and web surfaces in a pointer scope:

```dart
AerosDensityScope(
  density: AerosDensity.pointer, // mouse and trackpad
  child: child,
)
```

Rule: pointer on desktop web, touch on phones and tablets. `AerosDensity.of(context).sizes` gives the size tokens for the ambient density. A control's tappable box is at least 24 at pointer and 48 at touch.

To set a default control size for a subtree, use `AerosControlSizeScope(size: AerosControlSize.sm, child: …)`.

### 4. The app shell

```dart
AerosScaffold(
  topnav: const AerosTopnav(title: 'Orders'),
  sidenav: AerosSidenav(
    header: const AerosSidenavHeader(title: 'Aeros'),
    items: [
      AerosNavItem(label: 'Orders', icon: Icons.receipt_long, selected: true, count: 4, onTap: () {}),
      AerosNavItem(label: 'Catalog', icon: Icons.inventory_2, children: [
        AerosNavItem(label: 'Items', onTap: () {}),
      ]),
    ],
    footer: const AerosSidenavFooter(name: 'Signed-in user'),
  ),
  body: body,
)
```

The viewport width picks the presentation, the same three as on the web (full design: `docs/sidebar/spec.md`):

- below `md` (768): a drawer at touch sizes. It closes when a destination is chosen.
- `md` to `lg`: the 56px icon rail. The top bar's button floats the full sidenav over the page; it closes on a tap outside, Escape, or choosing a destination. `railBreakpoint` moves the upper bound.
- `lg` (1024) and up: 240 wide, collapsible to the rail.

Icons, the header mark and the footer avatar sit 28px from the edge in every state, and the width change is animated. In the rail a row shows its name beside it on hover or keyboard focus, a count becomes a dot, and a parent opens its children in a menu.

Give the scaffold an `AerosSidebarController` and it owns and remembers the wide-window choice. The package has no storage of its own, so plug yours in:

```dart
final sidebar = AerosSidebarController(
  load: () => prefs.getBool('sidebar.collapsed'),
  save: (collapsed) => prefs.setBool('sidebar.collapsed', collapsed),
);

AerosScaffold(sidebarController: sidebar, topnav: …, sidenav: …, body: …)
```

Cmd/Ctrl+B toggles the sidenav, except while typing in a text field (`keyboardShortcut: false` turns it off). Without a controller the app still owns the rail through `AerosSidenav(collapsed:)` and `onRailCollapsedChanged`, as before. `AerosNavItem(count:)` is a quiet number; add `countEmphasis: true` for a pill.

### 5. Overlays

Use the package's overlays, not Material's: `AerosDialog.show`, `AerosSheet.show`, `AerosMenu`, `AerosPopover`, `AerosSelect`, `AerosConfirmDialog.show`, `AerosSnackbar.show`.

## Keeping apps up to date with Renovate

Put this `renovate.json` in each consuming repo. It groups the two npm packages into one pull request and bumps the Flutter git `ref` when a new `v<version>` tag appears.

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

Design-system releases are visual. Review each bump and look at the app before merging; do not auto-merge. A major version, such as 2.x to 3.0, needs the steps in [migration.md](./migration.md).
