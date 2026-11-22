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
  SidebarMenuButton,
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

/** A matchMedia that answers the sidebar's own queries for a given window width. */
function mockWidth(width: number) {
  vi.stubGlobal(
    "matchMedia",
    vi.fn().mockImplementation((query: string) => {
      const min = /min-width:\s*(\d+)px/.exec(query);
      const max = /max-width:\s*(\d+)px/.exec(query);
      return {
        matches: (!min || width >= Number(min[1])) && (!max || width <= Number(max[1])),
        media: query,
        addEventListener: vi.fn(),
        removeEventListener: vi.fn()
      };
    })
  );
}

afterEach(() => {
  vi.unstubAllGlobals();
  window.localStorage.clear();
  document.cookie = "test.sidebar=; path=/; max-age=0";
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

  it("in the rail, a group opens its children in a menu and the sidebar stays collapsed", async () => {
    mockViewport(false);
    render(<Shell defaultCollapsed />);
    await userEvent.click(screen.getByRole("button", { name: "Catalog" }));
    const menu = await screen.findByRole("menu");
    expect(within(menu).getByRole("menuitem", { name: "Products" })).toHaveAttribute("href", "#products");
    expect(within(menu).getByRole("menuitem", { name: "Categories" })).toBeInTheDocument();
    expect(screen.getByRole("navigation", { name: "Sidebar", hidden: true })).toHaveAttribute("data-collapsed");
  });

  it("a group can hold a further group", async () => {
    mockViewport(false);
    render(
      <Sidebar>
        <SidebarGroup label="Master" defaultOpen>
          <SidebarGroup label="Locations" defaultOpen>
            <SidebarSubItem href="#countries">Countries</SidebarSubItem>
          </SidebarGroup>
          <SidebarSubItem href="#units">Units</SidebarSubItem>
        </SidebarGroup>
      </Sidebar>
    );
    expect(screen.getByRole("button", { name: "Locations" })).toHaveAttribute("aria-expanded", "true");
    expect(screen.getByRole("link", { name: "Countries" })).toBeInTheDocument();
    expect(screen.getByRole("link", { name: "Units" })).toBeInTheDocument();
  });
});

describe("Sidebar — remembered state and shortcut", () => {
  it("writes a cookie of the same name, so a server render can start in the right state", async () => {
    mockViewport(false);
    render(<Shell storageKey="test.sidebar" />);
    await userEvent.click(screen.getByRole("button", { name: "Toggle sidebar" }));
    expect(document.cookie).toContain("test.sidebar=1");
    await userEvent.click(screen.getByRole("button", { name: "Toggle sidebar" }));
    expect(document.cookie).toContain("test.sidebar=0");
  });

  it("Cmd/Ctrl+B is left alone while typing in a field", async () => {
    mockViewport(false);
    render(
      <>
        <Shell />
        <input aria-label="Note" />
      </>
    );
    await userEvent.click(screen.getByRole("textbox", { name: "Note" }));
    await userEvent.keyboard("{Control>}b{/Control}");
    expect(screen.getByRole("navigation", { name: "Sidebar" })).not.toHaveAttribute("data-collapsed");
  });

  it("the trigger points at the sidebar it controls", () => {
    mockViewport(false);
    render(<Shell />);
    const nav = screen.getByRole("navigation", { name: "Sidebar" });
    expect(nav.id).not.toBe("");
    expect(screen.getByRole("button", { name: "Toggle sidebar" })).toHaveAttribute("aria-controls", nav.id);
  });
});

describe("Sidebar — between md and lg", () => {
  it("starts as a rail whatever the remembered choice, and the trigger floats it open without saving", async () => {
    mockWidth(820);
    render(<Shell storageKey="test.sidebar" />);
    await act(async () => {});
    const nav = screen.getByRole("navigation", { name: "Sidebar" });
    const trigger = screen.getByRole("button", { name: "Toggle sidebar" });
    expect(nav).toHaveAttribute("data-collapsed");
    expect(trigger).toHaveAttribute("aria-expanded", "false");

    await userEvent.click(trigger);
    expect(nav).not.toHaveAttribute("data-collapsed");
    expect(nav).toHaveAttribute("data-floating");
    expect(trigger).toHaveAttribute("aria-expanded", "true");
    expect(window.localStorage.getItem("test.sidebar")).toBeNull();
  });

  it("the floating sidebar closes on Escape, on a press outside, and on choosing a destination", async () => {
    mockWidth(820);
    render(<Shell />);
    await act(async () => {});
    const nav = screen.getByRole("navigation", { name: "Sidebar" });
    const trigger = screen.getByRole("button", { name: "Toggle sidebar" });

    await userEvent.click(trigger);
    await userEvent.keyboard("{Escape}");
    expect(nav).not.toHaveAttribute("data-floating");

    await userEvent.click(trigger);
    await userEvent.click(screen.getByRole("main"));
    expect(nav).not.toHaveAttribute("data-floating");

    await userEvent.click(trigger);
    expect(nav).toHaveAttribute("data-floating");
    await userEvent.click(within(nav).getByRole("link", { name: /Inbox/ }));
    expect(nav).not.toHaveAttribute("data-floating");
  });

  it("at lg and up the same window is expanded", async () => {
    mockWidth(1280);
    render(<Shell />);
    await act(async () => {});
    expect(screen.getByRole("navigation", { name: "Sidebar" })).not.toHaveAttribute("data-collapsed");
  });
});

describe("Sidebar — counts and menu buttons", () => {
  it("a count is quiet text by default and a solid pill on request, announced the same way", () => {
    render(
      <Sidebar>
        <SidebarItem href="#a" count={128}>
          Orders
        </SidebarItem>
        <SidebarItem href="#b" count={4} countTone="solid">
          Messages
        </SidebarItem>
      </Sidebar>
    );
    expect(screen.getByRole("link", { name: /^Orders\s*,\s*99\+$/ })).toBeInTheDocument();
    expect(screen.getByRole("link", { name: /^Messages\s*,\s*4$/ })).toBeInTheDocument();
  });

  it("SidebarMenuButton is a button named by its name and sub line, and forwards props", async () => {
    const onClick = vi.fn();
    render(
      <Sidebar>
        <SidebarFooter>
          <SidebarMenuButton leading={<span>MS</span>} name="Meera Shah" sub="meera@example.com" onClick={onClick} aria-haspopup="menu" />
        </SidebarFooter>
      </Sidebar>
    );
    const button = screen.getByRole("button", { name: /Meera Shah/ });
    expect(button).toHaveAttribute("aria-haspopup", "menu");
    expect(button).toHaveTextContent("meera@example.com");
    await userEvent.click(button);
    expect(onClick).toHaveBeenCalledTimes(1);
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

  it("has a visible close button", async () => {
    mockViewport(true);
    render(<Shell />);
    await act(async () => {});
    await userEvent.click(screen.getByRole("button", { name: "Toggle sidebar" }));
    const sheet = await screen.findByRole("dialog", { name: "Sidebar" });
    await userEvent.click(within(sheet).getByRole("button", { name: "Close sidebar" }));
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
