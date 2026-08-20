"use client";
import * as React from "react";
import * as RA from "@radix-ui/react-avatar";
import { cva, type VariantProps } from "class-variance-authority";
import { cn } from "../lib/cn";

const avatarVariants = cva(
  "inline-flex items-center justify-center rounded-full font-bold overflow-hidden shrink-0",
  {
    variants: {
      size: {
        xs: "h-6 w-6 text-[9px]",
        sm: "h-[30px] w-[30px] text-[11px]",
        md: "h-[38px] w-[38px] text-[13px]",
        lg: "h-12 w-12 text-base",
        xl: "h-[60px] w-[60px] text-xl"
      },
      variant: {
        neutral: "bg-bg-subtle text-fg-primary border-[1.5px] border-border-default",
        inverse: "bg-bg-inverse text-fg-inverse",
        info:    "bg-info-bg text-info-text border-[1.5px] border-info-border",
        success: "bg-success-bg text-success-text border-[1.5px] border-success-border",
        warning: "bg-warning-bg text-warning-text border-[1.5px] border-warning-border"
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
      className={cn("flex [&>*]:ring-2 [&>*]:ring-bg-surface [&>*:not(:first-child)]:-ml-2.5", className)}
      {...props}
    >
      {children}
    </div>
  )
);
AvatarStack.displayName = "AvatarStack";

export { avatarVariants };
