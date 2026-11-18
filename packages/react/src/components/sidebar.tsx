"use client";
import * as React from "react";
import * as RC from "@radix-ui/react-collapsible";
import * as RD from "@radix-ui/react-dialog";
import { Slot, Slottable } from "@radix-ui/react-slot";
import { tokens } from "@aeros-core/tokens";
import { ChevronRight, PanelLeft } from "lucide-react";
import { cn } from "../lib/cn";
import { colorTransition, modalPanel, scrim } from "../internal/recipes";
import { Tooltip, TooltipContent, TooltipProvider, TooltipTrigger } from "./tooltip";

// The app sidebar. It follows the theme (surface + hairline, like every other
// resting surface); for dark chrome in a light app, theme the subtree:
//   <Sidebar data-theme="dark">
//
// Three presentations, one component tree:
//   expanded  240px, icon + label
//   rail      56px, icons only with tooltips (desktop, collapsed)
//   sheet     a left drawer at touch density (below the md breakpoint)
// SidebarProvider owns the state; without one the sidebar is simply expanded.

interface SidebarContextValue {
  /** Desktop rail mode. */
  collapsed: boolean;
  setCollapsed: (collapsed: boolean) => void;
  /** Below the md breakpoint the sidebar is a sheet. */
  isMobile: boolean;
  mobileOpen: boolean;
  setMobileOpen: (open: boolean) => void;
  /** Collapse/expand on desktop, open/close the sheet on mobile. */
  toggle: () => void;
}

const SidebarContext = React.createContext<SidebarContextValue>({
  collapsed: false,
  setCollapsed: () => {},
  isMobile: false,
  mobileOpen: false,
  setMobileOpen: () => {},
  toggle: () => {}
});

export const useSidebar = () => React.useContext(SidebarContext);

/** Icon-only presentation: the desktop rail (the mobile sheet is always expanded). */
const useRail = () => {
  const { collapsed, isMobile } = useSidebar();
  return collapsed && !isMobile;
};

export interface SidebarProviderProps {
  children: React.ReactNode;
  /** Start as a rail (uncontrolled). */
  defaultCollapsed?: boolean;
  /** Controlled rail state. */
  collapsed?: boolean;
  onCollapsedChange?: (collapsed: boolean) => void;
  /** Remember the rail state in localStorage under this key. */
  storageKey?: string;
  /** Toggle with Cmd/Ctrl+B. Default true. */
  keyboardShortcut?: boolean;
}

const MOBILE_QUERY = `(max-width: ${tokens.breakpoint.md - 1}px)`;

export function SidebarProvider({
  children,
  defaultCollapsed = false,
  collapsed: controlled,
  onCollapsedChange,
  storageKey,
  keyboardShortcut = true
}: SidebarProviderProps) {
  const [uncontrolled, setUncontrolled] = React.useState(defaultCollapsed);
  const [isMobile, setIsMobile] = React.useState(false);
  const [mobileOpen, setMobileOpen] = React.useState(false);
  const collapsed = controlled ?? uncontrolled;

  const setCollapsed = React.useCallback(
    (next: boolean) => {
      setUncontrolled(next);
      onCollapsedChange?.(next);
      if (storageKey) {
        try {
          window.localStorage.setItem(storageKey, next ? "1" : "0");
        } catch {
          /* storage unavailable (private mode, blocked) — the state still applies for this visit */
        }
      }
    },
    [onCollapsedChange, storageKey]
  );

  // Restore the remembered state after mount, so server and first client render agree.
  React.useEffect(() => {
    if (!storageKey) return;
    try {
      const saved = window.localStorage.getItem(storageKey);
      if (saved !== null) setUncontrolled(saved === "1");
    } catch {
      /* ignore */
    }
  }, [storageKey]);

  React.useEffect(() => {
    if (typeof window.matchMedia !== "function") return;
    const mq = window.matchMedia(MOBILE_QUERY);
    const sync = () => setIsMobile(mq.matches);
    sync();
    mq.addEventListener("change", sync);
    return () => mq.removeEventListener("change", sync);
  }, []);

  // Leaving mobile closes the sheet, so it cannot be stranded open off-screen.
  React.useEffect(() => {
    if (!isMobile) setMobileOpen(false);
  }, [isMobile]);

  const toggle = React.useCallback(() => {
    if (isMobile) setMobileOpen((open) => !open);
    else setCollapsed(!collapsed);
  }, [isMobile, collapsed, setCollapsed]);

  React.useEffect(() => {
    if (!keyboardShortcut) return;
    const onKeyDown = (event: KeyboardEvent) => {
      if (event.key.toLowerCase() === "b" && (event.metaKey || event.ctrlKey) && !event.shiftKey && !event.altKey) {
        event.preventDefault();
        toggle();
      }
    };
    window.addEventListener("keydown", onKeyDown);
    return () => window.removeEventListener("keydown", onKeyDown);
  }, [keyboardShortcut, toggle]);

  const value = React.useMemo(
    () => ({ collapsed, setCollapsed, isMobile, mobileOpen, setMobileOpen, toggle }),
    [collapsed, setCollapsed, isMobile, mobileOpen, toggle]
  );
  return <SidebarContext.Provider value={value}>{children}</SidebarContext.Provider>;
}

