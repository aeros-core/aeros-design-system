"use client";
import * as React from "react";
import * as RA from "@radix-ui/react-alert-dialog";
import { cn } from "../lib/cn";
import {
  dialogMotion,
  dialogPosition,
  dialogSize,
  modalDescription,
  modalFooter,
  modalHeader,
  modalPanel,
  modalTitle,
  scrim,
  type DialogSize
} from "../internal/recipes";

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
>(({ className, ...props }, ref) => <RA.Overlay ref={ref} className={cn(scrim, className)} {...props} />);
AlertDialogOverlay.displayName = "AlertDialogOverlay";

export const AlertDialogContent = React.forwardRef<
  React.ElementRef<typeof RA.Content>,
  React.ComponentPropsWithoutRef<typeof RA.Content> & {
    /** Max width: sm 400 (default), md 520, lg 720, xl 960. */
    size?: DialogSize;
  }
>(({ className, size = "sm", ...props }, ref) => (
  <RA.Portal>
    <AlertDialogOverlay />
    <RA.Content ref={ref} className={cn(modalPanel, dialogPosition, dialogSize[size], dialogMotion, className)} {...props} />
  </RA.Portal>
));
AlertDialogContent.displayName = "AlertDialogContent";

export const AlertDialogHeader = React.forwardRef<HTMLDivElement, React.HTMLAttributes<HTMLDivElement>>(
  ({ className, ...props }, ref) => <div ref={ref} className={cn(modalHeader, "pb-5 pr-5", className)} {...props} />
);
AlertDialogHeader.displayName = "AlertDialogHeader";

export const AlertDialogTitle = React.forwardRef<
  React.ElementRef<typeof RA.Title>,
  React.ComponentPropsWithoutRef<typeof RA.Title>
>(({ className, ...props }, ref) => <RA.Title ref={ref} className={cn(modalTitle, className)} {...props} />);
AlertDialogTitle.displayName = "AlertDialogTitle";

export const AlertDialogDescription = React.forwardRef<
  React.ElementRef<typeof RA.Description>,
  React.ComponentPropsWithoutRef<typeof RA.Description>
>(({ className, ...props }, ref) => (
  <RA.Description ref={ref} className={cn(modalDescription, className)} {...props} />
));
AlertDialogDescription.displayName = "AlertDialogDescription";

export const AlertDialogFooter = React.forwardRef<HTMLDivElement, React.HTMLAttributes<HTMLDivElement>>(
  ({ className, ...props }, ref) => <div ref={ref} className={cn(modalFooter, className)} {...props} />
);
AlertDialogFooter.displayName = "AlertDialogFooter";
