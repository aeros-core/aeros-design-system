---
"@aeros-core/tokens": minor
"@aeros-core/react": minor
---

2.2.0 — the sidebar spec, shared by web and Flutter.

**Sidebar (react)**: rows are a fixed 32px (`h-8`) with 16px icons; `SidebarSection` labels are sentence case, 12px medium (were 10px uppercase tracked); `SidebarItem` gains `count`, a pill announced with the label. The dark chrome is unchanged.

Flutter `AerosSidenav` moves to the same spec in this release (see `packages/flutter/CHANGELOG.md`).
