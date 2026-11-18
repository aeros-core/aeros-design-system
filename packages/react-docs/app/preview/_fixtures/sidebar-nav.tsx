"use client";

import {
  SidebarBrand,
  SidebarContent,
  SidebarFooter,
  SidebarGroup,
  SidebarHeader,
  SidebarItem,
  SidebarSection,
  SidebarSubItem,
} from "@aeros-core/react";
import { Box, Home, Inbox, Settings, Tags, Truck } from "lucide-react";

/** The navigation shared by the sidebar, rail and app-shell fixtures. */
export function SidebarNav() {
  return (
    <>
      <SidebarHeader>
        <SidebarBrand mark="A" name="Aeros" sub="Marketplace" />
      </SidebarHeader>
      <SidebarContent>
        <SidebarSection label="Workspace">
          <SidebarItem href="#" active icon={<Home />}>Dashboard</SidebarItem>
          <SidebarItem href="#" icon={<Inbox />} count={3} countTone="solid">Inbox</SidebarItem>
          <SidebarItem href="#" icon={<Box />} count={128}>Orders</SidebarItem>
          <SidebarItem href="#" icon={<Truck />} count={0}>Shipments</SidebarItem>
          <SidebarGroup label="Catalog" icon={<Tags />} defaultOpen>
            <SidebarSubItem href="#" active>Products</SidebarSubItem>
            <SidebarSubItem href="#">Categories</SidebarSubItem>
          </SidebarGroup>
        </SidebarSection>
        <SidebarSection label="No icons">
          <SidebarItem href="#">Inactive item</SidebarItem>
          <SidebarItem href="#">A very long destination label that truncates</SidebarItem>
        </SidebarSection>
      </SidebarContent>
      <SidebarFooter>
        <SidebarItem icon={<Settings />}>Settings</SidebarItem>
      </SidebarFooter>
    </>
  );
}
