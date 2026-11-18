import * as React from "react";
import { cn } from "../lib/cn";

export type CountBadgeTone = "solid" | "muted" | "danger";

const toneMap: Record<CountBadgeTone, string> = {
  solid: "bg-bg-inverse text-fg-inverse",
  muted: "bg-border-default text-fg-secondary",
  danger: "bg-danger text-fg-inverse"
};

export interface CountBadgeProps extends Omit<React.HTMLAttributes<HTMLSpanElement>, "children" | "aria-label"> {
  count: number;
  /** Counts above this read as "<max>+". */
  max?: number;
  tone?: CountBadgeTone;
  /** Render at zero. By default a zero count renders nothing. */
  showZero?: boolean;
  /** What the number means, read in place of the bare digits — e.g. "3 unread". */
  "aria-label"?: string;
}

/** A numeric pill: unread, pending, selected. */
export const CountBadge = React.forwardRef<HTMLSpanElement, CountBadgeProps>(
  ({ count, max = 99, tone = "solid", showZero = false, "aria-label": ariaLabel, className, ...props }, ref) => {
    if (count <= 0 && !showZero) return null;
    const text = count > max ? `${max}+` : String(Math.max(count, 0));
    return (
      <span
        ref={ref}
        className={cn(
          "inline-flex h-badge min-w-badge shrink-0 items-center justify-center rounded-pill px-1.5 text-label-xs tabular-nums",
          toneMap[tone],
          className
        )}
        {...props}
      >
        {/* A span has no role to carry aria-label, so the label is real (hidden) text. */}
        {ariaLabel ? (
          <>
            <span aria-hidden>{text}</span>
            <span className="sr-only">{ariaLabel}</span>
          </>
        ) : (
          text
        )}
      </span>
    );
  }
);
CountBadge.displayName = "CountBadge";
