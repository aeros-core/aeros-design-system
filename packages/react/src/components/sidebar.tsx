"use client";
import * as React from "react";
import * as RC from "@radix-ui/react-collapsible";
import * as RD from "@radix-ui/react-dialog";
import { Slot } from "@radix-ui/react-slot";
import { tokens } from "@aeros-core/tokens";
import { ChevronRight, ChevronsUpDown, PanelLeft, X } from "lucide-react";
import { cn } from "../lib/cn";
import { resolveLazyNode, resolveSlotChild } from "../internal/as-child";
import { colorTransition, modalPanel, scrim } from "../internal/recipes";
import { CountBadge } from "./count-badge";
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuLabel,
  DropdownMenuTrigger
} from "./dropdown-menu";
import { Tooltip, TooltipContent, TooltipProvider, TooltipTrigger } from "./tooltip";

// The app sidebar. It follows the theme (surface + hairline, like every other
// resting surface); for dark chrome in a light app, theme the subtree:
//   <Sidebar data-theme="dark">
//
// One component tree, three presentations, chosen by window width
// (design: docs/sidebar/spec.md):
//   sheet     below md      a left drawer at touch density
//   rail      md to lg      56px, icons only; the trigger floats the full
//                           sidebar over the page without reflowing it
//   expanded  lg and up     240px; the trigger collapses it to the rail and
//                           the choice is remembered
// The centre of every icon sits 28px from the edge (half the rail) in every
// state, so collapsing never moves an icon: labels fade, the width changes.
// SidebarProvider owns the state; without one the sidebar is simply expanded.

interface SidebarContextValue {
  /** True inside a SidebarProvider (the sidebar adapts to the window). */
  managed: boolean;
  /** The remembered choice at lg and up: true is the rail. */
  collapsed: boolean;
  setCollapsed: (collapsed: boolean) => void;
  /** Icons only right now: collapsed at lg and up, or between md and lg while not floating. */
  rail: boolean;
  /** Below the md breakpoint the sidebar is a sheet. */
  isMobile: boolean;
  mobileOpen: boolean;
  setMobileOpen: (open: boolean) => void;
  /** Between md and lg the sidebar is a rail that can float open. */
  isTablet: boolean;
  floating: boolean;
  setFloating: (open: boolean) => void;
  /** Collapse/expand at lg and up, float between md and lg, open/close the sheet below md. */
  toggle: () => void;
  /** Close the sheet or the floating sidebar (after choosing a destination). */
  dismiss: () => void;
  /** The id of the sidebar element, for aria-controls. */
  sidebarId?: string;
}

const noop = () => {};
const SidebarContext = React.createContext<SidebarContextValue>({
  managed: false,
  collapsed: false,
  setCollapsed: noop,
  rail: false,
  isMobile: false,
  mobileOpen: false,
  setMobileOpen: noop,
  isTablet: false,
  floating: false,
  setFloating: noop,
  toggle: noop,
  dismiss: noop
});

export const useSidebar = () => React.useContext(SidebarContext);

const useRail = () => useSidebar().rail;

/** Labels, counts and chevrons leave the rail by fading; they stay in the tree as the accessible name. */
const fade = (rail: boolean) =>
  cn("transition-opacity motion-reduce:transition-none", rail ? "opacity-0 duration-quick" : "opacity-100 duration-fast");

export interface SidebarProviderProps {
  children: React.ReactNode;
  /**
   * Start as a rail at lg and up (uncontrolled). In a server-rendered app, read the
   * cookie named by `storageKey` and pass `defaultCollapsed={value === "1"}`, so the
   * first paint already matches the remembered choice.
   */
  defaultCollapsed?: boolean;
  /** Controlled rail state. */
  collapsed?: boolean;
  onCollapsedChange?: (collapsed: boolean) => void;
  /**
   * Remember the choice under this key, in localStorage and in a cookie of the same
   * name ("1" collapsed, "0" expanded). Use a cookie-safe key: letters, digits, `.`, `_`, `-`.
   */
  storageKey?: string;
  /** Toggle with Cmd/Ctrl+B (ignored while typing in a field). Default true. */
  keyboardShortcut?: boolean;
}

