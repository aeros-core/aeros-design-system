import * as React from "react";
import { cn } from "../lib/cn";

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

export const Tr = React.forwardRef<HTMLTableRowElement, React.HTMLAttributes<HTMLTableRowElement>>(
  ({ className, ...props }, ref) => (
    <tr
      ref={ref}
      className={cn("hover:[&>td]:bg-bg-subtle [&>td]:transition-colors [&>td]:duration-(--aeros-duration-quick)", className)}
      {...props}
    />
  )
);
Tr.displayName = "Tr";

export const Th = React.forwardRef<HTMLTableCellElement, React.ThHTMLAttributes<HTMLTableCellElement>>(
  ({ className, scope = "col", ...props }, ref) => (
    <th
      ref={ref}
      scope={scope}
      className={cn(
        "text-[11px] font-semibold uppercase tracking-[0.06em] text-fg-muted text-left px-4 py-2.5 border-b border-border-default whitespace-nowrap",
        className
      )}
      {...props}
    />
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
