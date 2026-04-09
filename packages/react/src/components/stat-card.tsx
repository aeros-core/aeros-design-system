import * as React from "react";
import { ArrowUp, ArrowDown, Minus } from "lucide-react";
import { cn } from "../lib/cn";

export interface StatCardProps extends React.HTMLAttributes<HTMLDivElement> {
  label: string;
  value: React.ReactNode;
  mono?: boolean;
  delta?: { value: string; direction?: "up" | "down" | "flat" };
}

export function StatCard({ label, value, mono, delta, className, ...props }: StatCardProps) {
  return (
    <div
      className={cn(
        "rounded-xl border border-border-default bg-bg-surface p-[22px]",
        className
      )}
      {...props}
    >
      <div className="text-[11px] font-semibold uppercase tracking-[0.08em] text-slate-400 mb-2">
        {label}
      </div>
      <div
        className={cn(
          "text-[28px] font-extrabold tracking-[-0.03em] text-fg-primary leading-none",
          mono && "font-mono font-medium text-[26px] text-royal-900"
        )}
      >
        {value}
      </div>
      {delta && (
        <div
          className={cn(
            "mt-3 inline-flex items-center gap-1 text-xs font-semibold",
            delta.direction === "up" && "text-success",
            delta.direction === "down" && "text-danger",
            (!delta.direction || delta.direction === "flat") && "text-fg-muted font-normal"
          )}
        >
          {delta.direction === "up" && <ArrowUp className="h-3 w-3" strokeWidth={3} />}
          {delta.direction === "down" && <ArrowDown className="h-3 w-3" strokeWidth={3} />}
          {(!delta.direction || delta.direction === "flat") && <Minus className="h-3 w-3" />}
          {delta.value}
        </div>
      )}
    </div>
  );
}
