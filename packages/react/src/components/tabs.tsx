"use client";
import * as React from "react";
import * as RT from "@radix-ui/react-tabs";
import { cn } from "../lib/cn";

type Variant = "underline" | "pill";
const TabsVariantContext = React.createContext<Variant>("underline");

export interface TabsProps extends React.ComponentPropsWithoutRef<typeof RT.Root> {
  variant?: Variant;
}

export const Tabs = React.forwardRef<React.ElementRef<typeof RT.Root>, TabsProps>(
  ({ variant = "underline", ...props }, ref) => (
    <TabsVariantContext.Provider value={variant}>
      <RT.Root ref={ref} {...props} />
    </TabsVariantContext.Provider>
  )
);
Tabs.displayName = "Tabs";

export const TabsList = React.forwardRef<
  React.ElementRef<typeof RT.List>,
  React.ComponentPropsWithoutRef<typeof RT.List>
>(({ className, ...props }, ref) => {
  const variant = React.useContext(TabsVariantContext);
  return (
    <RT.List
      ref={ref}
      className={cn(
        variant === "underline"
          ? "flex border-b border-border-default"
          : "inline-flex gap-0.5 rounded-control bg-bg-inset p-0.5",
        className
      )}
      {...props}
    />
  );
});
TabsList.displayName = "TabsList";

export const TabsTrigger = React.forwardRef<
  React.ElementRef<typeof RT.Trigger>,
  React.ComponentPropsWithoutRef<typeof RT.Trigger>
>(({ className, ...props }, ref) => {
  const variant = React.useContext(TabsVariantContext);
  return (
    <RT.Trigger
      ref={ref}
      className={cn(
        "whitespace-nowrap text-label-sm text-fg-muted transition-colors duration-fast ease-standard",
        "",
        variant === "underline"
          ? "-mb-px h-control-lg border-b-2 border-transparent px-3 hover:text-fg-primary data-[state=active]:border-fg-primary data-[state=active]:text-fg-primary"
          : "h-control-sm rounded-item px-2.5 hover:text-fg-primary data-[state=active]:bg-bg-elevated data-[state=active]:text-fg-primary data-[state=active]:shadow-raised",
        className
      )}
      {...props}
    />
  );
});
TabsTrigger.displayName = "TabsTrigger";

export const TabsContent = React.forwardRef<
  React.ElementRef<typeof RT.Content>,
  React.ComponentPropsWithoutRef<typeof RT.Content>
>(({ className, ...props }, ref) => (
  <RT.Content
    ref={ref}
    className={cn("outline-none", className)}
    {...props}
  />
));
TabsContent.displayName = "TabsContent";

// Count pill used inside tab labels. Styles itself from the parent trigger's
// data-state, so no `active` prop bookkeeping is needed (still accepted as an
// override for use outside a TabsTrigger).
export interface TabCountProps extends React.HTMLAttributes<HTMLSpanElement> {
  active?: boolean;
}

export const TabCount = React.forwardRef<HTMLSpanElement, TabCountProps>(
  ({ children, active, className, ...props }, ref) => (
    <span
      ref={ref}
      className={cn(
        "ml-1.5 inline-flex h-4 min-w-4 items-center justify-center rounded-pill px-1 text-label-xs",
        active === undefined
          ? "bg-border-default text-fg-secondary [[data-state=active]_&]:bg-brand-primary [[data-state=active]_&]:text-fg-inverse"
          : active
            ? "bg-brand-primary text-fg-inverse"
            : "bg-border-default text-fg-secondary",
        className
      )}
      {...props}
    >
      {children}
    </span>
  )
);
TabCount.displayName = "TabCount";
