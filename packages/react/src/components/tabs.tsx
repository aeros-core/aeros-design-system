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
          : "inline-flex gap-[3px] rounded-lg border border-border-default bg-bg-subtle p-1",
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
        "text-sm font-medium text-fg-muted transition-colors whitespace-nowrap",
        "focus-visible:outline-none focus-visible:ring-[3px] focus-visible:ring-royal-100",
        variant === "underline"
          ? "px-4 py-2.5 border-b-2 border-transparent -mb-px hover:text-fg-primary data-[state=active]:text-royal-600 data-[state=active]:border-royal-600 data-[state=active]:font-semibold"
          : "rounded-md px-3.5 py-1.5 data-[state=active]:bg-bg-surface data-[state=active]:text-fg-primary data-[state=active]:font-semibold data-[state=active]:shadow-sm",
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
    className={cn("mt-4 focus-visible:outline-none", className)}
    {...props}
  />
));
TabsContent.displayName = "TabsContent";

// Count pill used inside tab labels
export function TabCount({ children, active }: { children: React.ReactNode; active?: boolean }) {
  return (
    <span
      className={cn(
        "ml-1.5 inline-flex items-center rounded-full px-1.5 py-px text-[10px] font-bold",
        active ? "bg-royal-100 text-royal-800" : "bg-ink-100 text-ink-600"
      )}
    >
      {children}
    </span>
  );
}
