import * as React from "react";
import { Slot } from "@radix-ui/react-slot";
import { cn } from "../lib/cn";
import { resolveLazyNode } from "../internal/as-child";

export interface CardProps extends React.HTMLAttributes<HTMLDivElement> {
  /**
   * Styles the card as clickable: pointer cursor, stronger border and a fill on hover.
   *
   * On its own this is styling only — use it for a card that contains its own
   * link or button (the card stays a plain `div`). Two ways to make the whole
   * card the control:
   *   - with `onClick`, the card becomes a button: focusable, announced as a
   *     button, activated by Enter and Space. Give it no other interactive
   *     content (a button may not contain a link or another button), and an
   *     `aria-label` when its text is long.
   *   - with `asChild`, the card renders as your element — a real link:
   *     `<Card asChild interactive><a href="/orders/1042">…</a></Card>`.
   */
  interactive?: boolean;
  /**
   * Render the single child element (an `<a>`, a framework `<Link>`) as the card,
   * with the card's styles. The child keeps its own semantics; nothing is added.
   */
  asChild?: boolean;
}

export const Card = React.forwardRef<HTMLDivElement, CardProps>(
  ({ className, interactive, asChild, onClick, onKeyDown, onKeyUp, children, ...props }, ref) => {
    const classes = cn(
      "overflow-hidden rounded-surface border border-border-default bg-bg-surface",
      interactive &&
        "cursor-pointer transition-colors duration-fast ease-standard hover:border-border-strong hover:bg-bg-subtle",
      // An inline child (an <a>) has to be a block to be a card.
      asChild && "block",
      className
    );

    if (asChild) {
      return (
        <Slot ref={ref} className={classes} onClick={onClick} onKeyDown={onKeyDown} onKeyUp={onKeyUp} {...props}>
          {/* From a Server Component the child can be a lazy reference; give Slot the element. */}
          {resolveLazyNode(children)}
        </Slot>
      );
    }

    // A clickable card is a button. Without onClick it is only styled as
    // clickable (its own link or button is the control), so it gets no role.
    const isButton = Boolean(interactive && onClick);
    // Only keys pressed on the card itself activate it, not ones bubbling up from its content.
    const onCard = (event: React.KeyboardEvent<HTMLDivElement>) =>
      isButton && !event.defaultPrevented && event.target === event.currentTarget;

    return (
      // The handlers only act when the card is a button (role + tabIndex below);
      // on a plain card they just forward the caller's own.
      // eslint-disable-next-line jsx-a11y/no-static-element-interactions
      <div
        ref={ref}
        className={classes}
        {...(isButton ? { role: "button", tabIndex: 0 } : null)}
        onClick={onClick}
        onKeyDown={(event) => {
          onKeyDown?.(event);
          if (!onCard(event)) return;
          if (event.key === "Enter") {
            event.preventDefault();
            event.currentTarget.click();
          }
          // Space activates on release, like a native button; stop the page scrolling meanwhile.
          if (event.key === " ") event.preventDefault();
        }}
        onKeyUp={(event) => {
          onKeyUp?.(event);
          if (onCard(event) && event.key === " ") event.currentTarget.click();
        }}
        {...props}
      >
        {children}
      </div>
    );
  }
);
Card.displayName = "Card";

export const CardHeader = React.forwardRef<HTMLDivElement, React.HTMLAttributes<HTMLDivElement>>(
  ({ className, ...props }, ref) => (
    <div
      ref={ref}
      className={cn("flex items-start justify-between gap-3 border-b border-border-default px-4 py-3", className)}
      {...props}
    />
  )
);
CardHeader.displayName = "CardHeader";

export const CardTitle = React.forwardRef<HTMLHeadingElement, React.HTMLAttributes<HTMLHeadingElement>>(
  ({ className, children, ...props }, ref) => (
    <h3
      ref={ref}
      className={cn("text-h3 text-fg-primary", className)}
      {...props}
    >
      {children}
    </h3>
  )
);
CardTitle.displayName = "CardTitle";

export const CardSubtitle = React.forwardRef<HTMLParagraphElement, React.HTMLAttributes<HTMLParagraphElement>>(
  ({ className, ...props }, ref) => (
    <p ref={ref} className={cn("mt-0.5 text-caption text-fg-muted", className)} {...props} />
  )
);
CardSubtitle.displayName = "CardSubtitle";

export const CardBody = React.forwardRef<HTMLDivElement, React.HTMLAttributes<HTMLDivElement>>(
  ({ className, ...props }, ref) => (
    <div ref={ref} className={cn("p-4", className)} {...props} />
  )
);
CardBody.displayName = "CardBody";

export const CardFooter = React.forwardRef<HTMLDivElement, React.HTMLAttributes<HTMLDivElement>>(
  ({ className, ...props }, ref) => (
    <div
      ref={ref}
      className={cn(
        "flex items-center justify-between gap-3 border-t border-border-default px-4 py-3",
        className
      )}
      {...props}
    />
  )
);
CardFooter.displayName = "CardFooter";
