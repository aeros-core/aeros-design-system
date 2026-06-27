"use client";
import * as React from "react";
import * as RG from "@radix-ui/react-radio-group";
import { cn } from "../lib/cn";

export const RadioGroup = React.forwardRef<
  React.ElementRef<typeof RG.Root>,
  React.ComponentPropsWithoutRef<typeof RG.Root>
>(({ className, ...props }, ref) => (
  <RG.Root ref={ref} className={cn("grid gap-2", className)} {...props} />
));
RadioGroup.displayName = "RadioGroup";

export const RadioGroupItem = React.forwardRef<
  React.ElementRef<typeof RG.Item>,
  React.ComponentPropsWithoutRef<typeof RG.Item>
>(({ className, ...props }, ref) => (
  <RG.Item
    ref={ref}
    className={cn(
      "aspect-square h-[18px] w-[18px] rounded-full border-[1.5px] border-border-strong bg-bg-surface",
      "transition-colors hover:border-border-focus focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-focus-ring focus-visible:ring-offset-2 focus-visible:ring-offset-bg-canvas",
      "data-[state=checked]:border-brand-primary",
      "disabled:opacity-40",
      className
    )}
    {...props}
  >
    <RG.Indicator className="flex h-full w-full items-center justify-center after:h-2 after:w-2 after:rounded-full after:bg-brand-primary after:content-['']" />
  </RG.Item>
));
RadioGroupItem.displayName = "RadioGroupItem";
