"use client";
import * as React from "react";
import * as RC from "@radix-ui/react-checkbox";
import { Check, Minus } from "lucide-react";
import { cn } from "../lib/cn";

export const Checkbox = React.forwardRef<
  React.ElementRef<typeof RC.Root>,
  React.ComponentPropsWithoutRef<typeof RC.Root>
>(({ className, ...props }, ref) => (
  <RC.Root
    ref={ref}
    className={cn(
      "peer h-[18px] w-[18px] shrink-0 rounded-[5px] border-[1.5px] border-border-strong bg-bg-surface",
      "transition-colors duration-[120ms]",
      "hover:border-royal-400",
      "focus-visible:outline-none focus-visible:ring-[3px] focus-visible:ring-royal-100",
      "data-[state=checked]:bg-royal-600 data-[state=checked]:border-royal-600 data-[state=checked]:text-white",
      "data-[state=indeterminate]:bg-royal-600 data-[state=indeterminate]:border-royal-600 data-[state=indeterminate]:text-white",
      "disabled:opacity-40 disabled:cursor-not-allowed",
      className
    )}
    {...props}
  >
    <RC.Indicator className="flex items-center justify-center text-current">
      {props.checked === "indeterminate" ? <Minus className="h-3 w-3" /> : <Check className="h-3 w-3" strokeWidth={3} />}
    </RC.Indicator>
  </RC.Root>
));
Checkbox.displayName = "Checkbox";
