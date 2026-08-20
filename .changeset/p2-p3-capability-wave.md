---
"@aeros-core/tokens": minor
"@aeros-core/react": minor
---

2.1.0 — audit P2/P3: component coverage + institutionalized quality gates.

**New components (react)**: Toast (`Toast*`, `Toaster`, imperative `toast()`), AlertDialog, Popover, Drawer/Sheet (right/left/bottom), Accordion, Pagination, Command/Combobox surface (cmdk), Calendar (react-day-picker, token-styled), Label, Separator, Spinner, Skeleton. Table gains sortable `Th` (`aria-sort`), `selected` rows, and `TableLoadingRow`/`TableEmptyRow`. Dialog/Drawer bodies scroll; overlay enter/exit animations actually run now (`tw-animate-css` — the old `animate-in` classes silently compiled to nothing).

**Tokens**: the Dart emission now includes theme aliases, easing curves, and semantic-dark sets, and is written into the Flutter package as `aeros_tokens.g.dart` — the Flutter token layer aliases it, making hand-drift structurally impossible (CI verifies freshness + completeness).

**Process**: vitest + Testing Library + jest-axe suite (Field ARIA wiring, live-region roles, table semantics, overlay behavior — axe-clean), eslint + jsx-a11y, and a version-lockstep check, all wired into CI.
