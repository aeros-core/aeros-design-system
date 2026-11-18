"use client";
import * as React from "react";
import * as RC from "@radix-ui/react-collapsible";
import { cn } from "../lib/cn";

/** A region that opens and closes under a trigger. Unstyled apart from the height animation. */
export const Collapsible = RC.Root;

/** The button that toggles the region. Pass `asChild` to use a `Button` (or any element) as the trigger. */
export const CollapsibleTrigger = RC.Trigger;

export const CollapsibleContent = React.forwardRef<
  React.ElementRef<typeof RC.Content>,
  React.ComponentPropsWithoutRef<typeof RC.Content>
>(({ className, ...props }, ref) => (
  <RC.Content
    ref={ref}
    className={cn(
      "overflow-hidden data-[state=open]:animate-collapsible-down data-[state=closed]:animate-collapsible-up motion-reduce:animate-none",
      className
    )}
    {...props}
  />
));
CollapsibleContent.displayName = "CollapsibleContent";

export type CollapsibleProps = React.ComponentPropsWithoutRef<typeof RC.Root>;
export type CollapsibleTriggerProps = React.ComponentPropsWithoutRef<typeof RC.Trigger>;
export type CollapsibleContentProps = React.ComponentPropsWithoutRef<typeof RC.Content>;
