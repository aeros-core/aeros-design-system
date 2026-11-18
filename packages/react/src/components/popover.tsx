"use client";
import * as React from "react";
import * as RP from "@radix-ui/react-popover";
import { cn } from "../lib/cn";
import { floatingPanel } from "../internal/recipes";

export const Popover: typeof RP.Root = RP.Root;
export const PopoverTrigger: typeof RP.Trigger = RP.Trigger;
export const PopoverAnchor: typeof RP.Anchor = RP.Anchor;
export const PopoverClose: typeof RP.Close = RP.Close;

export const PopoverContent = React.forwardRef<
  React.ElementRef<typeof RP.Content>,
  React.ComponentPropsWithoutRef<typeof RP.Content>
>(({ className, align = "center", sideOffset = 4, ...props }, ref) => (
  <RP.Portal>
    <RP.Content
      ref={ref}
      align={align}
      sideOffset={sideOffset}
      className={cn(
        floatingPanel,
        "w-72 max-h-(--radix-popover-content-available-height) overflow-y-auto p-3 text-body-sm",
        className
      )}
      {...props}
    />
  </RP.Portal>
));
PopoverContent.displayName = "PopoverContent";
