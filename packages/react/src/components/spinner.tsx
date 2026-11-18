import * as React from "react";
import { cn } from "../lib/cn";

export interface SpinnerProps extends React.HTMLAttributes<HTMLSpanElement> {
  size?: "sm" | "md" | "lg";
  /** Announced to assistive tech (visually hidden). */
  label?: string;
}

const sizeClasses = {
  sm: "size-icon-sm border-2",
  md: "size-icon-lg border-2",
  lg: "size-7 border-2"
};

export const Spinner = React.forwardRef<HTMLSpanElement, SpinnerProps>(
  ({ className, size = "md", label = "Loading", ...props }, ref) => (
    <span ref={ref} role="status" className={cn("inline-flex text-fg-muted", className)} {...props}>
      <span
        aria-hidden
        className={cn(
          "inline-block animate-spin rounded-full border-current border-r-transparent",
          sizeClasses[size]
        )}
      />
      <span className="sr-only">{label}</span>
    </span>
  )
);
Spinner.displayName = "Spinner";
