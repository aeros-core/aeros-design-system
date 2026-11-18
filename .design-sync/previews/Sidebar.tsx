import * as React from "react";
import {
  Sidebar,
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

const nav = (
  <>
    <SidebarHeader>
      <SidebarBrand mark="A" name="Aeros" sub="Marketplace" />
    </SidebarHeader>
    <SidebarContent>
      <SidebarSection label="Workspace">
        <SidebarItem href="#" active icon={<Home />}>
          Dashboard
        </SidebarItem>
        <SidebarItem href="#" icon={<Inbox />} count={3}>
          Inbox
        </SidebarItem>
        <SidebarItem href="#" icon={<Box />} count={128}>
          Orders
        </SidebarItem>
        <SidebarItem href="#" icon={<Truck />}>
          Shipments
        </SidebarItem>
        <SidebarGroup label="Catalog" icon={<Tags />} defaultOpen>
          <SidebarSubItem href="#" active>
            Products
          </SidebarSubItem>
          <SidebarSubItem href="#">Categories</SidebarSubItem>
        </SidebarGroup>
      </SidebarSection>
    </SidebarContent>
    <SidebarFooter>
      <SidebarItem icon={<Settings />}>Settings</SidebarItem>
    </SidebarFooter>
  </>
);

// Without a SidebarProvider the sidebar is static and expanded. It follows the theme.
export const Nav = () => (
  <div style={{ display: "flex", height: 460 }}>
    <Sidebar>{nav}</Sidebar>
  </div>
);

// Dark chrome is opt-in: scope the theme to the sidebar.
export const DarkChrome = () => (
  <div style={{ display: "flex", height: 460 }}>
    <Sidebar data-theme="dark">{nav}</Sidebar>
  </div>
);
