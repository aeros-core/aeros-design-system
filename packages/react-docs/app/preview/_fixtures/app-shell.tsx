"use client";

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
  SidebarProvider,
  SidebarTrigger,
} from "@aeros-core/react";
import { SidebarNav } from "./sidebar-nav";

// The whole frame: sidebar + header + content + footer. On the mobile viewport
// the sidebar is a (closed) sheet and the header's trigger opens it.
export default function AppShellFixture() {
  return (
    <SidebarProvider keyboardShortcut={false}>
      <AppShell className="overflow-hidden rounded-surface border border-border-default">
        <Sidebar>
          <SidebarNav />
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
}
