"use client";
import * as React from "react";
import * as RD from "@radix-ui/react-dialog";
import { X } from "lucide-react";
import { cn } from "../lib/cn";
import {
  dialogMotion,
  dialogPosition,
  dialogSize,
  modalBody,
  modalClose,
  modalDescription,
  modalFooter,
  modalHeader,
  modalPanel,
  modalTitle,
  scrim,
  type DialogSize
} from "../internal/recipes";

export const Dialog: typeof RD.Root = RD.Root;
export const DialogTrigger: typeof RD.Trigger = RD.Trigger;
export const DialogPortal: typeof RD.Portal = RD.Portal;
export const DialogClose: typeof RD.Close = RD.Close;

export const DialogOverlay = React.forwardRef<
  React.ElementRef<typeof RD.Overlay>,
  React.ComponentPropsWithoutRef<typeof RD.Overlay>
>(({ className, ...props }, ref) => <RD.Overlay ref={ref} className={cn(scrim, className)} {...props} />);
DialogOverlay.displayName = "DialogOverlay";

export const DialogContent = React.forwardRef<
  React.ElementRef<typeof RD.Content>,
  React.ComponentPropsWithoutRef<typeof RD.Content> & {
    /** Max width: sm 400, md 520 (default), lg 720, xl 960, full = viewport. */
    size?: DialogSize;
    /** Hide the corner close button (e.g. confirmation dialogs that must be answered). */
    showClose?: boolean;
  }
>(({ className, children, size = "md", showClose = true, ...props }, ref) => (
  <DialogPortal>
    <DialogOverlay />
    <RD.Content ref={ref} className={cn(modalPanel, dialogPosition, dialogSize[size], dialogMotion, className)} {...props}>
      {children}
      {showClose && (
        <RD.Close className={modalClose}>
          <X />
          <span className="sr-only">Close</span>
        </RD.Close>
      )}
    </RD.Content>
  </DialogPortal>
));
DialogContent.displayName = "DialogContent";

export const DialogHeader = React.forwardRef<HTMLDivElement, React.HTMLAttributes<HTMLDivElement>>(
  ({ className, ...props }, ref) => <div ref={ref} className={cn(modalHeader, className)} {...props} />
);
DialogHeader.displayName = "DialogHeader";

export const DialogTitle = React.forwardRef<
  React.ElementRef<typeof RD.Title>,
  React.ComponentPropsWithoutRef<typeof RD.Title>
>(({ className, ...props }, ref) => <RD.Title ref={ref} className={cn(modalTitle, className)} {...props} />);
DialogTitle.displayName = "DialogTitle";

export const DialogDescription = React.forwardRef<
  React.ElementRef<typeof RD.Description>,
  React.ComponentPropsWithoutRef<typeof RD.Description>
>(({ className, ...props }, ref) => (
  <RD.Description ref={ref} className={cn(modalDescription, className)} {...props} />
));
DialogDescription.displayName = "DialogDescription";

export const DialogBody = React.forwardRef<HTMLDivElement, React.HTMLAttributes<HTMLDivElement>>(
  ({ className, ...props }, ref) => <div ref={ref} className={cn(modalBody, className)} {...props} />
);
DialogBody.displayName = "DialogBody";

export const DialogFooter = React.forwardRef<HTMLDivElement, React.HTMLAttributes<HTMLDivElement>>(
  ({ className, ...props }, ref) => <div ref={ref} className={cn(modalFooter, className)} {...props} />
);
DialogFooter.displayName = "DialogFooter";
