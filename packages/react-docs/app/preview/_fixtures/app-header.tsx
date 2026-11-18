"use client";

import { AppHeader, AppHeaderActions, AppHeaderBrand, AppHeaderLink, AppHeaderNav, AppHeaderTitle, Avatar, Button } from "@aeros-core/react";
import { Bell, Search } from "lucide-react";
import { Group } from "./kit";

export default function AppHeaderFixture() {
  return (
    <>
      <Group label="Top navigation — brand, button links (active first), actions" className="flex-col items-stretch">
        <AppHeader className="static">
          <AppHeaderBrand mark="A" name="Aeros" />
          <AppHeaderNav>
            <AppHeaderLink active>Dashboard</AppHeaderLink>
            <AppHeaderLink>Marketplace</AppHeaderLink>
            <AppHeaderLink>Operations</AppHeaderLink>
            <AppHeaderLink>AI</AppHeaderLink>
          </AppHeaderNav>
          <AppHeaderActions>
            <Button variant="ghost" iconOnly aria-label="Search"><Search /></Button>
            <Button variant="ghost" iconOnly aria-label="Notifications"><Bell /></Button>
            <Avatar size="sm" variant="inverse" fallback="PS" />
          </AppHeaderActions>
        </AppHeader>
      </Group>
      <Group label="Anchor links (href)" className="flex-col items-stretch">
        <AppHeader className="static">
          <AppHeaderBrand mark="A" name="Aeros" />
          <AppHeaderNav>
            <AppHeaderLink href="#">Dashboard</AppHeaderLink>
            <AppHeaderLink href="#" active>Orders</AppHeaderLink>
          </AppHeaderNav>
        </AppHeader>
      </Group>
      <Group label="Page title (beside a sidebar)" className="flex-col items-stretch">
        <AppHeader className="static">
          <AppHeaderTitle>Orders</AppHeaderTitle>
          <AppHeaderActions>
            <Button size="sm" variant="secondary">Export</Button>
            <Button size="sm">New order</Button>
          </AppHeaderActions>
        </AppHeader>
      </Group>
    </>
  );
}
