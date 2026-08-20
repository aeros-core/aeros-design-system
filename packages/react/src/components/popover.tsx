"use client";
import * as React from "react";
import * as RP from "@radix-ui/react-popover";
import { cn } from "../lib/cn";

export const Popover: typeof RP.Root = RP.Root;
export const PopoverTrigger: typeof RP.Trigger = RP.Trigger;
export const PopoverAnchor: typeof RP.Anchor = RP.Anchor;
export const PopoverClose: typeof RP.Close = RP.Close;

export const PopoverContent = React.forwardRef<
  React.ElementRef<typeof RP.Content>,
  React.ComponentPropsWithoutRef<typeof RP.Content>
>(({ className, align = "center", sideOffset = 6, ...props }, ref) => (
  <RP.Portal>
    <RP.Content
      ref={ref}
      align={align}
      sideOffset={sideOffset}
      className={cn(
        "z-(--aeros-z-popover) w-72 rounded-lg border border-border-default bg-bg-elevated p-4 shadow-lg outline-none",
        "max-h-[var(--radix-popover-content-available-height)] overflow-y-auto",
        "data-[state=open]:animate-in data-[state=closed]:animate-out data-[state=closed]:fade-out-0 data-[state=open]:fade-in-0 data-[state=closed]:zoom-out-95 data-[state=open]:zoom-in-95 data-[side=bottom]:slide-in-from-top-1 data-[side=top]:slide-in-from-bottom-1 data-[side=right]:slide-in-from-left-1 data-[side=left]:slide-in-from-right-1 data-[state=open]:duration-(--aeros-duration-fast) data-[state=open]:ease-(--aeros-ease-entrance)",
        className
      )}
      {...props}
    />
  </RP.Portal>
));
PopoverContent.displayName = "PopoverContent";
