"use client";
import * as React from "react";
import * as RC from "@radix-ui/react-checkbox";
import { Check, Minus } from "lucide-react";
import { cn } from "../lib/cn";
import { colorTransition } from "../internal/recipes";

export const Checkbox = React.forwardRef<
  React.ElementRef<typeof RC.Root>,
  React.ComponentPropsWithoutRef<typeof RC.Root>
>(({ className, ...props }, ref) => (
  <RC.Root
    ref={ref}
    className={cn(
      "group peer size-4 shrink-0 rounded-item border border-border-strong bg-bg-surface text-fg-inverse",
      colorTransition,
      "hover:border-fg-muted",
      "data-[state=checked]:border-brand-primary data-[state=checked]:bg-brand-primary",
      "data-[state=indeterminate]:border-brand-primary data-[state=indeterminate]:bg-brand-primary",
      "disabled:cursor-not-allowed disabled:opacity-disabled",
      className
    )}
    {...props}
  >
    {/* Icon choice is driven by data-state so uncontrolled indeterminate works too. */}
    <RC.Indicator className="flex items-center justify-center text-current">
      <Check className="size-icon-xs group-data-[state=indeterminate]:hidden" strokeWidth={3} />
      <Minus className="hidden size-icon-xs group-data-[state=indeterminate]:block" strokeWidth={3} />
    </RC.Indicator>
  </RC.Root>
));
Checkbox.displayName = "Checkbox";
