import type { Metadata } from "next";
import { tokens } from "@aeros-core/tokens";
import { FRAMED_FIXTURES } from "../../../_registry";
import { CodeBlock } from "../../../_site/code-block";
import { FixtureEmbed } from "../../../_site/fixture-embed";
import { Code, PageIntro, Section, SpecCell, SpecTable } from "../../../_site/prose";

export const metadata: Metadata = { title: "App shell" };

const LAYOUT = `// app/layout.tsx
import {
  AppContent, AppFooter, AppHeader, AppHeaderActions, AppHeaderTitle, AppMain, AppShell,
  Sidebar, SidebarBrand, SidebarContent, SidebarFooter, SidebarHeader, SidebarItem,
  SidebarProvider, SidebarSection, SidebarTrigger,
} from "@aeros-core/react";

export default function Layout({ children }: { children: React.ReactNode }) {
  return (
    <SidebarProvider storageKey="app:sidebar">
      <AppShell>
        <Sidebar label="Main">
          <SidebarHeader>
            <SidebarBrand mark="A" name="Aeros" sub="Marketplace" />
          </SidebarHeader>
          <SidebarContent>
            <SidebarSection label="Workspace">
              <NavLink href="/" icon={<Home />}>Dashboard</NavLink>
              <NavLink href="/orders" icon={<Box />}>Orders</NavLink>
            </SidebarSection>
          </SidebarContent>
          <SidebarFooter>
            <SidebarItem href="/settings" icon={<Settings />}>Settings</SidebarItem>
          </SidebarFooter>
        </Sidebar>
        <AppMain>
          <AppHeader>
            <SidebarTrigger />
            <AppHeaderTitle>Orders</AppHeaderTitle>
            <AppHeaderActions>
              <Button size="sm">New order</Button>
            </AppHeaderActions>
          </AppHeader>
          <AppContent contained>{children}</AppContent>
          <AppFooter>© 2026 Aeros</AppFooter>
        </AppMain>
      </AppShell>
    </SidebarProvider>
  );
}`;

const NAV_LINK = `"use client";
import Link from "next/link";
import { usePathname } from "next/navigation";
import { SidebarItem, useSidebar } from "@aeros-core/react";

// A sidebar row that is a framework link, marked as the current page.
export function NavLink({ href, icon, children }: { href: string; icon: React.ReactNode; children: string }) {
  const pathname = usePathname();
  const { collapsed, isMobile } = useSidebar();
  const rail = collapsed && !isMobile;
  return (
    <SidebarItem asChild active={pathname === href} icon={icon} tooltip={children}>
      <Link href={href}>
        <span className={rail ? "sr-only" : "min-w-0 flex-1 truncate"}>{children}</span>
      </Link>
    </SidebarItem>
  );
}`;

const DARK = `<Sidebar data-theme="dark">…</Sidebar>`;

const frame = FRAMED_FIXTURES["app-shell"];

export default function AppShellPatternPage() {
  const { layout, size, breakpoint } = tokens;
  return (
    <>
      <PageIntro section="Patterns">
        The frame every Aeros app sits in: a sidebar beside a column of header, content and footer. All of it
        follows the theme and separates itself with hairlines. You are looking at it — this site is built from the
        same parts.
      </PageIntro>

      <Section
        title="Live"
        description="The app-shell fixture in a frame. Use the trigger in its header to collapse the sidebar to the rail."
      >
        {frame && (
          <FixtureEmbed
            slug="app-shell"
            title="App shell (live example)"
            height={frame.height}
            interactive={frame.interactive}
          />
        )}
      </Section>

      <Section
        title="Three presentations"
        description={
          <>
            One component tree, three layouts. <Code>SidebarProvider</Code> owns the state, remembers the rail under{" "}
            <Code>storageKey</Code>, and toggles on Cmd/Ctrl+B.
          </>
        }
      >
        <SpecTable label="Sidebar presentations" head={["Presentation", "When", "Width", "Rows"]}>
          <tr>
            <SpecCell>Expanded</SpecCell>
            <SpecCell className="text-fg-secondary">Desktop, default</SpecCell>
            <SpecCell mono>{layout.sidebar}px</SpecCell>
            <SpecCell className="text-fg-secondary">
              Icon and label, {size["nav-row"].pointer}px high
            </SpecCell>
          </tr>
          <tr>
            <SpecCell>Rail</SpecCell>
            <SpecCell className="text-fg-secondary">Desktop, collapsed</SpecCell>
            <SpecCell mono>{layout["sidebar-rail"]}px</SpecCell>
            <SpecCell className="text-fg-secondary">Icons only, with tooltips; a group expands the sidebar</SpecCell>
          </tr>
          <tr>
            <SpecCell>Sheet</SpecCell>
            <SpecCell className="text-fg-secondary">Below the md breakpoint ({breakpoint.md}px)</SpecCell>
            <SpecCell mono>{layout["sidebar-mobile"]}px</SpecCell>
            <SpecCell className="text-fg-secondary">
              Touch density, {size["nav-row"].touch}px high; closes when a destination is chosen
            </SpecCell>
          </tr>
        </SpecTable>
      </Section>

      <Section
        title="Composition"
        description={
          <>
            The header is {size.header.pointer}px and lines up with the sidebar header. <Code>AppContent contained</Code>{" "}
            centres the page at {layout["content-max"]}px.
          </>
        }
      >
        <CodeBlock title="app/layout.tsx" code={LAYOUT} />
      </Section>

      <Section
        title="Links and the current page"
        description={
          <>
            Pass a framework link through <Code>asChild</Code> and set <Code>active</Code> from the router; the row
            then carries <Code>aria-current=&quot;page&quot;</Code>. With <Code>asChild</Code> the label is yours to
            render, so hide it in the rail and give the row a <Code>tooltip</Code>.
          </>
        }
      >
        <CodeBlock title="nav-link.tsx" code={NAV_LINK} />
      </Section>

      <Section
        title="Dark chrome in a light app"
        description="The sidebar follows the page theme. To keep it dark regardless, theme the subtree."
      >
        <CodeBlock title="Dark sidebar" code={DARK} />
      </Section>
    </>
  );
}
