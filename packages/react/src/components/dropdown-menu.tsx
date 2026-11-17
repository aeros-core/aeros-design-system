"use client";
import * as React from "react";
import * as RD from "@radix-ui/react-dropdown-menu";
import { Check, ChevronRight } from "lucide-react";
import { cn } from "../lib/cn";
import { menuItem, menuItemDanger, menuItemState, menuLabel, menuPanel, menuSeparator, menuShortcut } from "../internal/recipes";

export const DropdownMenu: typeof RD.Root = RD.Root;
export const DropdownMenuTrigger: typeof RD.Trigger = RD.Trigger;
export const DropdownMenuGroup: typeof RD.Group = RD.Group;
export const DropdownMenuPortal: typeof RD.Portal = RD.Portal;
export const DropdownMenuRadioGroup: typeof RD.RadioGroup = RD.RadioGroup;
export const DropdownMenuSub: typeof RD.Sub = RD.Sub;

export const DropdownMenuContent = React.forwardRef<
  React.ElementRef<typeof RD.Content>,
  React.ComponentPropsWithoutRef<typeof RD.Content>
>(({ className, sideOffset = 4, ...props }, ref) => (
  <RD.Portal>
    <RD.Content
      ref={ref}
      sideOffset={sideOffset}
      className={cn(menuPanel, "max-h-(--radix-dropdown-menu-content-available-height)", className)}
      {...props}
    />
  </RD.Portal>
));
DropdownMenuContent.displayName = "DropdownMenuContent";

export const DropdownMenuItem = React.forwardRef<
  React.ElementRef<typeof RD.Item>,
  React.ComponentPropsWithoutRef<typeof RD.Item> & { destructive?: boolean }
>(({ className, destructive, ...props }, ref) => (
  <RD.Item ref={ref} className={cn(menuItem, menuItemState.radix, destructive && menuItemDanger, className)} {...props} />
));
DropdownMenuItem.displayName = "DropdownMenuItem";

/** A row that toggles. The check sits in a fixed leading slot so labels stay aligned. */
export const DropdownMenuCheckboxItem = React.forwardRef<
  React.ElementRef<typeof RD.CheckboxItem>,
  React.ComponentPropsWithoutRef<typeof RD.CheckboxItem>
>(({ className, children, ...props }, ref) => (
  <RD.CheckboxItem ref={ref} className={cn(menuItem, menuItemState.radix, "pl-8", className)} {...props}>
    <span className="absolute left-2 flex size-icon-md items-center justify-center">
      <RD.ItemIndicator>
        <Check className="text-fg-primary" />
      </RD.ItemIndicator>
    </span>
    {children}
  </RD.CheckboxItem>
));
DropdownMenuCheckboxItem.displayName = "DropdownMenuCheckboxItem";

/** One of a `DropdownMenuRadioGroup`. */
export const DropdownMenuRadioItem = React.forwardRef<
  React.ElementRef<typeof RD.RadioItem>,
  React.ComponentPropsWithoutRef<typeof RD.RadioItem>
>(({ className, children, ...props }, ref) => (
  <RD.RadioItem ref={ref} className={cn(menuItem, menuItemState.radix, "pl-8", className)} {...props}>
    <span className="absolute left-2 flex size-icon-md items-center justify-center">
      <RD.ItemIndicator>
        <span className="block size-1.5 rounded-full bg-fg-primary" />
      </RD.ItemIndicator>
    </span>
    {children}
  </RD.RadioItem>
));
DropdownMenuRadioItem.displayName = "DropdownMenuRadioItem";

export const DropdownMenuSubTrigger = React.forwardRef<
  React.ElementRef<typeof RD.SubTrigger>,
  React.ComponentPropsWithoutRef<typeof RD.SubTrigger>
>(({ className, children, ...props }, ref) => (
  <RD.SubTrigger
    ref={ref}
    className={cn(menuItem, menuItemState.radix, "data-[state=open]:bg-state-hover", className)}
    {...props}
  >
    {children}
    <ChevronRight className="ml-auto" />
  </RD.SubTrigger>
));
DropdownMenuSubTrigger.displayName = "DropdownMenuSubTrigger";

export const DropdownMenuSubContent = React.forwardRef<
  React.ElementRef<typeof RD.SubContent>,
  React.ComponentPropsWithoutRef<typeof RD.SubContent>
>(({ className, sideOffset = 6, ...props }, ref) => (
  <RD.Portal>
    <RD.SubContent ref={ref} sideOffset={sideOffset} className={cn(menuPanel, className)} {...props} />
  </RD.Portal>
));
DropdownMenuSubContent.displayName = "DropdownMenuSubContent";

export const DropdownMenuSeparator = React.forwardRef<
  React.ElementRef<typeof RD.Separator>,
  React.ComponentPropsWithoutRef<typeof RD.Separator>
>(({ className, ...props }, ref) => (
  <RD.Separator ref={ref} className={cn(menuSeparator, className)} {...props} />
));
DropdownMenuSeparator.displayName = "DropdownMenuSeparator";

export const DropdownMenuLabel = React.forwardRef<
  React.ElementRef<typeof RD.Label>,
  React.ComponentPropsWithoutRef<typeof RD.Label>
>(({ className, ...props }, ref) => <RD.Label ref={ref} className={cn(menuLabel, className)} {...props} />);
DropdownMenuLabel.displayName = "DropdownMenuLabel";

/** Keyboard hint at the end of a row, e.g. `⌘K`. Decorative — the item's own handler does the work. */
export const DropdownMenuShortcut = ({ className, ...props }: React.HTMLAttributes<HTMLSpanElement>) => (
  <span aria-hidden className={cn(menuShortcut, className)} {...props} />
);
DropdownMenuShortcut.displayName = "DropdownMenuShortcut";
