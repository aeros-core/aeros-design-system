"use client";
import * as React from "react";
import * as RP from "@radix-ui/react-progress";
import { cn } from "../lib/cn";

export interface ProgressProps extends React.ComponentPropsWithoutRef<typeof RP.Root> {
  color?: "royal" | "success" | "warning" | "danger";
}

const colorMap: Record<NonNullable<ProgressProps["color"]>, string> = {
  royal:   "bg-royal-600",
  success: "bg-success",
  warning: "bg-warning",
  danger:  "bg-danger"
};

export const Progress = React.forwardRef<React.ElementRef<typeof RP.Root>, ProgressProps>(
  ({ className, value = 0, color = "royal", ...props }, ref) => (
    <RP.Root
      ref={ref}
      className={cn("relative h-1.5 w-full overflow-hidden rounded-full bg-slate-100", className)}
      value={value}
      {...props}
    >
      <RP.Indicator
        className={cn("h-full w-full transition-transform duration-[320ms]", colorMap[color])}
        style={{ transform: `translateX(-${100 - (value ?? 0)}%)` }}
      />
    </RP.Root>
  )
);
Progress.displayName = "Progress";
