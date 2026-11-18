import * as React from "react";
import { ArrowDown, ArrowUp, ArrowUpDown } from "lucide-react";
import { cn } from "../lib/cn";
import { Spinner } from "./spinner";

export interface TableProps extends React.TableHTMLAttributes<HTMLTableElement> {
  /** Wraps the table in a rounded, bordered shell. */
  shell?: boolean;
  /** Class for the shell wrapper (only when `shell` is true). */
  containerClassName?: string;
}

export const Table = React.forwardRef<HTMLTableElement, TableProps>(
  ({ children, className, shell = true, containerClassName, ...props }, ref) => {
    const inner = (
      <table ref={ref} className={cn("w-full border-collapse", className)} {...props}>
        {children}
      </table>
    );
    if (!shell) return inner;
    return (
      <div className={cn("overflow-hidden rounded-surface border border-border-default bg-bg-surface", containerClassName)}>
        {inner}
      </div>
    );
  }
);
Table.displayName = "Table";

export const Thead = React.forwardRef<HTMLTableSectionElement, React.HTMLAttributes<HTMLTableSectionElement>>(
  ({ className, ...props }, ref) => (
    <thead ref={ref} className={cn("bg-bg-surface", className)} {...props} />
  )
);
Thead.displayName = "Thead";

export const Tbody = React.forwardRef<HTMLTableSectionElement, React.HTMLAttributes<HTMLTableSectionElement>>(
  ({ className, ...props }, ref) => (
    <tbody ref={ref} className={cn(className)} {...props} />
  )
);
Tbody.displayName = "Tbody";

export interface TrProps extends React.HTMLAttributes<HTMLTableRowElement> {
  /**
   * Marks the row as selected (persistent tint, `data-selected`). It does not set
   * `aria-selected`: that attribute is invalid on a row of a plain table — expose
   * the state through the row's own control (a checkbox) instead.
   */
  selected?: boolean;
}

export const Tr = React.forwardRef<HTMLTableRowElement, TrProps>(
  ({ className, selected, ...props }, ref) => (
    <tr
      ref={ref}
      data-selected={selected || undefined}
      className={cn(
        "hover:[&>td]:bg-state-hover [&>td]:transition-colors [&>td]:duration-quick",
        selected && "[&>td]:bg-state-selected hover:[&>td]:bg-state-selected",
        className
      )}
      {...props}
    />
  )
);
Tr.displayName = "Tr";

export interface ThProps extends React.ThHTMLAttributes<HTMLTableCellElement> {
  /** Renders the header as a sort button; pair with `sortDirection` + `onSort`. */
  sortable?: boolean;
  /** Current sort of this column (`false` = not sorted). Sets `aria-sort`. */
  sortDirection?: "asc" | "desc" | false;
  onSort?: () => void;
}

export const Th = React.forwardRef<HTMLTableCellElement, ThProps>(
  ({ className, scope = "col", sortable, sortDirection = false, onSort, children, ...props }, ref) => (
    <th
      ref={ref}
      scope={scope}
      aria-sort={
        sortable
          ? sortDirection === "asc" ? "ascending" : sortDirection === "desc" ? "descending" : "none"
          : undefined
      }
      className={cn(
        "whitespace-nowrap border-b border-border-default text-start text-label-xs text-fg-muted",
        sortable ? "p-0" : "h-control-lg px-3",
        className
      )}
      {...props}
    >
      {sortable ? (
        <button
          type="button"
          onClick={onSort}
          className={cn(
            "flex h-control-lg w-full items-center gap-1 px-3 text-label-xs",
            "transition-colors duration-quick hover:text-fg-primary",
            "focus-ring-inset",
            sortDirection ? "text-fg-primary" : "text-fg-muted"
          )}
        >
          {children}
          {sortDirection === "asc" ? (
            <ArrowUp className="size-icon-xs" aria-hidden />
          ) : sortDirection === "desc" ? (
            <ArrowDown className="size-icon-xs" aria-hidden />
          ) : (
            <ArrowUpDown className="size-icon-xs opacity-muted" aria-hidden />
          )}
        </button>
      ) : (
        children
      )}
    </th>
  )
);
Th.displayName = "Th";

export const Td = React.forwardRef<HTMLTableCellElement, React.TdHTMLAttributes<HTMLTableCellElement>>(
  ({ className, ...props }, ref) => (
    <td
      ref={ref}
      className={cn(
        "h-row border-b border-border-subtle px-3 py-1.5 text-body-sm text-fg-secondary [tr:last-child_&]:border-b-0",
        className
      )}
      {...props}
    />
  )
);
Td.displayName = "Td";

// Row-state helpers — render as the only row in Tbody while loading / empty.

export interface TableStateRowProps extends React.HTMLAttributes<HTMLTableRowElement> {
  /** Number of columns the message spans. */
  colSpan: number;
}

export interface TableLoadingRowProps extends TableStateRowProps {
  /** What assistive tech hears. Defaults to "Loading table data". */
  statusLabel?: string;
}

export const TableLoadingRow = ({ colSpan, className, children, statusLabel = "Loading table data", ...props }: TableLoadingRowProps) => (
  <tr {...props}>
    <td colSpan={colSpan} className={cn("px-3 py-10 text-center", className)}>
      <span className="inline-flex items-center gap-2 text-body-sm text-fg-muted">
        <Spinner size="sm" label="" aria-hidden />
        {children ?? "Loading…"}
      </span>
      <span className="sr-only" role="status">{statusLabel}</span>
    </td>
  </tr>
);

export const TableEmptyRow = ({ colSpan, className, children, ...props }: TableStateRowProps) => (
  <tr {...props}>
    <td colSpan={colSpan} className={cn("px-3 py-10 text-center text-body-sm text-fg-muted", className)}>
      {children ?? "No results."}
    </td>
  </tr>
);

// Cell helpers
export const TdStrong = ({ className, ...props }: React.HTMLAttributes<HTMLSpanElement>) => (
  <span className={cn("font-medium text-fg-primary", className)} {...props} />
);
export const TdMono = ({ className, ...props }: React.HTMLAttributes<HTMLSpanElement>) => (
  <span className={cn("font-mono text-mono-sm text-fg-primary", className)} {...props} />
);
export const TdMuted = ({ className, ...props }: React.HTMLAttributes<HTMLSpanElement>) => (
  <span className={cn("text-caption text-fg-muted", className)} {...props} />
);
