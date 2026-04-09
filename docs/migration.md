# Migration — from `index.html` to the packages

The original `index.html` v2 kit is preserved as a visual reference. Here's how its pieces map to the new packages.

| `index.html` | React | Flutter |
|---|---|---|
| `.btn-primary`, `.btn-secondary`, `.btn-ghost`, `.btn-danger`, `.btn-dark` | `<Button variant="…" />` | `AerosButton(variant: …)` |
| `.btn-xs`, `.btn-sm`, `.btn-lg`, `.btn-xl` | `<Button size="…" />` | `AerosButton(size: …)` |
| `.input` + `.input-prefix-icon` + `.input-suffix-action` | `<Input prefix={…} suffix={…} />` | `AerosTextField(prefix: …, suffix: …)` |
| `.field` + `.field-label` + `.field-hint` + `.field-error` | `<Field label … hint … error …>` | `AerosTextField(label, helperText, errorText)` |
| `.badge-green`, `.badge-amber`, etc. | `<Badge variant="green" dot />` | `AerosBadge(tone: …)` |
| `.tag-blue`, `.tag-grey`, `.tag-slate` | `<Tag variant="…" />` | `AerosTag(tone: …)` |
| `.card` + `.card-header` + `.card-body` + `.card-footer` | `<Card><CardHeader>…</CardHeader>…` | `AerosCard(title:, child:, footer:)` |
| `.stat-card` | `<StatCard />` | `AerosStatCard(…)` |
| `.alert-blue`, `.alert-green`, `.alert-amber`, `.alert-red` | `<Alert variant="…" title="…">…` | `AerosAlert(tone: …)` |
| `.progress-*` | `<Progress value={…} color="royal" />` | `AerosProgress(value: …)` |
| `.av` + `.av-stack` | `<Avatar size="md" tone="royal" />`, `<AvatarStack>` | `AerosAvatar(size: …, tone: …)` |
| `.tabs` / `.pill-tabs` | `<Tabs variant="underline|pill">` | `AerosTabs(variant: …)` |
| `.breadcrumb` | `<Breadcrumb items={…} />` | `AerosBreadcrumb(items: …)` |
| `.menu` + `.menu-item` | `DropdownMenu*` (Radix) | Material `PopupMenuButton` |
| `.modal` | `Dialog*` (Radix) | `showDialog` — theme handles styling |
| `.tooltip-body` | `Tooltip*` (Radix) | `Tooltip` — theme handles styling |
| `.table-shell`, `th`, `td`, `.td-mono`, `.td-strong`, `.td-muted` | `Table`, `Thead`, `Th`, `Td`, `TdMono`, `TdStrong`, `TdMuted` | `DataTable` + custom `TextStyle` |
| `.empty` + `.empty-icon` | `<EmptyState icon title description action />` | `AerosEmptyState(icon, title, description, action)` |
| `.topnav` | `<TopNav>` + `<TopNavBrand>` + `<TopNavLinks>` | — |
| `.sidebar` | `<Sidebar>` + `<SidebarBrand>` + `<SidebarSection>` + `<SidebarItem>` | — |

## What changed

- **Dark mode** — new. Every alias token has a dark value. Components use aliases not raw ramps.
- **Focus-visible everywhere** — previously only on inputs. Now global via `styles.css`.
- **Radix primitives** — Dialog, Tabs, Select, Checkbox, Radio, Switch, DropdownMenu, Tooltip, Avatar, Progress are all built on Radix for a11y + keyboard nav.
- **`prefers-reduced-motion`** — respected globally.
- **Button variants** — added `link` variant (no chrome).
- **StatCard delta direction** — formalized `up | down | flat`.
- **Icons** — React uses `lucide-react` (tree-shakeable, consistent stroke). Flutter uses Material icons.

## What the HTML kit still does better (for now)

- The single-file reference shows every component side-by-side. Until we build a React docs app, use it for visual spec lookups.
- The AI card with the gradient side-stripe is not in v1 — port on demand.

## Workflow

1. Find the old class in `index.html`.
2. Look it up in the table above.
3. Use the component. File a missing component issue if it's not listed.
