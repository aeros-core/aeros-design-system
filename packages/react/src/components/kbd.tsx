import * as React from "react";
import { cn } from "../lib/cn";

/** One key of a keyboard hint. */
export const Kbd = React.forwardRef<HTMLElement, React.HTMLAttributes<HTMLElement>>(
  ({ className, ...props }, ref) => (
    <kbd
      ref={ref}
      className={cn(
        "inline-flex h-5 min-w-5 items-center justify-center rounded-item border border-border-default bg-bg-subtle px-1 font-mono text-mono-xs text-fg-secondary",
        className
      )}
      {...props}
    />
  )
);
Kbd.displayName = "Kbd";

/** A key combination: `<KbdGroup><Kbd>⌘</Kbd><Kbd>K</Kbd></KbdGroup>`. */
export const KbdGroup = React.forwardRef<HTMLElement, React.HTMLAttributes<HTMLElement>>(
  ({ className, ...props }, ref) => (
    // HTML's own idiom for a combination is a <kbd> holding the keys.
    <kbd ref={ref} className={cn("inline-flex items-center gap-1 font-mono", className)} {...props} />
  )
);
KbdGroup.displayName = "KbdGroup";
