import * as React from "react";
import { describe, expect, it, vi } from "vitest";
import { render, screen, waitFor, within } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { axe } from "jest-axe";
import {
  Button,
  Calendar,
  Command,
  CommandEmpty,
  CommandGroup,
  CommandInput,
  CommandItem,
  CommandList,
  CommandSeparator,
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuGroup,
  DropdownMenuItem,
  DropdownMenuLabel,
  DropdownMenuSeparator,
  DropdownMenuTrigger
} from "../src";

// Behaviour + semantics only. No class-name or pixel assertions.

function RowMenu({
  onEdit = () => {},
  onArchive = () => {},
  onDelete = () => {}
}: {
  onEdit?: (e: Event) => void;
  onArchive?: (e: Event) => void;
  onDelete?: (e: Event) => void;
}) {
  return (
    <DropdownMenu>
      <DropdownMenuTrigger asChild>
        <Button variant="secondary">Actions</Button>
      </DropdownMenuTrigger>
      <DropdownMenuContent>
        <DropdownMenuGroup>
          <DropdownMenuLabel>Order</DropdownMenuLabel>
          <DropdownMenuItem onSelect={onEdit}>Edit</DropdownMenuItem>
          <DropdownMenuItem disabled onSelect={onArchive}>
            Archive
          </DropdownMenuItem>
        </DropdownMenuGroup>
        <DropdownMenuSeparator />
        <DropdownMenuItem destructive onSelect={onDelete}>
          Delete
        </DropdownMenuItem>
      </DropdownMenuContent>
    </DropdownMenu>
  );
}

