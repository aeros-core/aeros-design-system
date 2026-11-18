"use client";

import { Sidebar } from "@aeros-core/react";
import { SidebarNav } from "./sidebar-nav";

// No <Group> here: the sidebar is full-height chrome, shown next to a stub page.
// Without a SidebarProvider it is static and expanded at every viewport.
export default function SidebarFixture() {
  return (
    <div className="flex overflow-hidden rounded-surface border border-border-default">
      <Sidebar>
        <SidebarNav />
      </Sidebar>
      <div className="min-w-0 flex-1 bg-bg-canvas p-6">
        <p className="text-body-sm text-fg-secondary">Page content</p>
      </div>
    </div>
  );
}
