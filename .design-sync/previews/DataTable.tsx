import * as React from "react";
import {
  Badge,
  Button,
  DataTable,
  type DataTableColumn,
  type DataTableRowSelectionState,
  type DataTableSortingState,
} from "@aeros-core/react";

interface Order {
  id: string;
  vendor: string;
  city: string;
  units: number;
  value: number;
  status: "Dispatched" | "In QC" | "Pending" | "Rejected";
}

const orders: Order[] = [
  { id: "PO-1042", vendor: "Trimurti Packaging", city: "Pune", units: 12000, value: 124000, status: "Dispatched" },
  { id: "PO-1043", vendor: "Shakti Bearings", city: "Rajkot", units: 850, value: 68500, status: "In QC" },
  { id: "PO-1044", vendor: "Coastal Foods", city: "Kochi", units: 4200, value: 210000, status: "Pending" },
  { id: "PO-1045", vendor: "Meridian Logistics", city: "Mumbai", units: 60, value: 9200, status: "Rejected" },
  { id: "PO-1046", vendor: "Pacific Pack Co.", city: "Chennai", units: 7500, value: 41000, status: "Dispatched" },
  { id: "PO-1047", vendor: "Northwind Paper", city: "Delhi", units: 30000, value: 186000, status: "Pending" },
  { id: "PO-1048", vendor: "Apex Polymers", city: "Vadodara", units: 1600, value: 73250, status: "In QC" },
];

const statusVariant = { Dispatched: "success", "In QC": "info", Pending: "warning", Rejected: "danger" } as const;
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
  { accessorKey: "units", header: "Units", meta: { align: "end", mono: true, width: "7rem" }, cell: ({ row }) => grouped(row.original.units) },
  { accessorKey: "value", header: "Value (₹)", meta: { align: "end", mono: true, width: "9rem" }, cell: ({ row }) => grouped(row.original.value) },
];

const getRowId = (order: Order) => order.id;

export const SortedOrders = () => {
  const [sorting, setSorting] = React.useState<DataTableSortingState>([{ id: "vendor", desc: false }]);
  return (
    <DataTable aria-label="Orders" columns={columns} data={orders.slice(0, 5)} getRowId={getRowId} sorting={sorting} onSortingChange={setSorting} />
  );
};

export const SelectableWithActions = () => {
  const [rowSelection, setRowSelection] = React.useState<DataTableRowSelectionState>({ "PO-1043": true, "PO-1045": true });
  return (
    <DataTable
      aria-label="Orders, selectable"
      columns={columns}
      data={orders.slice(0, 5)}
      getRowId={getRowId}
      getRowLabel={(order) => `${order.id}, ${order.vendor}`}
      selectable
      rowSelection={rowSelection}
      onRowSelectionChange={setRowSelection}
      selectionActions={(rows) => (
        <>
          <Button variant="secondary" size="sm">Export {rows.length}</Button>
          <Button variant="danger-subtle" size="sm">Reject</Button>
        </>
      )}
    />
  );
};

export const CompactPaginated = () => (
  <DataTable aria-label="Order quantities" columns={numericColumns} data={orders} getRowId={getRowId} density="compact" pageSize={4} />
);

export const LoadingAndEmpty = () => (
  <div style={{ display: "grid", gap: 24 }}>
    <DataTable aria-label="Orders, loading" columns={columns} data={[]} loading />
    <DataTable aria-label="Orders, empty" columns={columns} data={[]} emptyState="No orders match the current filters." />
  </div>
);
