import * as React from "react";
import { cva, type VariantProps } from "class-variance-authority";
import { cn } from "../lib/cn";

const tagVariants = cva(
  "inline-flex items-center rounded-md px-2 py-0.5 text-[11px] font-semibold whitespace-nowrap",
  {
    variants: {
      variant: {
        blue:  "bg-royal-50 text-royal-800",
        grey:  "bg-ink-50 text-ink-600 border border-ink-100",
        slate: "bg-slate-800 text-slate-200"
      }
    },
    defaultVariants: { variant: "grey" }
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
