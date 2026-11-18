"use client";
import * as React from "react";
import {
  createColumnHelper,
  createPaginatedRowModel,
  createSortedRowModel,
  functionalUpdate,
  metaHelper,
  rowPaginationFeature,
  rowSelectionFeature,
  rowSortingFeature,
  sortFn_alphanumeric,
  sortFn_basic,
  sortFn_datetime,
  sortFn_text,
  tableFeatures,
  useTable,
  type ColumnDef,
  type ColumnHelper,
  type PaginationState,
  type ReactTable,
  type RowData,
  type RowSelectionState,
  type SortingState,
  type Updater
} from "@tanstack/react-table";
import { X } from "lucide-react";
import { cn } from "../lib/cn";
import { Button } from "./button";
import { Checkbox } from "./checkbox";
import { Pagination } from "./pagination";
import { Table, TableEmptyRow, TableLoadingRow, Tbody, Td, TdMono, Th, Thead, Tr } from "./table";

// A data grid for admin screens: TanStack Table for the model (sorting,
// selection, pagination), the presentational Table parts for the markup.
//
// Each state slice — sorting, rowSelection, pagination — is uncontrolled until
// its prop is passed. The manual* flags hand that stage to the server: the
// table then reports the change and renders `data` exactly as given.
//
// Keep `columns` stable (module scope or useMemo); a new array every render
// rebuilds the column model every render.

/** Per-column presentation, set on a column's `meta`. */
export interface DataTableColumnMeta {
  /** Horizontal alignment of the header and its cells. Default "start". */
  align?: "start" | "end" | "center";
  /** CSS width of the column, e.g. "8rem" or "20%". */
  width?: string;
  /** Monospaced, tabular figures — for ids, quantities and amounts. */
  mono?: boolean;
}

const features = tableFeatures({
  rowSortingFeature,
  rowSelectionFeature,
  rowPaginationFeature,
  sortedRowModel: createSortedRowModel(),
  paginatedRowModel: createPaginatedRowModel(),
  sortFns: {
    alphanumeric: sortFn_alphanumeric,
    basic: sortFn_basic,
    datetime: sortFn_datetime,
    text: sortFn_text
  },
  columnMeta: metaHelper<DataTableColumnMeta>()
});

/** The TanStack feature set every DataTable runs on. */
export type DataTableFeatures = typeof features;

/** A column definition (TanStack `ColumnDef`) bound to the DataTable feature set. */
export type DataTableColumn<T extends RowData, TValue = unknown> = ColumnDef<DataTableFeatures, T, TValue>;

/** The table instance handed to `toolbar`. */
export type DataTableInstance<T extends RowData> = ReactTable<DataTableFeatures, T>;

export type DataTableSortingState = SortingState;
export type DataTableRowSelectionState = RowSelectionState;
export type DataTablePaginationState = PaginationState;
export type DataTableDensity = "compact" | "default" | "comfortable";

/**
 * Typed column builder. `helper.columns([helper.accessor("total", { … })])`
 * keeps each accessor's value type inside its `cell` renderer.
 */
export function createDataTableColumnHelper<T extends RowData>(): ColumnHelper<DataTableFeatures, T> {
  return createColumnHelper<DataTableFeatures, T>();
}

