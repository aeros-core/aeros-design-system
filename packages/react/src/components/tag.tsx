import * as React from "react";
import { cva, type VariantProps } from "class-variance-authority";
import { cn } from "../lib/cn";

const tagVariants = cva(
  "inline-flex items-center rounded-md px-2 py-0.5 text-[11px] font-semibold whitespace-nowrap",
  {
    variants: {
      variant: {
        info:    "bg-info-bg text-info-text",
        neutral: "bg-bg-subtle text-fg-secondary border border-border-default",
        inverse: "bg-bg-inverse text-fg-inverse"
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
