"use client";
import * as React from "react";
import * as RS from "@radix-ui/react-select";
import { Check, ChevronDown, ChevronUp } from "lucide-react";
import { cn } from "../lib/cn";
import { useFieldControl, type FieldControlSize } from "./input";

export const Select: typeof RS.Root = RS.Root;
export const SelectValue: typeof RS.Value = RS.Value;
export const SelectGroup: typeof RS.Group = RS.Group;

type TriggerState = "default" | "error" | "success";

const triggerSizeClasses: Record<FieldControlSize, string> = {
  sm: "h-8 px-3 text-[13px]",
  md: "h-9 px-3.5 text-sm",
  lg: "h-10 px-4 text-sm"
};

const triggerStateClasses: Record<TriggerState, string> = {
  default: "border-border-default hover:border-border-strong focus:border-border-focus focus:shadow-focus",
  error:   "border-danger focus:shadow-focus-danger",
  success: "border-success focus:shadow-focus-success"
};

export const SelectTrigger = React.forwardRef<
  React.ElementRef<typeof RS.Trigger>,
  React.ComponentPropsWithoutRef<typeof RS.Trigger> & {
    state?: TriggerState;
    size?: FieldControlSize;
  }
>(({ className, children, state, size = "md", ...props }, ref) => {
  const { fieldProps, state: resolvedState } = useFieldControl(props, state);
  return (
    <RS.Trigger
      ref={ref}
      className={cn(
        "flex w-full items-center justify-between rounded-md border bg-bg-surface font-medium text-fg-primary",
        triggerSizeClasses[size],
        "transition-[border-color,box-shadow] duration-(--aeros-duration-fast)",
        "focus:outline-none data-[placeholder]:text-fg-muted disabled:opacity-40 disabled:cursor-not-allowed",
        triggerStateClasses[resolvedState],
        className
      )}
      {...props}
      {...fieldProps}
    >
      {children}
      <RS.Icon asChild>
        <ChevronDown className="h-4 w-4 text-fg-muted" />
      </RS.Icon>
    </RS.Trigger>
  );
});
SelectTrigger.displayName = "SelectTrigger";

export const SelectScrollUpButton = React.forwardRef<
  React.ElementRef<typeof RS.ScrollUpButton>,
  React.ComponentPropsWithoutRef<typeof RS.ScrollUpButton>
>(({ className, ...props }, ref) => (
  <RS.ScrollUpButton
    ref={ref}
    className={cn("flex cursor-default items-center justify-center py-1 text-fg-muted", className)}
    {...props}
  >
    <ChevronUp className="h-4 w-4" />
  </RS.ScrollUpButton>
));
SelectScrollUpButton.displayName = "SelectScrollUpButton";

export const SelectScrollDownButton = React.forwardRef<
  React.ElementRef<typeof RS.ScrollDownButton>,
  React.ComponentPropsWithoutRef<typeof RS.ScrollDownButton>
>(({ className, ...props }, ref) => (
  <RS.ScrollDownButton
    ref={ref}
    className={cn("flex cursor-default items-center justify-center py-1 text-fg-muted", className)}
    {...props}
  >
    <ChevronDown className="h-4 w-4" />
  </RS.ScrollDownButton>
));
SelectScrollDownButton.displayName = "SelectScrollDownButton";

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
        "z-(--aeros-z-popover) min-w-[var(--radix-select-trigger-width)] overflow-hidden rounded-lg border border-border-default bg-bg-elevated p-1.5 shadow-lg",
        // Long lists must scroll inside the viewport instead of overflowing it.
        "max-h-[min(var(--radix-select-content-available-height),24rem)]",
        "data-[state=open]:animate-in data-[state=closed]:animate-out data-[state=closed]:fade-out-0 data-[state=open]:fade-in-0 data-[state=open]:zoom-in-95 data-[state=closed]:zoom-out-95 data-[side=bottom]:slide-in-from-top-1 data-[side=top]:slide-in-from-bottom-1 data-[state=open]:duration-(--aeros-duration-fast) data-[state=open]:ease-(--aeros-ease-entrance)",
        className
      )}
      {...props}
    >
      <SelectScrollUpButton />
      <RS.Viewport className="p-0">{children}</RS.Viewport>
      <SelectScrollDownButton />
    </RS.Content>
  </RS.Portal>
));
SelectContent.displayName = "SelectContent";

export const SelectLabel = React.forwardRef<
  React.ElementRef<typeof RS.Label>,
  React.ComponentPropsWithoutRef<typeof RS.Label>
>(({ className, ...props }, ref) => (
  <RS.Label
    ref={ref}
    className={cn("px-2.5 pt-1.5 pb-0.5 text-[10px] font-semibold uppercase tracking-[0.06em] text-fg-muted", className)}
    {...props}
  />
));
SelectLabel.displayName = "SelectLabel";

export const SelectItem = React.forwardRef<
  React.ElementRef<typeof RS.Item>,
  React.ComponentPropsWithoutRef<typeof RS.Item>
>(({ className, children, ...props }, ref) => (
  <RS.Item
    ref={ref}
    className={cn(
      "relative flex cursor-pointer select-none items-center rounded-md py-2 pl-8 pr-2.5 text-sm font-medium text-fg-secondary",
      "focus:bg-bg-subtle focus:text-fg-primary focus:outline-none data-[state=checked]:text-fg-primary data-[state=checked]:font-semibold",
      "data-[disabled]:pointer-events-none data-[disabled]:opacity-40",
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
