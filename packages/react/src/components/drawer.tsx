"use client";
import * as React from "react";
import * as RD from "@radix-ui/react-dialog";
import { X } from "lucide-react";
import { cva, type VariantProps } from "class-variance-authority";
import { cn } from "../lib/cn";
import {
  modalBody,
  modalClose,
  modalDescription,
  modalFooter,
  modalHeader,
  modalPanel,
  modalTitle,
  scrim
} from "../internal/recipes";

// Side sheet built on the Dialog primitive — full focus trap, Escape, scrim.

export const Drawer: typeof RD.Root = RD.Root;
export const DrawerTrigger: typeof RD.Trigger = RD.Trigger;
export const DrawerClose: typeof RD.Close = RD.Close;
export const DrawerPortal: typeof RD.Portal = RD.Portal;

export const DrawerOverlay = React.forwardRef<
  React.ElementRef<typeof RD.Overlay>,
  React.ComponentPropsWithoutRef<typeof RD.Overlay>
>(({ className, ...props }, ref) => <RD.Overlay ref={ref} className={cn(scrim, className)} {...props} />);
DrawerOverlay.displayName = "DrawerOverlay";

const drawerVariants = cva(
  `fixed ${modalPanel} ` +
    "data-[state=open]:animate-in data-[state=closed]:animate-out " +
    "data-[state=open]:duration-slow data-[state=open]:ease-enter data-[state=closed]:duration-base data-[state=closed]:ease-exit " +
    "motion-reduce:animate-none",
  {
    variants: {
      side: {
        right: "inset-y-0 right-0 w-full data-[state=open]:slide-in-from-right data-[state=closed]:slide-out-to-right",
        left: "inset-y-0 left-0 w-full data-[state=open]:slide-in-from-left data-[state=closed]:slide-out-to-left",
        bottom:
          "inset-x-0 bottom-0 max-h-[85dvh] rounded-t-modal data-[state=open]:slide-in-from-bottom data-[state=closed]:slide-out-to-bottom"
      },
      /** Width of a side drawer: sm 360, md 480 (default), lg 640. Ignored for `bottom`. */
      size: { sm: "", md: "", lg: "" }
    },
    compoundVariants: [
      { side: ["left", "right"], size: "sm", class: "max-w-drawer-sm" },
      { side: ["left", "right"], size: "md", class: "max-w-drawer-md" },
      { side: ["left", "right"], size: "lg", class: "max-w-drawer-lg" }
    ],
    defaultVariants: { side: "right", size: "md" }
  }
);

export const DrawerContent = React.forwardRef<
  React.ElementRef<typeof RD.Content>,
  React.ComponentPropsWithoutRef<typeof RD.Content> &
    VariantProps<typeof drawerVariants> & {
      showClose?: boolean;
    }
>(({ className, children, side, size, showClose = true, ...props }, ref) => (
  <RD.Portal>
    <DrawerOverlay />
    <RD.Content ref={ref} className={cn(drawerVariants({ side, size }), className)} {...props}>
      {children}
      {showClose && (
        <RD.Close className={modalClose}>
          <X />
          <span className="sr-only">Close</span>
        </RD.Close>
      )}
    </RD.Content>
  </RD.Portal>
));
DrawerContent.displayName = "DrawerContent";

export const DrawerHeader = React.forwardRef<HTMLDivElement, React.HTMLAttributes<HTMLDivElement>>(
  ({ className, ...props }, ref) => <div ref={ref} className={cn(modalHeader, className)} {...props} />
);
DrawerHeader.displayName = "DrawerHeader";

export const DrawerTitle = React.forwardRef<
  React.ElementRef<typeof RD.Title>,
  React.ComponentPropsWithoutRef<typeof RD.Title>
>(({ className, ...props }, ref) => <RD.Title ref={ref} className={cn(modalTitle, className)} {...props} />);
DrawerTitle.displayName = "DrawerTitle";

export const DrawerDescription = React.forwardRef<
  React.ElementRef<typeof RD.Description>,
  React.ComponentPropsWithoutRef<typeof RD.Description>
>(({ className, ...props }, ref) => (
  <RD.Description ref={ref} className={cn(modalDescription, className)} {...props} />
));
DrawerDescription.displayName = "DrawerDescription";

export const DrawerBody = React.forwardRef<HTMLDivElement, React.HTMLAttributes<HTMLDivElement>>(
  ({ className, ...props }, ref) => <div ref={ref} className={cn(modalBody, className)} {...props} />
);
DrawerBody.displayName = "DrawerBody";

export const DrawerFooter = React.forwardRef<HTMLDivElement, React.HTMLAttributes<HTMLDivElement>>(
  ({ className, ...props }, ref) => <div ref={ref} className={cn(modalFooter, className)} {...props} />
);
DrawerFooter.displayName = "DrawerFooter";
