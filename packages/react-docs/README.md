# @aeros-core/react-docs

Live playground for `@aeros-core/react`. One Next.js app that renders every component with its props, on a single scrollable page — the React equivalent of the repo's `index.html` reference kit.

## Run it

```bash
# from the monorepo root
pnpm install
pnpm --filter @aeros-core/tokens build
pnpm --filter @aeros-core/react build
pnpm --filter @aeros-core/react-docs dev
```

Opens at **http://localhost:3000**.

## What you'll see

- Black sidebar navigation matching the new palette
- Every React component: Button, Input/Field, Textarea, Checkbox, RadioGroup, Switch, Badge, Tag, Card, StatCard, Alert, Progress, Avatar, AvatarStack, Tabs (underline + pill), Breadcrumb, DropdownMenu, Dialog, Tooltip, Table, EmptyState, TopNav, Sidebar
- Light theme by default (`data-theme="light"` on `<html>`)

## Extend it

Just edit [`app/page.tsx`](./app/page.tsx). Add a new `<Section>` and drop components inside. Hot-reload works.

## Dark mode

Toggle the theme by setting `data-theme="dark"` on `<html>`. A dev-mode theme switcher can be added later — the tokens are already there.
