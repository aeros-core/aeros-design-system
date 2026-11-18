"use client";
import * as React from "react";
import { createPortal } from "react-dom";
import { Command as CommandPrimitive, useCommandState } from "cmdk";
import { Search } from "lucide-react";
import { cn } from "../lib/cn";
import { menuItem, menuItemState, menuSeparator } from "../internal/recipes";

// cmdk-backed command menu / combobox surface. Compose inside a Popover for a
// select-with-search (see docs), or inside a Dialog for a command palette.
// cmdk provides the ARIA combobox/listbox wiring and keyboard navigation.
//
// Three things cmdk 1.1.1 gets wrong for assistive tech are corrected here
// (its roles and aria-activedescendant are set after the props spread, so they
// cannot be overridden through props):
//   - aria-activedescendant is kept pointing at the option that is active now
//     (useActiveDescendantSync);
//   - the empty message renders beside the listbox, in a live region, not
//     inside it — a listbox may only own options and groups;
//   - the separator is decorative (role="none"), for the same reason.

const ACTIVE_ITEM = '[cmdk-item=""][aria-selected="true"]';

/**
 * cmdk stores the active option's id one step late: it reads the DOM for the
 * `aria-selected` option before React has re-rendered the options, so after
 * typing a filter `aria-activedescendant` is empty or names an option that is
 * gone. This keeps the attribute (on the input and on the listbox) equal to the
 * id of the option that is actually marked selected, whenever either changes.
 */
function useActiveDescendantSync(inputRef: React.RefObject<HTMLInputElement | null>) {
  React.useEffect(() => {
    const root = inputRef.current?.closest('[cmdk-root=""]');
    if (!root || typeof MutationObserver === "undefined") return;
    const sync = () => {
      const id = root.querySelector(ACTIVE_ITEM)?.id;
      for (const el of root.querySelectorAll('[cmdk-input=""], [cmdk-list=""]')) {
        if (id) {
          if (el.getAttribute("aria-activedescendant") !== id) el.setAttribute("aria-activedescendant", id);
        } else if (el.hasAttribute("aria-activedescendant")) {
          el.removeAttribute("aria-activedescendant");
        }
      }
    };
    sync();
    const observer = new MutationObserver(sync);
    observer.observe(root, {
      subtree: true,
      childList: true,
      attributes: true,
      attributeFilter: ["aria-selected", "aria-activedescendant"]
    });
    return () => observer.disconnect();
  }, [inputRef]);
}

/** Where CommandEmpty renders: an element beside the listbox. `undefined` outside a CommandList. */
const EmptySlotContext = React.createContext<HTMLElement | null | undefined>(undefined);

export const Command = React.forwardRef<
  React.ElementRef<typeof CommandPrimitive>,
  React.ComponentPropsWithoutRef<typeof CommandPrimitive>
>(({ className, ...props }, ref) => (
  <CommandPrimitive
    ref={ref}
    className={cn(
      "flex w-full flex-col overflow-hidden rounded-surface bg-bg-elevated text-fg-primary",
      className
    )}
    {...props}
  />
));
Command.displayName = "Command";

export const CommandInput = React.forwardRef<
  React.ElementRef<typeof CommandPrimitive.Input>,
  React.ComponentPropsWithoutRef<typeof CommandPrimitive.Input>
>(({ className, ...props }, ref) => {
  const inputRef = React.useRef<HTMLInputElement | null>(null);
  useActiveDescendantSync(inputRef);
  const setRefs = React.useCallback(
    (node: HTMLInputElement | null) => {
      inputRef.current = node;
      if (typeof ref === "function") ref(node);
      else if (ref) ref.current = node;
    },
    [ref]
  );
  return (
    // The wrapper shows focus for the borderless input inside it.
    <div
      className="flex items-center gap-2 border-b border-border-default px-3 focus-within:border-border-focus"
      cmdk-input-wrapper=""
    >
      <Search aria-hidden className="size-icon-md shrink-0 text-fg-muted" />
      <CommandPrimitive.Input
        ref={setRefs}
        className={cn(
          "h-control-lg w-full bg-transparent text-body-sm text-fg-primary outline-none",
          "placeholder:text-fg-muted disabled:opacity-disabled",
          className
        )}
        {...props}
      />
    </div>
  );
});
CommandInput.displayName = "CommandInput";