// ── Sidebar ───────────────────────────────────────────────

export interface SidebarProps extends React.HTMLAttributes<HTMLElement> {
  /** Accessible name of the navigation landmark and of the mobile sheet. */
  label?: string;
}

export const Sidebar = React.forwardRef<HTMLElement, SidebarProps>(
  ({ className, children, label = "Sidebar", ...props }, ref) => {
    const { collapsed, isMobile, mobileOpen, setMobileOpen } = useSidebar();

    if (isMobile) {
      return (
        <RD.Root open={mobileOpen} onOpenChange={setMobileOpen}>
          <RD.Portal>
            <RD.Overlay className={scrim} />
            <RD.Content
              aria-describedby={undefined}
              className={cn(
                "fixed inset-y-0 left-0 w-sidebar-mobile max-w-[calc(100vw-3rem)]",
                modalPanel,
                "data-[state=open]:animate-in data-[state=closed]:animate-out",
                "data-[state=open]:slide-in-from-left data-[state=closed]:slide-out-to-left",
                "data-[state=open]:duration-slow data-[state=open]:ease-enter data-[state=closed]:duration-base data-[state=closed]:ease-exit",
                "motion-reduce:animate-none"
              )}
            >
              <RD.Title className="sr-only">{label}</RD.Title>
              {/* Touch sizes inside the sheet: 48px rows, 20px icons. */}
              <nav ref={ref} aria-label={label} data-density="touch" className={cn("flex min-h-0 flex-1 flex-col", className)} {...props}>
                {children}
              </nav>
            </RD.Content>
          </RD.Portal>
        </RD.Root>
      );
    }

    return (
      <TooltipProvider delayDuration={0} skipDelayDuration={0}>
        <nav
          ref={ref}
          aria-label={label}
          data-collapsed={collapsed || undefined}
          className={cn(
            "sticky top-0 flex h-dvh w-sidebar shrink-0 flex-col border-r border-border-default bg-bg-surface text-fg-primary",
            "transition-[width] duration-base ease-standard motion-reduce:transition-none",
            "data-[collapsed]:w-sidebar-rail",
            className
          )}
          {...props}
        >
          {children}
        </nav>
      </TooltipProvider>
    );
  }
);
Sidebar.displayName = "Sidebar";

/** Top block — the brand, a workspace switcher. Sits level with the app header. */
export const SidebarHeader = React.forwardRef<HTMLDivElement, React.HTMLAttributes<HTMLDivElement>>(
  ({ className, ...props }, ref) => (
    <div
      ref={ref}
      className={cn("flex h-header shrink-0 items-center gap-2 border-b border-border-default px-3", className)}
      {...props}
    />
  )
);
SidebarHeader.displayName = "SidebarHeader";

/** The scrolling list of sections. */
export const SidebarContent = React.forwardRef<HTMLDivElement, React.HTMLAttributes<HTMLDivElement>>(
  ({ className, ...props }, ref) => (
    <div ref={ref} className={cn("min-h-0 flex-1 overflow-y-auto overflow-x-hidden py-2", className)} {...props} />
  )
);
SidebarContent.displayName = "SidebarContent";

/** Bottom block — the account, a collapse control. */
export const SidebarFooter = React.forwardRef<HTMLDivElement, React.HTMLAttributes<HTMLDivElement>>(
  ({ className, ...props }, ref) => (
    <div
      ref={ref}
      className={cn("flex min-h-header shrink-0 items-center gap-2 border-t border-border-default px-3 py-2", className)}
      {...props}
    />
  )
);
SidebarFooter.displayName = "SidebarFooter";

export interface SidebarBrandProps extends React.HTMLAttributes<HTMLDivElement> {
  /** A letter or small logo in the mark tile. */
  mark?: React.ReactNode;
  /** The product name — rendered as the Aeros wordmark. */
  name: React.ReactNode;
  sub?: React.ReactNode;
}

export const SidebarBrand = React.forwardRef<HTMLDivElement, SidebarBrandProps>(
  ({ mark, name, sub, className, ...props }, ref) => {
    const rail = useRail();
    return (
      <div ref={ref} className={cn("flex min-w-0 items-center gap-2", rail && "mx-auto", className)} {...props}>
        {mark != null && (
          <div className="flex size-avatar-sm shrink-0 items-center justify-center rounded-item bg-brand-primary text-label-sm text-fg-inverse">
            {mark}
          </div>
        )}
        <div className={cn("min-w-0", rail && "sr-only")}>
          <div className="aeros-logo truncate text-body-lg leading-tight text-fg-primary">{name}</div>
          {sub && <div className="truncate text-caption text-fg-muted">{sub}</div>}
        </div>
      </div>
    );
  }
);
SidebarBrand.displayName = "SidebarBrand";

