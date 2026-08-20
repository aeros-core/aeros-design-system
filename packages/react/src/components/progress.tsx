"use client";
import * as React from "react";
import * as RP from "@radix-ui/react-progress";
import { cn } from "../lib/cn";

export interface ProgressProps extends React.ComponentPropsWithoutRef<typeof RP.Root> {
  variant?: "brand" | "success" | "warning" | "danger";
}

const variantMap: Record<NonNullable<ProgressProps["variant"]>, string> = {
  brand:   "bg-brand-primary",
  success: "bg-success",
  warning: "bg-warning",
  danger:  "bg-danger"
};

export const Progress = React.forwardRef<React.ElementRef<typeof RP.Root>, ProgressProps>(
  ({ className, value = 0, variant = "brand", ...props }, ref) => (
    <RP.Root
      ref={ref}
      className={cn("relative h-1.5 w-full overflow-hidden rounded-full bg-bg-subtle", className)}
      value={value}
      {...props}
    >
      <RP.Indicator
        className={cn("h-full w-full transition-transform duration-(--aeros-duration-slow) ease-(--aeros-ease-standard)", variantMap[variant])}
        style={{ transform: `translateX(-${100 - (value ?? 0)}%)` }}
      />
    </RP.Root>
  )
);
Progress.displayName = "Progress";
