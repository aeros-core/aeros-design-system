import * as React from "react";
import { Slot } from "@radix-ui/react-slot";
import { cva, type VariantProps } from "class-variance-authority";
import { cn } from "../lib/cn";

const buttonVariants = cva(
  "inline-flex items-center justify-center gap-2 font-medium whitespace-nowrap select-none " +
  "transition-[background-color,border-color,color,transform,box-shadow] duration-[120ms] ease-[cubic-bezier(0.2,0,0,1)] " +
  "active:scale-[0.985] disabled:opacity-40 disabled:pointer-events-none " +
  "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-focus-ring focus-visible:ring-offset-2 focus-visible:ring-offset-bg-canvas",
  {
    variants: {
      variant: {
        // brand-primary / fg-inverse are theme-aware: dark button + light text in light mode,
        // light button + dark text in dark mode. Subtle rest→hover lift, grounded on press.
        primary:   "bg-brand-primary text-fg-inverse shadow-sm hover:bg-brand-primary-hover hover:shadow-md hover:-translate-y-px active:translate-y-0 active:shadow-sm",
        secondary: "bg-bg-surface text-fg-primary border border-border-default shadow-xs hover:bg-bg-subtle hover:border-border-strong hover:shadow-sm hover:-translate-y-px active:translate-y-0",
        ghost:     "bg-transparent text-fg-secondary hover:bg-bg-subtle hover:text-fg-primary",
        danger:    "bg-danger-bg text-danger-text border border-[#FECACA] shadow-xs hover:bg-[#FECACA] hover:shadow-sm",
        dark:      "bg-brand-primary text-fg-inverse shadow-sm hover:bg-brand-primary-hover hover:shadow-md hover:-translate-y-px active:translate-y-0 active:shadow-sm",
        link:      "bg-transparent text-fg-primary underline-offset-4 hover:underline px-0 py-0 h-auto"
      },
      size: {
        xs: "h-7 px-2.5 gap-1.5 text-[11px] rounded-md",
        sm: "h-8 px-3 gap-1.5 text-[13px] rounded-md",
        md: "h-9 px-4 text-sm rounded-md",
        lg: "h-10 px-5 text-sm rounded-md",
        xl: "h-12 px-6 text-[15px] rounded-lg",
        "icon-sm": "h-8 w-8 rounded-md",
        "icon-md": "h-9 w-9 rounded-md",
        "icon-lg": "h-10 w-10 rounded-md"
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
