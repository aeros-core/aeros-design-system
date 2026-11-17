// Shared style recipes — the single place a family's look is defined, so
// components cannot drift apart. Not exported from the package.
//
// Plain strings and maps only (no hooks, no "use client"), so server
// components can import them.

/** Colour-only state changes. Nothing lifts, scales or gains a shadow on hover. */
export const colorTransition = "transition-colors duration-fast ease-standard";

export const disabledControl = "disabled:opacity-disabled disabled:pointer-events-none";

/**
 * Focus. The ring itself is the global `:focus-visible` outline (styles.css),
 * driven by the focus tokens — components do not draw their own. These
 * utilities only move it:
 *   focus-ring-field  sits on the field's border (text inputs, select trigger)
 *   focus-ring-inset  inside the element (table headers, flush rows)
 */

export type ControlSize = "xs" | "sm" | "md" | "lg" | "xl";

/** Height, padding, gap and label type for buttons and button-like controls. */
export const controlSize: Record<ControlSize, string> = {
  xs: "h-control-xs px-2 gap-1 text-label-xs [&_svg]:size-icon-xs",
  sm: "h-control-sm px-2.5 gap-1.5 text-label-sm [&_svg]:size-icon-sm",
  md: "h-control-md px-3 gap-1.5 text-label-sm [&_svg]:size-icon-md",
  lg: "h-control-lg px-3.5 gap-2 text-label-md [&_svg]:size-icon-md",
  xl: "h-control-xl px-4 gap-2 text-label-md [&_svg]:size-icon-lg"
};

/** Square, icon-only variant of the same ladder. */
export const controlSquare: Record<ControlSize, string> = {
  xs: "size-control-xs px-0",
  sm: "size-control-sm px-0",
  md: "size-control-md px-0",
  lg: "size-control-lg px-0",
  xl: "size-control-xl px-0"
};

export type FieldSize = "sm" | "md" | "lg";
export type FieldState = "default" | "error" | "success";

/** Every text-entry control: input, textarea, select trigger, combobox, date picker. */
export const fieldBase =
  "w-full rounded-control border bg-bg-surface text-fg-primary " +
  "placeholder:text-fg-muted data-[placeholder]:text-fg-muted " +
  `${colorTransition} focus-ring-field ` +
  "disabled:opacity-disabled disabled:cursor-not-allowed";

export const fieldSize: Record<FieldSize, string> = {
  sm: "h-control-sm px-2.5 text-body-sm",
  md: "h-control-md px-3 text-body-sm",
  lg: "h-control-lg px-3.5 text-body-md"
};

/** The border carries the state; the focus ring takes the same colour (styles.css). */
export const fieldState: Record<FieldState, string> = {
  default: "border-border-strong hover:border-fg-muted",
  error: "border-danger",
  success: "border-success"
};
