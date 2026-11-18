import type { FixtureSlug, Theme } from "./fixture-page";

// Shared by e2e/a11y.spec.ts (the preview fixtures) and e2e/site.spec.ts (the
// documentation pages, which inherit the violations of the fixtures they show).

export const WCAG_TAGS = ["wcag2a", "wcag2aa", "wcag21a", "wcag21aa"];

/**
 * Violations that exist in the components TODAY (baseline taken before the
 * redesign). Each entry is a to-do, not an exemption:
 *   - a violation that is NOT listed here fails the suite (no regressions);
 *   - a listed violation that no longer occurs ALSO fails the suite, so the
 *     entry has to be deleted when the component is fixed and the list can
 *     only shrink.
 * Never add an entry to make a new failure go away — fix the component.
 */
export const KNOWN_VIOLATIONS: Partial<Record<FixtureSlug, Partial<Record<Theme, string[]>>>> = {
  // TODO(select): aria-hidden-focus (serious). While the listbox is open Radix
  // Select aria-hides everything outside it, but the trigger inside that hidden
  // tree is still focusable. axe only forgives this for role="dialog" modals.
  "select-open": {
    light: ["aria-hidden-focus"],
    dark: ["aria-hidden-focus"],
  },

  // TODO(dropdown-menu): aria-hidden-focus (serious). Same cause as Select —
  // Radix DropdownMenu defaults to modal={true}, which aria-hides the page
  // (including the focusable trigger) while the menu is open.
  "dropdown-menu": {
    light: ["aria-hidden-focus"],
    dark: ["aria-hidden-focus"],
  },

  // TODO(command): aria-required-children (critical). cmdk's list is
  // role="listbox"; (1) <CommandSeparator> renders role="separator" as a
  // direct child, which a listbox may not own, and (2) in the empty state the
  // listbox contains no option/group at all.
  command: {
    light: ["aria-required-children"],
    dark: ["aria-required-children"],
  },

  // TODO(calendar): label-content-name-mismatch (serious, WCAG 2.5.3 — an axe
  // "experimental" rule that ships under the wcag2a tag). Every day button
  // shows "26" but is named "Sunday, July 26th, 2026" by react-day-picker's
  // default labelDayButton, so the visible text is not a whole word of the name.
  calendar: {
    light: ["label-content-name-mismatch"],
    dark: ["label-content-name-mismatch"],
  },

  // Same cause as `calendar`: the range picker's open popover contains it.
  "date-picker-open": {
    light: ["label-content-name-mismatch"],
    dark: ["label-content-name-mismatch"],
  },
};
