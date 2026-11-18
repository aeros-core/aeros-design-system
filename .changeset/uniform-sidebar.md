---
"@aeros-core/react": minor
---

Sidebar: the uniform design from `docs/sidebar/spec.md`.

- Between the `md` and `lg` breakpoints the sidebar is now a 56px rail; `SidebarTrigger` floats the full sidebar over the page. From `lg` it is expanded as before.
- Icons sit 28px from the edge in every state, so collapsing no longer moves them. Labels fade instead of being removed.
- In the rail a `SidebarGroup` opens its children in a menu instead of expanding the sidebar, and a count shows as a dot.
- `storageKey` also writes a cookie, so a server render can pass `defaultCollapsed` and paint the remembered state first.
- Cmd/Ctrl+B is ignored while typing in a field. The mobile sheet has a close button. `SidebarTrigger` sets `aria-controls`.
- New: `SidebarMenuButton`, `SidebarItem` `countTone` and `trailing`, `Sidebar` `edgeToggle`, nested `SidebarGroup`, and `rail`, `isTablet`, `floating`, `dismiss` on `useSidebar()`.

Visual changes to check: the current row uses `state-selected` at normal weight (was `bg-subtle` + semibold); counts are a quiet number unless `countTone="solid"`; `SidebarHeader` and `SidebarFooter` padding is 8px (was 12px); the `<nav>` now sits inside a positioning wrapper, so layout classes passed to `Sidebar` (width, `sticky`, `hidden`) no longer affect the column.
