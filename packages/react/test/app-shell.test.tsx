import { act, render, screen, within } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { axe } from "jest-axe";
import { afterEach, describe, expect, it, vi } from "vitest";
import {
  AppContent,
  AppFooter,
  AppHeader,
  AppHeaderActions,
  AppHeaderTitle,
  AppMain,
  AppShell,
  Sidebar,
  SidebarBrand,
  SidebarContent,
  SidebarFooter,
  SidebarGroup,
  SidebarHeader,
  SidebarItem,
  SidebarProvider,
  SidebarSection,
  SidebarSubItem,
  SidebarTrigger
} from "../src";

const Icon = () => <svg aria-hidden data-testid="icon" />;

function Shell(props: React.ComponentProps<typeof SidebarProvider>) {
  return (
    <SidebarProvider {...props}>
      <AppShell>
        <Sidebar>
          <SidebarHeader>
            <SidebarBrand mark="A" name="Aeros" sub="Marketplace" />
          </SidebarHeader>
          <SidebarContent>
            <SidebarSection label="Workspace">
              <SidebarItem href="#home" active icon={<Icon />}>
                Dashboard
              </SidebarItem>
              <SidebarItem href="#inbox" icon={<Icon />} count={3}>
                Inbox
              </SidebarItem>
              <SidebarGroup label="Catalog" icon={<Icon />}>
                <SidebarSubItem href="#products">Products</SidebarSubItem>
                <SidebarSubItem href="#categories">Categories</SidebarSubItem>
              </SidebarGroup>
            </SidebarSection>
          </SidebarContent>
          <SidebarFooter>Footer</SidebarFooter>
        </Sidebar>
        <AppMain>
          <AppHeader>
            <SidebarTrigger />
            <AppHeaderTitle>Dashboard</AppHeaderTitle>
            <AppHeaderActions>
              <button type="button">Account</button>
            </AppHeaderActions>
          </AppHeader>
          <AppContent>Page</AppContent>
          <AppFooter>© Aeros</AppFooter>
        </AppMain>
      </AppShell>
    </SidebarProvider>
  );
}

function mockViewport(mobile: boolean) {
  vi.stubGlobal(
    "matchMedia",
    vi.fn().mockImplementation((query: string) => ({
      matches: mobile,
      media: query,
      addEventListener: vi.fn(),
      removeEventListener: vi.fn()
    }))
  );
}

afterEach(() => {
  vi.unstubAllGlobals();
  window.localStorage.clear();
});

describe("AppShell landmarks", () => {
  it("exposes navigation, banner, main and contentinfo, with one h1", async () => {
    mockViewport(false);
    const { container } = render(<Shell />);
    expect(screen.getByRole("navigation", { name: "Sidebar" })).toBeInTheDocument();
    expect(screen.getByRole("banner")).toBeInTheDocument();
    expect(screen.getByRole("main")).toHaveTextContent("Page");
    expect(screen.getByRole("contentinfo")).toHaveTextContent("© Aeros");
    expect(screen.getAllByRole("heading", { level: 1 })).toHaveLength(1);
    expect(await axe(container)).toHaveNoViolations();
  });
});

