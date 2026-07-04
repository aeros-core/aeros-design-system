import * as React from "react";
import {
  TopNav,
  TopNavBrand,
  TopNavLinks,
  TopNavLink,
  TopNavRight,
  Avatar,
} from "@aeros-core/react";

export const Bar = () => (
  <TopNav>
    <TopNavBrand mark="A" name="Aeros" />
    <TopNavLinks>
      <TopNavLink active>Dashboard</TopNavLink>
      <TopNavLink>Marketplace</TopNavLink>
      <TopNavLink>Operations</TopNavLink>
      <TopNavLink>AI</TopNavLink>
    </TopNavLinks>
    <TopNavRight>
      <Avatar size="sm" tone="dark" fallback="PS" />
    </TopNavRight>
  </TopNav>
);
