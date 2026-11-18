import * as React from "react";
import { describe, expect, it, onTestFinished, vi } from "vitest";
import { render, screen, within } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { axe } from "jest-axe";
import {
  Breadcrumb,
  Sidebar,
  SidebarBrand,
  SidebarItem,
  SidebarProvider,
  SidebarSection,
  SidebarGroup,
  SidebarSubItem,
  TabCount,
  Tabs,
  TabsContent,
  TabsList,
  TabsTrigger,
  AppHeader,
  AppHeaderBrand,
  AppHeaderLink,
  AppHeaderNav,
  AppHeaderActions
} from "../src";

import { lazyChild } from "./lazy-child";

// Behaviour + semantics only. No class-name or pixel assertions.

function OrderTabs(props: Partial<React.ComponentProps<typeof Tabs>>) {
  return (
    <Tabs defaultValue="open" {...props}>
      <TabsList aria-label="Order status">
        <TabsTrigger value="open">
          Open<TabCount>12</TabCount>
        </TabsTrigger>
        <TabsTrigger value="packed">Packed</TabsTrigger>
        <TabsTrigger value="held" disabled>
          Held
        </TabsTrigger>
        <TabsTrigger value="shipped">Shipped</TabsTrigger>
      </TabsList>
      <TabsContent value="open">Open orders</TabsContent>
      <TabsContent value="packed">Packed orders</TabsContent>
      <TabsContent value="held">Held orders</TabsContent>
      <TabsContent value="shipped">Shipped orders</TabsContent>
    </Tabs>
  );
}

describe.each(["underline", "pill"] as const)("Tabs (variant=%s)", (variant) => {
  it("exposes a tablist with the default tab selected and only its panel shown", () => {
    render(<OrderTabs variant={variant} />);
    const list = screen.getByRole("tablist", { name: "Order status" });
    expect(within(list).getAllByRole("tab")).toHaveLength(4);
    expect(screen.getByRole("tab", { name: /Open/ })).toHaveAttribute("aria-selected", "true");
    expect(screen.getByRole("tab", { name: "Packed" })).toHaveAttribute("aria-selected", "false");

    const panels = screen.getAllByRole("tabpanel");
    expect(panels).toHaveLength(1);
    expect(panels[0]).toHaveTextContent("Open orders");
    expect(screen.queryByText("Packed orders")).not.toBeInTheDocument();
    // `variant` is a styling prop: it must not leak onto the DOM.
    expect(list.parentElement).not.toHaveAttribute("variant");
  });

  it("links each tab to its panel in both directions", () => {
    render(<OrderTabs variant={variant} />);
    const tab = screen.getByRole("tab", { name: /Open/ });
    const panel = screen.getByRole("tabpanel");
    expect(tab).toHaveAttribute("aria-controls", panel.id);
    expect(panel).toHaveAttribute("aria-labelledby", tab.id);
    expect(panel).toHaveAccessibleName(/Open/);
  });

  it("selects a tab on click and swaps the visible panel", async () => {
    const user = userEvent.setup();
    const onValueChange = vi.fn();
    render(<OrderTabs variant={variant} onValueChange={onValueChange} />);
    await user.click(screen.getByRole("tab", { name: "Packed" }));
    expect(onValueChange).toHaveBeenCalledExactlyOnceWith("packed");
    expect(screen.getByRole("tab", { name: "Packed" })).toHaveAttribute("aria-selected", "true");
    expect(screen.getByRole("tab", { name: /Open/ })).toHaveAttribute("aria-selected", "false");
    expect(screen.getByRole("tabpanel")).toHaveTextContent("Packed orders");
    expect(screen.queryByText("Open orders")).not.toBeInTheDocument();
  });

  it("roves with arrow keys, skipping disabled tabs and wrapping, with Home/End", async () => {
    const user = userEvent.setup();
    render(<OrderTabs variant={variant} />);
    const open = screen.getByRole("tab", { name: /Open/ });
    const packed = screen.getByRole("tab", { name: "Packed" });
    const shipped = screen.getByRole("tab", { name: "Shipped" });

    // The tablist is a single tab stop on the selected tab.
    await user.tab();
    expect(open).toHaveFocus();
    expect(packed).toHaveAttribute("tabindex", "-1");

    await user.keyboard("{ArrowRight}");
    expect(packed).toHaveFocus();
    expect(packed).toHaveAttribute("aria-selected", "true");
    expect(screen.getByRole("tabpanel")).toHaveTextContent("Packed orders");

    await user.keyboard("{ArrowRight}");
    expect(shipped).toHaveFocus();
    expect(screen.getByRole("tab", { name: "Held" })).toHaveAttribute("aria-selected", "false");
    expect(screen.getByRole("tabpanel")).toHaveTextContent("Shipped orders");

    await user.keyboard("{ArrowRight}");
    expect(open).toHaveFocus();
    await user.keyboard("{ArrowLeft}");
    expect(shipped).toHaveFocus();
    await user.keyboard("{Home}");
    expect(open).toHaveFocus();
    await user.keyboard("{End}");
    expect(shipped).toHaveFocus();
    expect(screen.getAllByRole("tab", { selected: true })).toHaveLength(1);

    // Tab leaves the list and lands on the active panel.
    await user.tab();
    expect(screen.getByRole("tabpanel")).toHaveFocus();
  });

  it("a disabled tab cannot be selected", async () => {
    const user = userEvent.setup();
    const onValueChange = vi.fn();
    render(<OrderTabs variant={variant} onValueChange={onValueChange} />);
    const held = screen.getByRole("tab", { name: "Held" });
    expect(held).toBeDisabled();
    await user.click(held);
    expect(onValueChange).not.toHaveBeenCalled();
    expect(screen.getByRole("tabpanel")).toHaveTextContent("Open orders");
  });

  it("follows a controlled value", () => {
    const { rerender } = render(<OrderTabs variant={variant} value="open" onValueChange={() => {}} />);
    rerender(<OrderTabs variant={variant} value="shipped" onValueChange={() => {}} />);
    expect(screen.getByRole("tab", { name: "Shipped" })).toHaveAttribute("aria-selected", "true");
    expect(screen.getByRole("tabpanel")).toHaveTextContent("Shipped orders");
  });

  it("with activationMode=manual, arrows move focus but only Enter/Space selects", async () => {
    const user = userEvent.setup();
    render(<OrderTabs variant={variant} activationMode="manual" />);
    await user.tab();
    await user.keyboard("{ArrowRight}");
    expect(screen.getByRole("tab", { name: "Packed" })).toHaveFocus();
    expect(screen.getByRole("tabpanel")).toHaveTextContent("Open orders");
    await user.keyboard("{Enter}");
    expect(screen.getByRole("tabpanel")).toHaveTextContent("Packed orders");
  });

  it("renders TabCount inside the tab, as part of its accessible name", () => {
    render(<OrderTabs variant={variant} />);
    const open = screen.getByRole("tab", { name: /Open/ });
    expect(within(open).getByText("12")).toBeInTheDocument();
    expect(open).toHaveAccessibleName(/12/);
  });

  it("has no axe violations", async () => {
    const { container } = render(<OrderTabs variant={variant} />);
    expect(await axe(container)).toHaveNoViolations();
  });
});

