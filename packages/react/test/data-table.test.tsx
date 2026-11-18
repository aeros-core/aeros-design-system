import * as React from "react";
import { describe, expect, it, vi } from "vitest";
import { render, screen, within } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { axe } from "jest-axe";
import {
  DataTable,
  createDataTableColumnHelper,
  type DataTableColumn,
  type DataTableProps,
  type DataTableRowSelectionState,
  type DataTableSortingState
} from "../src/components/data-table";

// Behaviour + semantics only. No class-name or pixel assertions.

interface Order {
  id: string;
  vendor: string;
  total: number;
  status: string;
}

const orders: Order[] = [
  { id: "o-1", vendor: "Trimurti Packaging", total: 124000, status: "Dispatched" },
  { id: "o-2", vendor: "Coastal Foods", total: 68500, status: "In QC" },
  { id: "o-3", vendor: "Shakti Bearings", total: 210000, status: "Pending" },
  { id: "o-4", vendor: "Meridian Logistics", total: 9200, status: "Dispatched" },
  { id: "o-5", vendor: "Pacific Pack Co.", total: 41000, status: "Pending" }
];

const columns: DataTableColumn<Order>[] = [
  { accessorKey: "vendor", header: "Vendor" },
  { accessorKey: "total", header: "Total", meta: { align: "end", mono: true, width: "8rem" } },
  { accessorKey: "status", header: "Status", enableSorting: false, meta: { align: "center" } }
];

const getRowId = (order: Order) => order.id;
const getRowLabel = (order: Order) => order.vendor;

function Orders(props: Partial<DataTableProps<Order>>) {
  return (
    <DataTable
      aria-label="Orders"
      columns={columns}
      data={orders}
      getRowId={getRowId}
      getRowLabel={getRowLabel}
      {...props}
    />
  );
}

/** Body rows, as the text of their first data cell. */
const vendors = () =>
  screen
    .getAllByRole("row")
    .slice(1)
    .map((row) => within(row).getAllByRole("cell").find((cell) => !within(cell).queryByRole("checkbox"))?.textContent);

const header = (name: string) => screen.getByRole("columnheader", { name });

describe("DataTable — rendering", () => {
  it("renders a named table with a header per column and a row per record", () => {
    render(<Orders />);
    const table = screen.getByRole("table", { name: "Orders" });
    expect(within(table).getAllByRole("columnheader").map((th) => th.textContent)).toEqual([
      "Vendor",
      "Total",
      "Status"
    ]);
    expect(within(table).getAllByRole("row")).toHaveLength(orders.length + 1);
    expect(vendors()).toEqual(orders.map((o) => o.vendor));
    expect(screen.getByRole("cell", { name: "124000" })).toBeInTheDocument();
  });

  it("takes its accessible name from `caption`", () => {
    render(<Orders aria-label={undefined} caption="Open purchase orders" />);
    expect(screen.getByRole("table", { name: "Open purchase orders" })).toBeInTheDocument();
  });

  it("forwards its ref and extra props to the root element", () => {
    const ref = React.createRef<HTMLDivElement>();
    const { container } = render(
      <DataTable ref={ref} data-testid="orders" aria-label="Orders" columns={columns} data={orders} />
    );
    expect(ref.current).toBe(container.firstElementChild);
    expect(ref.current).toHaveAttribute("data-testid", "orders");
  });

  it("renders custom cells and typed columns from the column helper", () => {
    const helper = createDataTableColumnHelper<Order>();
    const typed = helper.columns([
      helper.accessor("vendor", { header: "Vendor" }),
      helper.accessor("total", { header: "Total", cell: (ctx) => `₹${ctx.getValue().toFixed(0)}` })
    ]);
    render(<DataTable aria-label="Orders" columns={typed} data={orders} />);
    expect(screen.getByRole("cell", { name: "₹124000" })).toBeInTheDocument();
  });

  it("column align, width and mono meta keep header and cell semantics", () => {
    render(<Orders />);
    expect(header("Total")).toHaveAttribute("aria-sort", "none");
    expect(header("Status")).not.toHaveAttribute("aria-sort");
    const firstRow = screen.getAllByRole("row")[1];
    expect(within(firstRow).getAllByRole("cell").map((c) => c.textContent)).toEqual([
      "Trimurti Packaging",
      "124000",
      "Dispatched"
    ]);
  });

  it("renders the toolbar with the table instance", () => {
    render(<Orders toolbar={(table) => <span>{table.getRowModel().rows.length} orders</span>} />);
    expect(screen.getByText("5 orders")).toBeInTheDocument();
  });
});

