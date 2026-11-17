"use client";
import * as React from "react";
import * as RS from "@radix-ui/react-switch";
import { cn } from "../lib/cn";
import { colorTransition } from "../internal/recipes";

export const Switch = React.forwardRef<
  React.ElementRef<typeof RS.Root>,
  React.ComponentPropsWithoutRef<typeof RS.Root>
>(({ className, ...props }, ref) => (
  <RS.Root
    ref={ref}
    className={cn(
      "peer inline-flex h-5 w-9 shrink-0 cursor-pointer items-center rounded-full bg-border-strong",
      colorTransition,
      "hover:bg-fg-disabled data-[state=checked]:bg-brand-primary data-[state=checked]:hover:bg-brand-primary-hover",
      "disabled:cursor-not-allowed disabled:opacity-disabled",
      className
    )}
    {...props}
  >
    <RS.Thumb className="pointer-events-none block size-4 translate-x-0.5 rounded-full bg-bg-surface shadow-raised transition-transform duration-base ease-standard data-[state=checked]:translate-x-4.5" />
  </RS.Root>
));
Switch.displayName = "Switch";
