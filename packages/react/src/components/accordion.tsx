"use client";
import * as React from "react";
import * as RA from "@radix-ui/react-accordion";
import { ChevronDown } from "lucide-react";
import { cn } from "../lib/cn";

export const Accordion: typeof RA.Root = RA.Root;

export const AccordionItem = React.forwardRef<
  React.ElementRef<typeof RA.Item>,
  React.ComponentPropsWithoutRef<typeof RA.Item>
>(({ className, ...props }, ref) => (
  <RA.Item ref={ref} className={cn("border-b border-border-default last:border-b-0", className)} {...props} />
));
AccordionItem.displayName = "AccordionItem";

export const AccordionTrigger = React.forwardRef<
  React.ElementRef<typeof RA.Trigger>,
  React.ComponentPropsWithoutRef<typeof RA.Trigger>
>(({ className, children, ...props }, ref) => (
  <RA.Header className="flex">
    <RA.Trigger
      ref={ref}
      className={cn(
        "flex flex-1 items-center justify-between gap-3 py-3.5 text-left text-sm font-medium text-fg-primary",
        "transition-colors duration-(--aeros-duration-fast) hover:text-fg-secondary",
        "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-focus-ring focus-visible:ring-offset-2 focus-visible:ring-offset-bg-canvas rounded-sm",
        "[&[data-state=open]>svg]:rotate-180",
        className
      )}
      {...props}
    >
      {children}
      <ChevronDown aria-hidden className="h-4 w-4 shrink-0 text-fg-muted transition-transform duration-(--aeros-duration-base) ease-(--aeros-ease-standard)" />
    </RA.Trigger>
  </RA.Header>
));
AccordionTrigger.displayName = "AccordionTrigger";

export const AccordionContent = React.forwardRef<
  React.ElementRef<typeof RA.Content>,
  React.ComponentPropsWithoutRef<typeof RA.Content>
>(({ className, children, ...props }, ref) => (
  <RA.Content
    ref={ref}
    className="overflow-hidden text-[13px] text-fg-secondary data-[state=closed]:animate-accordion-up data-[state=open]:animate-accordion-down motion-reduce:animate-none"
    {...props}
  >
    <div className={cn("pb-4 pt-0 leading-relaxed", className)}>{children}</div>
  </RA.Content>
));
AccordionContent.displayName = "AccordionContent";
