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
        "overflow-hidden rounded-surface border border-border-default bg-bg-surface",
        interactive &&
          "cursor-pointer transition-colors duration-fast ease-standard hover:border-border-strong hover:bg-bg-subtle",
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
      className={cn("flex items-start justify-between gap-3 border-b border-border-default px-4 py-3", className)}
      {...props}
    />
  )
);
CardHeader.displayName = "CardHeader";

export const CardTitle = React.forwardRef<HTMLHeadingElement, React.HTMLAttributes<HTMLHeadingElement>>(
  ({ className, children, ...props }, ref) => (
    <h3
      ref={ref}
      className={cn("text-h3 text-fg-primary", className)}
      {...props}
    >
      {children}
    </h3>
  )
);
CardTitle.displayName = "CardTitle";

export const CardSubtitle = React.forwardRef<HTMLParagraphElement, React.HTMLAttributes<HTMLParagraphElement>>(
  ({ className, ...props }, ref) => (
    <p ref={ref} className={cn("mt-0.5 text-caption text-fg-muted", className)} {...props} />
  )
);
CardSubtitle.displayName = "CardSubtitle";

export const CardBody = React.forwardRef<HTMLDivElement, React.HTMLAttributes<HTMLDivElement>>(
  ({ className, ...props }, ref) => (
    <div ref={ref} className={cn("p-4", className)} {...props} />
  )
);
CardBody.displayName = "CardBody";

export const CardFooter = React.forwardRef<HTMLDivElement, React.HTMLAttributes<HTMLDivElement>>(
  ({ className, ...props }, ref) => (
    <div
      ref={ref}
      className={cn(
        "flex items-center justify-between gap-3 border-t border-border-default px-4 py-3",
        className
      )}
      {...props}
    />
  )
);
CardFooter.displayName = "CardFooter";