const { md, lg } = tokens.breakpoint;
const MOBILE_QUERY = `(max-width: ${md - 1}px)`;
const TABLET_QUERY = `(min-width: ${md}px) and (max-width: ${lg - 1}px)`;

const isTypingTarget = (target: EventTarget | null) =>
  target instanceof HTMLElement &&
  (target.isContentEditable || target.matches("input, textarea, select, [contenteditable], [role='textbox']"));

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
  const [isTablet, setIsTablet] = React.useState(false);
  const [mobileOpen, setMobileOpen] = React.useState(false);
  const [floating, setFloating] = React.useState(false);
  const sidebarId = React.useId();
  const collapsed = controlled ?? uncontrolled;

  const setCollapsed = React.useCallback(
    (next: boolean) => {
      setUncontrolled(next);
      onCollapsedChange?.(next);
      if (storageKey) {
        const value = next ? "1" : "0";
        try {
          window.localStorage.setItem(storageKey, value);
        } catch {
          /* storage unavailable (private mode, blocked) — the state still applies for this visit */
        }
        try {
          // The cookie lets a server render paint the remembered state on the first frame.
          document.cookie = `${encodeURIComponent(storageKey)}=${value}; path=/; max-age=31536000; samesite=lax`;
        } catch {
          /* ignore */
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
    const mobile = window.matchMedia(MOBILE_QUERY);
    const tablet = window.matchMedia(TABLET_QUERY);
    const sync = () => {
      setIsMobile(mobile.matches);
      // Mobile wins if both report true (a stubbed matchMedia in tests).
      setIsTablet(tablet.matches && !mobile.matches);
    };
    sync();
    mobile.addEventListener("change", sync);
    tablet.addEventListener("change", sync);
    return () => {
      mobile.removeEventListener("change", sync);
      tablet.removeEventListener("change", sync);
    };
  }, []);

  // Leaving a size closes its transient state, so nothing is stranded open.
  React.useEffect(() => {
    if (!isMobile) setMobileOpen(false);
  }, [isMobile]);
  React.useEffect(() => {
    if (!isTablet) setFloating(false);
  }, [isTablet]);

  const toggle = React.useCallback(() => {
    if (isMobile) setMobileOpen((open) => !open);
    else if (isTablet) setFloating((open) => !open);
    else setCollapsed(!collapsed);
  }, [isMobile, isTablet, collapsed, setCollapsed]);

  const dismiss = React.useCallback(() => {
    setMobileOpen(false);
    setFloating(false);
  }, []);

  React.useEffect(() => {
    if (!keyboardShortcut) return;
    const onKeyDown = (event: KeyboardEvent) => {
      if (event.key.toLowerCase() !== "b" || !(event.metaKey || event.ctrlKey) || event.shiftKey || event.altKey) return;
      // In a field Cmd/Ctrl+B means Bold; leave it alone.
      if (isTypingTarget(event.target)) return;
      event.preventDefault();
      toggle();
    };
    window.addEventListener("keydown", onKeyDown);
    return () => window.removeEventListener("keydown", onKeyDown);
  }, [keyboardShortcut, toggle]);

  // Escape closes the floating sidebar (the sheet handles its own).
  React.useEffect(() => {
    if (!floating) return;
    const onKeyDown = (event: KeyboardEvent) => {
      if (event.key === "Escape") setFloating(false);
    };
    window.addEventListener("keydown", onKeyDown);
    return () => window.removeEventListener("keydown", onKeyDown);
  }, [floating]);

  const rail = !isMobile && (isTablet ? !floating : collapsed);

  const value = React.useMemo(
    () => ({
      managed: true,
      collapsed,
      setCollapsed,
      rail,
      isMobile,
      mobileOpen,
      setMobileOpen,
      isTablet,
      floating,
      setFloating,
      toggle,
      dismiss,
      sidebarId
    }),
    [collapsed, setCollapsed, rail, isMobile, mobileOpen, isTablet, floating, toggle, dismiss, sidebarId]
  );
  return <SidebarContext.Provider value={value}>{children}</SidebarContext.Provider>;
}

// ── Sidebar ───────────────────────────────────────────────

export interface SidebarProps extends React.HTMLAttributes<HTMLElement> {
  /** Accessible name of the navigation landmark and of the mobile sheet. */
  label?: string;
  /** Let a click on the sidebar's edge toggle it (pointer convenience; inside a provider). Default true. */
  edgeToggle?: boolean;
}

function useMergedRef<T>(...refs: (React.Ref<T> | undefined)[]) {
  return React.useCallback((node: T | null) => {
    for (const ref of refs) {
      if (typeof ref === "function") ref(node);
      else if (ref) (ref as React.MutableRefObject<T | null>).current = node;
    }
  }, refs);
}

const widthMotion = "transition-[width] duration-base ease-standard motion-reduce:transition-none";

export const Sidebar = React.forwardRef<HTMLElement, SidebarProps>(
  ({ className, children, label = "Sidebar", edgeToggle = true, id, ...props }, ref) => {
    const { managed, collapsed, rail, isMobile, mobileOpen, setMobileOpen, floating, setFloating, toggle, sidebarId } =
      useSidebar();
    const navRef = React.useRef<HTMLElement | null>(null);
    const setRef = useMergedRef(ref, navRef);
    const navId = id ?? sidebarId;

    // A press outside the floating sidebar closes it. Menus it opened (portalled)
    // and the trigger (which toggles on its own) do not count as outside.
    React.useEffect(() => {
      if (!floating) return;
      const onPointerDown = (event: PointerEvent) => {
        const target = event.target as Element | null;
        if (!target || navRef.current?.contains(target)) return;
        if (target.closest?.("[data-radix-popper-content-wrapper], [data-sidebar-trigger]")) return;
        setFloating(false);
      };
      document.addEventListener("pointerdown", onPointerDown);
      return () => document.removeEventListener("pointerdown", onPointerDown);
    }, [floating, setFloating]);

    if (isMobile) {
      return (
        <RD.Root open={mobileOpen} onOpenChange={setMobileOpen}>
          <RD.Portal>
            <RD.Overlay className={scrim} />
            <RD.Content
              aria-describedby={undefined}
              className={cn(
                "fixed inset-y-0 left-0 w-sidebar-mobile max-w-[calc(100vw-3.5rem)]",
                modalPanel,
                "data-[state=open]:animate-in data-[state=closed]:animate-out",
                "data-[state=open]:slide-in-from-left data-[state=closed]:slide-out-to-left",
                "data-[state=open]:duration-slow data-[state=open]:ease-enter data-[state=closed]:duration-base data-[state=closed]:ease-exit",
                "motion-reduce:animate-none"
              )}
            >
              <RD.Title className="sr-only">{label}</RD.Title>
              {/* Touch sizes inside the sheet: 48px rows, 20px icons. */}
              <nav
                ref={setRef}
                id={navId}
                aria-label={label}
                data-density="touch"
                className={cn(
                  "relative flex min-h-0 flex-1 flex-col pb-[env(safe-area-inset-bottom)] pt-[env(safe-area-inset-top)]",
                  className
                )}
                {...props}
              >
                {children}
                <RD.Close
                  aria-label="Close sidebar"
                  className={cn(
                    "absolute right-1.5 top-[calc(env(safe-area-inset-top)+0.375rem)] z-raised inline-flex size-icon-button items-center justify-center rounded-control bg-bg-elevated text-fg-secondary",
                    colorTransition,
                    "hover:bg-state-hover hover:text-fg-primary [&_svg]:size-icon-md"
                  )}
                >
                  <X aria-hidden />
                </RD.Close>
              </nav>
            </RD.Content>
          </RD.Portal>
        </RD.Root>
      );
    }

    // Width is decided in CSS wherever it can be, so a tablet paints the rail
    // before the media query is read on the client: rail from md, full from lg
    // unless collapsed. Without a provider the sidebar is static and expanded.
    const width = !managed ? "w-sidebar" : collapsed ? "w-sidebar-rail" : "w-sidebar-rail lg:w-sidebar";

    return (
      <TooltipProvider delayDuration={0} skipDelayDuration={0}>
        {/* The slot holds the sidebar's place in the layout; the sidebar itself is
            positioned inside it so it can float wider than the slot between md and lg. */}
        <div
          className={cn(
            "sticky top-0 h-dvh shrink-0",
            widthMotion,
            width,
            // With a provider the sidebar is a sheet below md. Hide the desktop
            // column there in CSS too, so a phone never paints it first.
            managed && "max-md:hidden"
          )}
        >
          <nav
            ref={setRef}
            id={navId}
            aria-label={label}
            data-collapsed={rail || undefined}
            data-floating={floating || undefined}
            className={cn(
              "absolute inset-y-0 left-0 flex flex-col border-r border-border-default bg-bg-surface text-fg-primary",
              widthMotion,
              floating ? "z-overlay w-sidebar shadow-overlay" : width,
              className
            )}
            {...props}
          >
            {children}
            {managed && edgeToggle && (
              // Pointer convenience only: the SidebarTrigger is the accessible control.
              <button
                type="button"
                aria-hidden
                tabIndex={-1}
                onClick={toggle}
                className={cn(
                  "absolute inset-y-0 -right-1.5 z-raised w-3 cursor-pointer",
                  "after:absolute after:inset-y-0 after:left-1/2 after:w-0.5 after:-translate-x-1/2 after:bg-border-strong after:opacity-0",
                  "after:transition-opacity after:duration-fast hover:after:opacity-100 motion-reduce:after:transition-none"
                )}
              />
            )}
          </nav>
        </div>
      </TooltipProvider>
    );
  }
);
Sidebar.displayName = "Sidebar";

/** Top block — the brand, or a `SidebarMenuButton` that switches workspace. Sits level with the app header. */
export const SidebarHeader = React.forwardRef<HTMLDivElement, React.HTMLAttributes<HTMLDivElement>>(
  ({ className, ...props }, ref) => {
    const { isMobile } = useSidebar();
    return (
      <div
        ref={ref}
        className={cn(
          "flex h-header shrink-0 items-center gap-2 overflow-hidden border-b border-border-default px-2",
          // Room for the sheet's close button.
          isMobile && "pr-14",
          className
        )}
        {...props}
      />
    );
  }
);
SidebarHeader.displayName = "SidebarHeader";

/** The scrolling list of sections. */
export const SidebarContent = React.forwardRef<HTMLDivElement, React.HTMLAttributes<HTMLDivElement>>(
  ({ className, ...props }, ref) => (
    <div ref={ref} className={cn("min-h-0 flex-1 overflow-y-auto overflow-x-hidden py-1", className)} {...props} />
  )
);
SidebarContent.displayName = "SidebarContent";

/** Bottom block — pinned destinations (Settings, Help) or a `SidebarMenuButton` for the account. */
export const SidebarFooter = React.forwardRef<HTMLDivElement, React.HTMLAttributes<HTMLDivElement>>(
  ({ className, ...props }, ref) => (
    <div
      ref={ref}
      className={cn(
        "flex min-h-header shrink-0 items-center gap-2 overflow-hidden border-t border-border-default px-2 py-2",
        className
      )}
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
      // px-2 inside the header's px-2 puts the 24px mark's centre at 28px.
      <div ref={ref} className={cn("flex min-w-0 items-center gap-2.5 whitespace-nowrap px-2", className)} {...props}>
        {mark != null && (
          <div className="flex size-avatar-sm shrink-0 items-center justify-center rounded-item bg-brand-primary text-label-sm text-fg-inverse">
            {mark}
          </div>
        )}
        <div className={cn("min-w-0", fade(rail))}>
          <div className="aeros-logo truncate text-body-lg leading-tight text-fg-primary">{name}</div>
          {sub && <div className="truncate text-caption text-fg-muted">{sub}</div>}
        </div>
      </div>
    );
  }
);
SidebarBrand.displayName = "SidebarBrand";

