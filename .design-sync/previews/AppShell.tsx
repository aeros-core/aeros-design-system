import * as React from "react";
import {
  AppContent,
  AppFooter,
  AppHeader,
  AppHeaderActions,
  AppHeaderTitle,
  AppMain,
  AppShell,
  Button,
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
} from "@aeros-core/react";
import { Box, Home, Inbox, Settings, Tags, Truck } from "lucide-react";

const Nav = () => (
  <>
    <SidebarHeader>
      <SidebarBrand mark="A" name="Aeros" sub="Marketplace" />
    </SidebarHeader>
    <SidebarContent>
      <SidebarSection label="Workspace">
        <SidebarItem href="#" active icon={<Home />}>Dashboard</SidebarItem>
        <SidebarItem href="#" icon={<Inbox />} count={3}>Inbox</SidebarItem>
        <SidebarItem href="#" icon={<Box />} count={128}>Orders</SidebarItem>
        <SidebarItem href="#" icon={<Truck />}>Shipments</SidebarItem>
        <SidebarGroup label="Catalog" icon={<Tags />} defaultOpen>
          <SidebarSubItem href="#" active>Products</SidebarSubItem>
          <SidebarSubItem href="#">Categories</SidebarSubItem>
        </SidebarGroup>
      </SidebarSection>
    </SidebarContent>
    <SidebarFooter>
      <SidebarItem icon={<Settings />}>Settings</SidebarItem>
    </SidebarFooter>
  </>
);

const Shell = ({ collapsed }: { collapsed: boolean }) => (
  // SidebarProvider drives the rail / mobile-sheet behaviour of Sidebar and
  // SidebarTrigger. The shell is viewport-tall (min-h-dvh; the sidebar is h-dvh).
  <SidebarProvider keyboardShortcut={false} collapsed={collapsed}>
    <AppShell className="overflow-hidden rounded-surface border border-border-default">
      <Sidebar>
        <Nav />
      </Sidebar>
      <AppMain>
        <AppHeader>
          <SidebarTrigger />
          <AppHeaderTitle>Dashboard</AppHeaderTitle>
          <AppHeaderActions>
            <Button size="sm" variant="secondary">Export</Button>
            <Button size="sm">New order</Button>
          </AppHeaderActions>
        </AppHeader>
        <AppContent contained>
          <p className="text-body-sm text-fg-secondary">Page content</p>
        </AppContent>
        <AppFooter>
          <span>© 2026 Aeros</span>
          <span>v3.0</span>
        </AppFooter>
      </AppMain>
    </AppShell>
  </SidebarProvider>
);

export const FullFrame = () => <Shell collapsed={false} />;

export const CollapsedRail = () => <Shell collapsed />;
