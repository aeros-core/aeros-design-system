import * as React from "react";
import { Slot } from "@radix-ui/react-slot";
import { cva, type VariantProps } from "class-variance-authority";
import { cn } from "../lib/cn";
import { slotChildWith } from "../internal/as-child";
import { colorTransition, controlSize, controlSquare, disabledControl } from "../internal/recipes";
import { Spinner } from "./spinner";

const buttonVariants = cva(
  `inline-flex shrink-0 items-center justify-center whitespace-nowrap select-none rounded-control ${colorTransition} ${disabledControl}`,
  {
    variants: {
      variant: {
        // Solid ink. brand-primary / fg-inverse are theme-aware (dark on light, light on dark).
        primary: "bg-brand-primary text-fg-inverse hover:bg-brand-primary-hover",
        // Hairline on surface.
        secondary: "border border-border-strong bg-bg-surface text-fg-primary hover:bg-bg-subtle active:bg-border-default",
        // No chrome until hovered.
        ghost: "bg-transparent text-fg-secondary hover:bg-state-hover hover:text-fg-primary active:bg-state-pressed",
        // Destructive, solid — the one place a status colour fills a control.
        danger: "bg-danger text-fg-inverse hover:bg-danger-hover",
        // Destructive, quiet — for secondary placement next to a primary action.
        "danger-subtle": "border border-danger-border bg-danger-bg text-danger-text hover:border-danger",
        link: "bg-transparent text-fg-primary underline-offset-4 hover:underline"
      },
      size: controlSize,
      iconOnly: { true: "", false: "" }
    },
    compoundVariants: [
      // Emitted after the size classes, so tailwind-merge lets these win.
      { variant: "link", class: "h-auto px-0" },
      { iconOnly: true, size: "xs", class: controlSquare.xs },
      { iconOnly: true, size: "sm", class: controlSquare.sm },
      { iconOnly: true, size: "md", class: controlSquare.md },
      { iconOnly: true, size: "lg", class: controlSquare.lg },
      { iconOnly: true, size: "xl", class: controlSquare.xl }
    ],
    defaultVariants: { variant: "primary", size: "md", iconOnly: false }
  }
);

export interface ButtonProps
  extends React.ButtonHTMLAttributes<HTMLButtonElement>,
    VariantProps<typeof buttonVariants> {
  /** Render the child element (e.g. a router `<Link>`) with the button's styles. */
  asChild?: boolean;
  loading?: boolean;
  leadingIcon?: React.ReactNode;
  trailingIcon?: React.ReactNode;
  /** Square button holding a single icon. Give it an `aria-label`. */
  iconOnly?: boolean;
}

export const Button = React.forwardRef<HTMLButtonElement, ButtonProps>(
  ({ className, variant, size, iconOnly, asChild, loading, leadingIcon, trailingIcon, children, disabled, ...props }, ref) => {
    const leading = loading ? <Spinner size="sm" className="text-current" /> : leadingIcon;
    const shared = {
      ref,
      className: cn(buttonVariants({ variant, size, iconOnly }), className),
      disabled: disabled || loading,
      "aria-busy": loading || undefined,
      ...props
    };
    if (asChild) {
      // The caller's element becomes the button and the icons render inside it.
      // The child is resolved first: from a Server Component it can arrive as a
      // lazy reference, which Slot only unwraps as its direct child.
      return (
        <Slot {...shared}>
          {slotChildWith(children, (label) => (
            <>
              {leading}
              {label}
              {trailingIcon}
            </>
          ))}
        </Slot>
      );
    }
    return (
      <button {...shared}>
        {leading}
        {children}
        {trailingIcon}
      </button>
    );
  }
);
Button.displayName = "Button";

export { buttonVariants };
