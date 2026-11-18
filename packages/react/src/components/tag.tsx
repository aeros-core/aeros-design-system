import * as React from "react";
import { cva, type VariantProps } from "class-variance-authority";
import { cn } from "../lib/cn";

const tagVariants = cva(
  "inline-flex h-5 items-center whitespace-nowrap rounded-item border px-1.5 text-label-xs",
  {
    variants: {
      variant: {
        info:    "border-info-border bg-info-bg text-info-text",
        neutral: "border-border-default bg-bg-surface text-fg-secondary",
        inverse: "border-transparent bg-bg-inverse text-fg-inverse"
      }
    },
    defaultVariants: { variant: "neutral" }
  }
);

export interface TagProps
  extends React.HTMLAttributes<HTMLSpanElement>,
    VariantProps<typeof tagVariants> {}

export const Tag = React.forwardRef<HTMLSpanElement, TagProps>(
  ({ className, variant, ...props }, ref) => (
    <span ref={ref} className={cn(tagVariants({ variant }), className)} {...props} />
  )
);
Tag.displayName = "Tag";

export { tagVariants };