describe("TabCount", () => {
  it("renders standalone with or without the `active` override and forwards props", () => {
    render(
      <>
        <TabCount data-testid="plain">3</TabCount>
        <TabCount data-testid="on" active>
          4
        </TabCount>
        <TabCount data-testid="off" active={false}>
          5
        </TabCount>
      </>
    );
    expect(screen.getByTestId("plain")).toHaveTextContent("3");
    expect(screen.getByTestId("on")).toHaveTextContent("4");
    expect(screen.getByTestId("off")).toHaveTextContent("5");
    // `active` is a styling prop: it must not leak onto the DOM.
    expect(screen.getByTestId("on")).not.toHaveAttribute("active");
  });
});

describe("Breadcrumb", () => {
  const items = [
    { label: "Home", href: "/" },
    { label: "Orders", href: "/orders" },
    { label: "Drafts" },
    { label: "#1042", href: "/orders/1042" }
  ];

  it("is a Breadcrumb navigation landmark holding an ordered list", () => {
    render(<Breadcrumb items={items} />);
    const nav = screen.getByRole("navigation", { name: "Breadcrumb" });
    expect(within(nav).getByRole("list").tagName).toBe("OL");
    expect(within(nav).getAllByRole("listitem")).toHaveLength(4);
  });

  it("links ancestors that have an href and leaves the rest as text", () => {
    render(<Breadcrumb items={items} />);
    const links = screen.getAllByRole("link");
    expect(links.map((l) => [l.textContent, l.getAttribute("href")])).toEqual([
      ["Home", "/"],
      ["Orders", "/orders"]
    ]);
    expect(screen.getByText("Drafts")).not.toHaveAttribute("aria-current");
  });

  it("marks only the last item as the current page, and never as a link", () => {
    render(<Breadcrumb items={items} />);
    const current = screen.getByText("#1042");
    expect(current).toHaveAttribute("aria-current", "page");
    expect(current.closest("a")).toBeNull();
    expect(document.querySelectorAll("[aria-current]")).toHaveLength(1);
  });

  it("hides separators from assistive tech and accepts a custom one", () => {
    render(<Breadcrumb items={items} separator="/" />);
    const separators = screen.getAllByText("/");
    expect(separators).toHaveLength(3);
    separators.forEach((s) => expect(s).toHaveAttribute("aria-hidden", "true"));
  });

  it("a single item is the current page with no separator", () => {
    render(<Breadcrumb items={[{ label: "Home", href: "/" }]} separator="/" />);
    expect(screen.getByText("Home")).toHaveAttribute("aria-current", "page");
    expect(screen.queryByText("/")).not.toBeInTheDocument();
    expect(screen.queryByRole("link")).not.toBeInTheDocument();
  });

  it("renders nothing but the landmark for an empty trail", () => {
    render(<Breadcrumb items={[]} />);
    expect(screen.getByRole("navigation", { name: "Breadcrumb" })).toBeInTheDocument();
    expect(screen.queryAllByRole("listitem")).toHaveLength(0);
  });

  it("lets the caller rename the landmark", () => {
    render(<Breadcrumb items={items} aria-label="You are here" />);
    expect(screen.getByRole("navigation", { name: "You are here" })).toBeInTheDocument();
  });

  it("has no axe violations", async () => {
    const { container } = render(<Breadcrumb items={items} />);
    expect(await axe(container)).toHaveNoViolations();
  });
});