describe("DropdownMenu", () => {
  it("is closed until its trigger is activated, then exposes a menu of menuitems", async () => {
    const user = userEvent.setup();
    render(<RowMenu />);
    const trigger = screen.getByRole("button", { name: "Actions" });
    expect(trigger).toHaveAttribute("aria-haspopup", "menu");
    expect(trigger).toHaveAttribute("aria-expanded", "false");
    expect(screen.queryByRole("menu")).not.toBeInTheDocument();

    await user.click(trigger);
    expect(trigger).toHaveAttribute("aria-expanded", "true");
    const menu = screen.getByRole("menu");
    expect(within(menu).getAllByRole("menuitem").map((i) => i.textContent)).toEqual([
      "Edit",
      "Archive",
      "Delete"
    ]);
    expect(within(menu).getByRole("separator")).toBeInTheDocument();
    expect(within(menu).getByRole("group")).toBeInTheDocument();
  });

  it("fires onSelect and closes when an item is clicked", async () => {
    const user = userEvent.setup();
    const onEdit = vi.fn();
    render(<RowMenu onEdit={onEdit} />);
    await user.click(screen.getByRole("button", { name: "Actions" }));
    await user.click(screen.getByRole("menuitem", { name: "Edit" }));
    expect(onEdit).toHaveBeenCalledTimes(1);
    expect(screen.queryByRole("menu")).not.toBeInTheDocument();
  });

  it("a destructive item is still an ordinary, selectable menuitem", async () => {
    const user = userEvent.setup();
    const onDelete = vi.fn();
    render(<RowMenu onDelete={onDelete} />);
    await user.click(screen.getByRole("button", { name: "Actions" }));
    const del = screen.getByRole("menuitem", { name: "Delete" });
    expect(del).not.toHaveAttribute("aria-disabled");
    // `destructive` is a styling prop: it must not leak onto the DOM.
    expect(del).not.toHaveAttribute("destructive");
    await user.click(del);
    expect(onDelete).toHaveBeenCalledTimes(1);
    expect(screen.queryByRole("menu")).not.toBeInTheDocument();
  });

  it("a disabled item is announced as disabled and cannot be selected", async () => {
    const user = userEvent.setup();
    const onArchive = vi.fn();
    render(<RowMenu onArchive={onArchive} />);
    await user.click(screen.getByRole("button", { name: "Actions" }));
    const archive = screen.getByRole("menuitem", { name: "Archive" });
    expect(archive).toHaveAttribute("aria-disabled", "true");
    await user.click(archive);
    expect(onArchive).not.toHaveBeenCalled();
    expect(screen.getByRole("menu")).toBeInTheDocument();
  });

  it("opens from the keyboard, roves with arrows past disabled items, and selects with Enter", async () => {
    const user = userEvent.setup();
    const onEdit = vi.fn();
    const onArchive = vi.fn();
    const onDelete = vi.fn();
    render(<RowMenu onEdit={onEdit} onArchive={onArchive} onDelete={onDelete} />);
    const trigger = screen.getByRole("button", { name: "Actions" });

    await user.tab();
    expect(trigger).toHaveFocus();
    await user.keyboard("{Enter}");
    expect(await screen.findByRole("menu")).toBeInTheDocument();
    expect(screen.getByRole("menuitem", { name: "Edit" })).toHaveFocus();

    await user.keyboard("{ArrowDown}");
    expect(screen.getByRole("menuitem", { name: "Delete" })).toHaveFocus();
    await user.keyboard("{ArrowUp}");
    expect(screen.getByRole("menuitem", { name: "Edit" })).toHaveFocus();
    await user.keyboard("{End}");
    expect(screen.getByRole("menuitem", { name: "Delete" })).toHaveFocus();

    await user.keyboard("{Enter}");
    expect(onDelete).toHaveBeenCalledTimes(1);
    expect(onEdit).not.toHaveBeenCalled();
    expect(onArchive).not.toHaveBeenCalled();
    expect(screen.queryByRole("menu")).not.toBeInTheDocument();
    expect(trigger).toHaveFocus();
  });

  it("closes on Escape and returns focus to the trigger", async () => {
    const user = userEvent.setup();
    const onEdit = vi.fn();
    render(<RowMenu onEdit={onEdit} />);
    const trigger = screen.getByRole("button", { name: "Actions" });
    await user.click(trigger);
    expect(screen.getByRole("menu")).toBeInTheDocument();
    await user.keyboard("{Escape}");
    expect(screen.queryByRole("menu")).not.toBeInTheDocument();
    expect(onEdit).not.toHaveBeenCalled();
    expect(trigger).toHaveFocus();
  });

  it("an item can keep the menu open by preventing the select default", async () => {
    const user = userEvent.setup();
    render(<RowMenu onEdit={(e) => e.preventDefault()} />);
    await user.click(screen.getByRole("button", { name: "Actions" }));
    await user.click(screen.getByRole("menuitem", { name: "Edit" }));
    expect(screen.getByRole("menu")).toBeInTheDocument();
  });

  it("the open menu has no axe violations", async () => {
    const user = userEvent.setup();
    const { container } = render(<RowMenu />);
    expect(await axe(container)).toHaveNoViolations();
    await user.click(screen.getByRole("button", { name: "Actions" }));
    expect(await axe(screen.getByRole("menu"))).toHaveNoViolations();
  });
});

function Palette({
  onSelect = () => {},
  disabledItem = false,
  separator = true
}: {
  onSelect?: (value: string) => void;
  disabledItem?: boolean;
  separator?: boolean;
}) {
  return (
    <Command label="Command menu">
      <CommandInput placeholder="Search" />
      <CommandList>
        <CommandEmpty>No results.</CommandEmpty>
        <CommandGroup heading="Orders">
          <CommandItem onSelect={onSelect}>Create order</CommandItem>
          <CommandItem onSelect={onSelect} disabled={disabledItem}>
            Export orders
          </CommandItem>
        </CommandGroup>
        {separator && <CommandSeparator />}
        <CommandGroup heading="Catalog">
          <CommandItem onSelect={onSelect}>Add product</CommandItem>
        </CommandGroup>
      </CommandList>
    </Command>
  );
}

