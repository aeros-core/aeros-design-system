"use client";
import * as React from "react";
import * as RG from "@radix-ui/react-radio-group";
import { cn } from "../lib/cn";
import { colorTransition } from "../internal/recipes";

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
      "size-4 shrink-0 rounded-full border border-border-strong bg-bg-surface",
      colorTransition,
      "hover:border-fg-muted data-[state=checked]:border-brand-primary",
      "disabled:cursor-not-allowed disabled:opacity-disabled",
      className
    )}
    {...props}
  >
    <RG.Indicator className="flex h-full w-full items-center justify-center after:size-2 after:rounded-full after:bg-brand-primary after:content-['']" />
  </RG.Item>
));
RadioGroupItem.displayName = "RadioGroupItem";