describe("DataTable — sorting", () => {
  it("cycles ascending → descending → unsorted and reports it through aria-sort", async () => {
    const user = userEvent.setup();
    render(<Orders />);
    const sort = () => user.click(within(header("Vendor")).getByRole("button"));
    expect(header("Vendor")).toHaveAttribute("aria-sort", "none");

    await sort();
    expect(header("Vendor")).toHaveAttribute("aria-sort", "ascending");
    expect(vendors()).toEqual([
      "Coastal Foods",
      "Meridian Logistics",
      "Pacific Pack Co.",
      "Shakti Bearings",
      "Trimurti Packaging"
    ]);

    await sort();
    expect(header("Vendor")).toHaveAttribute("aria-sort", "descending");
    expect(vendors()?.[0]).toBe("Trimurti Packaging");

    await sort();
    expect(header("Vendor")).toHaveAttribute("aria-sort", "none");
    expect(vendors()).toEqual(orders.map((o) => o.vendor));
  });

  it("sorts numbers ascending first, and only one column at a time", async () => {
    const user = userEvent.setup();
    render(<Orders />);
    await user.click(within(header("Vendor")).getByRole("button"));
    await user.click(within(header("Total")).getByRole("button"));
    expect(header("Total")).toHaveAttribute("aria-sort", "ascending");
    expect(header("Vendor")).toHaveAttribute("aria-sort", "none");
    expect(vendors()?.[0]).toBe("Meridian Logistics");
    expect(vendors()?.[4]).toBe("Shakti Bearings");
  });

  it("does not offer sorting on a column that disables it", () => {
    render(<Orders />);
    expect(within(header("Status")).queryByRole("button")).not.toBeInTheDocument();
  });

  it("controlled + manualSorting: calls back, and leaves the order to the caller", async () => {
    const user = userEvent.setup();
    const onSortingChange = vi.fn<(sorting: DataTableSortingState) => void>();
    const { rerender } = render(<Orders manualSorting sorting={[]} onSortingChange={onSortingChange} />);

    await user.click(within(header("Vendor")).getByRole("button"));
    expect(onSortingChange).toHaveBeenCalledTimes(1);
    expect(onSortingChange).toHaveBeenCalledWith([{ id: "vendor", desc: false }]);
    // The prop did not change, so neither does the table.
    expect(header("Vendor")).toHaveAttribute("aria-sort", "none");
    expect(vendors()).toEqual(orders.map((o) => o.vendor));

    rerender(
      <Orders manualSorting sorting={[{ id: "vendor", desc: false }]} onSortingChange={onSortingChange} />
    );
    expect(header("Vendor")).toHaveAttribute("aria-sort", "ascending");
    // Still the caller's order: the server is expected to send sorted data.
    expect(vendors()).toEqual(orders.map((o) => o.vendor));
  });
});

