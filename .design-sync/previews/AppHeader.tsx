import * as React from "react";
import {
  AppHeader,
  AppHeaderActions,
  AppHeaderBrand,
  AppHeaderLink,
  AppHeaderNav,
  AppHeaderTitle,
  Avatar,
  Button,
} from "@aeros-core/react";
import { Bell, Search } from "lucide-react";

// `static` keeps the bar in the card's flow (it is sticky in a real AppShell).
export const TopNavigation = () => (
  <AppHeader className="static">
    <AppHeaderBrand mark="A" name="Aeros" />
    <AppHeaderNav>
      <AppHeaderLink active>Dashboard</AppHeaderLink>
      <AppHeaderLink>Marketplace</AppHeaderLink>
      <AppHeaderLink>Operations</AppHeaderLink>
      <AppHeaderLink>AI</AppHeaderLink>
    </AppHeaderNav>
    <AppHeaderActions>
      <Button variant="ghost" iconOnly aria-label="Search">
        <Search />
      </Button>
      <Button variant="ghost" iconOnly aria-label="Notifications">
        <Bell />
      </Button>
      <Avatar size="sm" variant="inverse" fallback="PS" />
    </AppHeaderActions>
  </AppHeader>
);

// Beside a sidebar the header carries the page title instead of the brand.
export const PageTitle = () => (
  <AppHeader className="static">
    <AppHeaderTitle>Orders</AppHeaderTitle>
    <AppHeaderActions>
      <Button size="sm" variant="secondary">
        Export
      </Button>
      <Button size="sm">New order</Button>
    </AppHeaderActions>
  </AppHeader>
);

// Dark chrome is opt-in: scope the theme to the bar.
export const DarkChrome = () => (
  <AppHeader className="static" data-theme="dark">
    <AppHeaderBrand mark="A" name="Aeros" />
    <AppHeaderNav>
      <AppHeaderLink href="#">Dashboard</AppHeaderLink>
      <AppHeaderLink href="#" active>
        Orders
      </AppHeaderLink>
    </AppHeaderNav>
  </AppHeader>
);
