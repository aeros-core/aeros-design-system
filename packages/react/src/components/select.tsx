"use client";
import * as React from "react";
import * as RS from "@radix-ui/react-select";
import { Check, ChevronDown } from "lucide-react";
import { cn } from "../lib/cn";

export const Select = RS.Root;
export const SelectValue = RS.Value;
export const SelectGroup = RS.Group;

export const SelectTrigger = React.forwardRef<
  React.ElementRef<typeof RS.Trigger>,
  React.ComponentPropsWithoutRef<typeof RS.Trigger>
>(({ className, children, ...props }, ref) => (
  <RS.Trigger
    ref={ref}
    className={cn(
      "flex h-10 w-full items-center justify-between rounded-md border border-border-default bg-bg-surface px-3.5 text-sm font-medium text-fg-primary",
      "hover:border-border-strong focus:outline-none focus:border-royal-400 focus:shadow-[0_0_0_3px_var(--aeros-focus-ring)]",
      "data-[placeholder]:text-ink-200 disabled:opacity-50",
      className
    )}
    {...props}
  >
    {children}
    <RS.Icon asChild>
      <ChevronDown className="h-4 w-4 text-slate-400" />
    </RS.Icon>
  </RS.Trigger>
));
SelectTrigger.displayName = "SelectTrigger";

export const SelectContent = React.forwardRef<
  React.ElementRef<typeof RS.Content>,
  React.ComponentPropsWithoutRef<typeof RS.Content>
>(({ className, children, position = "popper", ...props }, ref) => (
  <RS.Portal>
    <RS.Content
      ref={ref}
      position={position}
      sideOffset={4}
      className={cn(
        "z-[1500] min-w-[var(--radix-select-trigger-width)] overflow-hidden rounded-lg border border-border-default bg-bg-surface p-1.5 shadow-md",
        "data-[state=open]:animate-in data-[state=closed]:animate-out data-[state=closed]:fade-out-0 data-[state=open]:fade-in-0",
        className
      )}
      {...props}
    >
      <RS.Viewport className="p-0">{children}</RS.Viewport>
    </RS.Content>
  </RS.Portal>
));
SelectContent.displayName = "SelectContent";

export const SelectItem = React.forwardRef<
  React.ElementRef<typeof RS.Item>,
  React.ComponentPropsWithoutRef<typeof RS.Item>
>(({ className, children, ...props }, ref) => (
  <RS.Item
    ref={ref}
    className={cn(
      "relative flex cursor-pointer select-none items-center rounded-md py-2 pl-8 pr-2.5 text-sm font-medium text-fg-secondary",
      "focus:bg-slate-50 focus:text-fg-primary focus:outline-none data-[state=checked]:text-royal-600 data-[state=checked]:font-semibold",
      className
    )}
    {...props}
  >
    <span className="absolute left-2 flex h-4 w-4 items-center justify-center">
      <RS.ItemIndicator>
        <Check className="h-3.5 w-3.5" />
      </RS.ItemIndicator>
    </span>
    <RS.ItemText>{children}</RS.ItemText>
  </RS.Item>
));
SelectItem.displayName = "SelectItem";

export const SelectSeparator = React.forwardRef<
  React.ElementRef<typeof RS.Separator>,
  React.ComponentPropsWithoutRef<typeof RS.Separator>
>(({ className, ...props }, ref) => (
  <RS.Separator ref={ref} className={cn("my-1 h-px bg-border-default", className)} {...props} />
));
SelectSeparator.displayName = "SelectSeparator";
