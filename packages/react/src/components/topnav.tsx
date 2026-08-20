import * as React from "react";
import { Slot } from "@radix-ui/react-slot";
import { cn } from "../lib/cn";

export const TopNav = React.forwardRef<HTMLElement, React.HTMLAttributes<HTMLElement>>(
  ({ className, children, ...props }, ref) => (
    <header
      ref={ref}
      className={cn(
        "h-14 flex items-center gap-2.5 px-5 rounded-lg bg-ink-950 text-white",
        className
      )}
      {...props}
    >
      {children}
    </header>
  )
);
TopNav.displayName = "TopNav";

export interface TopNavBrandProps extends React.HTMLAttributes<HTMLDivElement> {
  mark?: React.ReactNode;
  name: React.ReactNode;
}

export const TopNavBrand = React.forwardRef<HTMLDivElement, TopNavBrandProps>(
  ({ mark, name, className, ...props }, ref) => (
    <div ref={ref} className={cn("flex items-center gap-2.5", className)} {...props}>
      <div className="flex h-[30px] w-[30px] items-center justify-center rounded-lg bg-white text-[13px] font-extrabold tracking-[-0.01em] text-ink-900">
        {mark}
      </div>
      <div className="aeros-logo text-[15px]">{name}</div>
    </div>
  )
);
TopNavBrand.displayName = "TopNavBrand";

export const TopNavLinks = React.forwardRef<HTMLElement, React.HTMLAttributes<HTMLElement>>(
  ({ className, children, ...props }, ref) => (
    <nav ref={ref} aria-label="Primary" className={cn("flex flex-1 gap-0.5 ml-1.5", className)} {...props}>
      {children}
    </nav>
  )
);
TopNavLinks.displayName = "TopNavLinks";

export interface TopNavLinkProps extends React.AnchorHTMLAttributes<HTMLAnchorElement> {
  active?: boolean;
  /** Render the child element (e.g. a framework `<Link>`) instead of a native anchor. */
  asChild?: boolean;
}

export const TopNavLink = React.forwardRef<HTMLAnchorElement, TopNavLinkProps>(
  ({ active, className, asChild, href, ...props }, ref) => {
    // Anchors without href are not keyboard-operable — fall back to a real button.
    const Comp: React.ElementType = asChild ? Slot : href != null ? "a" : "button";
    return (
      <Comp
        ref={ref}
        href={href}
        {...(Comp === "button" ? { type: "button" as const } : null)}
        aria-current={active ? "page" : undefined}
        className={cn(
          "text-[13px] font-medium px-2.5 py-1 rounded-md transition-colors duration-(--aeros-duration-quick)",
          "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-white/80",
          active ? "bg-white/10 text-white font-semibold" : "text-white/55 hover:bg-white/[0.05] hover:text-white/90",
          className
        )}
        {...props}
      />
    );
  }
);
TopNavLink.displayName = "TopNavLink";

export const TopNavRight = React.forwardRef<HTMLDivElement, React.HTMLAttributes<HTMLDivElement>>(
  ({ className, children, ...props }, ref) => (
    <div ref={ref} className={cn("flex items-center gap-2", className)} {...props}>
      {children}
    </div>
  )
);
TopNavRight.displayName = "TopNavRight";
