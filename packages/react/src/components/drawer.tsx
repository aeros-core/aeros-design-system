"use client";
import * as React from "react";
import * as RD from "@radix-ui/react-dialog";
import { X } from "lucide-react";
import { cva, type VariantProps } from "class-variance-authority";
import { cn } from "../lib/cn";

// Side sheet built on the Dialog primitive — full focus trap, Escape, scrim.

export const Drawer: typeof RD.Root = RD.Root;
export const DrawerTrigger: typeof RD.Trigger = RD.Trigger;
export const DrawerClose: typeof RD.Close = RD.Close;
export const DrawerPortal: typeof RD.Portal = RD.Portal;
export const DrawerTitle = RD.Title;
export const DrawerDescription = RD.Description;

export const DrawerOverlay = React.forwardRef<
  React.ElementRef<typeof RD.Overlay>,
  React.ComponentPropsWithoutRef<typeof RD.Overlay>
>(({ className, ...props }, ref) => (
  <RD.Overlay
    ref={ref}
    className={cn(
      "fixed inset-0 z-(--aeros-z-overlay) bg-ink-900/60 backdrop-blur-[2px]",
      "data-[state=open]:animate-in data-[state=closed]:animate-out data-[state=closed]:fade-out-0 data-[state=open]:fade-in-0",
      className
    )}
    {...props}
  />
));
DrawerOverlay.displayName = "DrawerOverlay";

const drawerVariants = cva(
  "fixed z-(--aeros-z-modal) flex flex-col bg-bg-elevated shadow-xl border-border-default focus-visible:outline-none " +
  "data-[state=open]:animate-in data-[state=closed]:animate-out data-[state=open]:duration-(--aeros-duration-slow) data-[state=open]:ease-(--aeros-ease-entrance) data-[state=closed]:duration-(--aeros-duration-base) motion-reduce:animate-none",
  {
    variants: {
      side: {
        right:  "inset-y-0 right-0 w-full max-w-md border-l data-[state=open]:slide-in-from-right data-[state=closed]:slide-out-to-right",
        left:   "inset-y-0 left-0 w-full max-w-md border-r data-[state=open]:slide-in-from-left data-[state=closed]:slide-out-to-left",
        bottom: "inset-x-0 bottom-0 max-h-[85dvh] rounded-t-xl border-t data-[state=open]:slide-in-from-bottom data-[state=closed]:slide-out-to-bottom"
      }
    },
    defaultVariants: { side: "right" }
  }
);

export const DrawerContent = React.forwardRef<
  React.ElementRef<typeof RD.Content>,
  React.ComponentPropsWithoutRef<typeof RD.Content> & VariantProps<typeof drawerVariants> & {
    showClose?: boolean;
  }
>(({ className, children, side, showClose = true, ...props }, ref) => (
  <RD.Portal>
    <DrawerOverlay />
    <RD.Content ref={ref} className={cn(drawerVariants({ side }), className)} {...props}>
      {children}
      {showClose && (
        <RD.Close className="absolute right-3 top-3 rounded-md p-1 text-fg-muted hover:bg-bg-subtle hover:text-fg-primary transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-focus-ring focus-visible:ring-offset-2 focus-visible:ring-offset-bg-elevated">
          <X className="h-4 w-4" />
          <span className="sr-only">Close</span>
        </RD.Close>
      )}
    </RD.Content>
  </RD.Portal>
));
DrawerContent.displayName = "DrawerContent";

export const DrawerHeader = React.forwardRef<HTMLDivElement, React.HTMLAttributes<HTMLDivElement>>(
  ({ className, ...props }, ref) => (
    <div ref={ref} className={cn("px-5 pt-5 pb-4 border-b border-border-default shrink-0", className)} {...props} />
  )
);
DrawerHeader.displayName = "DrawerHeader";

export const DrawerBody = React.forwardRef<HTMLDivElement, React.HTMLAttributes<HTMLDivElement>>(
  ({ className, ...props }, ref) => (
    <div ref={ref} className={cn("px-5 py-[18px] min-h-0 flex-1 overflow-y-auto", className)} {...props} />
  )
);
DrawerBody.displayName = "DrawerBody";

export const DrawerFooter = React.forwardRef<HTMLDivElement, React.HTMLAttributes<HTMLDivElement>>(
  ({ className, ...props }, ref) => (
    <div ref={ref} className={cn("flex justify-end gap-2 px-5 py-3.5 bg-bg-subtle border-t border-border-default shrink-0", className)} {...props} />
  )
);
DrawerFooter.displayName = "DrawerFooter";
