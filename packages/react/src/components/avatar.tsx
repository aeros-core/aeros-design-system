"use client";
import * as React from "react";
import * as RA from "@radix-ui/react-avatar";
import { cva, type VariantProps } from "class-variance-authority";
import { cn } from "../lib/cn";

const avatarVariants = cva(
  "inline-flex shrink-0 items-center justify-center overflow-hidden rounded-pill border font-medium",
  {
    variants: {
      size: {
        xs: "size-avatar-xs text-label-xs",
        sm: "size-avatar-sm text-label-xs",
        md: "size-avatar-md text-label-sm",
        lg: "size-avatar-lg text-label-md",
        xl: "size-avatar-xl text-h2"
      },
      variant: {
        neutral: "border-border-default bg-bg-subtle text-fg-primary",
        inverse: "border-transparent bg-bg-inverse text-fg-inverse",
        info:    "border-info-border bg-info-bg text-info-text",
        success: "border-success-border bg-success-bg text-success-text",
        warning: "border-warning-border bg-warning-bg text-warning-text"
      }
    },
    defaultVariants: { size: "md", variant: "neutral" }
  }
);

export interface AvatarProps
  extends React.ComponentPropsWithoutRef<typeof RA.Root>,
    VariantProps<typeof avatarVariants> {
  src?: string;
  alt?: string;
  fallback?: React.ReactNode;
}

export const Avatar = React.forwardRef<React.ElementRef<typeof RA.Root>, AvatarProps>(
  ({ className, size, variant, src, alt, fallback, ...props }, ref) => (
    <RA.Root ref={ref} className={cn(avatarVariants({ size, variant }), className)} {...props}>
      {src && <RA.Image className="h-full w-full object-cover" src={src} alt={alt ?? ""} />}
      <RA.Fallback className="flex h-full w-full items-center justify-center">
        {fallback}
      </RA.Fallback>
    </RA.Root>
  )
);
Avatar.displayName = "Avatar";

export const AvatarStack = React.forwardRef<HTMLDivElement, React.HTMLAttributes<HTMLDivElement>>(
  ({ children, className, ...props }, ref) => (
    <div
      ref={ref}
      className={cn("flex [&>*]:ring-2 [&>*]:ring-bg-surface [&>*:not(:first-child)]:-ml-2", className)}
      {...props}
    >
      {children}
    </div>
  )
);
AvatarStack.displayName = "AvatarStack";

export { avatarVariants };
