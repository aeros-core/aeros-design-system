"use client";

import * as React from "react";
import Link from "next/link";
import { usePathname } from "next/navigation";
import {
  AppContent,
  AppFooter,
  AppHeader,
  AppHeaderActions,
  AppHeaderTitle,
  AppMain,
  AppShell,
  Sidebar,
  SidebarBrand,
  SidebarContent,
  SidebarFooter,
  SidebarGroup,
  SidebarHeader,
  SidebarItem,
  SidebarProvider,
  SidebarSection,
  SidebarSubItem,
  SidebarTrigger,
  useSidebar,
} from "@aeros-core/react";
import {
  ArrowRightLeft,
  Bell,
  ClipboardList,
  Compass,
  ExternalLink,
  Home,
  Layers,
  LayoutGrid,
  LayoutTemplate,
  MousePointerClick,
  Palette,
  PanelsTopLeft,
  Rows3,
  Ruler,
  Scaling,
  Settings,
  SquareStack,
  Table2,
  TextCursorInput,
  Type,
  Zap,
} from "lucide-react";
import { componentsByFamily, getComponent, type Family } from "../_registry";
import { GITHUB_URL, componentHref, findRoute, normalizePath, routesIn, type SiteRoute } from "./routes";
import { DensitySwitch, ThemeSwitch } from "./theme";

const ROUTE_ICON: Record<string, React.ReactNode> = {
  "/": <Home />,
  "/migration": <ArrowRightLeft />,
  "/foundations/color": <Palette />,
  "/foundations/typography": <Type />,
  "/foundations/spacing-and-radius": <Ruler />,
  "/foundations/elevation": <Layers />,
  "/foundations/motion": <Zap />,
  "/foundations/density-and-sizing": <Scaling />,
  "/components": <LayoutGrid />,
  "/patterns/app-shell": <PanelsTopLeft />,
  "/patterns/data-table": <Rows3 />,
  "/patterns/form": <ClipboardList />,
  "/patterns/settings": <Settings />,
};

const FAMILY_ICON: Record<Family, React.ReactNode> = {
  Actions: <MousePointerClick />,
  Forms: <TextCursorInput />,
  "Data display": <Table2 />,
  Feedback: <Bell />,
  Navigation: <Compass />,
  Overlays: <SquareStack />,
  Layout: <LayoutTemplate />,
};

const FAMILY_GROUPS = componentsByFamily();

/** A sidebar row that is a Next `<Link>`. */
function NavItem({ route, pathname }: { route: SiteRoute; pathname: string }) {
  const { collapsed, isMobile } = useSidebar();
  const rail = collapsed && !isMobile;
  return (
    <SidebarItem asChild active={pathname === route.href} icon={ROUTE_ICON[route.href]} tooltip={route.title}>
      <Link href={route.href}>
        {/* With asChild the row's content is ours: hide the label in the rail, truncate it otherwise. */}
        <span className={rail ? "sr-only" : "min-w-0 flex-1 truncate"}>{route.title}</span>
      </Link>
    </SidebarItem>
  );
}

function SiteSidebar({ pathname }: { pathname: string }) {
  const { isMobile } = useSidebar();
  const activeFamily = FAMILY_GROUPS.find(({ slugs }) => slugs.some((slug) => componentHref(slug) === pathname))?.family;

  // The groups are controlled: a client-side navigation must open the family of
  // the page it lands on (an uncontrolled group only reads `active` on mount).
  const [open, setOpen] = React.useState<Partial<Record<Family, boolean>>>({});
  React.useEffect(() => {
    if (activeFamily) setOpen((current) => (current[activeFamily] ? current : { ...current, [activeFamily]: true }));
  }, [activeFamily]);

  return (
    // Until the provider has measured the viewport the sidebar renders in its
    // desktop form; `max-md:hidden` keeps that first frame off a phone screen.
    <Sidebar label="Site" className={isMobile ? undefined : "max-md:hidden"}>
      <SidebarHeader>
        <SidebarBrand mark="A" name="Aeros" sub="Design System" />
      </SidebarHeader>
      <SidebarContent>
        <SidebarSection label="Overview">
          {routesIn("Overview").map((route) => (
            <NavItem key={route.href} route={route} pathname={pathname} />
          ))}
        </SidebarSection>
        <SidebarSection label="Foundations">
          {routesIn("Foundations").map((route) => (
            <NavItem key={route.href} route={route} pathname={pathname} />
          ))}
        </SidebarSection>
        <SidebarSection label="Components">
          {routesIn("Components").map((route) => (
            <NavItem key={route.href} route={{ ...route, title: "All components" }} pathname={pathname} />
          ))}
          {FAMILY_GROUPS.map(({ family, slugs }) => (
            <SidebarGroup
              key={family}
              label={family}
              icon={FAMILY_ICON[family]}
              active={family === activeFamily}
              open={open[family] ?? family === activeFamily}
              onOpenChange={(next) => setOpen((current) => ({ ...current, [family]: next }))}
            >
              {slugs.map((slug) => (
                <SidebarSubItem key={slug} asChild active={pathname === componentHref(slug)}>
                  <Link href={componentHref(slug)}>{getComponent(slug).title}</Link>
                </SidebarSubItem>
              ))}
            </SidebarGroup>
          ))}
        </SidebarSection>
        <SidebarSection label="Patterns">
          {routesIn("Patterns").map((route) => (
            <NavItem key={route.href} route={route} pathname={pathname} />
          ))}
        </SidebarSection>
      </SidebarContent>
      <SidebarFooter>
        <SidebarItem href={GITHUB_URL} icon={<ExternalLink />}>
          GitHub
        </SidebarItem>
      </SidebarFooter>
    </Sidebar>
  );
}

export function SiteShell({ version, children }: { version: string; children: React.ReactNode }) {
  const pathname = normalizePath(usePathname() ?? "/");
  const route = findRoute(pathname);

  return (
    <SidebarProvider storageKey="aeros-docs:sidebar">
      <AppShell>
        <SiteSidebar pathname={pathname} />
        <AppMain>
          <AppHeader>
            <SidebarTrigger />
            <AppHeaderTitle>{route?.title ?? "Not found"}</AppHeaderTitle>
            <AppHeaderActions>
              <DensitySwitch />
              <ThemeSwitch />
            </AppHeaderActions>
          </AppHeader>
          <AppContent contained>{children}</AppContent>
          <AppFooter>
            <span>
              <span className="aeros-logo text-fg-secondary">Aeros</span> Design System · tokens v{version}
            </span>
            <a
              href={GITHUB_URL}
              className="rounded-item underline underline-offset-2 transition-colors duration-fast hover:text-fg-primary"
            >
              Source on GitHub
            </a>
          </AppFooter>
        </AppMain>
      </AppShell>
    </SidebarProvider>
  );
}
