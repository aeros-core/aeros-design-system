"use client";
import * as React from "react";
import * as RT from "@radix-ui/react-toggle";
import * as RTG from "@radix-ui/react-toggle-group";
import { cva } from "class-variance-authority";
import { cn } from "../lib/cn";
import {
  colorTransition,
  controlSize,
  controlSquare,
  disabledControl,
  type ControlSize
} from "../internal/recipes";

// ── Toggle ────────────────────────────────────────────────

export type ToggleVariant = "ghost" | "outline";

const toggleVariants = cva(
  `inline-flex shrink-0 items-center justify-center whitespace-nowrap select-none rounded-control text-fg-secondary ${colorTransition} ${disabledControl} ` +
    "hover:bg-state-hover hover:text-fg-primary active:bg-state-pressed " +
    // Pressed is a colour change only; it holds through hover.
    "data-[state=on]:bg-state-selected data-[state=on]:text-fg-primary",
  {
    variants: {
      variant: {
        ghost: "bg-transparent",
        outline: "border border-border-strong bg-bg-surface"
      },
      size: controlSize,
      iconOnly: { true: "", false: "" }
    },
    compoundVariants: [
      // Emitted after the size classes, so tailwind-merge lets these win.
      { iconOnly: true, size: "xs", class: controlSquare.xs },
      { iconOnly: true, size: "sm", class: controlSquare.sm },
      { iconOnly: true, size: "md", class: controlSquare.md },
      { iconOnly: true, size: "lg", class: controlSquare.lg },
      { iconOnly: true, size: "xl", class: controlSquare.xl }
    ],
    defaultVariants: { variant: "ghost", size: "md", iconOnly: false }
  }
);

interface ToggleStyleProps {
  variant?: ToggleVariant;
  size?: ControlSize;
  /** Square button holding a single icon. Give it an `aria-label`. */
  iconOnly?: boolean;
}

export interface ToggleProps extends React.ComponentPropsWithoutRef<typeof RT.Root>, ToggleStyleProps {}

/** A two-state button: `aria-pressed` on/off. */
export const Toggle = React.forwardRef<React.ElementRef<typeof RT.Root>, ToggleProps>(
  ({ className, variant, size, iconOnly, ...props }, ref) => (
    <RT.Root ref={ref} className={cn(toggleVariants({ variant, size, iconOnly }), className)} {...props} />
  )
);
Toggle.displayName = "Toggle";

// ── Toggle group ──────────────────────────────────────────

interface ToggleGroupContextValue {
  variant: ToggleVariant;
  size: ControlSize;
  joined: boolean;
}

const ToggleGroupContext = React.createContext<ToggleGroupContextValue>({
  variant: "ghost",
  size: "md",
  joined: false
});

export type ToggleGroupProps = React.ComponentPropsWithoutRef<typeof RTG.Root> & {
  variant?: ToggleVariant;
  size?: ControlSize;
  /** Butt the items together into one control with shared edges, instead of spacing them. */
  joined?: boolean;
};

/**
 * A set of toggles. `type="single"` allows one pressed item (and none);
 * `type="multiple"` any number. For a choice that must always have a value,
 * use `SegmentedControl`.
 */
export const ToggleGroup = React.forwardRef<React.ElementRef<typeof RTG.Root>, ToggleGroupProps>(
  ({ className, variant = "ghost", size = "md", joined = false, ...props }, ref) => {
    const ctx = React.useMemo(() => ({ variant, size, joined }), [variant, size, joined]);
    return (
      <ToggleGroupContext.Provider value={ctx}>
        <RTG.Root ref={ref} className={cn("inline-flex items-center", !joined && "gap-1", className)} {...props} />
      </ToggleGroupContext.Provider>
    );
  }
);
ToggleGroup.displayName = "ToggleGroup";

export interface ToggleGroupItemProps
  extends React.ComponentPropsWithoutRef<typeof RTG.Item>,
    Pick<ToggleStyleProps, "iconOnly"> {}

export const ToggleGroupItem = React.forwardRef<React.ElementRef<typeof RTG.Item>, ToggleGroupItemProps>(
  ({ className, iconOnly, ...props }, ref) => {
    const { variant, size, joined } = React.useContext(ToggleGroupContext);
    return (
      <RTG.Item
        ref={ref}
        className={cn(
          toggleVariants({ variant, size, iconOnly }),
          // Neighbours share one hairline; the focused item lifts so its ring is not covered.
          joined &&
            "relative rounded-none first:rounded-l-control last:rounded-r-control focus-visible:z-raised",
          joined && variant === "outline" && "-ml-px first:ml-0",
          className
        )}
        {...props}
      />
    );
  }
);
ToggleGroupItem.displayName = "ToggleGroupItem";

