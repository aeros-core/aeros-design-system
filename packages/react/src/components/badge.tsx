import * as React from "react";
import { cva, type VariantProps } from "class-variance-authority";
import { cn } from "../lib/cn";

const badgeVariants = cva(
  "inline-flex items-center gap-1.5 rounded-full px-2.5 py-1 text-[11px] font-semibold leading-none whitespace-nowrap",
  {
    variants: {
      variant: {
        green: "bg-success-bg text-success-text",
        amber: "bg-warning-bg text-warning-text",
        red:   "bg-danger-bg text-danger-text",
        blue:  "bg-royal-50 text-royal-800",
        grey:  "bg-ink-50 text-ink-600",
        dark:  "bg-slate-900 text-slate-200"
      }
    },
    defaultVariants: { variant: "grey" }
  }
);

const dotColor: Record<NonNullable<VariantProps<typeof badgeVariants>["variant"]>, string> = {
  green: "bg-success",
  amber: "bg-warning",
  red:   "bg-danger",
  blue:  "bg-royal-600",
  grey:  "bg-ink-400",
  dark:  "bg-slate-400"
};

export interface BadgeProps
  extends React.HTMLAttributes<HTMLSpanElement>,
    VariantProps<typeof badgeVariants> {
  dot?: boolean;
}

export const Badge = React.forwardRef<HTMLSpanElement, BadgeProps>(
  ({ className, variant = "grey", dot, children, ...props }, ref) => (
    <span ref={ref} className={cn(badgeVariants({ variant }), className)} {...props}>
      {dot && <span className={cn("h-1.5 w-1.5 rounded-full shrink-0", dotColor[variant!])} />}
      {children}
    </span>
  )
);
Badge.displayName = "Badge";

export { badgeVariants };