describe("Command", () => {
  it("wires a combobox input to a listbox of options", () => {
    render(<Palette />);
    const input = screen.getByRole("combobox", { name: "Command menu" });
    const list = screen.getByRole("listbox");
    expect(input).toHaveAttribute("aria-expanded", "true");
    expect(input).toHaveAttribute("aria-controls", list.id);
    expect(input).toHaveAttribute("placeholder", "Search");
    expect(within(list).getAllByRole("option").map((o) => o.textContent)).toEqual([
      "Create order",
      "Export orders",
      "Add product"
    ]);
    expect(screen.queryByText("No results.")).not.toBeInTheDocument();
  });

  it("filters items as the user types and restores them when cleared", async () => {
    const user = userEvent.setup();
    render(<Palette />);
    const input = screen.getByRole("combobox", { name: "Command menu" });

    await user.type(input, "product");
    expect(screen.getAllByRole("option").map((o) => o.textContent)).toEqual(["Add product"]);
    expect(screen.queryByText("No results.")).not.toBeInTheDocument();

    await user.clear(input);
    expect(screen.getAllByRole("option")).toHaveLength(3);
  });

  it("shows the Empty slot when nothing matches", async () => {
    const user = userEvent.setup();
    render(<Palette />);
    await user.type(screen.getByRole("combobox", { name: "Command menu" }), "zzzz");
    expect(screen.queryAllByRole("option")).toHaveLength(0);
    expect(screen.getByText("No results.")).toBeInTheDocument();
  });

  it("selects the active item with Enter", async () => {
    const user = userEvent.setup();
    const onSelect = vi.fn();
    render(<Palette onSelect={onSelect} />);
    const input = screen.getByRole("combobox", { name: "Command menu" });

    await user.type(input, "export");
    expect(screen.getByRole("option", { name: "Export orders" })).toHaveAttribute("aria-selected", "true");

    await user.keyboard("{Enter}");
    expect(onSelect).toHaveBeenCalledExactlyOnceWith("Export orders");
  });

  // cmdk 1.1.1 itself stores the active id one step late; CommandInput keeps
  // the attribute in step with the option that is marked selected.
  it("aria-activedescendant names the active option after filtering", async () => {
    const user = userEvent.setup();
    render(<Palette />);
    const input = screen.getByRole("combobox", { name: "Command menu" });
    await user.type(input, "export");
    const active = screen.getByRole("option", { name: "Export orders" });
    expect(active).toHaveAttribute("aria-selected", "true");
    await waitFor(() => expect(input).toHaveAttribute("aria-activedescendant", active.id), { timeout: 300 });
  });

  it("aria-activedescendant follows the active option from first render, through arrows, to no match", async () => {
    const user = userEvent.setup();
    render(<Palette />);
    const input = screen.getByRole("combobox", { name: "Command menu" });
    const activeId = () => screen.getByRole("option", { selected: true }).id;
    await waitFor(() => expect(input).toHaveAttribute("aria-activedescendant", activeId()));
    expect(screen.getByRole("option", { selected: true })).toHaveTextContent("Create order");

    await user.click(input);
    await user.keyboard("{ArrowDown}");
    await waitFor(() => expect(input).toHaveAttribute("aria-activedescendant", activeId()));
    expect(screen.getByRole("option", { selected: true })).toHaveTextContent("Export orders");

    // Nothing matches: the attribute must not keep naming a removed option.
    await user.type(input, "zzzz");
    await waitFor(() => expect(input).not.toHaveAttribute("aria-activedescendant"));
  });

  it("moves the active option with arrow keys while focus stays in the input", async () => {
    const user = userEvent.setup();
    const onSelect = vi.fn();
    render(<Palette onSelect={onSelect} />);
    const input = screen.getByRole("combobox", { name: "Command menu" });
    await user.click(input);
    expect(screen.getByRole("option", { name: "Create order" })).toHaveAttribute("aria-selected", "true");

    await user.keyboard("{ArrowDown}{ArrowDown}");
    expect(input).toHaveFocus();
    expect(screen.getByRole("option", { name: "Add product" })).toHaveAttribute("aria-selected", "true");
    expect(screen.getAllByRole("option", { selected: true })).toHaveLength(1);

    await user.keyboard("{ArrowUp}{Enter}");
    expect(onSelect).toHaveBeenCalledExactlyOnceWith("Export orders");
  });

  it("selects on click", async () => {
    const user = userEvent.setup();
    const onSelect = vi.fn();
    render(<Palette onSelect={onSelect} />);
    await user.click(screen.getByRole("option", { name: "Add product" }));
    expect(onSelect).toHaveBeenCalledExactlyOnceWith("Add product");
  });

  it("a disabled item is announced as disabled and skipped by keyboard and click", async () => {
    const user = userEvent.setup();
    const onSelect = vi.fn();
    render(<Palette onSelect={onSelect} disabledItem />);
    const disabled = screen.getByRole("option", { name: "Export orders" });
    expect(disabled).toHaveAttribute("aria-disabled", "true");

    await user.click(disabled);
    expect(onSelect).not.toHaveBeenCalled();

    await user.click(screen.getByRole("combobox", { name: "Command menu" }));
    await user.keyboard("{ArrowDown}{Enter}");
    expect(onSelect).toHaveBeenCalledExactlyOnceWith("Add product");
  });

  it("names each group from its heading", () => {
    render(<Palette />);
    expect(within(screen.getByRole("group", { name: "Orders" })).getAllByRole("option")).toHaveLength(2);
    expect(within(screen.getByRole("group", { name: "Catalog" })).getAllByRole("option")).toHaveLength(1);
  });

  // The rule between groups is decoration: the groups are already named, and a
  // listbox may only own options and groups, so it must not be a `separator`.
  it("the separator between groups is decorative and is dropped while searching", async () => {
    const user = userEvent.setup();
    const { container } = render(<Palette />);
    const list = screen.getByRole("listbox");
    const rule = () => container.querySelector("[cmdk-separator]");
    expect(list).toContainElement(rule() as HTMLElement);
    expect(within(list).queryByRole("separator")).not.toBeInTheDocument();
    await user.type(screen.getByRole("combobox", { name: "Command menu" }), "o");
    expect(rule()).toBeNull();
  });

  it("has no axe violations when populated", async () => {
    const { container } = render(<Palette separator={false} />);
    expect(await axe(container)).toHaveNoViolations();
  });

  it("has no axe violations in the empty state", async () => {
    const user = userEvent.setup();
    const { container } = render(<Palette separator={false} />);
    await user.type(screen.getByRole("combobox", { name: "Command menu" }), "zzzz");
    expect(screen.getByText("No results.")).toBeInTheDocument();
    expect(await axe(container)).toHaveNoViolations();
  });

  it("the empty message is announced from a live region outside the listbox", async () => {
    const user = userEvent.setup();
    const { container } = render(<Palette />);
    const status = container.querySelector<HTMLElement>("[cmdk-empty-slot]")!;
    expect(status).toHaveAttribute("aria-live", "polite");
    expect(status).toBeEmptyDOMElement();
    await user.type(screen.getByRole("combobox", { name: "Command menu" }), "zzzz");
    expect(status).toHaveTextContent("No results.");
    expect(screen.getByRole("listbox")).not.toContainElement(screen.getByText("No results."));
  });

  it("the empty message is never put in the live region while the options are still mounting", () => {
    const seen: string[] = [];
    const observer = new MutationObserver((records) => {
      for (const record of records) for (const node of record.addedNodes) seen.push(node.textContent ?? "");
    });
    observer.observe(document.body, { subtree: true, childList: true });
    render(<Palette />);
    seen.push(...observer.takeRecords().flatMap((r) => Array.from(r.addedNodes, (n) => n.textContent ?? "")));
    observer.disconnect();
    expect(seen.filter((text) => text === "No results.")).toEqual([]);
  });

  it("a list with a CommandSeparator has no axe violations", async () => {
    const { container } = render(<Palette />);
    expect(await axe(container)).toHaveNoViolations();
  });
});

