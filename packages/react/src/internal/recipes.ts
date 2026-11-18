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

// ── Floating surfaces ─────────────────────────────────────
// A floating layer is bg-elevated + an elevation shadow. The shadow carries its
// own 1px edge, so floating surfaces never take a border class.

/** Menus, popovers, selects, tooltips: quick fade + slight scale from the trigger side. */
export const overlayMotion =
  "data-[state=open]:animate-in data-[state=closed]:animate-out " +
  "data-[state=open]:fade-in-0 data-[state=closed]:fade-out-0 " +
  "data-[state=open]:zoom-in-97 data-[state=closed]:zoom-out-97 " +
  "data-[side=bottom]:slide-in-from-top-1 data-[side=top]:slide-in-from-bottom-1 " +
  "data-[side=right]:slide-in-from-left-1 data-[side=left]:slide-in-from-right-1 " +
  "data-[state=open]:duration-fast data-[state=open]:ease-enter " +
  "data-[state=closed]:duration-quick data-[state=closed]:ease-exit";

export const floatingPanel = `z-popover rounded-surface bg-bg-elevated text-fg-primary shadow-overlay outline-none ${overlayMotion}`;

/** A floating panel holding rows. 4px padding + 4px row radius nests inside the 8px panel. */
export const menuPanel = `${floatingPanel} min-w-48 overflow-x-hidden overflow-y-auto p-1`;

/** One row spec for every list of choices: dropdown, select, command, combobox. */
export const menuItem =
  "relative flex min-h-control-sm cursor-default select-none items-center gap-2 rounded-item px-2 " +
  "text-body-sm text-fg-primary outline-none transition-colors duration-quick " +
  "[&_svg]:size-icon-md [&_svg]:shrink-0 [&_svg]:text-fg-muted";

/** Radix marks the active row with data-highlighted; cmdk with data-selected. */
export const menuItemState = {
  radix: "data-[highlighted]:bg-state-hover data-[disabled]:pointer-events-none data-[disabled]:opacity-disabled",
  cmdk: "data-[selected=true]:bg-state-hover data-[disabled=true]:pointer-events-none data-[disabled=true]:opacity-disabled"
};

export const menuItemDanger = "text-danger-text [&_svg]:text-danger-text data-[highlighted]:bg-danger-bg";
export const menuLabel = "px-2 py-1.5 text-caption text-fg-muted";
export const menuSeparator = "-mx-1 my-1 h-px bg-border-default";
/** Right-aligned keyboard hint inside a row. */
export const menuShortcut = "ml-auto pl-4 text-caption text-fg-muted";

// ── Modals ────────────────────────────────────────────────

export const scrim =
  "fixed inset-0 z-overlay bg-scrim " +
  "data-[state=open]:animate-in data-[state=closed]:animate-out data-[state=open]:fade-in-0 data-[state=closed]:fade-out-0 " +
  "data-[state=open]:duration-base data-[state=closed]:duration-fast";

export const modalPanel = "z-modal flex flex-col bg-bg-elevated text-fg-primary shadow-modal outline-none";

/** Centered dialogs: fade + a very slight scale. */
export const dialogMotion =
  "data-[state=open]:animate-in data-[state=closed]:animate-out " +
  "data-[state=open]:fade-in-0 data-[state=closed]:fade-out-0 " +
  "data-[state=open]:zoom-in-98 data-[state=closed]:zoom-out-98 " +
  "data-[state=open]:duration-base data-[state=open]:ease-enter " +
  "data-[state=closed]:duration-fast data-[state=closed]:ease-exit";

export type DialogSize = "sm" | "md" | "lg" | "xl" | "full";
export const dialogSize: Record<DialogSize, string> = {
  sm: "max-w-dialog-sm",
  md: "max-w-dialog-md",
  lg: "max-w-dialog-lg",
  xl: "max-w-dialog-xl",
  full: "max-w-[calc(100vw-2rem)]"
};

export const dialogPosition =
  "fixed left-1/2 top-1/2 w-[calc(100vw-2rem)] max-h-[calc(100dvh-4rem)] -translate-x-1/2 -translate-y-1/2 overflow-hidden rounded-modal";

export const modalHeader = "shrink-0 px-5 pt-5 pb-3 pr-12";
export const modalTitle = "text-h3 text-fg-primary";
export const modalDescription = "mt-1 text-body-sm text-fg-secondary";
/** min-h-0 + overflow lets a long body scroll instead of pushing the footer off-screen. */
export const modalBody = "min-h-0 flex-1 overflow-y-auto px-5 pb-5";
export const modalFooter = "flex shrink-0 justify-end gap-2 border-t border-border-default px-5 py-3";
export const modalClose =
  "absolute right-3 top-3 inline-flex size-control-sm items-center justify-center rounded-control text-fg-muted " +
  "transition-colors duration-quick hover:bg-state-hover hover:text-fg-primary [&_svg]:size-icon-md";