export const CommandList = React.forwardRef<
  React.ElementRef<typeof CommandPrimitive.List>,
  React.ComponentPropsWithoutRef<typeof CommandPrimitive.List>
>(({ className, ...props }, ref) => {
  const [emptySlot, setEmptySlot] = React.useState<HTMLDivElement | null>(null);
  return (
    <EmptySlotContext.Provider value={emptySlot}>
      <CommandPrimitive.List
        ref={ref}
        className={cn(
          "max-h-72 overflow-y-auto overflow-x-hidden p-1",
          // Nothing to show (every option filtered out): take the listbox out of
          // the layout and the accessibility tree; the empty message stands in.
          "[&:not(:has([cmdk-list-sizer]>:not([hidden])))]:hidden",
          className
        )}
        {...props}
      />
      {/* CommandEmpty renders here. A polite live region, so "No results." is announced when it appears. */}
      <div ref={setEmptySlot} aria-live="polite" cmdk-empty-slot="" className="not-empty:p-1" />
    </EmptySlotContext.Provider>
  );
});
CommandList.displayName = "CommandList";

export const CommandEmpty = React.forwardRef<
  React.ElementRef<typeof CommandPrimitive.Empty>,
  React.ComponentPropsWithoutRef<typeof CommandPrimitive.Empty>
>(({ className, ...props }, ref) => {
  const slot = React.useContext(EmptySlotContext);
  const empty = (
    <CommandPrimitive.Empty
      ref={ref}
      className={cn("py-6 text-center text-body-sm text-fg-muted", className)}
      {...props}
    />
  );
  // Outside a CommandList there is no slot: render in place, as cmdk does.
  if (slot === undefined) return empty;
  return slot ? createPortal(empty, slot) : null;
});
CommandEmpty.displayName = "CommandEmpty";

export const CommandGroup = React.forwardRef<
  React.ElementRef<typeof CommandPrimitive.Group>,
  React.ComponentPropsWithoutRef<typeof CommandPrimitive.Group>
>(({ className, ...props }, ref) => (
  <CommandPrimitive.Group
    ref={ref}
    className={cn(
      "overflow-hidden",
      "[&_[cmdk-group-heading]]:px-2 [&_[cmdk-group-heading]]:py-1.5 [&_[cmdk-group-heading]]:text-caption [&_[cmdk-group-heading]]:text-fg-muted",
      className
    )}
    {...props}
  />
));
CommandGroup.displayName = "CommandGroup";

export const CommandSeparator = React.forwardRef<
  React.ElementRef<typeof CommandPrimitive.Separator>,
  React.ComponentPropsWithoutRef<typeof CommandPrimitive.Separator>
>(({ className, alwaysRender, ...props }, ref) => {
  // Like cmdk's own separator it is dropped while searching (results are
  // re-sorted, so there is nothing to divide) unless `alwaysRender` is set.
  const searching = useCommandState((state) => Boolean(state.search));
  if (searching && !alwaysRender) return null;
  // Not cmdk's Separator: that one is role="separator", which a listbox may not
  // own. The groups are already named, so the rule is decoration.
  return <div ref={ref} role="none" cmdk-separator="" className={cn(menuSeparator, className)} {...props} />;
});
CommandSeparator.displayName = "CommandSeparator";

export const CommandItem = React.forwardRef<
  React.ElementRef<typeof CommandPrimitive.Item>,
  React.ComponentPropsWithoutRef<typeof CommandPrimitive.Item>
>(({ className, ...props }, ref) => (
  <CommandPrimitive.Item
    ref={ref}
    className={cn(menuItem, menuItemState.cmdk, className)}
    {...props}
  />
));
CommandItem.displayName = "CommandItem";
