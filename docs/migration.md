# Migration

## 1.x → 2.0.0 (2026-08 audit release)

One coordinated major across `@aeros-core/tokens`, `@aeros-core/react`, and `aeros_design_system` (Flutter). Versions are lockstep from 2.0.0 on.

### Variant renames (both platforms)

Color-word variants renamed to intent — the old names advertised colors the monochrome system doesn't have (`blue` rendered grey):

| Component | Old | New |
|---|---|---|
| Badge / AerosBadge | `green` / `amber` / `red` / `blue` / `grey` / `dark` | `success` / `warning` / `danger` / `info` / `neutral` / `inverse` |
| Alert / AerosAlert | `blue` / `green` / `amber` / `red` | `info` / `success` / `warning` / `danger` |
| Tag / AerosTag | `blue` / `grey` / `dark` | `info` / `neutral` / `inverse` |
| Avatar | `tone="ink|dark|royal|green|amber"` | `variant="neutral|inverse|info|success|warning"` |
| Progress | `color="royal|success|warning|danger"` | `variant="brand|success|warning|danger"` |
| Button | `variant="dark"` | removed — use `primary` (they were identical) |

### Tokens

- `royal-*` and `slate-*` ramps deleted — use `ink-*` (they were byte-identical copies).
- `accent` / `accent-muted` aliases removed (nothing consumed them).
- `warning` base is `#CC6D04` (was `#D97706`, which failed WCAG 3:1 on the warning chip).
- Status colors and shadows now flip in dark mode (`semanticDark` / `shadowDark`); if you hardcoded light status hexes, switch to the `success-*` / `warning-*` / … classes (web) or `context.aerosSemantic` (Flutter).
- Breakpoints unified to 640/768/1024/1280/1536 on both platforms. Flutter's old 600/900/1200/1600 scale is gone; `AerosBreakpoint.xxl` added, and desktop switches keyed off `md = 900` now fire at 768.

### Web behavior changes

- `Field` now auto-generates ids and wires `aria-describedby` / `aria-invalid` — remove manual `htmlFor`/`id` pairs unless you need a specific id.
- `Alert` defaults to `role="status"`; pass `role="alert"` explicitly if you need assertive announcement outside the `danger` variant.
- `SidebarItem` / `TopNavLink` render a `<button>` when no `href` is given, and accept `asChild` for framework `<Link>`s.
- Form controls (`Input`, `Textarea`, `SelectTrigger`) accept `size="sm|md|lg"`; disabled opacity unified at 40%.

### Flutter behavior changes

- `AerosTypography` role styles inherit the ambient color unless `color:` is passed (no more hardcoded light defaults).
- `AerosCheckbox` / `AerosRadio` / `AerosSwitch` default to padded 48dp touch targets; pass `compact: true` for the old dense layout.
- `AerosSeverityPalette.of(severity, isDark: context.aeros.isDark)` for dark-correct severity chips.

---

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
