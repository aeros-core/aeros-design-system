import { COMPONENT_SLUGS, getComponent, type ComponentSlug } from "../_registry";

/**
 * Every page of the showcase site. Plain data (no React) so the shell, the
 * pages and the Playwright smoke spec all read the same list.
 */

export type SiteSection = "Overview" | "Foundations" | "Components" | "Patterns";

export interface SiteRoute {
  href: string;
  title: string;
  section: SiteSection;
  /** One line shown on index cards. */
  summary: string;
}

export const STATIC_ROUTES = [
  {
    href: "/",
    title: "Introduction",
    section: "Overview",
    summary: "What the system is, its principles and how to install it.",
  },
  {
    href: "/migration",
    title: "Migrating to 3.0",
    section: "Overview",
    summary: "The headline breaking changes and where the full guide lives.",
  },
  {
    href: "/foundations/color",
    title: "Color",
    section: "Foundations",
    summary: "The ink ramp, the theme-aware aliases and the status sets.",
  },
  {
    href: "/foundations/typography",
    title: "Typography",
    section: "Foundations",
    summary: "Every type role: size, line height, weight and tracking in one class.",
  },
  {
    href: "/foundations/spacing-and-radius",
    title: "Spacing and radius",
    section: "Foundations",
    summary: "The 4-based spacing scale and the semantic radii.",
  },
  {
    href: "/foundations/elevation",
    title: "Elevation",
    section: "Foundations",
    summary: "Three intents for floating layers; resting surfaces take a hairline.",
  },
  {
    href: "/foundations/motion",
    title: "Motion",
    section: "Foundations",
    summary: "Four durations and three easings, with a replayable demo.",
  },
  {
    href: "/foundations/density-and-sizing",
    title: "Density and sizing",
    section: "Foundations",
    summary: "Control sizes for pointer and touch, side by side.",
  },
  {
    href: "/components",
    title: "Components",
    section: "Components",
    summary: "Every component, grouped by family.",
  },
  {
    href: "/patterns/app-shell",
    title: "App shell",
    section: "Patterns",
    summary: "Sidebar, header, content and footer — the frame this site uses.",
  },
  {
    href: "/patterns/data-table",
    title: "Data table screen",
    section: "Patterns",
    summary: "An orders screen: page header, filter chips, data table, pagination.",
  },
  {
    href: "/patterns/form",
    title: "Form",
    section: "Patterns",
    summary: "A create form with every field type and a submit bar.",
  },
  {
    href: "/patterns/settings",
    title: "Settings",
    section: "Patterns",
    summary: "Tabs, switches and a danger zone behind a confirmation.",
  },
] as const satisfies readonly SiteRoute[];

export const componentHref = (slug: ComponentSlug) => `/components/${slug}`;

export const COMPONENT_ROUTES: SiteRoute[] = COMPONENT_SLUGS.map((slug) => ({
  href: componentHref(slug),
  title: getComponent(slug).title,
  section: "Components",
  summary: getComponent(slug).description,
}));

export const ALL_ROUTES: SiteRoute[] = [...STATIC_ROUTES, ...COMPONENT_ROUTES];

/** Next's `usePathname()` may carry a trailing slash depending on the host. */
export function normalizePath(pathname: string): string {
  return pathname.length > 1 ? pathname.replace(/\/+$/, "") : pathname;
}

export function findRoute(pathname: string): SiteRoute | undefined {
  const path = normalizePath(pathname);
  return ALL_ROUTES.find((route) => route.href === path);
}

export const routesIn = (section: SiteSection): SiteRoute[] =>
  STATIC_ROUTES.filter((route) => route.section === section);

export const GITHUB_URL = "https://github.com/aeros-core/aeros-design-system";
export const MIGRATION_GUIDE_URL = `${GITHUB_URL}/blob/main/docs/migration.md`;
