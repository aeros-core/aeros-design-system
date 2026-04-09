import * as React from "react";
import { Slot } from "@radix-ui/react-slot";
import { cva, type VariantProps } from "class-variance-authority";
import { cn } from "../lib/cn";

const buttonVariants = cva(
  "inline-flex items-center justify-center gap-2 font-semibold whitespace-nowrap select-none " +
  "transition-[background-color,border-color,color,transform,box-shadow] duration-[120ms] " +
  "active:scale-[0.98] disabled:opacity-40 disabled:pointer-events-none " +
  "focus-visible:outline-none focus-visible:ring-[3px] focus-visible:ring-royal-100",
  {
    variants: {
      variant: {
        primary:   "bg-royal-600 text-white hover:bg-royal-800",
        secondary: "bg-bg-surface text-fg-primary border border-border-default hover:bg-slate-50 hover:border-border-strong",
        ghost:     "bg-transparent text-royal-600 border border-royal-100 hover:bg-royal-50 hover:border-royal-200",
        danger:    "bg-danger-bg text-danger-text border border-[#FECACA] hover:bg-[#FEE2E2]",
        dark:      "bg-slate-900 text-white hover:bg-slate-800",
        link:      "bg-transparent text-royal-600 underline-offset-4 hover:underline px-0 py-0 h-auto"
      },
      size: {
        xs: "h-7 px-3 text-[11px] rounded-md",
        sm: "h-8 px-[14px] text-xs rounded-md",
        md: "h-10 px-[18px] text-sm rounded-md",
        lg: "h-11 px-[26px] text-[15px] rounded-lg",
        xl: "h-[52px] px-8 text-base rounded-lg",
        "icon-sm": "h-8 w-8 rounded-md",
        "icon-md": "h-10 w-10 rounded-md",
        "icon-lg": "h-11 w-11 rounded-lg"
      }
    },
    defaultVariants: { variant: "primary", size: "md" }
  }
);

export interface ButtonProps
  extends React.ButtonHTMLAttributes<HTMLButtonElement>,
    VariantProps<typeof buttonVariants> {
  asChild?: boolean;
  loading?: boolean;
  leadingIcon?: React.ReactNode;
  trailingIcon?: React.ReactNode;
}

export const Button = React.forwardRef<HTMLButtonElement, ButtonProps>(
  ({ className, variant, size, asChild, loading, leadingIcon, trailingIcon, children, disabled, ...props }, ref) => {
    const Comp = asChild ? Slot : "button";
    return (
      <Comp
        ref={ref}
        className={cn(buttonVariants({ variant, size }), className)}
        disabled={disabled || loading}
        aria-busy={loading || undefined}
        {...props}
      >
        {loading ? (
          <span className="inline-block h-3.5 w-3.5 animate-spin rounded-full border-2 border-current border-r-transparent" aria-hidden />
        ) : leadingIcon}
        {children}
        {trailingIcon}
      </Comp>
    );
  }
);
Button.displayName = "Button";

export { buttonVariants };
