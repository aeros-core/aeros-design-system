"use client";

import { Sidebar, SidebarProvider } from "@aeros-core/react";
import { SidebarNav } from "./sidebar-nav";

// The collapsed rail (desktop). Below the md breakpoint the provider turns the
// sidebar into a closed sheet, so the mobile screenshot shows the page alone.
export default function SidebarRailFixture() {
  return (
    <SidebarProvider defaultCollapsed keyboardShortcut={false}>
      <div className="flex overflow-hidden rounded-surface border border-border-default">
        <Sidebar>
          <SidebarNav />
        </Sidebar>
        <div className="min-w-0 flex-1 bg-bg-canvas p-6">
          <p className="text-body-sm text-fg-secondary">Page content</p>
        </div>
      </div>
    </SidebarProvider>
  );
}
