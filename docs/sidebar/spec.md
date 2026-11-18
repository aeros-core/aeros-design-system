# The Aeros sidebar

Status: design approved 2026-11-18. Built in React (`packages/react/src/components/sidebar.tsx`) and Flutter (`aeros_sidenav.dart`, `aeros_scaffold.dart`, `aeros_sidebar_controller.dart`).
Prototype: [`prototype.html`](prototype.html) (open it in a browser; every state described here is live in it).

One sidebar for every Aeros app, on React/Next.js and Flutter, on phones, iPads and desktops. It keeps the skeleton both packages already ship (240 / 56 / 280, hairline, monochrome) and finishes it: a tablet mode, a remembered user toggle, icons that never move, and the same behaviour on both platforms.

## 1. Why

A survey of the apps on 2026-11-18 found:

- Nine different sidebar widths (220 to 300px, and one flex ratio), five active-row styles, three phone patterns.
- One app collapses at all (Personal OS), by screen width only. No app lets the user collapse the sidebar and remembers it.
- The marketplace keeps two hand-synced nav lists (web rail and phone drawer) that have drifted in production.
- Two web apps still use retired Royal Blue; several render "Aeros" as plain text.
- The design-system components exist on both platforms but differ: React has persistence, a shortcut and animation; Flutter has none of the three. Neither has a tablet mode.

## 2. Research that shaped it

| Source | What it says | What we took |
|---|---|---|
| Material 3 window size classes | Under 600 a bar or modal drawer; 600 to 840 a rail; larger, a permanent drawer. M3 Expressive replaces the drawer with an expanding rail. | Three presentations of one component; the rail and the full sidebar are the same object. |
| Apple HIG, sidebars and tab bars | iPad favours a sidebar that can collapse; avoid hiding destinations behind "More". | iPad gets the real sidebar, never a reduced tab set. |
| shadcn/ui Sidebar | `icon` and `offcanvas` collapse modes, ⌘B, state in a cookie so server render matches, a sheet on mobile, tooltips only in the rail. | Cookie persistence, the shortcut, tooltips only when collapsed. |
| Sidebar UX write-ups and component specs | Expanded 240 to 280, collapsed 48 to 64. Icon rails need tooltips on hover and focus, plus a clear active mark. Hover-to-expand is a library feature, not a recommended practice. | Keep 240 / 56. No hover-to-expand. |

## 3. One tree, three presentations

| Window width | Presentation | Starts as | The toggle |
|---|---|---|---|
| under 768 (`md`) | **Drawer**, 280px, capped at viewport minus 56. Slides over the page with a scrim. | closed | opens / closes |
| 768 to 1023 | **Rail**, 56px, in the layout. | rail | expands to 240 as a **floating** panel over the page. The page does not reflow. Closes on click outside, Esc, or choosing a page. |
| 1024 (`lg`) and up | **Expanded**, 240px, in the layout. | expanded | collapses to the 56px rail; the page reflows; the choice is remembered. |

- Widths are the existing tokens `layout.sidebar` (240), `layout.sidebar-rail` (56), `layout.sidebar-mobile` (280). No new tokens are required.
- Apps declare **one** destination list. The component decides how to present it. This is what removes the marketplace twin-list bug.
- In Flutter the width comes from `AerosViewportScope` or `MediaQuery`, as today, so a native iPad gets the rail or the full sidebar instead of the phone drawer.

## 4. Anatomy

Top to bottom:

1. **Header** (`size.header`: 48 pointer, 56 touch; hairline below). A 24px mark, the product name, and one optional line under it (organisation or section). When it switches organisation it is a button with a chevron pair. The literal word "Aeros" always uses the wordmark (`aeros-logo` / `AerosWordmark`). In the rail only the mark remains.
2. **Search row** (optional). A normal row: search icon, "Search", `⌘K` hint.
3. **Navigation** (scrolls). An unlabelled first group, then labelled sections.
4. **Pinned group** (optional, hairline above). Settings, Help. Does not scroll away.
5. **Footer** (min `size.header`; hairline above). 24px avatar, name, one line (email, role or balance). Opens the account menu. In the rail only the avatar remains.

Surface: `bg-surface` with a 1px `border-default` hairline on the content side, no shadow, per the resting-surface rule. Only the floating tablet panel and the phone drawer take `elevation.overlay`.

## 5. Measurements

| | Pointer | Touch | Token |
|---|---|---|---|
| Row height | 32 | 48 | `size.nav-row` |
| Icon | 16 | 20 | `size.nav-icon` |
| Label | 13 / weight 500 | 14 / weight 500 | `size.nav-label` |
| Header and footer height | 48 | 56 | `size.header` |
| Row radius | 4 | 4 | `shape.item` |
| Sidebar inner padding | 8 | 8 | `space.2` |
| Gap between rows | 2 | 2 | `space.0.5` |
| Icon to label gap | 10 | 10 | `space.2.5` |
| Section label | 12, `fg-muted`, sentence case, 28px block with 8px above | same | `text.caption` |
| Count (quiet) | 12, `fg-muted`, tabular numerals | same | `text.caption` |
| Count (emphasised) | 18px pill, `bg-inverse` / `fg-inverse`, 11px | 20px | `size.badge`, `text.label-xs` |

