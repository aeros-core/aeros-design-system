"use client";
import * as React from "react";
import * as RD from "@radix-ui/react-dropdown-menu";
import { cn } from "../lib/cn";

export const DropdownMenu: typeof RD.Root = RD.Root;
export const DropdownMenuTrigger: typeof RD.Trigger = RD.Trigger;
export const DropdownMenuGroup: typeof RD.Group = RD.Group;
export const DropdownMenuPortal: typeof RD.Portal = RD.Portal;

export const DropdownMenuContent = React.forwardRef<
  React.ElementRef<typeof RD.Content>,
  React.ComponentPropsWithoutRef<typeof RD.Content>
>(({ className, sideOffset = 6, ...props }, ref) => (
  <RD.Portal>
    <RD.Content
      ref={ref}
      sideOffset={sideOffset}
      className={cn(
        "z-[1500] min-w-[200px] overflow-hidden rounded-lg border border-border-default bg-bg-elevated p-1.5 shadow-lg",
        "data-[state=open]:animate-in data-[state=closed]:animate-out data-[state=closed]:fade-out-0 data-[state=open]:fade-in-0 data-[state=closed]:zoom-out-95 data-[state=open]:zoom-in-95 data-[side=bottom]:slide-in-from-top-1 data-[side=top]:slide-in-from-bottom-1 data-[side=right]:slide-in-from-left-1 data-[side=left]:slide-in-from-right-1 data-[state=open]:duration-150 data-[state=open]:ease-[cubic-bezier(0.16,1,0.3,1)]",
        className
      )}
      {...props}
    />
  </RD.Portal>
));
DropdownMenuContent.displayName = "DropdownMenuContent";

export const DropdownMenuItem = React.forwardRef<
  React.ElementRef<typeof RD.Item>,
  React.ComponentPropsWithoutRef<typeof RD.Item> & { destructive?: boolean }
>(({ className, destructive, ...props }, ref) => (
  <RD.Item
    ref={ref}
    className={cn(
      "flex cursor-pointer items-center gap-2.5 rounded-md px-[11px] py-2 text-[13px] font-medium text-fg-secondary",
      "transition-colors duration-[90ms] focus:bg-bg-subtle focus:text-fg-primary focus:outline-none",
      destructive && "text-danger-text focus:bg-danger-bg",
      className
    )}
    {...props}
  />
));
DropdownMenuItem.displayName = "DropdownMenuItem";

export const DropdownMenuSeparator = React.forwardRef<
  React.ElementRef<typeof RD.Separator>,
  React.ComponentPropsWithoutRef<typeof RD.Separator>
>(({ className, ...props }, ref) => (
  <RD.Separator ref={ref} className={cn("my-1 h-px bg-border-default", className)} {...props} />
));
DropdownMenuSeparator.displayName = "DropdownMenuSeparator";

export const DropdownMenuLabel = React.forwardRef<
  React.ElementRef<typeof RD.Label>,
  React.ComponentPropsWithoutRef<typeof RD.Label>
>(({ className, ...props }, ref) => (
  <RD.Label
    ref={ref}
    className={cn("px-[11px] pt-1.5 pb-0.5 text-[10px] font-semibold uppercase tracking-[0.06em] text-fg-muted", className)}
    {...props}
  />
));
DropdownMenuLabel.displayName = "DropdownMenuLabel";
