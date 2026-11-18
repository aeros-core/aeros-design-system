"use client";
import * as React from "react";
import * as RL from "@radix-ui/react-label";
import { cn } from "../lib/cn";

/** Standalone label for controls used outside a `<Field>` wrapper. */
export const Label = React.forwardRef<
  React.ElementRef<typeof RL.Root>,
  React.ComponentPropsWithoutRef<typeof RL.Root>
>(({ className, ...props }, ref) => (
  <RL.Root
    ref={ref}
    className={cn(
      "text-label-sm text-fg-primary select-none",
      "peer-disabled:cursor-not-allowed peer-disabled:opacity-disabled",
      className
    )}
    {...props}
  />
));
Label.displayName = "Label";
