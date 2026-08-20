"use client";
import * as React from "react";
import { ChevronLeft, ChevronRight } from "lucide-react";
import { cn } from "../lib/cn";

export interface PaginationProps extends Omit<React.HTMLAttributes<HTMLElement>, "onChange"> {
  /** Current page, 1-based. */
  page: number;
  /** Total number of pages. */
  count: number;
  onPageChange?: (page: number) => void;
  /** Pages shown on each side of the current page. */
  siblings?: number;
}

function range(from: number, to: number): number[] {
  return Array.from({ length: to - from + 1 }, (_, i) => from + i);
}

/** 1 … 4 [5] 6 … 20 — first/last always visible, ellipses when gaps exist. */
function pageModel(page: number, count: number, siblings: number): Array<number | "…"> {
  const total = siblings * 2 + 5; // first + last + current + siblings + 2 ellipses
  if (count <= total) return range(1, count);
  const left = Math.max(page - siblings, 2);
  const right = Math.min(page + siblings, count - 1);
  return [
    1,
    ...(left > 2 ? (["…"] as const) : []),
    ...range(left, right),
    ...(right < count - 1 ? (["…"] as const) : []),
    count
  ];
}

const itemBase =
  "inline-flex h-8 min-w-8 items-center justify-center rounded-md px-2 text-[13px] font-medium " +
  "transition-colors duration-(--aeros-duration-quick) " +
  "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-focus-ring focus-visible:ring-offset-2 focus-visible:ring-offset-bg-canvas " +
  "disabled:opacity-40 disabled:cursor-not-allowed";

export const Pagination = React.forwardRef<HTMLElement, PaginationProps>(
  ({ page, count, onPageChange, siblings = 1, className, ...props }, ref) => {
    const items = pageModel(page, count, siblings);
    const go = (p: number) => {
      if (p >= 1 && p <= count && p !== page) onPageChange?.(p);
    };
    return (
      <nav ref={ref} aria-label="Pagination" className={cn("flex items-center gap-1", className)} {...props}>
        <button
          type="button"
          className={cn(itemBase, "text-fg-secondary hover:bg-bg-subtle hover:text-fg-primary")}
          onClick={() => go(page - 1)}
          disabled={page <= 1}
          aria-label="Previous page"
        >
          <ChevronLeft className="h-4 w-4" aria-hidden />
        </button>
        {items.map((item, i) =>
          item === "…" ? (
            <span key={`gap-${i}`} aria-hidden className="inline-flex h-8 min-w-8 items-center justify-center text-[13px] text-fg-muted">
              …
            </span>
          ) : (
            <button
              key={item}
              type="button"
              aria-label={`Page ${item}`}
              aria-current={item === page ? "page" : undefined}
              className={cn(
                itemBase,
                item === page
                  ? "bg-brand-primary text-fg-inverse font-semibold"
                  : "text-fg-secondary hover:bg-bg-subtle hover:text-fg-primary"
              )}
              onClick={() => go(item)}
            >
              {item}
            </button>
          )
        )}
        <button
          type="button"
          className={cn(itemBase, "text-fg-secondary hover:bg-bg-subtle hover:text-fg-primary")}
          onClick={() => go(page + 1)}
          disabled={page >= count}
          aria-label="Next page"
        >
          <ChevronRight className="h-4 w-4" aria-hidden />
        </button>
      </nav>
    );
  }
);
Pagination.displayName = "Pagination";