**The 28px rule.** The centre of every icon, the mark and the avatar sits 28px from the sidebar's outer edge in every state. 28 is half of the 56px rail, so collapsing never moves an icon: labels fade and the width changes around them. Row left padding is therefore `20px minus half the icon` (12 for a 16px icon, 10 for a 20px icon) inside the 8px sidebar padding.

Sub-items: no icon, weight 450, indented under a 1px `border-default` guide line that sits 20px in. Each further level indents 10px more. Two levels is the design target; a third level works by the same rule and is there for aeros-admin.

## 6. States

| Part | Idle | Hover | Pressed | Current page | Focus |
|---|---|---|---|---|---|
| Row | `fg-secondary`, no fill | `state-hover`, `fg-primary` | `state-pressed` | `state-selected`, `fg-primary` | the global focus ring, inset 2px |
| Sub-row | `fg-secondary`, weight 450 | as row | as row | `state-selected`, `fg-primary`, weight 500 | as row |
| Group holding the current page, in the rail | – | – | – | `state-selected` on the group's icon row | – |
| Header / footer button | no fill | `state-hover` | `state-pressed` | – | as row |
| Edge toggle | invisible | 2px `border-strong` line | – | – | line shown |

- The current page is marked by fill and text colour only. Top-level weight does not change, so labels never reflow. No accent bar, no colour.
- Colour transitions take `duration.quick` (80ms). State is never shown by lift, scale or ripple.
- A disabled row uses `fg-disabled` and takes no hover.

### In the rail

- Labels, counts, chevrons and section labels fade out; a section label is replaced by a 24px hairline in the same 28px block, so rows keep their vertical positions.
- A row with a count shows a 6px dot at the top right of its icon.
- Every row, the header and the footer show a tooltip to the right, with no delay, on hover and on keyboard focus. A count is included: "Messages · 4".
- A group opens a **flyout menu** to the right listing its pages (nested groups appear as labelled, indented runs). It does not force the sidebar open, which is what both platforms do today.
- Sub-items are hidden and removed from the tab order.

## 7. Collapsing

- **One control on every screen:** the trigger at the leading edge of the app header. On phones it shows the menu icon and opens the drawer; elsewhere it shows the panel icon and collapses or expands. This is where `SidebarTrigger` and `AerosTopnav` already put it.
- **Pointer extra:** the sidebar's edge is a 12px-wide click target (6px either side of the hairline).
- **Keyboard:** ⌘B on macOS, Ctrl+B elsewhere. Ignored while focus is in a text field or editable area, where it means Bold.
- **No hover-to-expand.** It fires by accident and has no touch equivalent.
- **Remembered:** only the 1024-and-up choice is stored. Tablets always start as a rail and phones always start closed.
  - Web: written to a cookie and to `localStorage`. A Next.js layout reads the cookie and passes `defaultCollapsed`, so the first paint is already correct. Today the saved rail state flashes expanded first.
  - Flutter: an `AerosSidebarController` with `load` / `save` callbacks. The package stays dependency-free; each app plugs in its own storage.

## 8. Motion

| What | Duration | Easing |
|---|---|---|
| Sidebar width (and page reflow) | `duration.base` 180ms | `ease.standard` |
| Labels out | `duration.quick` 80ms | `ease.standard` |
| Labels in | `duration.fast` 120ms, after a 60ms delay | `ease.standard` |
| Group open / close | 180ms | `ease.standard` |
| Chevron turn | 120ms | `ease.standard` |
| Drawer and scrim in | `duration.slow` 260ms | `ease.enter` |
| Drawer and scrim out | 180ms | `ease.exit` |

With reduced motion on, every one of these is instant.

## 9. Phone and iPad

- The drawer always uses touch sizes, whatever the app's density.
- It has a visible close button at the top right, and also closes on scrim tap, Esc, and choosing a page.
- Focus moves into the drawer when it opens, is trapped while it is open, and returns to the trigger when it closes. The page behind is inert.
- It pads itself by the safe-area insets on all sides.
- Flutter adds edge-swipe to open and swipe to close.
- The sidebar takes an optional top inset for the macOS window buttons (Personal OS needs 22px).

## 10. Accessibility

- `nav` landmark with a label ("Main"); each labelled section is a group named by its label.
- `aria-current="page"` on the current row; `aria-expanded` on groups and on the trigger; `aria-controls` on the trigger.
- Rail rows keep their accessible names; counts are announced with the label.
- Minimum target 24px with a pointer, 48px with touch (`size.min-target`).
- Mirrors in right-to-left: the sidebar sits on the right, chevrons and the flyout direction flip, and the 28px rule is measured from the right edge.
- Colours are existing alias pairs that already pass `check:contrast`.

## 11. What changes in the packages

Both columns are built.

