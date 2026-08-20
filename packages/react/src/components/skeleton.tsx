import * as React from "react";
import { cn } from "../lib/cn";

/**
 * Loading placeholder. Hidden from assistive tech — pair the region with a
 * visually-hidden "Loading" announcement (e.g. a `<Spinner>`) or `aria-busy`
 * on the container.
 */
export const Skeleton = React.forwardRef<HTMLDivElement, React.HTMLAttributes<HTMLDivElement>>(
  ({ className, ...props }, ref) => (
    <div
      ref={ref}
      aria-hidden
      className={cn("animate-pulse rounded-md bg-bg-subtle motion-reduce:animate-none", className)}
      {...props}
    />
  )
);
Skeleton.displayName = "Skeleton";
