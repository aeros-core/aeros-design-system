/**
 * The single source of truth for which preview fixtures exist.
 *
 * Plain data on purpose — no React, no CSS imports — so the Playwright specs in
 * `e2e/` can import it from Node. `FIXTURES` in `./index.ts` is typed as
 * `Record<FixtureSlug, …>`, so a slug without a component (or a component
 * without a slug) is a type error and fails `next build`.
 */
export const FIXTURE_SLUGS = [
  "foundations-type",
  "foundations-surfaces",
  "button",
  "input",
  "textarea",
  "select",
  "select-open",
  "checkbox",
  "radio",
  "switch",
  "badge",
  "tag",
  "card",
  "stat-card",
  "alert",
  "progress",
  "avatar",
  "tabs",
  "breadcrumb",
  "dropdown-menu",
  "dialog",
  "alert-dialog",
  "drawer-right",
  "drawer-left",
  "drawer-bottom",
  "popover",
  "tooltip",
  "table",
  "empty-state",
  "topnav",
  "sidebar",
  "dot-matrix",
  "label",
  "separator",
  "spinner",
  "skeleton",
  "accordion",
  "toast",
  "pagination",
  "command",
  "calendar",
] as const;

export type FixtureSlug = (typeof FIXTURE_SLUGS)[number];
