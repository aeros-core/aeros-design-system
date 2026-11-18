import type { FixtureSlug, Theme } from "./fixture-page";

// Shared by e2e/a11y.spec.ts (the preview fixtures) and e2e/site.spec.ts (the
// documentation pages, which inherit the violations of the fixtures they show).

export const WCAG_TAGS = ["wcag2a", "wcag2aa", "wcag21a", "wcag21aa"];

/**
 * Violations axe reports on the fixtures TODAY. An entry is a to-do unless its
 * comment says why it is a false positive; either way:
 *   - a violation that is NOT listed here fails the suite (no regressions);
 *   - a listed violation that no longer occurs ALSO fails the suite, so the
 *     entry has to be deleted when the component is fixed and the list can
 *     only shrink.
 * Never add an entry to make a new failure go away — fix the component.
 */
export const KNOWN_VIOLATIONS: Partial<Record<FixtureSlug, Partial<Record<Theme, string[]>>>> = {
  // select-open / dropdown-menu: aria-hidden-focus (serious) — an axe FALSE
  // POSITIVE for this pattern, kept listed (not a to-do for our wrappers).
  //
  // What axe sees: while a modal Radix Select or DropdownMenu is open, Radix
  // calls `hideOthers(content)` (aria-hidden on everything outside the popup)
  // and the trigger, inside that hidden tree, still has tabindex=0.
  // Why it is not a defect: the trigger cannot be reached while it is hidden.
  // Focus is inside the popup (which is outside the hidden tree), the popup is
  // a trapped FocusScope, Tab is cancelled in its keydown handler, and pointer
  // events outside it are disabled; closing the popup removes aria-hidden
  // before focus returns to the trigger. (@radix-ui/react-menu dist/index.mjs:
  // hideOthers, trapFocus, `if (event.key === "Tab") event.preventDefault()`;
  // @radix-ui/react-select has the same three.) axe's rule has an escape hatch
  // for exactly this — the `focusable-modal-open` check — but its
  // `isModalOpen()` heuristic only recognises role="dialog"/aria-modal and
  // full-viewport overlays, not a role="menu"/"listbox" popup.
  // Why not "fix" it: DropdownMenu `modal={false}` would drop the aria-hidden,
  // and with it the outside-pointer blocking and scroll lock (a click outside
  // would also activate whatever is under it) — a behaviour change made only
  // to satisfy the checker; Select has no non-modal mode at all. Making the
  // trigger tabindex=-1 while open would fight Radix's focus return.
  // The entries go when Radix or axe changes; the suite fails if they stop occurring.
  "select-open": {
    light: ["aria-hidden-focus"],
    dark: ["aria-hidden-focus"],
  },
  "dropdown-menu": {
    light: ["aria-hidden-focus"],
    dark: ["aria-hidden-focus"],
  },
};