describe("DataTable — selection", () => {
  it("has no checkboxes unless selectable", () => {
    render(<Orders />);
    expect(screen.queryByRole("checkbox")).not.toBeInTheDocument();
  });

  it("selects one row; the header checkbox turns indeterminate", async () => {
    const user = userEvent.setup();
    render(<Orders selectable />);
    const all = screen.getByRole("checkbox", { name: "Select all rows" });
    expect(all).toHaveAttribute("aria-checked", "false");

    await user.click(screen.getByRole("checkbox", { name: "Select Coastal Foods" }));
    expect(screen.getByRole("checkbox", { name: "Select Coastal Foods" })).toBeChecked();
    expect(screen.getByRole("checkbox", { name: "Select Trimurti Packaging" })).not.toBeChecked();
    expect(all).toHaveAttribute("aria-checked", "mixed");
  });

  it("selects and clears every row from the header checkbox", async () => {
    const user = userEvent.setup();
    render(<Orders selectable />);
    const all = screen.getByRole("checkbox", { name: "Select all rows" });

    await user.click(all);
    expect(all).toBeChecked();
    for (const order of orders) {
      expect(screen.getByRole("checkbox", { name: `Select ${order.vendor}` })).toBeChecked();
    }

    await user.click(all);
    expect(all).not.toBeChecked();
    expect(screen.queryAllByRole("checkbox", { checked: true })).toHaveLength(0);
  });

  it("labels row checkboxes by position when no row label is given", () => {
    render(<Orders selectable getRowLabel={undefined} />);
    expect(screen.getByRole("checkbox", { name: "Select row 1" })).toBeInTheDocument();
    expect(screen.getByRole("checkbox", { name: "Select row 5" })).toBeInTheDocument();
  });

  it("does not put aria-selected on rows; the checkbox carries the state", async () => {
    const user = userEvent.setup();
    render(<Orders selectable />);
    await user.click(screen.getByRole("checkbox", { name: "Select Coastal Foods" }));
    for (const row of screen.getAllByRole("row")) expect(row).not.toHaveAttribute("aria-selected");
  });

  it("controlled: renders the given selection and calls back with the next one", async () => {
    const user = userEvent.setup();
    const onRowSelectionChange = vi.fn<(selection: DataTableRowSelectionState) => void>();
    render(<Orders selectable rowSelection={{ "o-2": true }} onRowSelectionChange={onRowSelectionChange} />);
    expect(screen.getByRole("checkbox", { name: "Select Coastal Foods" })).toBeChecked();

    await user.click(screen.getByRole("checkbox", { name: "Select Shakti Bearings" }));
    expect(onRowSelectionChange).toHaveBeenCalledWith({ "o-2": true, "o-3": true });
    // The prop did not change.
    expect(screen.getByRole("checkbox", { name: "Select Shakti Bearings" })).not.toBeChecked();
  });

  it("keeps the selection on the same records when the order changes", async () => {
    const user = userEvent.setup();
    render(<Orders selectable />);
    await user.click(screen.getByRole("checkbox", { name: "Select Trimurti Packaging" }));
    await user.click(within(header("Vendor")).getByRole("button"));
    expect(screen.getByRole("checkbox", { name: "Select Trimurti Packaging" })).toBeChecked();
    expect(screen.getAllByRole("checkbox", { checked: true })).toHaveLength(1);
  });

  it("shows a selection bar with the count and actions, and clears from it", async () => {
    const user = userEvent.setup();
    const selectionActions = vi.fn((rows: Order[]) => <button type="button">Export {rows.length}</button>);
    render(<Orders selectable selectionActions={selectionActions} />);
    expect(screen.queryByText(/selected$/)).not.toBeInTheDocument();

    await user.click(screen.getByRole("checkbox", { name: "Select Coastal Foods" }));
    await user.click(screen.getByRole("checkbox", { name: "Select Shakti Bearings" }));
    expect(screen.getByText("2 selected")).toBeInTheDocument();
    expect(screen.getByRole("button", { name: "Export 2" })).toBeInTheDocument();
    expect(selectionActions).toHaveBeenLastCalledWith([orders[1], orders[2]]);

    await user.click(screen.getByRole("button", { name: "Clear selection" }));
    expect(screen.queryByText(/selected$/)).not.toBeInTheDocument();
    expect(screen.queryAllByRole("checkbox", { checked: true })).toHaveLength(0);
  });

  it("shows no selection bar without selectionActions", async () => {
    const user = userEvent.setup();
    render(<Orders selectable />);
    await user.click(screen.getByRole("checkbox", { name: "Select Coastal Foods" }));
    expect(screen.queryByRole("button", { name: "Clear selection" })).not.toBeInTheDocument();
  });
});

describe("DataTable — states", () => {
  it("loading replaces the rows with one busy row spanning every column", () => {
    render(<Orders selectable loading />);
    expect(screen.getByRole("table", { name: "Orders" })).toHaveAttribute("aria-busy", "true");
    expect(screen.getByText("Loading table data")).toBeInTheDocument();
    expect(screen.queryByText("Trimurti Packaging")).not.toBeInTheDocument();
    const rows = screen.getAllByRole("row");
    expect(rows).toHaveLength(2);
    // 3 columns + the selection column.
    expect(within(rows[1]).getByRole("cell")).toHaveAttribute("colspan", "4");
    expect(screen.getByRole("checkbox", { name: "Select all rows" })).toBeDisabled();
  });

  it("empty shows a default message spanning every column", () => {
    render(<Orders data={[]} />);
    const cell = screen.getByRole("cell", { name: "No results." });
    expect(cell).toHaveAttribute("colspan", "3");
    expect(screen.getAllByRole("row")).toHaveLength(2);
  });

  it("empty renders a custom emptyState", () => {
    render(<Orders data={[]} emptyState={<span>No orders match the filters.</span>} />);
    expect(screen.getByText("No orders match the filters.")).toBeInTheDocument();
    expect(screen.queryByText("No results.")).not.toBeInTheDocument();
  });
});