export interface SidebarMenuButtonProps extends Omit<React.ButtonHTMLAttributes<HTMLButtonElement>, "name"> {
  /** A 24px mark or avatar. */
  leading?: React.ReactNode;
  name: React.ReactNode;
  sub?: React.ReactNode;
  /** Show the up/down chevrons that mark it as a menu. Default true. */
  chevron?: boolean;
  /** Tooltip text in the rail. Defaults to `name` when it is plain text. */
  tooltip?: string;
}

/**
 * A header or footer block that opens a menu: the workspace switcher, the account.
 * Use it as the child of a `DropdownMenuTrigger asChild`. In the rail only `leading` shows.
 */
export const SidebarMenuButton = React.forwardRef<HTMLButtonElement, SidebarMenuButtonProps>(
  ({ leading, name, sub, chevron = true, tooltip, className, ...props }, ref) => {
    const rail = useRail();
    const button = (
      <button
        ref={ref}
        type="button"
        className={cn(
          `flex w-full min-w-0 items-center gap-2.5 overflow-hidden whitespace-nowrap rounded-item px-2 py-1 text-left ${colorTransition}`,
          "hover:bg-state-hover active:bg-state-pressed",
          className
        )}
        {...props}
      >
        {leading != null && <span className="flex size-avatar-sm shrink-0 items-center justify-center">{leading}</span>}
        <span className={cn("grid min-w-0 flex-1", fade(rail))}>
          <span className="truncate text-label-sm text-fg-primary">{name}</span>
          {sub && <span className="truncate text-caption text-fg-muted">{sub}</span>}
        </span>
        {chevron && <ChevronsUpDown aria-hidden className={cn("size-icon-sm shrink-0 text-fg-muted", fade(rail))} />}
      </button>
    );
    const tip = tooltip ?? (typeof name === "string" ? name : undefined);
    if (!rail || !tip) return button;
    return (
      <Tooltip>
        <TooltipTrigger asChild>{button}</TooltipTrigger>
        <TooltipContent side="right">{tip}</TooltipContent>
      </Tooltip>
    );
  }
);
SidebarMenuButton.displayName = "SidebarMenuButton";

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
            In the rail a hairline takes its place in the same block, so rows keep their positions. */}
        {label && (
          <div className="relative flex h-7 items-end overflow-hidden whitespace-nowrap px-2 pb-1 text-caption text-fg-muted">
            <span id={labelId} className={fade(rail)}>
              {label}
            </span>
            {rail && <span aria-hidden className="absolute inset-x-2 top-1/2 h-px bg-border-default" />}
          </div>
        )}
        {children}
      </div>
    );
  }
);
SidebarSection.displayName = "SidebarSection";

