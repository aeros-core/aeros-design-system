# @aeros-core/react

The Aeros React components: Radix primitives, Tailwind v4, class-variance-authority. Built for Next.js; the published bundle carries `"use client"`.

Peer dependencies: React 18.2 or 19, Tailwind CSS 4.

## Install

The package is on GitHub Packages. Auth setup is in [docs/consuming.md](../../docs/consuming.md).

```bash
pnpm add @aeros-core/react @aeros-core/tokens
```

## CSS

```css
/* app/globals.css */
@import "@aeros-core/react/styles.css"; /* Tailwind, the tokens, the Aeros theme, base styles */
@import "@aeros-core/react/fonts.css";  /* optional: self-hosted Inter, Nunito Sans, IBM Plex Mono */
```

- `styles.css` does not load fonts. Import `fonts.css`, or load the faces yourself.
- The theme resets Tailwind's default palette, radii, shadows, easings and font families. Use the alias and token classes: `bg-bg-surface`, `text-fg-muted`, `border-border-default`, `rounded-control`, `shadow-overlay`, `text-body-sm`.
- Theme with `data-theme="light" | "dark" | "system"` on `<html>` or any element. Touch sizes with `data-density="touch"`.

## A minimal example

```tsx
// app/layout.tsx
import "./globals.css";
import {
  AppShell, AppMain, AppHeader, AppHeaderTitle, AppContent,
  Sidebar, SidebarProvider, SidebarHeader, SidebarBrand, SidebarContent,
  SidebarSection, SidebarItem, SidebarTrigger, Toaster
} from "@aeros-core/react";

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en" data-theme="light">
      <body>
        <SidebarProvider storageKey="app.sidebar">
          <AppShell>
            <Sidebar>
              <SidebarHeader>
                <SidebarBrand mark="A" name="Aeros" />
              </SidebarHeader>
              <SidebarContent>
                <SidebarSection label="Workspace">
                  <SidebarItem href="/orders" active>Orders</SidebarItem>
                  <SidebarItem href="/catalog">Catalog</SidebarItem>
                </SidebarSection>
              </SidebarContent>
            </Sidebar>
            <AppMain>
              <AppHeader>
                <SidebarTrigger />
                <AppHeaderTitle>Orders</AppHeaderTitle>
              </AppHeader>
              <AppContent>{children}</AppContent>
            </AppMain>
          </AppShell>
        </SidebarProvider>
        <Toaster />
      </body>
    </html>
  );
}
```

```tsx
"use client";
import { Button, Field, FieldGroup, Input, toast } from "@aeros-core/react";

export function CompanyForm() {
  return (
    <FieldGroup>
      <Field label="Company" hint="As registered" required>
        <Input placeholder="Aeros Pvt Ltd" />
      </Field>
      <Button onClick={() => toast({ title: "Saved", variant: "success" })}>Save</Button>
    </FieldGroup>
  );
}
```

- `Field` wires label, hint and error to its control. It has no margin; `FieldGroup` stacks fields.
- Variants are named by intent: `success`, `warning`, `danger`, `info`, `neutral`, `inverse`.
- `Toaster` is mounted once; `toast()` is called from anywhere.

The full inventory is in [docs/components.md](../../docs/components.md). Upgrading from 2.x: [docs/migration.md](../../docs/migration.md).

## Contributing

**Components compose recipes; they do not restate styles.** [`src/internal/recipes.ts`](./src/internal/recipes.ts) is the single definition of control sizing, the field look, floating surfaces, menu rows and modal parts. It is not exported.

- Use a recipe when one exists. If two components need the same classes, move them into `recipes.ts`.
- Token classes only: alias colours, `text-<role>`, `rounded-item|control|surface|modal|pill`, `shadow-raised|overlay|modal`, `h-control-<size>`, `duration-<name>`, `ease-<name>`, `z-<layer>`. No hex, no arbitrary values, no Tailwind default palette or scale steps. `pnpm check:hardcoded` enforces this.
- State changes are colour only: `transition-colors duration-fast ease-standard`. Nothing lifts or scales.
- Do not draw a focus ring. The global `:focus-visible` outline in `styles.css` is the ring; move it with `focus-ring-field` or `focus-ring-inset` if needed.
- A resting surface has a hairline border and no shadow. A floating layer has an elevation and no border class.
- Merge classes with `cn()`. Forward refs and spread remaining props.
- A new component needs: an export in `src/index.ts`, a test, a fixture in `packages/react-docs`, a row in `docs/components.md`, and a changeset.

## Test

```bash
pnpm build   # tsup, the "use client" guard, declarations
pnpm test    # vitest, Testing Library, jest-axe
pnpm lint    # eslint with jsx-a11y
```

From the repository root:

```bash
pnpm check:hardcoded   # src uses tokens only
pnpm test:visual       # Playwright screenshots of every fixture
pnpm test:a11y         # axe on every fixture, light and dark
```

Screenshot baselines are generated on Linux in CI, never on a developer machine. See [docs/releasing.md](../../docs/releasing.md#image-baselines).