describe("Sidebar — rail", () => {
  it("the trigger collapses and expands, and reports aria-expanded", async () => {
    mockViewport(false);
    render(<Shell />);
    const nav = screen.getByRole("navigation", { name: "Sidebar" });
    const trigger = screen.getByRole("button", { name: "Toggle sidebar" });
    expect(trigger).toHaveAttribute("aria-expanded", "true");
    expect(nav).not.toHaveAttribute("data-collapsed");

    await userEvent.click(trigger);
    expect(trigger).toHaveAttribute("aria-expanded", "false");
    expect(nav).toHaveAttribute("data-collapsed");

    await userEvent.click(trigger);
    expect(nav).not.toHaveAttribute("data-collapsed");
  });

  it("collapsed rows keep their accessible names, counts and current page", () => {
    mockViewport(false);
    render(<Shell defaultCollapsed />);
    const nav = screen.getByRole("navigation", { name: "Sidebar" });
    expect(within(nav).getByRole("link", { name: "Dashboard" })).toHaveAttribute("aria-current", "page");
    expect(within(nav).getByRole("link", { name: /Inbox\s*,\s*3/ })).toBeInTheDocument();
    expect(within(nav).getByRole("group", { name: "Workspace" })).toBeInTheDocument();
  });

  it("Cmd/Ctrl+B toggles, and can be turned off", async () => {
    mockViewport(false);
    const { unmount } = render(<Shell />);
    await userEvent.keyboard("{Control>}b{/Control}");
    expect(screen.getByRole("navigation", { name: "Sidebar" })).toHaveAttribute("data-collapsed");
    unmount();

    render(<Shell keyboardShortcut={false} />);
    await userEvent.keyboard("{Control>}b{/Control}");
    expect(screen.getByRole("navigation", { name: "Sidebar" })).not.toHaveAttribute("data-collapsed");
  });

  it("remembers the rail state under storageKey and reports changes", async () => {
    mockViewport(false);
    const onCollapsedChange = vi.fn();
    const { unmount } = render(<Shell storageKey="test.sidebar" onCollapsedChange={onCollapsedChange} />);
    await userEvent.click(screen.getByRole("button", { name: "Toggle sidebar" }));
    expect(onCollapsedChange).toHaveBeenCalledWith(true);
    expect(window.localStorage.getItem("test.sidebar")).toBe("1");
    unmount();

    render(<Shell storageKey="test.sidebar" />);
    expect(screen.getByRole("navigation", { name: "Sidebar" })).toHaveAttribute("data-collapsed");
  });
});

describe("Sidebar — nesting", () => {
  it("a group reveals its children, and starts open when it holds the current page", async () => {
    mockViewport(false);
    render(<Shell />);
    const trigger = screen.getByRole("button", { name: "Catalog" });
    expect(trigger).toHaveAttribute("aria-expanded", "false");
    expect(screen.queryByRole("link", { name: "Products" })).toBeNull();
    await userEvent.click(trigger);
    expect(trigger).toHaveAttribute("aria-expanded", "true");
    expect(screen.getByRole("link", { name: "Products" })).toBeInTheDocument();
  });

  it("an active group is open and marks its current child", () => {
    mockViewport(false);
    render(
      <Sidebar>
        <SidebarGroup label="Catalog" active>
          <SidebarSubItem href="#products" active>
            Products
          </SidebarSubItem>
        </SidebarGroup>
      </Sidebar>
    );
    expect(screen.getByRole("link", { name: "Products" })).toHaveAttribute("aria-current", "page");
  });

  it("in the rail, a group expands the sidebar instead of hiding its children", async () => {
    mockViewport(false);
    render(<Shell defaultCollapsed />);
    await userEvent.click(screen.getByRole("button", { name: "Catalog" }));
    expect(screen.getByRole("navigation", { name: "Sidebar" })).not.toHaveAttribute("data-collapsed");
  });
});

describe("Sidebar — mobile sheet", () => {
  it("is closed until the trigger opens it as a dialog, and closes on choosing a destination", async () => {
    mockViewport(true);
    render(<Shell />);
    await act(async () => {});
    expect(screen.queryByRole("navigation", { name: "Sidebar" })).toBeNull();

    await userEvent.click(screen.getByRole("button", { name: "Toggle sidebar" }));
    const sheet = await screen.findByRole("dialog", { name: "Sidebar" });
    const nav = within(sheet).getByRole("navigation", { name: "Sidebar" });
    expect(nav).toHaveAttribute("data-density", "touch");

    await userEvent.click(within(nav).getByRole("link", { name: /Inbox/ }));
    expect(screen.queryByRole("dialog")).toBeNull();
  });

  it("Escape closes the sheet", async () => {
    mockViewport(true);
    render(<Shell />);
    await act(async () => {});
    await userEvent.click(screen.getByRole("button", { name: "Toggle sidebar" }));
    await screen.findByRole("dialog", { name: "Sidebar" });
    await userEvent.keyboard("{Escape}");
    expect(screen.queryByRole("dialog")).toBeNull();
  });
});

describe("Sidebar without a provider", () => {
  it("renders expanded and static", () => {
    render(
      <Sidebar>
        <SidebarItem href="#a">Alpha</SidebarItem>
      </Sidebar>
    );
    expect(screen.getByRole("navigation", { name: "Sidebar" })).not.toHaveAttribute("data-collapsed");
    expect(screen.getByRole("link", { name: "Alpha" })).toBeInTheDocument();
  });
});
