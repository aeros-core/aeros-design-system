import * as React from "react";
import { Slot } from "@radix-ui/react-slot";
import { ChevronDown, X } from "lucide-react";
import { cn } from "../lib/cn";
import { colorTransition } from "../internal/recipes";
import { CountBadge } from "./count-badge";

export type FilterChipTone = "neutral" | "warning";

// The frame carries the hairline and fill; the buttons inside are transparent.
const frameTone: Record<FilterChipTone, { idle: string; active: string }> = {
  neutral: {
    idle: "border-border-default bg-bg-surface text-fg-secondary",
    active: "border-border-strong bg-state-selected text-fg-primary"
  },
  warning: {
    idle: "border-warning-border bg-warning-bg text-warning-text",
    active: "border-warning bg-warning-bg text-warning-text"
  }
};

export interface FilterChipProps extends Omit<React.ButtonHTMLAttributes<HTMLButtonElement>, "value"> {
  label: string;
  /** The applied value, shown after the label: "Status: Open". */
  value?: React.ReactNode;
  /** A filter is applied. */
  active?: boolean;
  /** Number of selected values / matches, shown as a count pill. */
  count?: number;
  /** Shows a separate clear button next to the chip. */
  onClear?: () => void;
  tone?: FilterChipTone;
  /** Trailing chevron, for a chip that opens a menu or popover. */
  dropdown?: boolean;
  /**
   * Render the single child element as the chip's main control (a Popover or
   * DropdownMenu trigger, a link). The chip supplies its content.
   */
  asChild?: boolean;
  /** Classes for the main control; `className` goes to the outer frame. */
  controlClassName?: string;
}

/**
 * A compact filter control. `ref` and button props go to the main control, so
 * it also works as the child of a `PopoverTrigger asChild`.
 */
export const FilterChip = React.forwardRef<HTMLButtonElement, FilterChipProps>(
  (
    {
      label,
      value,
      active = false,
      count,
      onClear,
      tone = "neutral",
      dropdown = false,
      asChild = false,
      className,
      controlClassName,
      disabled,
      children,
      ...props
    },
    ref
  ) => {
    const hasValue = value != null && value !== false && value !== "";
    const content = (
      <>
        <span className="truncate">
          {label}
          {hasValue && ":"}
        </span>
        {hasValue && <span className={cn("truncate", tone === "neutral" && "text-fg-primary")}>{value}</span>}
        {count != null && <CountBadge count={count} tone={active ? "solid" : "muted"} />}
        {dropdown && <ChevronDown aria-hidden className="size-icon-sm shrink-0 opacity-70" />}
      </>
    );
    const controlClass = cn(
      `inline-flex h-full min-w-0 items-center gap-1.5 rounded-pill pl-2.5 text-label-sm ${colorTransition}`,
      "hover:bg-state-hover active:bg-state-pressed disabled:pointer-events-none",
      onClear ? "pr-1.5" : "pr-2.5",
      controlClassName
    );

    return (
      <span
        data-active={active || undefined}
        className={cn(
          `inline-flex h-control-sm max-w-full items-center rounded-pill border ${colorTransition}`,
          frameTone[tone][active ? "active" : "idle"],
          disabled && "opacity-disabled",
          className
        )}
      >
        {asChild ? (
          <Slot ref={ref} className={controlClass} {...props}>
            {React.isValidElement(children) ? React.cloneElement(children, undefined, content) : null}
          </Slot>
        ) : (
          <button
            ref={ref}
            type="button"
            disabled={disabled}
            // A plain chip is an on/off filter; a dropdown chip states its value in text instead.
            aria-pressed={dropdown ? undefined : active}
            className={controlClass}
            {...props}
          >
            {content}
          </button>
        )}
        {onClear && (
          <button
            type="button"
            aria-label={`Clear ${label}`}
            disabled={disabled}
            onClick={onClear}
            className={`mr-0.5 inline-flex size-5 shrink-0 items-center justify-center rounded-pill opacity-70 ${colorTransition} hover:bg-state-hover hover:opacity-100 disabled:pointer-events-none`}
          >
            <X aria-hidden className="size-icon-xs" />
          </button>
        )}
      </span>
    );
  }
);
FilterChip.displayName = "FilterChip";