export interface DataTableProps<T extends RowData>
  extends Omit<React.HTMLAttributes<HTMLDivElement>, "children" | "onChange"> {
  columns: ReadonlyArray<DataTableColumn<T>>;
  data: ReadonlyArray<T>;
  /** Stable row identity. Without it rows are identified by index, which breaks selection across sorts and pages. */
  getRowId?: (row: T, index: number) => string;
  /** Names a row for assistive tech: its checkbox reads "Select <label>". Defaults to the row's position. */
  getRowLabel?: (row: T) => string;

  /** Controlled sort. Omit for uncontrolled. */
  sorting?: DataTableSortingState;
  onSortingChange?: (sorting: DataTableSortingState) => void;
  /** The server sorts: headers still report the change, `data` renders in the order given. */
  manualSorting?: boolean;

  /** Adds a leading checkbox column. */
  selectable?: boolean;
  /** Controlled selection, keyed by row id. Omit for uncontrolled. */
  rowSelection?: DataTableRowSelectionState;
  onRowSelectionChange?: (rowSelection: DataTableRowSelectionState) => void;

  /** Row height: compact 32, default 40 (48 at touch density), comfortable 48. */
  density?: DataTableDensity;
  /** Keeps the header visible while the body scrolls. Pair with `maxHeight`. */
  stickyHeader?: boolean;
  /** Turns the table area into a vertical scroll container of at most this height. */
  maxHeight?: number | string;

  loading?: boolean;
  /** Shown instead of rows when there is no data. */
  emptyState?: React.ReactNode;

  /** Makes rows activatable: click, Enter or Space. */
  onRowClick?: (
    row: T,
    event: React.MouseEvent<HTMLTableRowElement> | React.KeyboardEvent<HTMLTableRowElement>
  ) => void;

  /** Enables pagination with this many rows per page (uncontrolled). */
  pageSize?: number;
  /** Controlled pagination (`pageIndex` is 0-based). Enables pagination. */
  pagination?: DataTablePaginationState;
  onPaginationChange?: (pagination: DataTablePaginationState) => void;
  /** The server paginates: `data` is the current page; pass `rowCount`. */
  manualPagination?: boolean;
  /** Total rows across all pages, for `manualPagination`. */
  rowCount?: number;

  /** Rendered above the table. */
  toolbar?: (table: DataTableInstance<T>) => React.ReactNode;
  /** Actions for the selection bar, shown while rows are selected. Receives the selected rows present in `data`. */
  selectionActions?: (rows: T[]) => React.ReactNode;

  /** Accessible name of the table, rendered as a visually hidden `<caption>`. */
  caption?: React.ReactNode;
}

// Same surface as Table's own shell, which cannot host a scroll area or a footer.
const tableShell = "isolate overflow-hidden rounded-surface border border-border-default bg-bg-surface";

const rowHeight: Record<DataTableDensity, string | undefined> = {
  compact: "32px",
  // The size token decides (40 pointer / 48 touch).
  default: undefined,
  comfortable: "48px"
};

const alignCell = { start: "text-start", end: "text-end", center: "text-center" } as const;
/** A sortable header is a flex button, so it is justified rather than text-aligned. */
const alignSortButton = { start: "", end: "[&>button]:justify-end", center: "[&>button]:justify-center" } as const;

const INTERACTIVE = "a,button,input,select,textarea,label,summary,[role='button'],[role='checkbox'],[role='menuitem'],[role='switch']";

/** True when the event started on a control inside the row (or in something portalled out of it). */
function startedOnControl(event: React.SyntheticEvent<HTMLTableRowElement>): boolean {
  const row = event.currentTarget;
  const target = event.target as Element;
  if (!row.contains(target)) return true;
  const control = target.closest(INTERACTIVE);
  return control !== null && control !== row && row.contains(control);
}

/** State that is uncontrolled until `controlled` is passed. Accepts TanStack updaters. */
function useSlice<S>(controlled: S | undefined, initial: S, onChange: ((value: S) => void) | undefined) {
  const [inner, setInner] = React.useState(initial);
  const value = controlled !== undefined ? controlled : inner;
  const latest = React.useRef(value);
  latest.current = value;
  const set = React.useCallback(
    (updater: Updater<S>) => {
      const next = functionalUpdate(updater, latest.current);
      latest.current = next;
      setInner(next);
      onChange?.(next);
    },
    [onChange]
  );
  return [value, set] as const;
}

const NO_SORTING: DataTableSortingState = [];
const NO_SELECTION: DataTableRowSelectionState = {};

