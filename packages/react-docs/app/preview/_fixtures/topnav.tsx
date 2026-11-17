"use client";

import { Avatar, TopNav, TopNavBrand, TopNavLink, TopNavLinks, TopNavRight } from "@aeros-core/react";
import { Group } from "./kit";

export default function TopNavFixture() {
  return (
    <>
      <Group label="Button links (no href), active first" className="flex-col items-stretch">
        <TopNav>
          <TopNavBrand mark="A" name="Aeros" />
          <TopNavLinks>
            <TopNavLink active>Dashboard</TopNavLink>
            <TopNavLink>Marketplace</TopNavLink>
            <TopNavLink>Operations</TopNavLink>
            <TopNavLink>AI</TopNavLink>
          </TopNavLinks>
          <TopNavRight>
            <Avatar size="sm" variant="inverse" fallback="PS" />
          </TopNavRight>
        </TopNav>
      </Group>
      <Group label="Anchor links (href), brand only on the right" className="flex-col items-stretch">
        <TopNav>
          <TopNavBrand mark="A" name="Aeros" />
          <TopNavLinks>
            <TopNavLink href="#">Dashboard</TopNavLink>
            <TopNavLink href="#" active>Orders</TopNavLink>
          </TopNavLinks>
        </TopNav>
      </Group>
    </>
  );
}
