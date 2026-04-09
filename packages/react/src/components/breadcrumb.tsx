import * as React from "react";
import { ChevronRight } from "lucide-react";
import { cn } from "../lib/cn";

export interface BreadcrumbItem {
  label: React.ReactNode;
  href?: string;
}

export interface BreadcrumbProps extends React.HTMLAttributes<HTMLElement> {
  items: BreadcrumbItem[];
  separator?: React.ReactNode;
}

export function Breadcrumb({ items, separator, className, ...props }: BreadcrumbProps) {
  return (
    <nav aria-label="Breadcrumb" className={cn("flex items-center gap-1", className)} {...props}>
      <ol className="flex items-center gap-1">
        {items.map((item, i) => {
          const last = i === items.length - 1;
          return (
            <li key={i} className="flex items-center gap-1">
              {item.href && !last ? (
                <a href={item.href} className="text-[13px] font-medium text-fg-muted hover:text-fg-primary">
                  {item.label}
                </a>
              ) : (
                <span
                  className={cn(
                    "text-[13px] font-medium",
                    last ? "text-fg-primary font-semibold" : "text-fg-muted"
                  )}
                  aria-current={last ? "page" : undefined}
                >
                  {item.label}
                </span>
              )}
              {!last && (
                <span aria-hidden className="text-ink-200 flex items-center">
                  {separator ?? <ChevronRight className="h-3.5 w-3.5" />}
                </span>
              )}
            </li>
          );
        })}
      </ol>
    </nav>
  );
}
