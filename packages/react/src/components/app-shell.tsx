import * as React from "react";
import { Slot } from "@radix-ui/react-slot";
import { cn } from "../lib/cn";
import { resolveLazyNode } from "../internal/as-child";
import { colorTransition } from "../internal/recipes";

// The page frame: a sidebar beside a column of header, content and footer.
//
//   <SidebarProvider>
//     <AppShell>
//       <Sidebar>…</Sidebar>
//       <AppMain>
//         <AppHeader>…</AppHeader>
//         <AppContent>…</AppContent>
//         <AppFooter>…</AppFooter>
//       </AppMain>
//     </AppShell>
//   </SidebarProvider>
//
// All of it follows the theme. These are plain layout elements with no hooks.
// (The published bundle is one client module, so they render as client
// components; Server Components can still compose them.)

export const AppShell = React.forwardRef<HTMLDivElement, React.HTMLAttributes<HTMLDivElement>>(
  ({ className, ...props }, ref) => (
    <div ref={ref} className={cn("flex min-h-dvh bg-bg-canvas text-fg-primary", className)} {...props} />
  )
);
AppShell.displayName = "AppShell";

/** The column beside the sidebar. */
export const AppMain = React.forwardRef<HTMLDivElement, React.HTMLAttributes<HTMLDivElement>>(
  ({ className, ...props }, ref) => <div ref={ref} className={cn("flex min-w-0 flex-1 flex-col", className)} {...props} />
);
AppMain.displayName = "AppMain";

/** The top bar: full width, hairline below, level with the sidebar header. */
export const AppHeader = React.forwardRef<HTMLElement, React.HTMLAttributes<HTMLElement>>(
  ({ className, ...props }, ref) => (
    <header
      ref={ref}
      className={cn(
        "sticky top-0 z-sticky flex h-header shrink-0 items-center gap-3 border-b border-border-default bg-bg-surface px-4",
        className
      )}
      {...props}
    />
  )
);
AppHeader.displayName = "AppHeader";

export interface AppHeaderBrandProps extends React.HTMLAttributes<HTMLDivElement> {
  /** A letter or small logo in the mark tile. */
  mark?: React.ReactNode;
  /** The product name — rendered as the Aeros wordmark. */
  name: React.ReactNode;
}

/** For apps without a sidebar; with one, the brand lives in `SidebarHeader`. */
export const AppHeaderBrand = React.forwardRef<HTMLDivElement, AppHeaderBrandProps>(
  ({ mark, name, className, ...props }, ref) => (
    <div ref={ref} className={cn("flex shrink-0 items-center gap-2", className)} {...props}>
      {mark != null && (
        <div className="flex size-avatar-sm items-center justify-center rounded-item bg-brand-primary text-label-sm text-fg-inverse">
          {mark}
        </div>
      )}
      <div className="aeros-logo text-body-lg text-fg-primary">{name}</div>
    </div>
  )
);
AppHeaderBrand.displayName = "AppHeaderBrand";

export interface AppHeaderTitleProps extends React.HTMLAttributes<HTMLElement> {
  /**
   * The element to render. `h1` by default; use `"div"` (or `"h2"`) when the page
   * body has its own `h1`, e.g. a `PageHeader`, so the page keeps a single h1.
   */
  as?: "h1" | "h2" | "div";
}

/** The page or section title. */
export const AppHeaderTitle = React.forwardRef<HTMLElement, AppHeaderTitleProps>(
  ({ className, as: Comp = "h1", ...props }, ref) => (
    <Comp
      ref={ref as React.Ref<HTMLHeadingElement & HTMLDivElement>}
      className={cn("min-w-0 truncate text-h4 text-fg-primary", className)}
      {...props}
    />
  )
);
AppHeaderTitle.displayName = "AppHeaderTitle";

/** Primary destinations, for a top-navigation layout. */
export const AppHeaderNav = React.forwardRef<HTMLElement, React.HTMLAttributes<HTMLElement>>(
  ({ className, ...props }, ref) => (
    <nav ref={ref} aria-label="Primary" className={cn("flex min-w-0 flex-1 items-center gap-0.5", className)} {...props} />
  )
);
AppHeaderNav.displayName = "AppHeaderNav";

export interface AppHeaderLinkProps extends React.AnchorHTMLAttributes<HTMLAnchorElement> {
  active?: boolean;
  /** Render the child element (e.g. a framework `<Link>`) instead of a native anchor. */
  asChild?: boolean;
}

export const AppHeaderLink = React.forwardRef<HTMLAnchorElement, AppHeaderLinkProps>(
  ({ active, className, asChild, href, children, ...props }, ref) => {
    // Anchors without href are not keyboard-operable — fall back to a real button.
    const Comp: React.ElementType = asChild ? Slot : href != null ? "a" : "button";
    return (
      <Comp
        ref={ref}
        href={href}
        {...(Comp === "button" ? { type: "button" as const } : null)}
        aria-current={active ? "page" : undefined}
        className={cn(
          `inline-flex h-control-sm shrink-0 items-center whitespace-nowrap rounded-control px-2.5 text-label-sm ${colorTransition}`,
          active ? "bg-bg-subtle text-fg-primary" : "text-fg-secondary hover:bg-state-hover hover:text-fg-primary",
          className
        )}
        {...props}
      >
        {/* From a Server Component the child can be a lazy reference; give Slot the element. */}
        {asChild ? resolveLazyNode(children) : children}
      </Comp>
    );
  }
);
AppHeaderLink.displayName = "AppHeaderLink";

/** Trailing controls: search, notifications, the account menu. */
export const AppHeaderActions = React.forwardRef<HTMLDivElement, React.HTMLAttributes<HTMLDivElement>>(
  ({ className, ...props }, ref) => (
    <div ref={ref} className={cn("ml-auto flex shrink-0 items-center gap-1.5", className)} {...props} />
  )
);
AppHeaderActions.displayName = "AppHeaderActions";

/** The scrolling page area. `contained` centres content at the readable max width. */
export const AppContent = React.forwardRef<
  HTMLElement,
  React.HTMLAttributes<HTMLElement> & { contained?: boolean }
>(({ className, contained, ...props }, ref) => (
  <main ref={ref} className={cn("min-w-0 flex-1 p-4 md:p-6", contained && "mx-auto w-full max-w-content-max", className)} {...props} />
));
AppContent.displayName = "AppContent";

export const AppFooter = React.forwardRef<HTMLElement, React.HTMLAttributes<HTMLElement>>(
  ({ className, ...props }, ref) => (
    <footer
      ref={ref}
      className={cn(
        "flex shrink-0 flex-wrap items-center justify-between gap-x-4 gap-y-1 border-t border-border-default px-4 py-3 text-caption text-fg-muted md:px-6",
        className
      )}
      {...props}
    />
  )
);
AppFooter.displayName = "AppFooter";
