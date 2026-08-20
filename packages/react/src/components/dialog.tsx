"use client";
import * as React from "react";
import * as RD from "@radix-ui/react-dialog";
import { X } from "lucide-react";
import { cn } from "../lib/cn";

export const Dialog: typeof RD.Root = RD.Root;
export const DialogTrigger: typeof RD.Trigger = RD.Trigger;
export const DialogPortal: typeof RD.Portal = RD.Portal;
export const DialogClose: typeof RD.Close = RD.Close;

export const DialogOverlay = React.forwardRef<
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
DialogOverlay.displayName = "DialogOverlay";

export const DialogContent = React.forwardRef<
  React.ElementRef<typeof RD.Content>,
  React.ComponentPropsWithoutRef<typeof RD.Content> & {
    /** Hide the corner close button (e.g. confirmation dialogs that must be answered). */
    showClose?: boolean;
  }
>(({ className, children, showClose = true, ...props }, ref) => (
  <DialogPortal>
    <DialogOverlay />
    <RD.Content
      ref={ref}
      className={cn(
        "fixed left-1/2 top-1/2 z-(--aeros-z-modal) w-full max-w-[420px] -translate-x-1/2 -translate-y-1/2",
        "flex flex-col max-h-[calc(100dvh-4rem)]",
        "rounded-xl border border-border-default bg-bg-elevated shadow-xl overflow-hidden",
        "focus-visible:outline-none",
        "data-[state=open]:animate-in data-[state=closed]:animate-out data-[state=closed]:fade-out-0 data-[state=open]:fade-in-0 data-[state=closed]:zoom-out-95 data-[state=open]:zoom-in-95 data-[state=open]:duration-(--aeros-duration-base) data-[state=open]:ease-(--aeros-ease-entrance)",
        className
      )}
      {...props}
    >
      {children}
      {showClose && (
        <RD.Close className="absolute right-3 top-3 rounded-md p-1 text-fg-muted hover:bg-bg-subtle hover:text-fg-primary transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-focus-ring focus-visible:ring-offset-2 focus-visible:ring-offset-bg-elevated">
          <X className="h-4 w-4" />
          <span className="sr-only">Close</span>
        </RD.Close>
      )}
    </RD.Content>
  </DialogPortal>
));
DialogContent.displayName = "DialogContent";

export const DialogHeader = React.forwardRef<HTMLDivElement, React.HTMLAttributes<HTMLDivElement>>(
  ({ className, ...props }, ref) => (
    <div ref={ref} className={cn("px-5 pt-5 pb-4 border-b border-border-default shrink-0", className)} {...props} />
  )
);
DialogHeader.displayName = "DialogHeader";

export const DialogTitle = React.forwardRef<
  React.ElementRef<typeof RD.Title>,
  React.ComponentPropsWithoutRef<typeof RD.Title>
>(({ className, ...props }, ref) => (
  <RD.Title
    ref={ref}
    className={cn("text-lg font-semibold tracking-[-0.01em] text-fg-primary", className)}
    {...props}
  />
));
DialogTitle.displayName = "DialogTitle";

export const DialogDescription = React.forwardRef<
  React.ElementRef<typeof RD.Description>,
  React.ComponentPropsWithoutRef<typeof RD.Description>
>(({ className, ...props }, ref) => (
  <RD.Description
    ref={ref}
    className={cn("mt-1 text-[13px] text-fg-muted", className)}
    {...props}
  />
));
DialogDescription.displayName = "DialogDescription";

export const DialogBody = React.forwardRef<HTMLDivElement, React.HTMLAttributes<HTMLDivElement>>(
  ({ className, ...props }, ref) => (
    // min-h-0 + overflow lets long bodies scroll instead of pushing the footer off-screen.
    <div ref={ref} className={cn("px-5 py-[18px] min-h-0 overflow-y-auto", className)} {...props} />
  )
);
DialogBody.displayName = "DialogBody";

export const DialogFooter = React.forwardRef<HTMLDivElement, React.HTMLAttributes<HTMLDivElement>>(
  ({ className, ...props }, ref) => (
    <div
      ref={ref}
      className={cn(
        "flex justify-end gap-2 px-5 py-3.5 bg-bg-subtle border-t border-border-default shrink-0",
        className
      )}
      {...props}
    />
  )
);
DialogFooter.displayName = "DialogFooter";
