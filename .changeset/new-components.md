---
"@aeros-core/react": major
---

**3.0 — new components.**

- **DataTable** — sorting, row selection with a selection bar, density (`compact` / `default` / `comfortable`), sticky header, loading and empty states, client or server pagination, clickable rows. Built on `@tanstack/react-table` v9 and the existing `Table` parts; `createDataTableColumnHelper` gives typed cells.
- **Combobox** and **MultiCombobox** — a select with search (groups, descriptions, clear, async options).
- **DatePicker** and **DateRangePicker** — field-styled triggers over `Calendar`, with min/max, presets and form posting.
- **NumberInput** — keyboard stepping, clamping, precision, unit prefix/suffix.
- **Toggle**, **ToggleGroup**, **SegmentedControl**.
- **Collapsible**, **ScrollArea**, **CountBadge**, **FilterChip**, **Kbd**, **PageHeader**, **FileUpload**, **Stepper**.

Changed: `Tr selected` no longer sets `aria-selected` (invalid on a plain table row) — it sets `data-selected`; `Th` aligns with `text-start`; `TableLoadingRow` takes `statusLabel`.
