"use client";
import * as React from "react";
import * as RSA from "@radix-ui/react-scroll-area";
import { cn } from "../lib/cn";
import { colorTransition } from "../internal/recipes";

export interface ScrollAreaProps
  extends Omit<React.ComponentPropsWithoutRef<typeof RSA.Root>, "aria-label" | "aria-labelledby"> {
  /** Which axes scroll (and show a scrollbar). */
  orientation?: "vertical" | "horizontal" | "both";
  /**
   * Names the scrolling region. The viewport is a keyboard stop so it can be
   * scrolled with the arrow keys; a name tells screen-reader users what it is.
   */
  "aria-label"?: string;
  "aria-labelledby"?: string;
  viewportClassName?: string;
  viewportRef?: React.Ref<HTMLDivElement>;
}

const ScrollBar = ({ orientation }: { orientation: "vertical" | "horizontal" }) => (
  <RSA.Scrollbar
    orientation={orientation}
    className={cn(
      `flex touch-none select-none p-px ${colorTransition}`,
      orientation === "vertical" ? "h-full w-2" : "h-2 flex-col"
    )}
  >
    <RSA.Thumb className={`relative flex-1 rounded-pill bg-border-strong hover:bg-fg-muted ${colorTransition}`} />
  </RSA.Scrollbar>
);

/**
 * A scroll container with thin, token-coloured scrollbars. Size it from the
 * outside (`className="h-64"`); the content scrolls inside.
 */
export const ScrollArea = React.forwardRef<React.ElementRef<typeof RSA.Root>, ScrollAreaProps>(
  (
    {
      className,
      children,
      orientation = "vertical",
      "aria-label": ariaLabel,
      "aria-labelledby": ariaLabelledby,
      viewportClassName,
      viewportRef,
      ...props
    },
    ref
  ) => {
    const labelled = ariaLabel != null || ariaLabelledby != null;
    return (
      <RSA.Root ref={ref} className={cn("relative overflow-hidden", className)} {...props}>
        <RSA.Viewport
          ref={viewportRef}
          // Focusable so the keyboard can scroll it. The root clips, so the focus ring sits inside.
          tabIndex={0}
          role={labelled ? "region" : undefined}
          aria-label={ariaLabel}
          aria-labelledby={ariaLabelledby}
          className={cn("size-full focus-ring-inset", viewportClassName)}
        >
          {children}
        </RSA.Viewport>
        {orientation !== "horizontal" && <ScrollBar orientation="vertical" />}
        {orientation !== "vertical" && <ScrollBar orientation="horizontal" />}
        {orientation === "both" && <RSA.Corner />}
      </RSA.Root>
    );
  }
);
ScrollArea.displayName = "ScrollArea";
