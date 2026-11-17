import * as React from "react";
import { cva, type VariantProps } from "class-variance-authority";
import { cn } from "../lib/cn";

const badgeVariants = cva(
  "inline-flex h-5 items-center gap-1.5 whitespace-nowrap rounded-pill border px-2 text-label-xs",
  {
    variants: {
      variant: {
        success: "border-success-border bg-success-bg text-success-text",
        warning: "border-warning-border bg-warning-bg text-warning-text",
        danger:  "border-danger-border bg-danger-bg text-danger-text",
        info:    "border-info-border bg-info-bg text-info-text",
        neutral: "border-border-default bg-bg-surface text-fg-secondary",
        inverse: "border-transparent bg-bg-inverse text-fg-inverse"
      }
    },
    defaultVariants: { variant: "neutral" }
  }
);

const dotColor: Record<NonNullable<VariantProps<typeof badgeVariants>["variant"]>, string> = {
  success: "bg-success",
  warning: "bg-warning",
  danger:  "bg-danger",
  info:    "bg-info",
  neutral: "bg-fg-muted",
  inverse: "bg-fg-disabled"
};

export interface BadgeProps
  extends React.HTMLAttributes<HTMLSpanElement>,
    VariantProps<typeof badgeVariants> {
  dot?: boolean;
}

export const Badge = React.forwardRef<HTMLSpanElement, BadgeProps>(
  ({ className, variant = "neutral", dot, children, ...props }, ref) => (
    <span ref={ref} className={cn(badgeVariants({ variant }), className)} {...props}>
      {dot && <span className={cn("size-1.5 shrink-0 rounded-full", dotColor[variant!])} />}
      {children}
    </span>
  )
);
Badge.displayName = "Badge";

export { badgeVariants };