describe("DataTable — pagination", () => {
  it("is off by default", () => {
    render(<Orders />);
    expect(screen.queryByRole("navigation", { name: "Pagination" })).not.toBeInTheDocument();
  });

  it("pages through the data and shows the visible range", async () => {
    const user = userEvent.setup();
    render(<Orders pageSize={2} />);
    expect(vendors()).toEqual(["Trimurti Packaging", "Coastal Foods"]);
    expect(screen.getByText("1–2 of 5")).toBeInTheDocument();

    await user.click(screen.getByRole("button", { name: "Next page" }));
    expect(vendors()).toEqual(["Shakti Bearings", "Meridian Logistics"]);
    expect(screen.getByText("3–4 of 5")).toBeInTheDocument();

    await user.click(screen.getByRole("button", { name: "Page 3" }));
    expect(vendors()).toEqual(["Pacific Pack Co."]);
    expect(screen.getByText("5–5 of 5")).toBeInTheDocument();
    expect(screen.getByRole("button", { name: "Next page" })).toBeDisabled();
  });

  it("returns to the first page when the sort changes", async () => {
    const user = userEvent.setup();
    render(<Orders pageSize={2} />);
    await user.click(screen.getByRole("button", { name: "Page 2" }));
    await user.click(within(header("Vendor")).getByRole("button"));
    expect(screen.getByText("1–2 of 5")).toBeInTheDocument();
    expect(vendors()).toEqual(["Coastal Foods", "Meridian Logistics"]);
  });

  it("steps back when the data shrinks under the current page", async () => {
    const user = userEvent.setup();
    const { rerender } = render(<Orders pageSize={2} />);
    await user.click(screen.getByRole("button", { name: "Page 3" }));
    rerender(<Orders pageSize={2} data={orders.slice(0, 3)} />);
    expect(screen.getByText("3–3 of 3")).toBeInTheDocument();
    expect(vendors()).toEqual(["Shakti Bearings"]);
  });

  it("controlled + manualPagination: renders the page it is given and calls back", async () => {
    const user = userEvent.setup();
    const onPaginationChange = vi.fn();
    render(
      <Orders
        data={orders.slice(0, 2)}
        manualPagination
        rowCount={50}
        pagination={{ pageIndex: 1, pageSize: 2 }}
        onPaginationChange={onPaginationChange}
      />
    );
    expect(vendors()).toEqual(["Trimurti Packaging", "Coastal Foods"]);
    expect(screen.getByText("3–4 of 50")).toBeInTheDocument();
    expect(screen.getByRole("button", { name: "Page 25" })).toBeInTheDocument();

    await user.click(screen.getByRole("button", { name: "Next page" }));
    expect(onPaginationChange).toHaveBeenCalledWith({ pageIndex: 2, pageSize: 2 });
    expect(screen.getByText("3–4 of 50")).toBeInTheDocument();
  });

  it("select all covers the current page only", async () => {
    const user = userEvent.setup();
    render(<Orders selectable pageSize={2} />);
    await user.click(screen.getByRole("checkbox", { name: "Select all rows" }));
    await user.click(screen.getByRole("button", { name: "Next page" }));
    expect(screen.getByRole("checkbox", { name: "Select all rows" })).not.toBeChecked();
    expect(screen.queryAllByRole("checkbox", { checked: true })).toHaveLength(0);
  });
});

describe("DataTable — row activation", () => {
  it("rows are not focusable without onRowClick", () => {
    render(<Orders />);
    for (const row of screen.getAllByRole("row")) expect(row).not.toHaveAttribute("tabindex");
  });

  it("fires on click, Enter and Space with the row's record", async () => {
    const user = userEvent.setup();
    const onRowClick = vi.fn();
    render(<Orders onRowClick={onRowClick} />);
    const row = screen.getAllByRole("row")[2];

    await user.click(within(row).getByText("Coastal Foods"));
    expect(onRowClick).toHaveBeenCalledTimes(1);
    expect(onRowClick.mock.calls[0][0]).toBe(orders[1]);

    row.focus();
    expect(row).toHaveFocus();
    await user.keyboard("{Enter}");
    expect(onRowClick).toHaveBeenCalledTimes(2);
    await user.keyboard(" ");
    expect(onRowClick).toHaveBeenCalledTimes(3);
    expect(onRowClick.mock.calls[2][0]).toBe(orders[1]);
  });

  it("body rows are in the tab order; the header row is not", () => {
    render(<Orders onRowClick={() => {}} />);
    const [head, ...body] = screen.getAllByRole("row");
    expect(head).not.toHaveAttribute("tabindex");
    for (const row of body) expect(row).toHaveAttribute("tabindex", "0");
  });

  it("a control inside the row does not activate the row", async () => {
    const user = userEvent.setup();
    const onRowClick = vi.fn();
    render(<Orders selectable onRowClick={onRowClick} />);
    const checkbox = screen.getByRole("checkbox", { name: "Select Coastal Foods" });
    await user.click(checkbox);
    expect(checkbox).toBeChecked();
    checkbox.focus();
    await user.keyboard("{Enter}");
    expect(onRowClick).not.toHaveBeenCalled();
  });
});

