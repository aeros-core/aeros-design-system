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
      <div className={cn("rounded-lg border border-border-default overflow-hidden", containerClassName)}>
        {inner}
      </div>
    );
  }
);
Table.displayName = "Table";

export const Thead = React.forwardRef<HTMLTableSectionElement, React.HTMLAttributes<HTMLTableSectionElement>>(
  ({ className, ...props }, ref) => (
    <thead ref={ref} className={cn("bg-bg-subtle", className)} {...props} />
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
  /** Marks the row as selected (`aria-selected` + persistent tint). */
  selected?: boolean;
}

export const Tr = React.forwardRef<HTMLTableRowElement, TrProps>(
  ({ className, selected, ...props }, ref) => (
    <tr
      ref={ref}
      aria-selected={selected || undefined}
      data-selected={selected || undefined}
      className={cn(
        "hover:[&>td]:bg-bg-subtle [&>td]:transition-colors [&>td]:duration-(--aeros-duration-quick)",
        selected && "[&>td]:bg-brand-primary-muted hover:[&>td]:bg-brand-primary-muted",
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
        "text-[11px] font-semibold uppercase tracking-[0.06em] text-fg-muted text-left border-b border-border-default whitespace-nowrap",
        sortable ? "p-0" : "px-4 py-2.5",
        className
      )}
      {...props}
    >
      {sortable ? (
        <button
          type="button"
          onClick={onSort}
          className={cn(
            "flex w-full items-center gap-1 px-4 py-2.5 text-[11px] font-semibold uppercase tracking-[0.06em]",
            "transition-colors duration-(--aeros-duration-quick) hover:text-fg-primary",
            "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-inset focus-visible:ring-focus-ring",
            sortDirection ? "text-fg-primary" : "text-fg-muted"
          )}
        >
          {children}
          {sortDirection === "asc" ? (
            <ArrowUp className="h-3 w-3" aria-hidden />
          ) : sortDirection === "desc" ? (
            <ArrowDown className="h-3 w-3" aria-hidden />
          ) : (
            <ArrowUpDown className="h-3 w-3 opacity-50" aria-hidden />
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
        "text-[13px] text-fg-secondary font-normal px-4 py-3 border-b border-border-subtle [tr:last-child_&]:border-b-0",
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

export const TableLoadingRow = ({ colSpan, className, children, ...props }: TableStateRowProps) => (
  <tr {...props}>
    <td colSpan={colSpan} className={cn("px-4 py-10 text-center", className)}>
      <span className="inline-flex items-center gap-2.5 text-[13px] text-fg-muted">
        <Spinner size="sm" label="" aria-hidden />
        {children ?? "Loading…"}
      </span>
      <span className="sr-only" role="status">Loading table data</span>
    </td>
  </tr>
);

export const TableEmptyRow = ({ colSpan, className, children, ...props }: TableStateRowProps) => (
  <tr {...props}>
    <td colSpan={colSpan} className={cn("px-4 py-10 text-center text-[13px] text-fg-muted", className)}>
      {children ?? "No results."}
    </td>
  </tr>
);

// Cell helpers
export const TdStrong = ({ className, ...props }: React.HTMLAttributes<HTMLSpanElement>) => (
  <span className={cn("font-semibold text-fg-primary", className)} {...props} />
);
export const TdMono = ({ className, ...props }: React.HTMLAttributes<HTMLSpanElement>) => (
  <span className={cn("font-mono text-xs font-medium text-fg-primary", className)} {...props} />
);
export const TdMuted = ({ className, ...props }: React.HTMLAttributes<HTMLSpanElement>) => (
  <span className={cn("text-xs text-fg-muted", className)} {...props} />
);
