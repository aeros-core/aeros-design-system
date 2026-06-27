import * as React from "react";
import { cn } from "../lib/cn";

export function Table({
  children,
  className,
  shell = true
}: {
  children: React.ReactNode;
  className?: string;
  shell?: boolean;
}) {
  const inner = (
    <table className={cn("w-full border-collapse", className)}>
      {children}
    </table>
  );
  if (!shell) return inner;
  return (
    <div className="rounded-lg border border-border-default overflow-hidden">
      {inner}
    </div>
  );
}

export function Thead(props: React.HTMLAttributes<HTMLTableSectionElement>) {
  return <thead className={cn("bg-bg-subtle", props.className)} {...props} />;
}

export function Tbody(props: React.HTMLAttributes<HTMLTableSectionElement>) {
  return <tbody {...props} />;
}

export function Tr({ className, ...props }: React.HTMLAttributes<HTMLTableRowElement>) {
  return <tr className={cn("hover:[&>td]:bg-bg-subtle [&>td]:transition-colors [&>td]:duration-[90ms]", className)} {...props} />;
}

export function Th({ className, ...props }: React.ThHTMLAttributes<HTMLTableCellElement>) {
  return (
    <th
      className={cn(
        "text-[11px] font-semibold uppercase tracking-[0.06em] text-fg-muted text-left px-4 py-2.5 border-b border-border-default whitespace-nowrap",
        className
      )}
      {...props}
    />
  );
}

export function Td({ className, ...props }: React.TdHTMLAttributes<HTMLTableCellElement>) {
  return (
    <td
      className={cn(
        "text-[13px] text-fg-secondary font-normal px-4 py-3 border-b border-border-subtle last:[tr:last-child_&]:border-b-0",
        className
      )}
      {...props}
    />
  );
}

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
