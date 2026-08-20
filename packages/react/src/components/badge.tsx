import * as React from "react";
import { cva, type VariantProps } from "class-variance-authority";
import { cn } from "../lib/cn";

const badgeVariants = cva(
  "inline-flex items-center gap-1.5 rounded-full px-2.5 py-1 text-[11px] font-semibold leading-none whitespace-nowrap",
  {
    variants: {
      variant: {
        success: "bg-success-bg text-success-text",
        warning: "bg-warning-bg text-warning-text",
        danger:  "bg-danger-bg text-danger-text",
        info:    "bg-info-bg text-info-text",
        neutral: "bg-bg-subtle text-fg-secondary",
        inverse: "bg-bg-inverse text-fg-inverse"
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
  inverse: "bg-ink-400"
};

export interface BadgeProps
  extends React.HTMLAttributes<HTMLSpanElement>,
    VariantProps<typeof badgeVariants> {
  dot?: boolean;
}

export const Badge = React.forwardRef<HTMLSpanElement, BadgeProps>(
  ({ className, variant = "neutral", dot, children, ...props }, ref) => (
    <span ref={ref} className={cn(badgeVariants({ variant }), className)} {...props}>
      {dot && <span className={cn("h-1.5 w-1.5 rounded-full shrink-0", dotColor[variant!])} />}
      {children}
    </span>
  )
);
Badge.displayName = "Badge";

export { badgeVariants };
