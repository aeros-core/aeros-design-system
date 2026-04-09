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
      "fixed inset-0 z-[1300] bg-ink-900/60 backdrop-blur-[2px]",
      "data-[state=open]:animate-in data-[state=closed]:animate-out data-[state=closed]:fade-out-0 data-[state=open]:fade-in-0",
      className
    )}
    {...props}
  />
));
DialogOverlay.displayName = "DialogOverlay";

export const DialogContent = React.forwardRef<
  React.ElementRef<typeof RD.Content>,
  React.ComponentPropsWithoutRef<typeof RD.Content>
>(({ className, children, ...props }, ref) => (
  <DialogPortal>
    <DialogOverlay />
    <RD.Content
      ref={ref}
      className={cn(
        "fixed left-1/2 top-1/2 z-[1400] w-full max-w-[420px] -translate-x-1/2 -translate-y-1/2",
        "rounded-xl border border-border-default bg-bg-surface shadow-xl overflow-hidden",
        "focus-visible:outline-none",
        "data-[state=open]:animate-in data-[state=closed]:animate-out data-[state=closed]:fade-out-0 data-[state=open]:fade-in-0 data-[state=closed]:zoom-out-95 data-[state=open]:zoom-in-95",
        className
      )}
      {...props}
    >
      {children}
      <RD.Close className="absolute right-3 top-3 rounded-md p-1 text-fg-muted hover:bg-bg-subtle focus-visible:outline-none focus-visible:ring-[3px] focus-visible:ring-ink-100">
        <X className="h-4 w-4" />
        <span className="sr-only">Close</span>
      </RD.Close>
    </RD.Content>
  </DialogPortal>
));
DialogContent.displayName = "DialogContent";

export function DialogHeader({ className, ...props }: React.HTMLAttributes<HTMLDivElement>) {
  return <div className={cn("px-[22px] pt-5 pb-4 border-b border-border-default", className)} {...props} />;
}

export const DialogTitle = React.forwardRef<
  React.ElementRef<typeof RD.Title>,
  React.ComponentPropsWithoutRef<typeof RD.Title>
>(({ className, ...props }, ref) => (
  <RD.Title
    ref={ref}
    className={cn("text-base font-bold tracking-[-0.01em] text-fg-primary", className)}
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

export function DialogBody({ className, ...props }: React.HTMLAttributes<HTMLDivElement>) {
  return <div className={cn("px-[22px] py-[18px]", className)} {...props} />;
}

export function DialogFooter({ className, ...props }: React.HTMLAttributes<HTMLDivElement>) {
  return (
    <div
      className={cn(
        "flex justify-end gap-2 px-[22px] py-3.5 bg-bg-subtle border-t border-border-default",
        className
      )}
      {...props}
    />
  );
}