describe("DataTable — density and scrolling", () => {
  it("density sets the row-height variable on the root; default leaves it to the token", () => {
    const { container, rerender } = render(<Orders density="compact" />);
    const root = container.firstElementChild as HTMLElement;
    expect(root.style.getPropertyValue("--aeros-size-row")).toBe("32px");
    rerender(<Orders density="comfortable" />);
    expect(root.style.getPropertyValue("--aeros-size-row")).toBe("48px");
    rerender(<Orders />);
    expect(root.style.getPropertyValue("--aeros-size-row")).toBe("");
  });

  it("maxHeight makes the table area a keyboard-reachable scroll region", () => {
    render(<Orders stickyHeader maxHeight={200} />);
    const region = screen.getByRole("group", { name: "Scrollable table" });
    expect(region).toHaveAttribute("tabindex", "0");
    expect(region.style.maxHeight).toBe("200px");
    expect(within(region).getByRole("table", { name: "Orders" })).toBeInTheDocument();
  });
});

describe("DataTable — labels", () => {
  const labels = {
    selected: (count: number) => `${count} ausgewählt`,
    clearSelection: "Auswahl aufheben",
    selectAll: "Alle Zeilen auswählen",
    selectRow: (label: string) => `${label} auswählen`,
    rowPosition: (position: number) => `Zeile ${position}`,
    scrollRegion: "Scrollbare Tabelle",
    rangeOf: (from: number, to: number, total: number) => `${from}–${to} von ${total}`,
    loading: "Lädt…",
    loadingStatus: "Tabellendaten werden geladen",
    empty: "Keine Ergebnisse."
  };

  it("every built-in string can be replaced", async () => {
    const user = userEvent.setup();
    const { rerender } = render(
      <Orders labels={labels} selectable selectionActions={() => null} pageSize={2} maxHeight={200} />
    );
    expect(screen.getByRole("checkbox", { name: "Alle Zeilen auswählen" })).toBeInTheDocument();
    expect(screen.getByRole("group", { name: "Scrollbare Tabelle" })).toBeInTheDocument();
    expect(screen.getByText("1–2 von 5")).toBeInTheDocument();

    await user.click(screen.getByRole("checkbox", { name: "Trimurti Packaging auswählen" }));
    expect(screen.getByRole("status")).toHaveTextContent("1 ausgewählt");
    await user.click(screen.getByRole("button", { name: "Auswahl aufheben" }));
    expect(screen.queryByRole("status")).not.toBeInTheDocument();

    rerender(<Orders labels={labels} selectable getRowLabel={undefined} />);
    expect(screen.getByRole("checkbox", { name: "Zeile 1 auswählen" })).toBeInTheDocument();

    rerender(<Orders labels={labels} loading />);
    expect(screen.getByText("Lädt…")).toBeInTheDocument();
    expect(screen.getByRole("status")).toHaveTextContent("Tabellendaten werden geladen");

    rerender(<Orders labels={labels} data={[]} />);
    expect(screen.getByText("Keine Ergebnisse.")).toBeInTheDocument();
    rerender(<Orders labels={labels} data={[]} emptyState="Nichts hier" />);
    expect(screen.getByText("Nichts hier")).toBeInTheDocument();
    expect(screen.queryByText("Keine Ergebnisse.")).not.toBeInTheDocument();
  });

  it("a partial object keeps the English defaults for the rest", () => {
    render(<Orders labels={{ selectAll: "Tout sélectionner" }} selectable pageSize={2} />);
    expect(screen.getByRole("checkbox", { name: "Tout sélectionner" })).toBeInTheDocument();
    expect(screen.getByRole("checkbox", { name: "Select Trimurti Packaging" })).toBeInTheDocument();
    expect(screen.getByText("1–2 of 5")).toBeInTheDocument();
  });
});

describe("DataTable — axe", () => {
  it.each([
    ["default", {}],
    ["selectable with a selection bar", { selectable: true, rowSelection: { "o-2": true }, selectionActions: () => <button type="button">Export</button> }],
    ["loading", { loading: true, selectable: true }],
    ["empty", { data: [] }],
    ["paginated", { pageSize: 2 }],
    ["sticky header in a scroll area, clickable rows", { stickyHeader: true, maxHeight: 200, onRowClick: () => {} }]
  ] as Array<[string, Partial<DataTableProps<Order>>]>)("%s has no violations", async (_name, props) => {
    const { container } = render(<Orders {...props} />);
    expect(await axe(container)).toHaveNoViolations();
  });
});
