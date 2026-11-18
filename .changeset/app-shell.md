---
"@aeros-core/react": major
---

**3.0 — the app shell.** The sidebar and header follow the theme (they were permanently dark) and are built for real app frames.

- **Sidebar:** `SidebarProvider` + `useSidebar` (rail state, optional `storageKey` persistence, Cmd/Ctrl+B), a 56px icon rail with tooltips, one level of nesting (`SidebarGroup` / `SidebarSubItem`), and a left sheet at touch density below the `md` breakpoint. New parts: `SidebarHeader`, `SidebarContent`, `SidebarFooter`, `SidebarTrigger`. Width is 240 (was 228).
- **Shell:** `AppShell`, `AppMain`, `AppHeader` (48px, full width, hairline), `AppHeaderBrand`, `AppHeaderTitle`, `AppHeaderNav`, `AppHeaderLink`, `AppHeaderActions`, `AppContent`, `AppFooter`.
- **Breaking:** `TopNav` → `AppHeader`, `TopNavBrand` → `AppHeaderBrand`, `TopNavLinks` → `AppHeaderNav`, `TopNavLink` → `AppHeaderLink`, `TopNavRight` → `AppHeaderActions`. The header is no longer a rounded dark bar.
- **Breaking:** put `SidebarBrand` inside `SidebarHeader` and the sections inside `SidebarContent`. For dark chrome in a light app, theme the subtree: `<Sidebar data-theme="dark">`.
- Fixed: `SidebarItem asChild` threw, so a framework `<Link>` could not be used as a row.