// One row look for items, sub-items and group triggers. The left padding is
// 20px minus half the icon, which (inside the section's 8px) centres the icon at 28px.
const rowBase =
  `group/row relative flex h-nav-row w-full min-w-0 shrink-0 items-center gap-2.5 overflow-hidden whitespace-nowrap rounded-item ` +
  `pl-[calc(1.25rem-var(--aeros-size-nav-icon)/2)] pr-2 text-left text-label-sm [[data-density=touch]_&]:text-label-md ${colorTransition} ` +
  "[&>svg]:size-nav-icon [&>svg]:shrink-0";
const rowIdle = "text-fg-secondary hover:bg-state-hover hover:text-fg-primary active:bg-state-pressed";
// Fill and text colour only: the weight does not change, so labels never reflow.
const rowActive = "bg-state-selected text-fg-primary";

/** No icon: a small marker keeps labels aligned with rows that have one. */
const Marker = ({ active }: { active?: boolean }) => (
  <span aria-hidden className="flex size-nav-icon shrink-0 items-center justify-center">
    <span className={cn("size-1.5 rounded-full", active ? "bg-fg-primary" : "bg-border-strong")} />
  </span>
);

/** Inside a group: how deep, and whether the children are being shown in the rail's flyout menu. */
const NestContext = React.createContext<{ depth: number; flyout: boolean }>({ depth: 0, flyout: false });

