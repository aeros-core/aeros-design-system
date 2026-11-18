"use client";

import * as React from "react";
import {
  Badge,
  Button,
  DataTable,
  FilterChip,
  Input,
  PageHeader,
  Pagination,
  type DataTableColumn,
  type DataTableRowSelectionState,
  type DataTableSortingState,
} from "@aeros-core/react";
import { Download, Plus, Search } from "lucide-react";

const STATUSES = ["Pending", "In QC", "Dispatched", "Rejected"] as const;
type Status = (typeof STATUSES)[number];

interface Order {
  id: string;
  vendor: string;
  city: string;
  units: number;
  value: number;
  due: string;
  dueDay: number;
  status: Status;
  late: boolean;
}

const VENDORS: Array<[vendor: string, city: string]> = [
  ["Trimurti Packaging", "Pune"],
  ["Shakti Bearings", "Rajkot"],
  ["Coastal Foods", "Kochi"],
  ["Meridian Logistics", "Mumbai"],
  ["Pacific Pack Co.", "Chennai"],
  ["Northwind Paper", "Delhi"],
  ["Apex Polymers", "Vadodara"],
  ["Sahyadri Cartons", "Nashik"],
];

// Deterministic sample data: no clock, no randomness.
const ORDERS: Order[] = Array.from({ length: 24 }, (_, i) => {
  const [vendor, city] = VENDORS[(i * 3) % VENDORS.length]!;
  const units = (((i * 7) % 12) + 1) * 500;
  const status = STATUSES[(i * 5 + (i % 3)) % STATUSES.length]!;
  const dueDay = 3 + ((i * 11) % 26);
  return {
    id: `PO-${1042 + i}`,
    vendor,
    city,
    units,
    value: units * (9 + ((i * 4) % 13)),
    due: `${String(dueDay).padStart(2, "0")} Aug 2026`,
    dueDay,
    status,
    late: dueDay < 12 && (status === "Pending" || status === "In QC"),
  };
});

const STATUS_VARIANT = { Pending: "warning", "In QC": "info", Dispatched: "success", Rejected: "danger" } as const;

/** Indian digit grouping without a locale lookup, so server and client agree. */
function rupees(n: number): string {
  const s = String(n);
  if (s.length <= 3) return s;
  return `${s.slice(0, -3).replace(/\B(?=(\d{2})+(?!\d))/g, ",")},${s.slice(-3)}`;
}

const COLUMNS: DataTableColumn<Order>[] = [
  { accessorKey: "id", header: "Order", meta: { mono: true, width: "6.5rem" } },
  {
    accessorKey: "vendor",
    header: "Vendor",
    cell: ({ row }) => (
      <span className="block min-w-40">
        <span className="font-medium text-fg-primary">{row.original.vendor}</span>
        <span className="block text-caption text-fg-muted">{row.original.city}</span>
      </span>
    ),
  },
  {
    accessorKey: "units",
    header: "Units",
    meta: { align: "end", mono: true, width: "6rem" },
    cell: ({ row }) => rupees(row.original.units),
  },
  {
    accessorKey: "value",
    header: "Value (₹)",
    meta: { align: "end", mono: true, width: "8rem" },
    cell: ({ row }) => rupees(row.original.value),
  },
  {
    accessorKey: "dueDay",
    header: "Due",
    meta: { mono: true, width: "8rem" },
    cell: ({ row }) => (
      <span className={row.original.late ? "text-warning-text" : undefined}>{row.original.due}</span>
    ),
  },
  {
    accessorKey: "status",
    header: "Status",
    enableSorting: false,
    meta: { width: "8rem" },
    cell: ({ row }) => (
      <Badge variant={STATUS_VARIANT[row.original.status]} dot>
        {row.original.status}
      </Badge>
    ),
  },
];

const PAGE_SIZE = 8;
const LATE_COUNT = ORDERS.filter((order) => order.late).length;
const getRowId = (order: Order) => order.id;
const getRowLabel = (order: Order) => `${order.id}, ${order.vendor}`;

