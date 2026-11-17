"use client";

import { Sidebar, SidebarBrand, SidebarItem, SidebarSection } from "@aeros-core/react";
import { Box, Home, Inbox, Settings, Truck } from "lucide-react";

// No <Group> here: the sidebar is full-height chrome, shown next to a stub page.
export default function SidebarFixture() {
  return (
    <div className="flex overflow-hidden rounded-lg border border-border-default">
      <Sidebar>
        <SidebarBrand mark="A" name="Aeros" sub="Marketplace" />
        <SidebarSection label="Workspace">
          <SidebarItem href="#" active icon={<Home />}>Dashboard</SidebarItem>
          <SidebarItem href="#" icon={<Inbox />} count={3}>Inbox</SidebarItem>
          <SidebarItem href="#" icon={<Box />} count={128}>Orders</SidebarItem>
          <SidebarItem href="#" icon={<Truck />} count={0}>Shipments</SidebarItem>
        </SidebarSection>
        <SidebarSection label="Default dot marker">
          <SidebarItem href="#" active>Active item</SidebarItem>
          <SidebarItem href="#">Inactive item</SidebarItem>
          <SidebarItem href="#">A very long destination label that truncates</SidebarItem>
        </SidebarSection>
        <SidebarSection>
          <SidebarItem icon={<Settings />}>Settings (button, no href)</SidebarItem>
        </SidebarSection>
      </Sidebar>
      <div className="min-w-0 flex-1 bg-bg-surface p-6">
        <p className="text-sm text-fg-secondary">Page content</p>
      </div>
    </div>
  );
}
