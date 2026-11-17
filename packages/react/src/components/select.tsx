"use client";
import * as React from "react";
import * as RS from "@radix-ui/react-select";
import { Check, ChevronDown, ChevronUp } from "lucide-react";
import { cn } from "../lib/cn";
import {
  fieldBase,
  fieldSize,
  fieldState,
  menuItem,
  menuItemState,
  menuLabel,
  menuPanel,
  menuSeparator,
  type FieldState
} from "../internal/recipes";
import { useFieldControl, type FieldControlSize } from "./input";

export const Select: typeof RS.Root = RS.Root;
export const SelectValue: typeof RS.Value = RS.Value;
export const SelectGroup: typeof RS.Group = RS.Group;

type TriggerState = FieldState;

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
      className={cn(fieldBase, "flex items-center justify-between gap-2 text-left", fieldSize[size], fieldState[resolvedState], className)}
      {...props}
      {...fieldProps}
    >
      {children}
      <RS.Icon asChild>
        <ChevronDown className="size-icon-md shrink-0 text-fg-muted" />
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
        menuPanel,
        "min-w-(--radix-select-trigger-width)",
        // Long lists must scroll inside the viewport instead of overflowing it.
        "max-h-[min(var(--radix-select-content-available-height),24rem)]",
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
    className={cn(menuLabel, className)}
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
    className={cn(menuItem, menuItemState.radix, "pr-8", className)}
    {...props}
  >
    <RS.ItemText>{children}</RS.ItemText>
    {/* The check trails the label, so labels line up with the trigger's text. */}
    <span className="absolute right-2 flex size-icon-md items-center justify-center">
      <RS.ItemIndicator>
        <Check className="text-fg-primary" />
      </RS.ItemIndicator>
    </span>
  </RS.Item>
));
SelectItem.displayName = "SelectItem";

export const SelectSeparator = React.forwardRef<
  React.ElementRef<typeof RS.Separator>,
  React.ComponentPropsWithoutRef<typeof RS.Separator>
>(({ className, ...props }, ref) => (
  <RS.Separator ref={ref} className={cn(menuSeparator, className)} {...props} />
));
SelectSeparator.displayName = "SelectSeparator";
