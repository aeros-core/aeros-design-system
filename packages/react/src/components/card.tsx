import * as React from "react";
import { cn } from "../lib/cn";

export interface CardProps extends React.HTMLAttributes<HTMLDivElement> {
  /** Adds a hover elevation lift — use for clickable cards (links, selectable items). */
  interactive?: boolean;
}

export const Card = React.forwardRef<HTMLDivElement, CardProps>(
  ({ className, interactive, ...props }, ref) => (
    <div
      ref={ref}
      className={cn(
        "rounded-xl border border-border-default bg-bg-surface shadow-sm overflow-hidden",
        interactive &&
          "transition-[box-shadow,transform] duration-200 ease-[cubic-bezier(0.3,0,0,1)] hover:shadow-md hover:-translate-y-0.5 cursor-pointer",
        className
      )}
      {...props}
    />
  )
);
Card.displayName = "Card";

export const CardHeader = React.forwardRef<HTMLDivElement, React.HTMLAttributes<HTMLDivElement>>(
  ({ className, ...props }, ref) => (
    <div
      ref={ref}
      className={cn("flex items-start justify-between gap-3 px-5 pt-[18px] pb-3 border-b border-border-default", className)}
      {...props}
    />
  )
);
CardHeader.displayName = "CardHeader";

export const CardTitle = React.forwardRef<HTMLHeadingElement, React.HTMLAttributes<HTMLHeadingElement>>(
  ({ className, ...props }, ref) => (
    <h3
      ref={ref}
      className={cn("text-[18px] font-semibold leading-snug tracking-[-0.01em] text-fg-primary", className)}
      {...props}
    />
  )
);
CardTitle.displayName = "CardTitle";

export const CardSubtitle = React.forwardRef<HTMLParagraphElement, React.HTMLAttributes<HTMLParagraphElement>>(
  ({ className, ...props }, ref) => (
    <p ref={ref} className={cn("mt-0.5 text-xs text-fg-muted", className)} {...props} />
  )
);
CardSubtitle.displayName = "CardSubtitle";

export const CardBody = React.forwardRef<HTMLDivElement, React.HTMLAttributes<HTMLDivElement>>(
  ({ className, ...props }, ref) => (
    <div ref={ref} className={cn("px-5 py-[18px]", className)} {...props} />
  )
);
CardBody.displayName = "CardBody";

export const CardFooter = React.forwardRef<HTMLDivElement, React.HTMLAttributes<HTMLDivElement>>(
  ({ className, ...props }, ref) => (
    <div
      ref={ref}
      className={cn(
        "flex items-center justify-between gap-3 px-5 py-3 bg-bg-subtle border-t border-border-default",
        className
      )}
      {...props}
    />
  )
);
CardFooter.displayName = "CardFooter";
