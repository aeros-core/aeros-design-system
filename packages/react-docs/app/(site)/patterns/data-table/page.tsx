import type { Metadata } from "next";
import { CodeBlock } from "../../../_site/code-block";
import { Code, Demo, PageIntro, Section } from "../../../_site/prose";
import { OrdersScreen } from "./orders-screen";

export const metadata: Metadata = { title: "Data table screen" };

const COMPOSITION = `<PageHeader
  title="Orders"
  description="Purchase orders raised by your buyers."
  actions={<Button leadingIcon={<Plus />}>New order</Button>}
/>

<div className="flex flex-wrap items-center gap-2">
  <Input aria-label="Search orders" prefix={<Search />} value={query} onChange={…} />
  {STATUSES.map((status) => (
    <FilterChip key={status} label={status} active={filter.has(status)} onClick={() => toggle(status)} />
  ))}
  <FilterChip label="Late" tone="warning" count={lateCount} active={lateOnly} onClick={toggleLate} />
</div>

<DataTable
  aria-label="Orders"
  columns={columns}          // module scope — keep the array stable
  data={pageRows}            // already filtered, sorted and sliced
  getRowId={(order) => order.id}
  selectable
  rowSelection={selection}
  onRowSelectionChange={setSelection}
  sorting={sorting}
  onSortingChange={setSorting}
  manualSorting              // the caller (or the server) sorts
  selectionActions={(rows) => <Button size="sm" variant="secondary">Export {rows.length}</Button>}
  emptyState="No orders match the current filters."
/>

<div className="flex flex-wrap items-center justify-between gap-3">
  <span className="text-body-sm text-fg-muted">Showing 1–8 of 24</span>
  <Pagination page={page} count={pageCount} onPageChange={setPage} />
</div>`;

export default function DataTablePatternPage() {
  return (
    <>
      <PageIntro section="Patterns">
        The screen an operator spends the day in: a list of records to search, narrow, sort, select and act on. A
        page header names it and holds the primary action, filter chips narrow it, the data table shows it, and
        pagination sits underneath.
      </PageIntro>

      <Section
        title="Live"
        description="Everything works: search, the status chips, sorting by any header, selection across pages, and paging."
      >
        <Demo>
          <OrdersScreen />
        </Demo>
      </Section>

      <Section
        title="Composition"
        description={
          <>
            Sorting and paging are owned by the screen here (<Code>manualSorting</Code> plus a sliced{" "}
            <Code>data</Code>), which is the shape a server-backed list has. For a small client-side list, drop both
            and pass <Code>pageSize</Code> — the table then sorts and pages by itself.
          </>
        }
      >
        <CodeBlock title="orders-screen.tsx" code={COMPOSITION} />
      </Section>

      <Section title="Rules of thumb">
        <ul className="grid max-w-prose list-disc gap-2 pl-5 text-body-md text-fg-secondary">
          <li>Ids, quantities and amounts are monospaced and amounts are end-aligned, so columns of numbers line up.</li>
          <li>Status is a badge with a dot: the colour reports state and the text says what it is.</li>
          <li>Filters reset the page to 1; selection survives sorting and paging because rows have a stable id.</li>
          <li>The warning tone is for a filter that surfaces a problem. Ordinary filters stay neutral.</li>
        </ul>
      </Section>
    </>
  );
}