export interface SidebarItemProps extends React.AnchorHTMLAttributes<HTMLAnchorElement> {
  active?: boolean;
  icon?: React.ReactNode;
  /** Shown when above zero (unread, pending) and announced with the label. A dot in the rail. */
  count?: number;
  /** `quiet` (default) is a muted number; `solid` is a filled pill for counts that need attention. */
  countTone?: "quiet" | "solid";
  /** Content at the row's end, e.g. a `<Kbd>` hint. Hidden in the rail. */
  trailing?: React.ReactNode;
  /**
   * Render the child element (e.g. a framework `<Link>`) as the row instead of a
   * native anchor: `<SidebarItem asChild icon={…}><Link href="/orders">Orders</Link></SidebarItem>`.
   * The row behaves exactly like the default one — the icon, the label and `count`
   * render inside the child, the label truncates, and in the rail it is visually
   * hidden but stays the accessible name. Pass only the label as the child's content.
   */
  asChild?: boolean;
  /**
   * Tooltip text in the rail. Defaults to the label when it is plain text
   * (with `asChild`, the child element's text content).
   */
  tooltip?: string;
}

export const SidebarItem = React.forwardRef<HTMLAnchorElement, SidebarItemProps>(
  ({ active, icon, count, countTone = "quiet", trailing, className, children, asChild, href, tooltip, ...props }, ref) => {
    const { rail, dismiss } = useSidebar();
    // Anchors without href are not keyboard-operable — fall back to a real button.
    const Comp: React.ElementType = asChild ? Slot : href != null ? "a" : "button";
    const hasCount = count != null && count > 0;
    const { onClick, ...rest } = props;
    // asChild: the caller's element becomes the row and its content is the label.
    // (Resolved first — from a Server Component the child can be a lazy reference.)
    const child = asChild ? resolveSlotChild(children) : null;
    const label = child ? child.props.children : children;

    const content = (
      <>
        {icon ?? <Marker active={active} />}
        <span className={cn("min-w-0 flex-1 truncate", fade(rail))}>{label}</span>
        {trailing != null && <span className={cn("ml-auto flex shrink-0 items-center", fade(rail))}>{trailing}</span>}
        {hasCount && (
          <span className={cn("ml-auto flex shrink-0 items-center", fade(rail))}>
            {/* Read as "Inbox, 3" rather than "Inbox3". */}
            <span className="sr-only">, </span>
            {countTone === "solid" ? (
              <CountBadge count={count} />
            ) : (
              <span className="pr-1 text-caption tabular-nums text-fg-muted">{count > 99 ? "99+" : count}</span>
            )}
          </span>
        )}
        {hasCount && rail && (
          // In the rail a dot on the icon's corner says there is a count; the tooltip gives the number.
          <span
            aria-hidden
            className="absolute left-[calc(1.25rem+var(--aeros-size-nav-icon)/2-0.375rem)] top-[calc(50%-var(--aeros-size-nav-icon)/2-0.25rem)] size-2.5 rounded-full border-2 border-bg-surface bg-fg-primary"
          />
        )}
      </>
    );

    const row = (
      <Comp
        ref={ref}
        href={href}
        {...(Comp === "button" ? { type: "button" as const } : null)}
        aria-current={active ? "page" : undefined}
        className={cn(rowBase, active ? rowActive : rowIdle, className)}
        onClick={(event: React.MouseEvent<HTMLAnchorElement>) => {
          onClick?.(event);
          // Choosing a destination dismisses the sheet or the floating sidebar.
          dismiss();
        }}
        {...rest}
      >
        {asChild ? child && React.cloneElement(child, undefined, content) : content}
      </Comp>
    );

    const tip = tooltip ?? (typeof label === "string" ? label : undefined);
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
 * A parent destination with children (`SidebarSubItem`s, or another `SidebarGroup`
 * for a further level — two levels is the design target). In the rail the parent
 * shows its icon and opens its children in a menu beside it.
 */
export const SidebarGroup = React.forwardRef<HTMLDivElement, SidebarGroupProps>(
  ({ label, icon, active, defaultOpen, className, children, ...props }, ref) => {
    const rail = useRail();
    const nest = React.useContext(NestContext);
    // Opens when it comes to hold the current page (client-side navigation),
    // not only on mount; the user can still close it.
    const [open, setOpen] = React.useState(defaultOpen ?? active ?? false);
    React.useEffect(() => {
      if (active) setOpen(true);
    }, [active]);

    // A group inside the rail's flyout menu: a label, then its children, indented.
    if (nest.flyout) {
      return (
        <div ref={ref} className={className}>
          <DropdownMenuLabel>{label}</DropdownMenuLabel>
          <div className="pl-3">
            <NestContext.Provider value={{ depth: nest.depth + 1, flyout: true }}>{children}</NestContext.Provider>
          </div>
        </div>
      );
    }

    // In the rail there is no room for children, so the parent opens them in a
    // menu beside it (the sidebar stays collapsed).
    if (rail) {
      const button = (
        <button type="button" className={cn(rowBase, active ? rowActive : rowIdle)}>
          {icon ?? <Marker active={active} />}
          <span className={cn("min-w-0 flex-1 truncate", fade(true))}>{label}</span>
        </button>
      );
      return (
        <div ref={ref} className={cn("grid", className)}>
          <DropdownMenu>
            {typeof label === "string" ? (
              <Tooltip>
                <TooltipTrigger asChild>
                  <DropdownMenuTrigger asChild>{button}</DropdownMenuTrigger>
                </TooltipTrigger>
                <TooltipContent side="right">{label}</TooltipContent>
              </Tooltip>
            ) : (
              <DropdownMenuTrigger asChild>{button}</DropdownMenuTrigger>
            )}
            <DropdownMenuContent side="right" align="start" sideOffset={12}>
              <DropdownMenuLabel>{label}</DropdownMenuLabel>
              <NestContext.Provider value={{ depth: 1, flyout: true }}>{children}</NestContext.Provider>
            </DropdownMenuContent>
          </DropdownMenu>
        </div>
      );
    }

    const nested = nest.depth > 0;
    return (
      <RC.Root ref={ref} open={open} onOpenChange={setOpen} className={cn("grid gap-0.5", className)} {...props}>
        <RC.Trigger className={cn(rowBase, nested && "pl-2.5 text-body-sm", rowIdle, active && "text-fg-primary")}>
          {!nested && (icon ?? <Marker active={active} />)}
          <span className="min-w-0 flex-1 truncate">{label}</span>
          <ChevronRight
            aria-hidden
            className="ml-auto size-icon-sm text-fg-muted transition-transform duration-fast ease-standard group-data-[state=open]/row:rotate-90 motion-reduce:transition-none"
          />
        </RC.Trigger>
        <RC.Content className="overflow-hidden data-[state=closed]:animate-collapsible-up data-[state=open]:animate-collapsible-down motion-reduce:animate-none">
          {/* The guide line sits under the parent's icon centre (28px from the edge). */}
          <div className={cn("grid gap-0.5 border-l border-border-default pl-2", nested ? "ml-2.5" : "ml-5")}>
            <NestContext.Provider value={{ depth: nest.depth + 1, flyout: false }}>{children}</NestContext.Provider>
          </div>
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

/** A child of `SidebarGroup`: no icon, indented under the group's guide line. */
export const SidebarSubItem = React.forwardRef<HTMLAnchorElement, SidebarSubItemProps>(
  ({ active, asChild, href, className, onClick, children, ...props }, ref) => {
    const { dismiss } = useSidebar();
    const { flyout } = React.useContext(NestContext);
    const Comp: React.ElementType = asChild ? Slot : href != null ? "a" : "button";
    const element = (
      <Comp
        ref={ref}
        href={href}
        {...(Comp === "button" ? { type: "button" as const } : null)}
        aria-current={active ? "page" : undefined}
        className={
          flyout
            ? cn("aria-[current=page]:bg-state-selected aria-[current=page]:font-medium", className)
            : cn(rowBase, "pl-2.5 text-body-sm", active ? cn(rowActive, "font-medium") : rowIdle, className)
        }
        onClick={(event: React.MouseEvent<HTMLAnchorElement>) => {
          onClick?.(event);
          dismiss();
        }}
        {...props}
      >
        {/* From a Server Component the child can be a lazy reference; give Slot the element. */}
        {asChild ? resolveLazyNode(children) : children}
      </Comp>
    );
    // In the rail's flyout the same element is a menu item (arrow keys, type-ahead, closes on choose).
    return flyout ? <DropdownMenuItem asChild>{element}</DropdownMenuItem> : element;
  }
);
SidebarSubItem.displayName = "SidebarSubItem";

/**
 * The one sidebar control, for every window size: collapses/expands at lg and up,
 * floats the sidebar open between md and lg, opens the sheet below md.
 * Place it at the leading edge of the app header.
 */
export const SidebarTrigger = React.forwardRef<HTMLButtonElement, React.ButtonHTMLAttributes<HTMLButtonElement>>(
  ({ className, onClick, children, ...props }, ref) => {
    const { toggle, rail, isMobile, mobileOpen, sidebarId } = useSidebar();
    return (
      <button
        ref={ref}
        type="button"
        data-sidebar-trigger=""
        aria-label="Toggle sidebar"
        aria-expanded={isMobile ? mobileOpen : !rail}
        // The sheet is not in the document while closed, so there is nothing to point at.
        aria-controls={!isMobile || mobileOpen ? sidebarId : undefined}
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