export interface SidebarSectionProps extends React.HTMLAttributes<HTMLDivElement> {
  label?: React.ReactNode;
}

export const SidebarSection = React.forwardRef<HTMLDivElement, SidebarSectionProps>(
  ({ label, className, children, ...props }, ref) => {
    const labelId = React.useId();
    const rail = useRail();
    return (
      <div
        ref={ref}
        role="group"
        aria-labelledby={label ? labelId : undefined}
        className={cn("grid gap-0.5 px-2 py-1", className)}
        {...props}
      >
        {/* Sentence case, quiet: the label sorts the destinations, it does not compete with them.
            In the rail it stays for assistive tech and a hairline marks the group. */}
        {label && (
          <div id={labelId} className={cn("px-2 pb-1 pt-2 text-caption font-medium text-fg-muted", rail && "sr-only")}>
            {label}
          </div>
        )}
        {label && rail && <div aria-hidden className="mx-2 my-1 h-px bg-border-default" />}
        {children}
      </div>
    );
  }
);
SidebarSection.displayName = "SidebarSection";

// One row look for items, sub-items and group triggers.
const rowBase =
  `group/row flex h-nav-row w-full min-w-0 items-center gap-2 rounded-item px-2 text-left text-body-sm ${colorTransition} ` +
  "[&>svg]:size-nav-icon [&>svg]:shrink-0";
const rowIdle = "text-fg-secondary hover:bg-state-hover hover:text-fg-primary";
const rowActive = "bg-bg-subtle font-semibold text-fg-primary";

const CountPill = ({ count }: { count: number }) => (
  <span className="ml-auto inline-flex h-badge min-w-badge shrink-0 items-center justify-center rounded-pill bg-bg-inverse px-1.5 text-label-xs text-fg-inverse">
    {/* Read as "Inbox, 3" rather than "Inbox3". */}
    <span className="sr-only">, </span>
    {count > 99 ? "99+" : count}
  </span>
);

export interface SidebarItemProps extends React.AnchorHTMLAttributes<HTMLAnchorElement> {
  active?: boolean;
  icon?: React.ReactNode;
  /** Shown as a count pill when above zero (unread, pending) and announced with the label. */
  count?: number;
  /** Render the child element (e.g. a framework `<Link>`) instead of a native anchor. */
  asChild?: boolean;
  /** Tooltip text in the rail. Defaults to the label when it is plain text. */
  tooltip?: string;
}

export const SidebarItem = React.forwardRef<HTMLAnchorElement, SidebarItemProps>(
  ({ active, icon, count, className, children, asChild, href, tooltip, ...props }, ref) => {
    const rail = useRail();
    const { isMobile, setMobileOpen } = useSidebar();
    // Anchors without href are not keyboard-operable — fall back to a real button.
    const Comp: React.ElementType = asChild ? Slot : href != null ? "a" : "button";
    const hasCount = count != null && count > 0;
    const { onClick, ...rest } = props;

    const row = (
      <Comp
        ref={ref}
        href={href}
        {...(Comp === "button" ? { type: "button" as const } : null)}
        aria-current={active ? "page" : undefined}
        className={cn(rowBase, active ? rowActive : rowIdle, rail && "justify-center px-0", className)}
        onClick={(event: React.MouseEvent<HTMLAnchorElement>) => {
          onClick?.(event);
          // Choosing a destination dismisses the mobile sheet.
          if (isMobile) setMobileOpen(false);
        }}
        {...rest}
      >
        {icon ?? (
          // No icon: a small marker keeps labels aligned with rows that have one.
          <span aria-hidden className="flex size-nav-icon shrink-0 items-center justify-center">
            <span className={cn("size-1.5 rounded-full", active ? "bg-fg-primary" : "bg-border-strong")} />
          </span>
        )}
        {asChild ? (
          // The caller's element becomes the row; the icon renders inside it.
          <Slottable>{children}</Slottable>
        ) : (
          <>
            <span className={cn("min-w-0 flex-1 truncate", rail && "sr-only")}>{children}</span>
            {hasCount && !rail && <CountPill count={count} />}
            {hasCount && rail && <span className="sr-only">, {count}</span>}
          </>
        )}
      </Comp>
    );

    const tip = tooltip ?? (typeof children === "string" ? children : undefined);
    if (!rail || !tip) return row;
    return (
      <Tooltip>
        <TooltipTrigger asChild>{row}</TooltipTrigger>
        <TooltipContent side="right">{hasCount ? `${tip} · ${count}` : tip}</TooltipContent>
      </Tooltip>
    );
  }
);
SidebarItem.displayName = "SidebarItem";

