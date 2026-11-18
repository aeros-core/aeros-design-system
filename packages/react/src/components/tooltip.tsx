"use client";
import * as React from "react";
import * as RT from "@radix-ui/react-tooltip";
import { cn } from "../lib/cn";

export const TooltipProvider: typeof RT.Provider = RT.Provider;
export const Tooltip: typeof RT.Root = RT.Root;
export const TooltipTrigger: typeof RT.Trigger = RT.Trigger;

export const TooltipContent = React.forwardRef<
  React.ElementRef<typeof RT.Content>,
  React.ComponentPropsWithoutRef<typeof RT.Content> & {
    /** Draw a small pointer toward the trigger. */
    arrow?: boolean;
  }
>(({ className, sideOffset = 6, arrow, children, ...props }, ref) => (
  <RT.Portal>
    <RT.Content
      ref={ref}
      sideOffset={sideOffset}
      className={cn(
        "z-tooltip max-w-xs rounded-item bg-bg-inverse px-2 py-1 text-caption text-fg-inverse",
        "data-[state=delayed-open]:animate-in data-[state=instant-open]:animate-in data-[state=closed]:animate-out",
        "data-[state=delayed-open]:fade-in-0 data-[state=instant-open]:fade-in-0 data-[state=closed]:fade-out-0",
        "data-[state=delayed-open]:zoom-in-97 data-[state=closed]:zoom-out-97",
        "data-[state=delayed-open]:duration-fast data-[state=delayed-open]:ease-enter data-[state=closed]:duration-quick data-[state=closed]:ease-exit",
        className
      )}
      {...props}
    >
      {children}
      {arrow && <RT.Arrow className="fill-bg-inverse" width={10} height={5} />}
    </RT.Content>
  </RT.Portal>
));
TooltipContent.displayName = "TooltipContent";