describe("Sidebar", () => {
  it("is a navigation landmark named Sidebar, renameable by the caller", () => {
    const { rerender } = render(<Sidebar>content</Sidebar>);
    expect(screen.getByRole("navigation", { name: "Sidebar" })).toHaveTextContent("content");
    rerender(<Sidebar aria-label="Workspace">content</Sidebar>);
    expect(screen.getByRole("navigation", { name: "Workspace" })).toBeInTheDocument();
  });

  it("SidebarBrand renders mark and name, and sub only when given", () => {
    const { rerender } = render(<SidebarBrand mark="A" name="Aeros" sub="factory.aeros.dev" />);
    expect(screen.getByText("A")).toBeInTheDocument();
    expect(screen.getByText("Aeros")).toBeInTheDocument();
    expect(screen.getByText("factory.aeros.dev")).toBeInTheDocument();
    rerender(<SidebarBrand mark="A" name="Aeros" />);
    expect(screen.queryByText("factory.aeros.dev")).not.toBeInTheDocument();
  });

  it("an unlabelled section is still a group, without a dangling labelledby", () => {
    render(
      <SidebarSection>
        <SidebarItem href="/a">A</SidebarItem>
      </SidebarSection>
    );
    const group = screen.getByRole("group");
    expect(group).not.toHaveAttribute("aria-labelledby");
    expect(within(group).getByRole("link", { name: "A" })).toBeInTheDocument();
  });

  it("only the active item carries aria-current=page, as a link or a button", () => {
    render(
      <Sidebar>
        <SidebarItem href="/home">Home</SidebarItem>
        <SidebarItem href="/orders" active>
          Orders
        </SidebarItem>
        <SidebarItem>Settings</SidebarItem>
      </Sidebar>
    );
    expect(screen.getByRole("link", { name: "Orders" })).toHaveAttribute("aria-current", "page");
    expect(screen.getByRole("link", { name: "Home" })).not.toHaveAttribute("aria-current");
    expect(screen.getByRole("button", { name: "Settings" })).not.toHaveAttribute("aria-current");
  });

  it("the button fallback is type=button, has no href, and is keyboard-operable", async () => {
    const user = userEvent.setup();
    const onClick = vi.fn();
    const onSubmit = vi.fn((e: React.FormEvent) => e.preventDefault());
    render(
      <form onSubmit={onSubmit}>
        <SidebarItem onClick={onClick}>Collapse</SidebarItem>
      </form>
    );
    const button = screen.getByRole("button", { name: "Collapse" });
    expect(button).toHaveAttribute("type", "button");
    expect(button).not.toHaveAttribute("href");
    await user.tab();
    expect(button).toHaveFocus();
    await user.keyboard("{Enter}");
    await user.keyboard(" ");
    expect(onClick).toHaveBeenCalledTimes(2);
    expect(onSubmit).not.toHaveBeenCalled();
  });

  it("a link item forwards clicks and anchor props", async () => {
    const user = userEvent.setup();
    const onClick = vi.fn((e: React.MouseEvent) => e.preventDefault());
    render(
      <SidebarItem href="/docs" target="_blank" rel="noreferrer" onClick={onClick}>
        Docs
      </SidebarItem>
    );
    const link = screen.getByRole("link", { name: "Docs" });
    expect(link).toHaveAttribute("target", "_blank");
    expect(link).toHaveAttribute("rel", "noreferrer");
    await user.click(link);
    expect(onClick).toHaveBeenCalledTimes(1);
  });

  it("caps the count at 99+ and hides it for zero, negative or missing counts", () => {
    render(
      <>
        <SidebarItem href="/a" count={250}>
          Alerts
        </SidebarItem>
        <SidebarItem href="/b" count={99}>
          Batches
        </SidebarItem>
        <SidebarItem href="/c" count={-1}>
          Credits
        </SidebarItem>
        <SidebarItem href="/d">Drafts</SidebarItem>
      </>
    );
    expect(screen.getByRole("link", { name: /^Alerts\s*,\s*99\+$/ })).toBeInTheDocument();
    expect(screen.getByRole("link", { name: /^Batches\s*,\s*99$/ })).toBeInTheDocument();
    expect(screen.getByRole("link", { name: "Credits" })).toBeInTheDocument();
    expect(screen.getByRole("link", { name: "Drafts" })).toBeInTheDocument();
  });

  it("renders a caller-supplied icon in place of the default marker", () => {
    render(
      <SidebarItem href="/a" icon={<svg data-testid="icon" aria-hidden="true" />}>
        Alerts
      </SidebarItem>
    );
    const link = screen.getByRole("link", { name: "Alerts" });
    expect(within(link).getByTestId("icon")).toBeInTheDocument();
  });

  // The caller's element becomes the row; the icon renders inside it.
  it("asChild renders the caller's link element with aria-current", () => {
    const error = vi.spyOn(console, "error").mockImplementation(() => {});
    onTestFinished(() => error.mockRestore());
    render(
      <SidebarItem asChild active>
        <a href="/orders" data-router-link="">
          Orders
        </a>
      </SidebarItem>
    );
    const link = screen.getByRole("link", { name: "Orders" });
    expect(link).toHaveAttribute("href", "/orders");
    expect(link).toHaveAttribute("data-router-link");
    expect(link).toHaveAttribute("aria-current", "page");
  });

  it("asChild behaves like the default row: icon, label and count inside the child", () => {
    render(
      <SidebarItem asChild icon={<svg data-testid="icon" />} count={3}>
        <a href="/inbox">Inbox</a>
      </SidebarItem>
    );
    const link = screen.getByRole("link", { name: "Inbox , 3" });
    expect(link).toHaveAttribute("href", "/inbox");
    expect(within(link).getByTestId("icon")).toBeInTheDocument();
    expect(within(link).getByText("3")).toBeVisible();
  });

  it("asChild in the rail keeps the label as the accessible name, announces the count and shows a tooltip", async () => {
    const user = userEvent.setup();
    render(
      <SidebarProvider defaultCollapsed>
        <Sidebar>
          <SidebarItem asChild icon={<svg aria-hidden />} count={3}>
            <a href="/inbox">Inbox</a>
          </SidebarItem>
        </Sidebar>
      </SidebarProvider>
    );
    const link = screen.getByRole("link", { name: "Inbox , 3" });
    // The tooltip defaults to the child's text content.
    await user.hover(link);
    expect(await screen.findByRole("tooltip")).toHaveTextContent("Inbox · 3");
  });

  it("asChild rows render a child that arrives as a lazy (server) reference", () => {
    render(
      <Sidebar>
        <SidebarItem asChild active icon={<svg data-testid="icon" />}>
          {lazyChild(<a href="/orders">Orders</a>)}
        </SidebarItem>
        <SidebarGroup label="Catalog" defaultOpen>
          <SidebarSubItem asChild active>
            {lazyChild(<a href="/catalog/cups">Cups</a>)}
          </SidebarSubItem>
        </SidebarGroup>
      </Sidebar>
    );
    const orders = screen.getByRole("link", { name: "Orders" });
    expect(orders).toHaveAttribute("aria-current", "page");
    expect(within(orders).getByTestId("icon")).toBeInTheDocument();
    expect(screen.getByRole("link", { name: "Cups" })).toHaveAttribute("aria-current", "page");
  });

  it("a full sidebar has no axe violations", async () => {
    const { container } = render(
      <Sidebar>
        <SidebarBrand mark="A" name="Aeros" sub="factory" />
        <SidebarSection label="Floor">
          <SidebarItem href="/home" active>
            Home
          </SidebarItem>
          <SidebarItem href="/inbox" count={3}>
            Inbox
          </SidebarItem>
          <SidebarItem>Collapse</SidebarItem>
        </SidebarSection>
        <SidebarSection>
          <SidebarItem href="/settings">Settings</SidebarItem>
        </SidebarSection>
      </Sidebar>
    );
    expect(await axe(container)).toHaveNoViolations();
  });
});

