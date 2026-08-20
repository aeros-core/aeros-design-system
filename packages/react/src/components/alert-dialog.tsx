"use client";
import * as React from "react";
import * as RA from "@radix-ui/react-alert-dialog";
import { cn } from "../lib/cn";

// Destructive / must-answer confirmations. Unlike Dialog there is no corner
// close and no outside-click dismiss — the user answers with the actions.

export const AlertDialog: typeof RA.Root = RA.Root;
export const AlertDialogTrigger: typeof RA.Trigger = RA.Trigger;
export const AlertDialogPortal: typeof RA.Portal = RA.Portal;
export const AlertDialogAction: typeof RA.Action = RA.Action;
export const AlertDialogCancel: typeof RA.Cancel = RA.Cancel;

export const AlertDialogOverlay = React.forwardRef<
  React.ElementRef<typeof RA.Overlay>,
  React.ComponentPropsWithoutRef<typeof RA.Overlay>
>(({ className, ...props }, ref) => (
  <RA.Overlay
    ref={ref}
    className={cn(
      "fixed inset-0 z-(--aeros-z-overlay) bg-ink-900/60 backdrop-blur-[2px]",
      "data-[state=open]:animate-in data-[state=closed]:animate-out data-[state=closed]:fade-out-0 data-[state=open]:fade-in-0",
      className
    )}
    {...props}
  />
));
AlertDialogOverlay.displayName = "AlertDialogOverlay";

export const AlertDialogContent = React.forwardRef<
  React.ElementRef<typeof RA.Content>,
  React.ComponentPropsWithoutRef<typeof RA.Content>
>(({ className, ...props }, ref) => (
  <RA.Portal>
    <AlertDialogOverlay />
    <RA.Content
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
    />
  </RA.Portal>
));
AlertDialogContent.displayName = "AlertDialogContent";

export const AlertDialogHeader = React.forwardRef<HTMLDivElement, React.HTMLAttributes<HTMLDivElement>>(
  ({ className, ...props }, ref) => (
    <div ref={ref} className={cn("px-5 pt-5 pb-4 shrink-0", className)} {...props} />
  )
);
AlertDialogHeader.displayName = "AlertDialogHeader";

export const AlertDialogTitle = React.forwardRef<
  React.ElementRef<typeof RA.Title>,
  React.ComponentPropsWithoutRef<typeof RA.Title>
>(({ className, ...props }, ref) => (
  <RA.Title
    ref={ref}
    className={cn("text-lg font-semibold tracking-[-0.01em] text-fg-primary", className)}
    {...props}
  />
));
AlertDialogTitle.displayName = "AlertDialogTitle";

export const AlertDialogDescription = React.forwardRef<
  React.ElementRef<typeof RA.Description>,
  React.ComponentPropsWithoutRef<typeof RA.Description>
>(({ className, ...props }, ref) => (
  <RA.Description
    ref={ref}
    className={cn("mt-1 text-[13px] text-fg-muted", className)}
    {...props}
  />
));
AlertDialogDescription.displayName = "AlertDialogDescription";

export const AlertDialogFooter = React.forwardRef<HTMLDivElement, React.HTMLAttributes<HTMLDivElement>>(
  ({ className, ...props }, ref) => (
    <div
      ref={ref}
      className={cn("flex justify-end gap-2 px-5 py-3.5 bg-bg-subtle border-t border-border-default shrink-0", className)}
      {...props}
    />
  )
);
AlertDialogFooter.displayName = "AlertDialogFooter";