// Local-time dates so the grid is identical in every timezone.
const JAN_2026 = new Date(2026, 0, 1);
const TODAY = new Date(2026, 0, 10);
const day = (name: RegExp) => screen.getByRole("button", { name });

describe("Calendar", () => {
  it("renders the requested month as a labelled grid, independent of the real date", () => {
    render(<Calendar mode="single" month={JAN_2026} today={TODAY} />);
    const grid = screen.getByRole("grid", { name: "January 2026" });
    // react-day-picker hides the weekday header row from assistive tech (each
    // day button's label already carries its weekday), so query hidden nodes.
    expect(within(grid).getAllByRole("columnheader", { hidden: true }).map((h) => h.textContent)).toEqual([
      "Su",
      "Mo",
      "Tu",
      "We",
      "Th",
      "Fr",
      "Sa"
    ]);
    // January 2026 starts on a Thursday and spans 5 Sunday-first weeks.
    expect(within(grid).getAllByRole("gridcell")).toHaveLength(35);
    expect(day(/^1, \w+, January 2026/)).toBeInTheDocument();
    expect(day(/^31, \w+, January 2026/)).toBeInTheDocument();
    expect(day(/^10, Saturday, January 2026, today$/)).toBeInTheDocument();
  });

  it("shows outside days by default and hides them with showOutsideDays=false", () => {
    const { rerender } = render(<Calendar mode="single" month={JAN_2026} today={TODAY} />);
    expect(day(/^28, \w+, December 2025/)).toBeInTheDocument();
    rerender(<Calendar mode="single" month={JAN_2026} today={TODAY} showOutsideDays={false} />);
    expect(screen.queryByRole("button", { name: /^28, \w+, December 2025/ })).not.toBeInTheDocument();
  });

  it("calls onSelect with the clicked day", async () => {
    const user = userEvent.setup();
    const onSelect = vi.fn();
    render(<Calendar mode="single" month={JAN_2026} today={TODAY} onSelect={onSelect} />);
    await user.click(day(/^15, \w+, January 2026/));
    expect(onSelect).toHaveBeenCalledTimes(1);
    const selected = onSelect.mock.calls[0][0] as Date;
    expect([selected.getFullYear(), selected.getMonth(), selected.getDate()]).toEqual([2026, 0, 15]);
  });

  it("marks the selected day for assistive tech", () => {
    render(<Calendar mode="single" month={JAN_2026} today={TODAY} selected={new Date(2026, 0, 15)} />);
    const selectedCells = screen.getAllByRole("gridcell", { selected: true });
    expect(selectedCells).toHaveLength(1);
    expect(within(selectedCells[0]).getByRole("button")).toHaveAccessibleName(
      "15, Thursday, January 2026, selected"
    );
  });

  it("clicking the selected day clears it unless `required`", async () => {
    const user = userEvent.setup();
    const onSelect = vi.fn();
    const selected = new Date(2026, 0, 15);
    const { rerender } = render(
      <Calendar mode="single" month={JAN_2026} today={TODAY} selected={selected} onSelect={onSelect} />
    );
    await user.click(day(/^15, \w+, January 2026/));
    expect(onSelect.mock.calls[0][0]).toBeUndefined();

    onSelect.mockClear();
    rerender(
      <Calendar mode="single" required month={JAN_2026} today={TODAY} selected={selected} onSelect={onSelect} />
    );
    await user.click(day(/^15, \w+, January 2026/));
    expect(onSelect.mock.calls[0][0]).toEqual(selected);
  });

  it("moves focus between days with the arrow keys", async () => {
    const user = userEvent.setup();
    render(<Calendar mode="single" month={JAN_2026} today={TODAY} />);
    const start = day(/^15, \w+, January 2026/);
    start.focus();

    await user.keyboard("{ArrowRight}");
    expect(day(/^16, \w+, January 2026/)).toHaveFocus();
    await user.keyboard("{ArrowDown}");
    expect(day(/^23, \w+, January 2026/)).toHaveFocus();
    await user.keyboard("{ArrowLeft}");
    expect(day(/^22, \w+, January 2026/)).toHaveFocus();
    await user.keyboard("{ArrowUp}");
    expect(start).toHaveFocus();
    await user.keyboard("{Home}");
    expect(day(/^11, \w+, January 2026/)).toHaveFocus();
    await user.keyboard("{End}");
    expect(day(/^17, \w+, January 2026/)).toHaveFocus();
  });

  it("selects the focused day with Enter and with Space", async () => {
    const user = userEvent.setup();
    const onSelect = vi.fn();
    render(<Calendar mode="single" month={JAN_2026} today={TODAY} onSelect={onSelect} />);
    day(/^15, \w+, January 2026/).focus();
    await user.keyboard("{ArrowRight}{Enter}");
    expect((onSelect.mock.calls[0][0] as Date).getDate()).toBe(16);
    await user.keyboard("{ArrowRight} ");
    expect((onSelect.mock.calls[1][0] as Date).getDate()).toBe(17);
  });

  it("has a single tab stop inside the day grid", () => {
    render(<Calendar mode="single" month={JAN_2026} today={TODAY} />);
    const tabbable = within(screen.getByRole("grid"))
      .getAllByRole("button")
      .filter((b) => b.getAttribute("tabindex") === "0");
    expect(tabbable).toHaveLength(1);
    expect(tabbable[0]).toHaveAccessibleName(/^10, \w+, January 2026/);
  });

  it("navigates months with the previous/next buttons and arrow keys across the month edge", async () => {
    const user = userEvent.setup();
    const onMonthChange = vi.fn();
    render(<Calendar mode="single" defaultMonth={JAN_2026} today={TODAY} onMonthChange={onMonthChange} />);

    await user.click(screen.getByRole("button", { name: "Go to the Next Month" }));
    expect(screen.getByRole("grid", { name: "February 2026" })).toBeInTheDocument();
    await user.click(screen.getByRole("button", { name: "Go to the Previous Month" }));
    await user.click(screen.getByRole("button", { name: "Go to the Previous Month" }));
    expect(screen.getByRole("grid", { name: "December 2025" })).toBeInTheDocument();
    expect(onMonthChange).toHaveBeenCalledTimes(3);

    day(/^31, \w+, December 2025/).focus();
    await user.keyboard("{ArrowRight}");
    expect(screen.getByRole("grid", { name: "January 2026" })).toBeInTheDocument();
    expect(day(/^1, \w+, January 2026/)).toHaveFocus();
  });

  it("disabled days cannot be selected", async () => {
    const user = userEvent.setup();
    const onSelect = vi.fn();
    render(
      <Calendar
        mode="single"
        month={JAN_2026}
        today={TODAY}
        disabled={{ before: new Date(2026, 0, 10) }}
        onSelect={onSelect}
      />
    );
    const past = day(/^5, \w+, January 2026/);
    expect(past).toBeDisabled();
    await user.click(past);
    expect(onSelect).not.toHaveBeenCalled();
    await user.click(day(/^12, \w+, January 2026/));
    expect(onSelect).toHaveBeenCalledTimes(1);
  });

  it("range mode reports from/to and announces a multi-selectable grid", async () => {
    const user = userEvent.setup();
    const onSelect = vi.fn();
    function Range() {
      const [range, setRange] = React.useState<{ from?: Date; to?: Date } | undefined>();
      return (
        <Calendar
          mode="range"
          month={JAN_2026}
          today={TODAY}
          selected={range as never}
          onSelect={(r: { from?: Date; to?: Date } | undefined) => {
            onSelect(r);
            setRange(r);
          }}
        />
      );
    }
    render(<Range />);
    expect(screen.getByRole("grid", { name: "January 2026" })).toHaveAttribute("aria-multiselectable", "true");
    await user.click(day(/^12, \w+, January 2026/));
    await user.click(day(/^14, \w+, January 2026/));
    const last = onSelect.mock.calls.at(-1)?.[0] as { from: Date; to: Date };
    expect([last.from.getDate(), last.to.getDate()]).toEqual([12, 14]);
    expect(screen.getAllByRole("gridcell", { selected: true })).toHaveLength(3);
  });

  it("has no axe violations", async () => {
    const { container } = render(
      <Calendar mode="single" month={JAN_2026} today={TODAY} selected={new Date(2026, 0, 15)} />
    );
    expect(await axe(container)).toHaveNoViolations();
  });
});
