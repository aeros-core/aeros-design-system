"use client";

import * as React from "react";
import {
  Badge,
  Button,
  DataTable,
  type DataTableColumn,
  type DataTableRowSelectionState,
  type DataTableSortingState,
} from "@aeros-core/react";
import { Group } from "./kit";

interface Order {
  id: string;
  vendor: string;
  city: string;
  units: number;
  value: number;
  status: "Dispatched" | "In QC" | "Pending" | "Rejected";
}

// Deterministic: fixed records, no dates, no randomness.
const orders: Order[] = [
  { id: "PO-1042", vendor: "Trimurti Packaging", city: "Pune", units: 12000, value: 124000, status: "Dispatched" },
  { id: "PO-1043", vendor: "Shakti Bearings", city: "Rajkot", units: 850, value: 68500, status: "In QC" },
  { id: "PO-1044", vendor: "Coastal Foods", city: "Kochi", units: 4200, value: 210000, status: "Pending" },
  { id: "PO-1045", vendor: "Meridian Logistics", city: "Mumbai", units: 60, value: 9200, status: "Rejected" },
  { id: "PO-1046", vendor: "Pacific Pack Co.", city: "Chennai", units: 7500, value: 41000, status: "Dispatched" },
  { id: "PO-1047", vendor: "Northwind Paper", city: "Delhi", units: 30000, value: 186000, status: "Pending" },
  { id: "PO-1048", vendor: "Apex Polymers", city: "Vadodara", units: 1600, value: 73250, status: "In QC" },
  { id: "PO-1049", vendor: "Sahyadri Cartons", city: "Nashik", units: 9800, value: 55400, status: "Dispatched" },
];

const statusVariant = {
  Dispatched: "success",
  "In QC": "info",
  Pending: "warning",
  Rejected: "danger",
} as const;

// A fixed formatter (no locale lookup), so screenshots match on every machine.
const grouped = (n: number) => String(n).replace(/\B(?=(\d{3})+(?!\d))/g, ",");

const columns: DataTableColumn<Order>[] = [
  { accessorKey: "id", header: "Order", meta: { mono: true, width: "7rem" } },
  { accessorKey: "vendor", header: "Vendor" },
  { accessorKey: "city", header: "City" },
  {
    accessorKey: "status",
    header: "Status",
    enableSorting: false,
    cell: ({ row }) => (
      <Badge variant={statusVariant[row.original.status]} dot>
        {row.original.status}
      </Badge>
    ),
  },
];

const numericColumns: DataTableColumn<Order>[] = [
  { accessorKey: "id", header: "Order", meta: { mono: true, width: "7rem" } },
  { accessorKey: "vendor", header: "Vendor" },
  {
    accessorKey: "units",
    header: "Units",
    meta: { align: "end", mono: true, width: "7rem" },
    cell: ({ row }) => grouped(row.original.units),
  },
  {
    accessorKey: "value",
    header: "Value (₹)",
    meta: { align: "end", mono: true, width: "9rem" },
    cell: ({ row }) => grouped(row.original.value),
  },
];

const getRowId = (order: Order) => order.id;
const getRowLabel = (order: Order) => `${order.id}, ${order.vendor}`;

export default function DataTableFixture() {
  const [sorting, setSorting] = React.useState<DataTableSortingState>([{ id: "vendor", desc: false }]);
  const [rowSelection, setRowSelection] = React.useState<DataTableRowSelectionState>({
    "PO-1043": true,
    "PO-1045": true,
  });

  return (
    <>
      <Group label="Default — sorted by vendor, ascending" className="flex-col items-stretch">
        <DataTable
          aria-label="Orders"
          columns={columns}
          data={orders.slice(0, 5)}
          getRowId={getRowId}
          sorting={sorting}
          onSortingChange={setSorting}
        />
      </Group>
      <Group label="Selectable — two rows selected, selection bar" className="flex-col items-stretch">
        <DataTable
          aria-label="Orders, selectable"
          columns={columns}
          data={orders.slice(0, 5)}
          getRowId={getRowId}
          getRowLabel={getRowLabel}
          selectable
          rowSelection={rowSelection}
          onRowSelectionChange={setRowSelection}
          selectionActions={(rows) => (
            <>
              <Button variant="secondary" size="sm">
                Export {rows.length}
              </Button>
              <Button variant="danger-subtle" size="sm">
                Reject
              </Button>
            </>
          )}
        />
      </Group>
      <Group label="Compact density — mono numeric columns, end-aligned" className="flex-col items-stretch">
        <DataTable
          aria-label="Order quantities"
          columns={numericColumns}
          data={orders.slice(0, 6)}
          getRowId={getRowId}
          density="compact"
        />
      </Group>
      <Group label="Loading" className="flex-col items-stretch">
        <DataTable aria-label="Orders, loading" columns={columns} data={[]} loading />
      </Group>
      <Group label="Empty" className="flex-col items-stretch">
        <DataTable
          aria-label="Orders, empty"
          columns={columns}
          data={[]}
          emptyState="No orders match the current filters."
        />
      </Group>
      <Group label="Paginated — 3 per page" className="flex-col items-stretch">
        <DataTable
          aria-label="Orders, paginated"
          columns={numericColumns}
          data={orders}
          getRowId={getRowId}
          pageSize={3}
        />
      </Group>
    </>
  );
}
