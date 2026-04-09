"use client";
import * as React from "react";
import * as RT from "@radix-ui/react-tooltip";
import { cn } from "../lib/cn";

export const TooltipProvider = RT.Provider;
export const Tooltip = RT.Root;
export const TooltipTrigger = RT.Trigger;

export const TooltipContent = React.forwardRef<
  React.ElementRef<typeof RT.Content>,
  React.ComponentPropsWithoutRef<typeof RT.Content>
>(({ className, sideOffset = 8, ...props }, ref) => (
  <RT.Portal>
    <RT.Content
      ref={ref}
      sideOffset={sideOffset}
      className={cn(
        "z-[1700] rounded-md bg-ink-900 px-2.5 py-1.5 text-xs font-medium text-white shadow-md",
        "data-[state=delayed-open]:animate-in data-[state=closed]:animate-out data-[state=closed]:fade-out-0 data-[state=delayed-open]:fade-in-0",
        className
      )}
      {...props}
    />
  </RT.Portal>
));
TooltipContent.displayName = "TooltipContent";