describe("AppHeader", () => {
  function Nav({ onSignOut = () => {} }: { onSignOut?: () => void }) {
    return (
      <AppHeader>
        <AppHeaderBrand mark="A" name="Aeros" />
        <AppHeaderNav>
          <AppHeaderLink href="/home">Home</AppHeaderLink>
          <AppHeaderLink href="/orders" active>
            Orders
          </AppHeaderLink>
          <AppHeaderLink onClick={onSignOut}>Sign out</AppHeaderLink>
        </AppHeaderNav>
        <AppHeaderActions>
          <span>parth@aeros.dev</span>
        </AppHeaderActions>
      </AppHeader>
    );
  }

  it("is a banner containing the brand, a Primary navigation and the right slot", () => {
    render(<Nav />);
    const banner = screen.getByRole("banner");
    expect(within(banner).getByText("A")).toBeInTheDocument();
    expect(within(banner).getByText("Aeros")).toBeInTheDocument();
    expect(within(banner).getByText("parth@aeros.dev")).toBeInTheDocument();
    const nav = within(banner).getByRole("navigation", { name: "Primary" });
    expect(within(nav).getAllByRole("link")).toHaveLength(2);
  });

  it("only the active link carries aria-current=page", () => {
    render(<Nav />);
    expect(screen.getByRole("link", { name: "Orders" })).toHaveAttribute("aria-current", "page");
    expect(screen.getByRole("link", { name: "Home" })).not.toHaveAttribute("aria-current");
    expect(screen.getByRole("link", { name: "Home" })).toHaveAttribute("href", "/home");
    expect(document.querySelectorAll("[aria-current]")).toHaveLength(1);
  });

  it("falls back to a keyboard-operable type=button when no href is given", async () => {
    const user = userEvent.setup();
    const onSignOut = vi.fn();
    render(<Nav onSignOut={onSignOut} />);
    const button = screen.getByRole("button", { name: "Sign out" });
    expect(button).toHaveAttribute("type", "button");
    expect(button).not.toHaveAttribute("href");

    await user.tab();
    await user.tab();
    await user.tab();
    expect(button).toHaveFocus();
    await user.keyboard("{Enter}");
    expect(onSignOut).toHaveBeenCalledTimes(1);
  });

  it("an active button fallback also carries aria-current", () => {
    render(<AppHeaderLink active>Dashboard</AppHeaderLink>);
    expect(screen.getByRole("button", { name: "Dashboard" })).toHaveAttribute("aria-current", "page");
  });

  it("asChild renders the caller's link element with aria-current", () => {
    render(
      <AppHeaderLink asChild active>
        <a href="/orders" data-router-link="">
          Orders
        </a>
      </AppHeaderLink>
    );
    const link = screen.getByRole("link", { name: "Orders" });
    expect(link).toHaveAttribute("href", "/orders");
    expect(link).toHaveAttribute("data-router-link");
    expect(link).toHaveAttribute("aria-current", "page");
  });

  it("asChild renders a child that arrives as a lazy (server) reference", () => {
    render(
      <AppHeaderLink asChild active>
        {lazyChild(<a href="/orders">Orders</a>)}
      </AppHeaderLink>
    );
    expect(screen.getByRole("link", { name: "Orders" })).toHaveAttribute("aria-current", "page");
  });

  it("lets the caller rename the links landmark", () => {
    render(<AppHeaderNav aria-label="Sections">x</AppHeaderNav>);
    expect(screen.getByRole("navigation", { name: "Sections" })).toBeInTheDocument();
  });

  it("has no axe violations", async () => {
    const { container } = render(<Nav />);
    expect(await axe(container)).toHaveNoViolations();
  });
});