export function OrdersScreen() {
  const [query, setQuery] = React.useState("");
  const [statuses, setStatuses] = React.useState<ReadonlySet<Status>>(new Set());
  const [lateOnly, setLateOnly] = React.useState(false);
  const [sorting, setSorting] = React.useState<DataTableSortingState>([{ id: "dueDay", desc: false }]);
  const [selection, setSelection] = React.useState<DataTableRowSelectionState>({});
  const [page, setPage] = React.useState(1);

  const rows = React.useMemo(() => {
    const needle = query.trim().toLowerCase();
    const filtered = ORDERS.filter(
      (order) =>
        (statuses.size === 0 || statuses.has(order.status)) &&
        (!lateOnly || order.late) &&
        (needle === "" || `${order.id} ${order.vendor} ${order.city}`.toLowerCase().includes(needle))
    );
    const sort = sorting[0];
    if (!sort) return filtered;
    const key = sort.id as keyof Order;
    const direction = sort.desc ? -1 : 1;
    return [...filtered].sort((a, b) => {
      const x = a[key];
      const y = b[key];
      const order = typeof x === "number" && typeof y === "number" ? x - y : String(x).localeCompare(String(y));
      return order * direction || a.id.localeCompare(b.id);
    });
  }, [query, statuses, lateOnly, sorting]);

  const pageCount = Math.max(1, Math.ceil(rows.length / PAGE_SIZE));
  const current = Math.min(page, pageCount);
  const pageRows = rows.slice((current - 1) * PAGE_SIZE, current * PAGE_SIZE);
  const filtered = query !== "" || statuses.size > 0 || lateOnly;
  const selectedCount = Object.values(selection).filter(Boolean).length;

  // Any change to what is listed goes back to the first page.
  const narrow = (change: () => void) => {
    change();
    setPage(1);
  };

  const toggleStatus = (status: Status) =>
    narrow(() =>
      setStatuses((currentSet) => {
        const next = new Set(currentSet);
        if (next.has(status)) next.delete(status);
        else next.add(status);
        return next;
      })
    );

  const reset = () =>
    narrow(() => {
      setQuery("");
      setStatuses(new Set());
      setLateOnly(false);
    });

  return (
    <div className="grid min-w-0 gap-4">
      <PageHeader
        as="h2"
        title="Orders"
        description={`${ORDERS.length} purchase orders raised by your buyers.`}
        actions={
          <>
            <Button variant="secondary" leadingIcon={<Download />}>
              Export
            </Button>
            <Button leadingIcon={<Plus />}>New order</Button>
          </>
        }
      />

      <div className="flex flex-wrap items-center gap-2">
        <Input
          aria-label="Search orders"
          prefix={<Search />}
          placeholder="Search by order, vendor or city"
          value={query}
          onChange={(event) => narrow(() => setQuery(event.target.value))}
          containerClassName="w-full sm:w-72"
        />
        <div role="group" aria-label="Filter by status" className="flex flex-wrap items-center gap-2">
          {STATUSES.map((status) => (
            <FilterChip
              key={status}
              label={status}
              active={statuses.has(status)}
              aria-pressed={statuses.has(status)}
              onClick={() => toggleStatus(status)}
            />
          ))}
          <FilterChip
            label="Late"
            tone="warning"
            count={LATE_COUNT}
            active={lateOnly}
            aria-pressed={lateOnly}
            onClick={() => narrow(() => setLateOnly((value) => !value))}
          />
        </div>
        {filtered && (
          <Button variant="ghost" size="sm" onClick={reset}>
            Clear filters
          </Button>
        )}
      </div>

      <DataTable
        aria-label="Orders"
        columns={COLUMNS}
        data={pageRows}
        getRowId={getRowId}
        getRowLabel={getRowLabel}
        selectable
        rowSelection={selection}
        onRowSelectionChange={setSelection}
        sorting={sorting}
        onSortingChange={setSorting}
        manualSorting
        emptyState="No orders match the current filters."
        selectionActions={(selected) => (
          <>
            <Button variant="secondary" size="sm">
              Export {selected.length}
            </Button>
            <Button variant="danger-subtle" size="sm">
              Reject
            </Button>
          </>
        )}
      />

      <div className="flex flex-wrap items-center justify-between gap-3">
        <span className="text-body-sm text-fg-muted" aria-live="polite">
          {rows.length === 0
            ? "No orders"
            : `Showing ${(current - 1) * PAGE_SIZE + 1}–${(current - 1) * PAGE_SIZE + pageRows.length} of ${rows.length}`}
          {selectedCount > 0 && ` · ${selectedCount} selected`}
        </span>
        <Pagination page={current} count={pageCount} onPageChange={setPage} />
      </div>
    </div>
  );
}