export interface SidebarGroupProps extends Omit<React.ComponentPropsWithoutRef<typeof RC.Root>, "title"> {
  /** The parent row's label. */
  label: React.ReactNode;
  icon?: React.ReactNode;
  /** Marks the parent as holding the current page; it then starts open. */
  active?: boolean;
}

/**
 * A parent destination with one level of children (`SidebarSubItem`s).
 * In the rail the parent shows only its icon; expand the sidebar to reach the children.
 */
export const SidebarGroup = React.forwardRef<HTMLDivElement, SidebarGroupProps>(
  ({ label, icon, active, defaultOpen, className, children, ...props }, ref) => {
    const rail = useRail();
    const { setCollapsed } = useSidebar();

    // In the rail there is nowhere to show children, so the parent is a plain
    // button whose useful action is to expand the sidebar. (Not a collapsible
    // trigger: that would point aria-controls at content that is not rendered.)
    if (rail) {
      const button = (
        <button
          type="button"
          className={cn(rowBase, rowIdle, active && "text-fg-primary", "justify-center px-0")}
          onClick={() => setCollapsed(false)}
        >
          {icon}
          <span className="sr-only">{label}</span>
        </button>
      );
      return (
        <div ref={ref} className={cn("grid", className)}>
          {typeof label === "string" ? (
            <Tooltip>
              <TooltipTrigger asChild>{button}</TooltipTrigger>
              <TooltipContent side="right">{label}</TooltipContent>
            </Tooltip>
          ) : (
            button
          )}
        </div>
      );
    }

    return (
      <RC.Root ref={ref} defaultOpen={defaultOpen ?? active} className={cn("grid gap-0.5", className)} {...props}>
        <RC.Trigger className={cn(rowBase, rowIdle, active && "text-fg-primary")}>
          {icon}
          <span className="min-w-0 flex-1 truncate">{label}</span>
          <ChevronRight
            aria-hidden
            className="ml-auto text-fg-muted transition-transform duration-fast ease-standard group-data-[state=open]/row:rotate-90"
          />
        </RC.Trigger>
        <RC.Content className="grid gap-0.5 overflow-hidden data-[state=closed]:animate-collapsible-up data-[state=open]:animate-collapsible-down motion-reduce:animate-none">
          {children}
        </RC.Content>
      </RC.Root>
    );
  }
);
SidebarGroup.displayName = "SidebarGroup";

export interface SidebarSubItemProps extends React.AnchorHTMLAttributes<HTMLAnchorElement> {
  active?: boolean;
  asChild?: boolean;
}

/** A child of `SidebarGroup`. Its label lines up with the parent's label. */
export const SidebarSubItem = React.forwardRef<HTMLAnchorElement, SidebarSubItemProps>(
  ({ active, asChild, href, className, onClick, ...props }, ref) => {
    const { isMobile, setMobileOpen } = useSidebar();
    const Comp: React.ElementType = asChild ? Slot : href != null ? "a" : "button";
    return (
      <Comp
        ref={ref}
        href={href}
        {...(Comp === "button" ? { type: "button" as const } : null)}
        aria-current={active ? "page" : undefined}
        // Left padding = row padding + icon + gap, so the label aligns with the parent's.
        className={cn(rowBase, "pl-[calc(1rem+var(--aeros-size-nav-icon))]", active ? rowActive : rowIdle, className)}
        onClick={(event: React.MouseEvent<HTMLAnchorElement>) => {
          onClick?.(event);
          if (isMobile) setMobileOpen(false);
        }}
        {...props}
      />
    );
  }
);
SidebarSubItem.displayName = "SidebarSubItem";

/** Collapses/expands the sidebar on desktop and opens the sheet on mobile. Place it in the app header. */
export const SidebarTrigger = React.forwardRef<HTMLButtonElement, React.ButtonHTMLAttributes<HTMLButtonElement>>(
  ({ className, onClick, children, ...props }, ref) => {
    const { toggle, collapsed, isMobile, mobileOpen } = useSidebar();
    return (
      <button
        ref={ref}
        type="button"
        aria-label="Toggle sidebar"
        aria-expanded={isMobile ? mobileOpen : !collapsed}
        className={cn(
          `inline-flex size-control-md shrink-0 items-center justify-center rounded-control text-fg-secondary ${colorTransition}`,
          "hover:bg-state-hover hover:text-fg-primary [&_svg]:size-icon-md",
          className
        )}
        onClick={(event) => {
          onClick?.(event);
          toggle();
        }}
        {...props}
      >
        {children ?? <PanelLeft aria-hidden />}
      </button>
    );
  }
);
SidebarTrigger.displayName = "SidebarTrigger";
