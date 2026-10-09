"use client";
import * as React from "react";
import { Slot } from "@radix-ui/react-slot";
import { cn } from "../lib/cn";

// The sidebar is deliberate fixed chrome: it stays dark in both themes, so it
// uses static ink stops + white overlays rather than theme aliases. Focus rings
// are explicit (white) because the global focus outline is near-black in light.

export const Sidebar = React.forwardRef<HTMLElement, React.HTMLAttributes<HTMLElement>>(
  ({ className, children, ...props }, ref) => (
    <nav
      ref={ref}
      aria-label="Sidebar"
      className={cn(
        "w-[228px] shrink-0 h-screen sticky top-0 overflow-y-auto bg-ink-950 text-white border-r border-ink-800 [scrollbar-width:none] [&::-webkit-scrollbar]:hidden",
        className
      )}
      {...props}
    >
      {children}
    </nav>
  )
);
Sidebar.displayName = "Sidebar";

export interface SidebarBrandProps extends React.HTMLAttributes<HTMLDivElement> {
  mark?: React.ReactNode;
  name: React.ReactNode;
  sub?: React.ReactNode;
}

export const SidebarBrand = React.forwardRef<HTMLDivElement, SidebarBrandProps>(
  ({ mark, name, sub, className, ...props }, ref) => (
    <div ref={ref} className={cn("flex items-center gap-2.5 px-4 py-3.5 border-b border-white/5", className)} {...props}>
      <div className="flex h-8 w-8 items-center justify-center rounded-lg bg-white text-base font-extrabold text-ink-900">
        {mark}
      </div>
      <div className="min-w-0">
        <div className="aeros-logo text-base text-white leading-tight">{name}</div>
        {sub && <div className="mt-px font-mono text-[10px] text-ink-400 truncate">{sub}</div>}
      </div>
    </div>
  )
);
SidebarBrand.displayName = "SidebarBrand";

export interface SidebarSectionProps extends React.HTMLAttributes<HTMLDivElement> {
  label?: React.ReactNode;
}

export const SidebarSection = React.forwardRef<HTMLDivElement, SidebarSectionProps>(
  ({ label, className, children, ...props }, ref) => {
    const labelId = React.useId();
    return (
      <div
        ref={ref}
        role="group"
        aria-labelledby={label ? labelId : undefined}
        className={cn("px-3 pt-3 pb-1", className)}
        {...props}
      >
        {/* Sentence case, quiet: the label sorts the destinations, it does not compete with them. */}
        {label && (
          <div id={labelId} className="mb-1.5 mt-2 px-3 text-xs font-medium text-ink-400">
            {label}
          </div>
        )}
        {children}
      </div>
    );
  }
);
SidebarSection.displayName = "SidebarSection";

export interface SidebarItemProps extends React.AnchorHTMLAttributes<HTMLAnchorElement> {
  active?: boolean;
  icon?: React.ReactNode;
  /** Shown as a count pill when above zero (unread, pending) and announced with the label. */
  count?: number;
  /** Render the child element (e.g. a framework `<Link>`) instead of a native anchor. */
  asChild?: boolean;
}

export const SidebarItem = React.forwardRef<HTMLAnchorElement, SidebarItemProps>(
  ({ active, icon, count, className, children, asChild, href, ...props }, ref) => {
    // Anchors without href are not keyboard-operable — fall back to a real button.
    const Comp: React.ElementType = asChild ? Slot : href != null ? "a" : "button";
    return (
      <Comp
        ref={ref}
        href={href}
        {...(Comp === "button" ? { type: "button" as const } : null)}
        aria-current={active ? "page" : undefined}
        className={cn(
          "flex h-8 w-full items-center gap-2.5 rounded-md px-3 text-[13px] font-medium transition-colors duration-(--aeros-duration-quick) text-left [&>svg]:size-4 [&>svg]:shrink-0",
          "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-white/80",
          active
            ? "bg-white/[0.08] text-white"
            : "font-normal text-white/55 hover:bg-white/[0.05] hover:text-white/90",
          className
        )}
        {...props}
      >
        {icon ?? <span className={cn("h-1.5 w-1.5 rounded-full", active ? "bg-white" : "bg-white/20")} />}
        {asChild ? (
          children
        ) : (
          <>
            <span className="min-w-0 flex-1 truncate">{children}</span>
            {count != null && count > 0 && (
              <span className="ml-auto inline-flex h-[18px] min-w-[18px] items-center justify-center rounded-full bg-white px-1.5 text-[11px] font-semibold text-ink-950">
                <span className="sr-only">, </span>
                {count > 99 ? "99+" : count}
              </span>
            )}
          </>
        )}
      </Comp>
    );
  }
);
SidebarItem.displayName = "SidebarItem";
