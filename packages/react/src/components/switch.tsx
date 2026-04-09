"use client";
import * as React from "react";
import * as RS from "@radix-ui/react-switch";
import { cn } from "../lib/cn";

export const Switch = React.forwardRef<
  React.ElementRef<typeof RS.Root>,
  React.ComponentPropsWithoutRef<typeof RS.Root>
>(({ className, ...props }, ref) => (
  <RS.Root
    ref={ref}
    className={cn(
      "peer inline-flex h-6 w-[42px] shrink-0 cursor-pointer items-center rounded-full transition-colors",
      "bg-ink-200 data-[state=checked]:bg-royal-600",
      "focus-visible:outline-none focus-visible:ring-[3px] focus-visible:ring-royal-100",
      "disabled:opacity-40 disabled:cursor-not-allowed",
      className
    )}
    {...props}
  >
    <RS.Thumb className="pointer-events-none block h-[18px] w-[18px] translate-x-[3px] rounded-full bg-white shadow-[0_1px_3px_rgba(0,0,0,0.18)] transition-transform data-[state=checked]:translate-x-[21px]" />
  </RS.Root>
));
Switch.displayName = "Switch";