Two differences from this spec in the React build: the row label uses `text-label-sm` (13) and `text-label-md` (14, touch) because `size.nav-label` has no Tailwind utility yet, and labels fade in over 120ms without the 60ms delay (arbitrary delays are not allowed by `check:hardcoded`). The workspace switcher and the account block are one part, `SidebarMenuButton`.

Differences in the Flutter build: the drawer stays Material's `Drawer` (it already has edge-swipe to open and swipe to close) rather than `AerosSheet`; the side tooltip and the rail menu's side placement are private to the sidenav, so `AerosTooltip` and `AerosPopover` are unchanged; labels are covered and revealed by the moving edge instead of fading; an explicit `AerosSidenav(density:)` still wins over the scope, and with neither the rows stay pointer-sized as before. Flutter has no separate edge toggle.

**React** (`packages/react/src/components/sidebar.tsx`, `app-shell.tsx`)

| Today | Becomes |
|---|---|
| One breakpoint (`md`); tablets get the full desktop sidebar | Rail from `md`, floating expand, full sidebar from `lg` |
| State restored from `localStorage` after mount | Cookie plus `localStorage`; server-rendered first paint |
| ⌘B fires while typing | Ignored in fields and editable areas |
| Rail group expands the whole sidebar | Opens a flyout (`DropdownMenu`, side right) |
| Active row `bg-subtle` + semibold | `state-selected`, weight unchanged |
| Label `text-body-sm` | `size.nav-label` (defined in tokens, unused today) |
| Private `CountPill`, always solid | Quiet count by default, exported `CountBadge` for emphasised, dot in the rail |
| No close button in the sheet; no `aria-controls` | Both added |
| Icon position shifts between states | The 28px rule |
| Toggle only via `SidebarTrigger` | Plus the edge target |
| No account or organisation parts | `SidebarSwitcher` and `SidebarAccount` slots built on `DropdownMenu` and `Avatar` |

**Flutter** (`packages/flutter/lib/src/widgets/aeros_sidenav.dart`, `aeros_scaffold.dart`)

| Today | Becomes |
|---|---|
| App holds a `collapsed` bool; nothing saved | `AerosSidebarController` with pluggable storage |
| Width switches instantly | Animated, `AerosMotion.base` / `standard`, zero under reduced motion |
| One 768 threshold | Same three presentations as React |
| Material `Drawer` | `AerosSheet(side: left)` with touch density, auto-close on navigation, safe areas |
| Material `Tooltip`, 260ms wait, default side, label only | `AerosTooltip` to the side, no wait, label and count (needs a side placement added to `AerosTooltip` and `AerosPopover`) |
| Rail parent calls `onExpandRequested` | Flyout via `AerosMenu` |
| Group open state set once | Reopens when the selection moves into it |
| Count hidden in the rail | Dot |
| Density passed separately from `AerosDensityScope` | Read from the scope; the drawer forces touch |
| No shortcut, no nav semantics | ⌘B / Ctrl+B; container and current-page semantics |

Both: a tablet-width case in the tests and visual baselines (neither suite has one today).

## 12. Moving each app over

| App | Today | Note |
|---|---|---|
| Marketplace (Flutter) | DS rail on web, custom drawer on phone and native iPad, two lists | Hardest. One destination list feeds both; needs the DS upgraded from v1.3.6. The guest frame and promo card stay app-level slots. |
| aeros-admin (Flutter web) | DS sidenav, three levels, flex width, no mobile | Fixed 240 replaces the flex ratio. Third level works; consider flattening Locations. |
| FactoryOS | Forked drawer widgets, 260 / 280 | Delete the forks. The org switcher moves to the header; the duplicate org pill in the top bar goes. |
| Personal OS | Custom sidebar, 220 / 64, width-driven rail, bottom tabs | Gains the user toggle. Bottom tabs: see open questions. |
| Socials, Agent Home | DS sidenav at 256, bottom tabs on phones | Width to 240. Bottom tabs: see open questions. |
| WMS | Material `ListTile` shell | Straight swap. |
| Wedding (Next.js) | Custom, Royal Blue, hidden on phones | Straight swap; fixes the brand break and adds phone navigation. |
| Seller admin editor rail, Mind Maps notes panel | Tool and content panels | Not app navigation. Out of scope. |

## 13. Open questions

1. **Bottom tab bars.** Socials, Personal OS, Agent Home and HR use bottom tabs on phones. This design uses the drawer on phones everywhere. Either those apps move to the drawer, or the design system later adds a bottom bar driven by the same destination list (primary items plus More).
2. **Surface colour.** The sidebar is `bg-surface` (white in light theme) to match the resting-surface rule. A `bg-canvas` sidebar beside a white page is a common alternative and would be a one-token change.
3. **Hover flyouts.** Rail flyouts open on click. Opening on hover is faster with a mouse but adds accidental opens.
4. **Not checked in the prototype:** right-to-left, real safe-area insets on a device, and swipe gestures. These are specified here but only the Flutter build can prove them.
