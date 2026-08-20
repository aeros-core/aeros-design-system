import * as React from "react";
import { cn } from "../lib/cn";

export interface SpinnerProps extends React.HTMLAttributes<HTMLSpanElement> {
  size?: "sm" | "md" | "lg";
  /** Announced to assistive tech (visually hidden). */
  label?: string;
}

const sizeClasses = {
  sm: "h-3.5 w-3.5 border-2",
  md: "h-5 w-5 border-2",
  lg: "h-7 w-7 border-[3px]"
};

export const Spinner = React.forwardRef<HTMLSpanElement, SpinnerProps>(
  ({ className, size = "md", label = "Loading", ...props }, ref) => (
    <span ref={ref} role="status" className={cn("inline-flex", className)} {...props}>
      <span
        aria-hidden
        className={cn(
          "inline-block animate-spin rounded-full border-current border-r-transparent text-fg-muted",
          sizeClasses[size]
        )}
      />
      <span className="sr-only">{label}</span>
    </span>
  )
);
Spinner.displayName = "Spinner";
