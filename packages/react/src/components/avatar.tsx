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
      tone: {
        royal: "bg-royal-50 text-royal-800 border-[1.5px] border-royal-100",
        dark:  "bg-slate-800 text-slate-200",
        green: "bg-success-bg text-success-text border-[1.5px] border-[#BBF7D0]",
        amber: "bg-warning-bg text-warning-text border-[1.5px] border-[#FDE68A]"
      }
    },
    defaultVariants: { size: "md", tone: "royal" }
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
  ({ className, size, tone, src, alt, fallback, ...props }, ref) => (
    <RA.Root ref={ref} className={cn(avatarVariants({ size, tone }), className)} {...props}>
      {src && <RA.Image className="h-full w-full object-cover" src={src} alt={alt ?? ""} />}
      <RA.Fallback className="flex h-full w-full items-center justify-center">
        {fallback}
      </RA.Fallback>
    </RA.Root>
  )
);
Avatar.displayName = "Avatar";

export function AvatarStack({
  children,
  className
}: {
  children: React.ReactNode;
  className?: string;
}) {
  return (
    <div className={cn("flex [&>*]:ring-2 [&>*]:ring-white [&>*:not(:first-child)]:-ml-2.5", className)}>
      {children}
    </div>
  );
}
