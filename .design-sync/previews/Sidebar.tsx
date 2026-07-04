import * as React from "react";
import {
  Sidebar,
  SidebarBrand,
  SidebarSection,
  SidebarItem,
} from "@aeros-core/react";

export const Nav = () => (
  <Sidebar>
    <SidebarBrand mark="A" name="Aeros" sub="Operations" />
    <SidebarSection label="Overview">
      <SidebarItem href="#" active>
        Dashboard
      </SidebarItem>
      <SidebarItem href="#">Orders</SidebarItem>
      <SidebarItem href="#">RFQs</SidebarItem>
      <SidebarItem href="#">Shipments</SidebarItem>
    </SidebarSection>
    <SidebarSection label="Manage">
      <SidebarItem href="#">Catalog</SidebarItem>
      <SidebarItem href="#">Contacts</SidebarItem>
      <SidebarItem href="#">Team</SidebarItem>
    </SidebarSection>
  </Sidebar>
);