function DataTableInner<T extends RowData>(
  {
    columns,
    data,
    getRowId,
    getRowLabel,
    sorting: sortingProp,
    onSortingChange,
    manualSorting = false,
    selectable = false,
    rowSelection: rowSelectionProp,
    onRowSelectionChange,
    density = "default",
    stickyHeader = false,
    maxHeight,
    loading = false,
    emptyState,
    onRowClick,
    pageSize,
    pagination: paginationProp,
    onPaginationChange,
    manualPagination = false,
    rowCount,
    toolbar,
    selectionActions,
    caption,
    className,
    style,
    "aria-label": ariaLabel,
    "aria-labelledby": ariaLabelledBy,
    ...props
  }: DataTableProps<T>,
  ref: React.ForwardedRef<HTMLDivElement>
) {
  const paginated = pageSize !== undefined || paginationProp !== undefined;

  const [sorting, setSortingState] = useSlice(sortingProp, NO_SORTING, onSortingChange);
  const [rowSelection, setRowSelection] = useSlice(rowSelectionProp, NO_SELECTION, onRowSelectionChange);
  const [pageState, setPagination] = useSlice(
    paginationProp,
    { pageIndex: 0, pageSize: pageSize ?? 10 },
    onPaginationChange
  );

  // Uncontrolled pagination follows a changed `pageSize` prop.
  const size = Math.max(1, paginationProp?.pageSize ?? pageSize ?? pageState.pageSize);
  const total = manualPagination ? rowCount ?? data.length : data.length;
  const pageCount = Math.max(1, Math.ceil(total / size));
  // Data can shrink under the current page; never render past the last one.
  const pageIndex = Math.min(Math.max(0, pageState.pageIndex), pageCount - 1);
  const pagination = React.useMemo(() => ({ pageIndex, pageSize: size }), [pageIndex, size]);

  const setSorting = React.useCallback(
    (updater: Updater<DataTableSortingState>) => {
      setSortingState(updater);
      // A new order makes the current page meaningless; the server decides for itself.
      if (paginated && !manualPagination) setPagination((old) => ({ ...old, pageIndex: 0 }));
    },
    [setSortingState, setPagination, paginated, manualPagination]
  );

  const table = useTable({
    features,
    // TanStack wants mutable array types; it does not mutate them.
    columns: columns as Array<DataTableColumn<T>>,
    data: data as Array<T>,
    getRowId,
    state: { sorting, rowSelection, pagination },
    onSortingChange: setSorting,
    onRowSelectionChange: setRowSelection,
    onPaginationChange: setPagination,
    manualSorting,
    // Not paginating is "one page holding everything", so nothing is sliced.
    manualPagination: manualPagination || !paginated,
    rowCount: manualPagination ? total : undefined,
    // Page resets are handled above, in step with React state.
    autoResetPageIndex: false,
    enableRowSelection: selectable,
    enableMultiSort: false,
    // asc → desc → none for every column, numbers included.
    sortDescFirst: false
  });

  const [scrolled, setScrolled] = React.useState(false);
  const onScroll = (event: React.UIEvent<HTMLDivElement>) => {
    const next = event.currentTarget.scrollTop > 0;
    setScrolled((prev) => (prev === next ? prev : next));
  };

  const headerGroups = table.getHeaderGroups();
  const rows = table.getRowModel().rows;
  const colSpan = table.getAllLeafColumns().length + (selectable ? 1 : 0);
  const showRows = !loading && rows.length > 0;

  const allSelected = showRows && table.getIsAllPageRowsSelected();
  const someSelected = showRows && !allSelected && table.getIsSomePageRowsSelected();
  const selectedCount = Object.keys(rowSelection).length;
  const showSelectionBar = selectable && selectedCount > 0 && selectionActions !== undefined;

  const firstRow = total === 0 ? 0 : pageIndex * size + 1;
  const lastRow = Math.min(total, pageIndex * size + (manualPagination ? rows.length : size));

  const stickyCell = stickyHeader && cn("sticky top-0 z-sticky bg-bg-surface", scrolled && "shadow-raised");
  const scrolls = maxHeight !== undefined;
  const densityStyle = rowHeight[density]
    ? ({ "--aeros-size-row": rowHeight[density] } as React.CSSProperties)
    : undefined;

  return (
    <div
      ref={ref}
      data-density={density}
      className={cn("flex min-w-0 flex-col gap-2", className)}
      style={{ ...densityStyle, ...style }}
      {...props}
    >
      {toolbar ? <div className="flex flex-wrap items-center gap-2">{toolbar(table)}</div> : null}

      {showSelectionBar ? (
        <div className="flex min-h-control-lg flex-wrap items-center gap-2 rounded-surface border border-border-default bg-bg-subtle px-3 py-1">
          <span className="text-label-sm text-fg-primary" role="status">
            {selectedCount} selected
          </span>
          <div className="flex flex-1 flex-wrap items-center gap-2">
            {selectionActions(table.getSelectedRowModel().rows.map((row) => row.original))}
          </div>
          <Button variant="ghost" size="sm" leadingIcon={<X aria-hidden />} onClick={() => setRowSelection({})}>
            Clear selection
          </Button>
        </div>
      ) : null}

      <div className={tableShell}>
        <div
          className={cn(scrolls ? "overflow-auto focus-ring-inset" : "overflow-x-auto")}
          style={scrolls ? { maxHeight } : undefined}
          onScroll={stickyHeader ? onScroll : undefined}
          // A scroll area has to be reachable without a pointer.
          tabIndex={scrolls ? 0 : undefined}
          role={scrolls ? "group" : undefined}
          aria-label={scrolls ? "Scrollable table" : undefined}
        >
          <Table
            shell={false}
            aria-label={ariaLabel}
            aria-labelledby={ariaLabelledBy}
            aria-busy={loading || undefined}
            // Collapsed borders do not travel with a sticky cell.
            className={cn(stickyHeader && "border-separate border-spacing-0")}
          >
            {caption ? <caption className="sr-only">{caption}</caption> : null}
            <Thead>
              {headerGroups.map((group, groupIndex) => (
                <Tr key={group.id}>
                  {selectable && groupIndex === 0 ? (
                    <Th rowSpan={headerGroups.length} className={cn("w-10 pe-0", stickyCell)}>
                      <span className="flex items-center">
                        <Checkbox
                          aria-label="Select all rows"
                          checked={allSelected ? true : someSelected ? "indeterminate" : false}
                          disabled={!showRows}
                          onCheckedChange={(checked) => table.toggleAllPageRowsSelected(checked === true)}
                        />
                      </span>
                    </Th>
                  ) : null}
                  {group.headers.map((header) => {
                    const meta = header.column.columnDef.meta;
                    const align = meta?.align ?? "start";
                    const canSort = !header.isPlaceholder && header.column.getCanSort();
                    return (
                      <Th
                        key={header.id}
                        colSpan={header.colSpan > 1 ? header.colSpan : undefined}
                        scope={header.colSpan > 1 ? "colgroup" : "col"}
                        sortable={canSort}
                        sortDirection={canSort ? header.column.getIsSorted() : false}
                        onSort={canSort ? () => header.column.toggleSorting() : undefined}
                        style={meta?.width ? { width: meta.width } : undefined}
                        className={cn(alignCell[align], canSort && alignSortButton[align], stickyCell)}
                      >
                        {header.isPlaceholder ? null : <table.FlexRender header={header} />}
                      </Th>
                    );
                  })}
                </Tr>
              ))}
            </Thead>
            <Tbody>
              {loading ? (
                <TableLoadingRow colSpan={colSpan} />
              ) : rows.length === 0 ? (
                <TableEmptyRow colSpan={colSpan}>{emptyState}</TableEmptyRow>
              ) : (
                rows.map((row, rowIndex) => {
                  const selected = selectable && row.getIsSelected();
                  const label = getRowLabel ? getRowLabel(row.original) : `row ${pageIndex * size + rowIndex + 1}`;
                  return (
                    <Tr
                      key={row.id}
                      selected={selected}
                      tabIndex={onRowClick ? 0 : undefined}
                      className={cn(onRowClick && "cursor-pointer focus-ring-inset")}
                      onClick={
                        onRowClick
                          ? (event) => {
                              if (!startedOnControl(event)) onRowClick(row.original, event);
                            }
                          : undefined
                      }
                      onKeyDown={
                        onRowClick
                          ? (event) => {
                              if (event.target !== event.currentTarget) return;
                              if (event.key !== "Enter" && event.key !== " ") return;
                              event.preventDefault();
                              onRowClick(row.original, event);
                            }
                          : undefined
                      }
                    >
                      {selectable ? (
                        <Td className="w-10 pe-0">
                          <span className="flex items-center">
                            <Checkbox
                              aria-label={`Select ${label}`}
                              checked={selected}
                              disabled={!row.getCanSelect()}
                              onCheckedChange={(checked) => row.toggleSelected(checked === true)}
                            />
                          </span>
                        </Td>
                      ) : null}
                      {row.getAllCells().map((cell) => {
                        const meta = cell.column.columnDef.meta;
                        const content = <table.FlexRender cell={cell} />;
                        return (
                          <Td key={cell.id} className={alignCell[meta?.align ?? "start"]}>
                            {meta?.mono ? <TdMono className="tabular-nums">{content}</TdMono> : content}
                          </Td>
                        );
                      })}
                    </Tr>
                  );
                })
              )}
            </Tbody>
          </Table>
        </div>

        {paginated && total > 0 ? (
          <div className="flex flex-wrap items-center justify-between gap-2 border-t border-border-default px-3 py-2">
            <span className="text-caption text-fg-muted tabular-nums">
              {firstRow}–{lastRow} of {total}
            </span>
            <Pagination
              page={pageIndex + 1}
              count={pageCount}
              onPageChange={(page) => table.setPageIndex(page - 1)}
            />
          </div>
        ) : null}
      </div>
    </div>
  );
}

export const DataTable = React.forwardRef(DataTableInner) as (<T extends RowData>(
  props: DataTableProps<T> & React.RefAttributes<HTMLDivElement>
) => React.ReactElement | null) & { displayName?: string };
DataTable.displayName = "DataTable";