// ── Segmented control ─────────────────────────────────────

type SegmentedSize = "sm" | "md";

interface SegmentedContextValue {
  size: SegmentedSize;
  fullWidth: boolean;
  select: (value: string) => void;
}

const SegmentedContext = React.createContext<SegmentedContextValue>({
  size: "md",
  fullWidth: false,
  select: () => {}
});

// The track adds 2px of padding each side, so sm/md land on the 28/32 control heights.
const segmentSize: Record<SegmentedSize, string> = {
  sm: "h-control-xs px-2 gap-1 text-label-xs [&_svg]:size-icon-xs",
  md: "h-control-sm px-2.5 gap-1.5 text-label-sm [&_svg]:size-icon-sm"
};

export interface SegmentedControlProps
  extends Omit<
    React.ComponentPropsWithoutRef<typeof RTG.Root>,
    "type" | "value" | "defaultValue" | "onValueChange" | "orientation"
  > {
  value?: string;
  defaultValue?: string;
  onValueChange?: (value: string) => void;
  size?: SegmentedSize;
  /** Stretch to the container, splitting the width evenly between segments. */
  fullWidth?: boolean;
}

/**
 * One choice out of a few, always with a value: picking the selected segment
 * again does nothing. Announced as a radio group; arrow keys move the selection.
 * Give it an `aria-label` (or `aria-labelledby`).
 */
export const SegmentedControl = React.forwardRef<React.ElementRef<typeof RTG.Root>, SegmentedControlProps>(
  (
    { className, value: valueProp, defaultValue, onValueChange, size = "md", fullWidth = false, ...props },
    ref
  ) => {
    const [inner, setInner] = React.useState(defaultValue ?? "");
    const controlled = valueProp !== undefined;
    const value = controlled ? valueProp : inner;

    const select = React.useCallback(
      (next: string) => {
        // Radix reports "" when the pressed item is pressed again — a segmented
        // control never empties, so that is ignored.
        if (!next || next === value) return;
        if (!controlled) setInner(next);
        onValueChange?.(next);
      },
      [controlled, onValueChange, value]
    );

    const ctx = React.useMemo(() => ({ size, fullWidth, select }), [size, fullWidth, select]);

    return (
      <SegmentedContext.Provider value={ctx}>
        <RTG.Root
          ref={ref}
          role="radiogroup"
          {...props}
          type="single"
          value={value}
          onValueChange={select}
          className={cn(
            "gap-0.5 rounded-control bg-bg-inset p-0.5",
            fullWidth ? "flex w-full" : "inline-flex",
            className
          )}
        />
      </SegmentedContext.Provider>
    );
  }
);
SegmentedControl.displayName = "SegmentedControl";

export interface SegmentedControlItemProps extends React.ComponentPropsWithoutRef<typeof RTG.Item> {
  icon?: React.ReactNode;
}

export const SegmentedControlItem = React.forwardRef<React.ElementRef<typeof RTG.Item>, SegmentedControlItemProps>(
  ({ className, icon, children, value, onFocus, onPointerDown, onBlur, ...props }, ref) => {
    const { size, fullWidth, select } = React.useContext(SegmentedContext);
    // Selection follows keyboard focus, as with native radios — but not the
    // focus a pointer press causes; the click that follows selects.
    const pointerFocus = React.useRef(false);
    return (
      <RTG.Item
        ref={ref}
        value={value}
        className={cn(
          `inline-flex min-w-0 items-center justify-center whitespace-nowrap select-none rounded-item text-fg-muted ${colorTransition} ${disabledControl}`,
          "hover:text-fg-primary data-[state=on]:bg-bg-elevated data-[state=on]:text-fg-primary data-[state=on]:shadow-raised",
          "[&_svg]:shrink-0",
          segmentSize[size],
          fullWidth && "flex-1",
          className
        )}
        onPointerDown={(event) => {
          onPointerDown?.(event);
          pointerFocus.current = true;
        }}
        onFocus={(event) => {
          onFocus?.(event);
          if (!pointerFocus.current && !event.defaultPrevented) select(value);
          pointerFocus.current = false;
        }}
        onBlur={(event) => {
          onBlur?.(event);
          pointerFocus.current = false;
        }}
        {...props}
      >
        {icon}
        {children}
      </RTG.Item>
    );
  }
);
SegmentedControlItem.displayName = "SegmentedControlItem";

export { toggleVariants };
