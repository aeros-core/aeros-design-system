import * as React from "react";
import { ArrowUp, ArrowDown, Minus } from "lucide-react";
import { cn } from "../lib/cn";

export interface StatCardProps extends React.HTMLAttributes<HTMLDivElement> {
  label: string;
  value: React.ReactNode;
  mono?: boolean;
  delta?: { value: string; direction?: "up" | "down" | "flat" };
}

export const StatCard = React.forwardRef<HTMLDivElement, StatCardProps>(
  ({ label, value, mono, delta, className, ...props }, ref) => {
  return (
    <div
      ref={ref}
      className={cn(
        "rounded-surface border border-border-default bg-bg-surface p-4",
        className
      )}
      {...props}
    >
      <div className="mb-2 text-caption text-fg-muted">
        {label}
      </div>
      <div
        className={cn(
          "text-h1 leading-none text-fg-primary",
          mono && "font-mono text-mono-lg leading-none"
        )}
      >
        {value}
      </div>
      {delta && (
        <div
          className={cn(
            "mt-2 inline-flex items-center gap-1 text-caption font-medium",
            delta.direction === "up" && "text-success-text",
            delta.direction === "down" && "text-danger-text",
            (!delta.direction || delta.direction === "flat") && "text-fg-muted"
          )}
        >
          {delta.direction === "up" && <ArrowUp aria-hidden className="size-icon-xs" strokeWidth={2.5} />}
          {delta.direction === "down" && <ArrowDown aria-hidden className="size-icon-xs" strokeWidth={2.5} />}
          {(!delta.direction || delta.direction === "flat") && <Minus aria-hidden className="size-icon-xs" />}
          {/* The arrow and colour are decorative; say the direction in words too. */}
          {delta.direction === "up" && <span className="sr-only">Up </span>}
          {delta.direction === "down" && <span className="sr-only">Down </span>}
          {delta.value}
        </div>
      )}
    </div>
  );
});
StatCard.displayName = "StatCard";
