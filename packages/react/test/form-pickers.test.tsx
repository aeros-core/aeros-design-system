import * as React from "react";
import { describe, expect, it, vi } from "vitest";
import { render, screen, within } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { axe } from "jest-axe";
import { Combobox, MultiCombobox, type ComboboxOption } from "../src/components/combobox";
import { DatePicker, DateRangePicker, formatDisplayDate, toISODate } from "../src/components/date-picker";
import { Field } from "../src/components/input";
import { NumberInput } from "../src/components/number-input";

// Behaviour + semantics only. No class-name or pixel assertions.

const regions: ComboboxOption[] = [
  { value: "west", label: "West", group: "India" },
  { value: "south", label: "South", group: "India" },
  { value: "north", label: "North", group: "India", disabled: true },
  { value: "export", label: "Export", description: "Outside the country" }
];

const hidden = (container: HTMLElement, name: string) =>
  Array.from(container.querySelectorAll<HTMLInputElement>(`input[type="hidden"][name="${name}"]`)).map(
    (input) => input.value
  );

// ── Combobox ──────────────────────────────────────────────

describe("Combobox", () => {
  it("is a collapsed combobox showing its placeholder until a value is chosen", () => {
    render(<Combobox aria-label="Region" options={regions} placeholder="Pick a region" />);
    const trigger = screen.getByRole("combobox", { name: "Region" });
    expect(trigger).toHaveAttribute("aria-expanded", "false");
    expect(trigger).toHaveTextContent("Pick a region");
    expect(screen.queryByRole("listbox")).not.toBeInTheDocument();
  });

  it("opens on click, lists grouped options and moves focus to the search box", async () => {
    const user = userEvent.setup();
    render(<Combobox aria-label="Region" options={regions} searchPlaceholder="Search regions" />);
    const trigger = screen.getByRole("combobox", { name: "Region" });

    await user.click(trigger);
    expect(trigger).toHaveAttribute("aria-expanded", "true");
    const popup = document.getElementById(trigger.getAttribute("aria-controls")!);
    expect(popup).toBeInTheDocument();
    const listbox = within(popup!).getByRole("listbox");
    expect(within(listbox).getAllByRole("option").map((o) => o.textContent)).toEqual([
      "West",
      "South",
      "North",
      "ExportOutside the country"
    ]);
    expect(within(listbox).getByRole("group", { name: "India" })).toBeInTheDocument();
    expect(screen.getByPlaceholderText("Search regions")).toHaveFocus();
  });

  it("opens with the arrow keys", async () => {
    const user = userEvent.setup();
    render(<Combobox aria-label="Region" options={regions} />);
    screen.getByRole("combobox", { name: "Region" }).focus();
    await user.keyboard("{ArrowDown}");
    expect(screen.getByRole("listbox")).toBeInTheDocument();
  });

  it("filters the list as the user types, matching label and description", async () => {
    const user = userEvent.setup();
    render(<Combobox aria-label="Region" options={regions} />);
    await user.click(screen.getByRole("combobox", { name: "Region" }));

    await user.keyboard("sou");
    expect(screen.getAllByRole("option").map((o) => o.textContent)).toEqual(["South"]);

    await user.clear(screen.getByPlaceholderText("Search…"));
    await user.keyboard("country");
    expect(screen.getAllByRole("option")).toHaveLength(1);
    expect(screen.getByRole("option", { name: /Export/ })).toBeInTheDocument();
  });

  it("selects on click, closes, shows the choice and returns focus to the trigger", async () => {
    const user = userEvent.setup();
    const onValueChange = vi.fn();
    render(<Combobox aria-label="Region" options={regions} placeholder="Pick a region" onValueChange={onValueChange} />);
    const trigger = screen.getByRole("combobox", { name: "Region" });

    await user.click(trigger);
    await user.click(screen.getByRole("option", { name: "South" }));
    expect(onValueChange).toHaveBeenCalledExactlyOnceWith("south");
    expect(screen.queryByRole("listbox")).not.toBeInTheDocument();
    expect(trigger).toHaveAttribute("aria-expanded", "false");
    expect(trigger).toHaveTextContent("South");
    expect(trigger).toHaveFocus();
  });

  it("selects the filtered match with Enter", async () => {
    const user = userEvent.setup();
    const onValueChange = vi.fn();
    render(<Combobox aria-label="Region" options={regions} onValueChange={onValueChange} />);
    const trigger = screen.getByRole("combobox", { name: "Region" });

    await user.click(trigger);
    await user.keyboard("exp{Enter}");
    expect(onValueChange).toHaveBeenCalledExactlyOnceWith("export");
    expect(screen.queryByRole("listbox")).not.toBeInTheDocument();
    expect(trigger).toHaveTextContent("Export");
  });

  it("moves through options with the arrow keys and skips disabled ones", async () => {
    const user = userEvent.setup();
    const onValueChange = vi.fn();
    render(<Combobox aria-label="Region" options={regions} onValueChange={onValueChange} />);
    await user.click(screen.getByRole("combobox", { name: "Region" }));
    // West → South → (North is disabled) → Export
    await user.keyboard("{ArrowDown}{ArrowDown}{Enter}");
    expect(onValueChange).toHaveBeenCalledExactlyOnceWith("export");
  });

  it("marks the selected option when reopened", async () => {
    const user = userEvent.setup();
    render(<Combobox aria-label="Region" options={regions} defaultValue="south" />);
    await user.click(screen.getByRole("combobox", { name: "Region" }));
    expect(screen.getByRole("option", { name: "South" })).toHaveAttribute("aria-checked", "true");
    expect(screen.getByRole("option", { name: "West" })).toHaveAttribute("aria-checked", "false");
  });

  it("clears the value with the clear button", async () => {
    const user = userEvent.setup();
    const onValueChange = vi.fn();
    render(
      <Combobox
        aria-label="Region"
        options={regions}
        defaultValue="west"
        clearable
        placeholder="Pick a region"
        onValueChange={onValueChange}
      />
    );
    const trigger = screen.getByRole("combobox", { name: "Region" });
    expect(trigger).toHaveTextContent("West");

    await user.click(screen.getByRole("button", { name: "Clear selection" }));
    expect(onValueChange).toHaveBeenCalledExactlyOnceWith(null);
    expect(trigger).toHaveTextContent("Pick a region");
    expect(screen.queryByRole("button", { name: "Clear selection" })).not.toBeInTheDocument();
    expect(screen.queryByRole("listbox")).not.toBeInTheDocument();
    expect(trigger).toHaveFocus();
  });

  it("offers no clear button unless clearable", () => {
    render(<Combobox aria-label="Region" options={regions} defaultValue="west" />);
    expect(screen.queryByRole("button", { name: "Clear selection" })).not.toBeInTheDocument();
  });

  it("does not select a disabled option", async () => {
    const user = userEvent.setup();
    const onValueChange = vi.fn();
    render(<Combobox aria-label="Region" options={regions} onValueChange={onValueChange} />);
    await user.click(screen.getByRole("combobox", { name: "Region" }));
    const north = screen.getByRole("option", { name: "North" });
    expect(north).toHaveAttribute("aria-disabled", "true");

    await user.click(north);
    expect(onValueChange).not.toHaveBeenCalled();
    expect(screen.getByRole("listbox")).toBeInTheDocument();
  });

  it("shows the empty text when nothing matches", async () => {
    const user = userEvent.setup();
    render(<Combobox aria-label="Region" options={regions} emptyText="No region found." />);
    await user.click(screen.getByRole("combobox", { name: "Region" }));
    await user.keyboard("zzz");
    expect(screen.queryAllByRole("option")).toHaveLength(0);
    expect(screen.getByText("No region found.")).toBeInTheDocument();
  });

  it("closes on Escape without changing the value and returns focus to the trigger", async () => {
    const user = userEvent.setup();
    const onValueChange = vi.fn();
    render(<Combobox aria-label="Region" options={regions} onValueChange={onValueChange} />);
    const trigger = screen.getByRole("combobox", { name: "Region" });
    await user.click(trigger);
    await user.keyboard("we{Escape}");
    expect(screen.queryByRole("listbox")).not.toBeInTheDocument();
    expect(onValueChange).not.toHaveBeenCalled();
    expect(trigger).toHaveFocus();
  });

  it("forgets the search text between openings", async () => {
    const user = userEvent.setup();
    render(<Combobox aria-label="Region" options={regions} />);
    const trigger = screen.getByRole("combobox", { name: "Region" });
    await user.click(trigger);
    await user.keyboard("sou{Escape}");
    await user.click(trigger);
    expect(screen.getAllByRole("option")).toHaveLength(4);
  });

  it("does not open when disabled", async () => {
    const user = userEvent.setup();
    render(<Combobox aria-label="Region" options={regions} disabled />);
    const trigger = screen.getByRole("combobox", { name: "Region" });
    expect(trigger).toBeDisabled();
    await user.click(trigger);
    expect(screen.queryByRole("listbox")).not.toBeInTheDocument();
  });

  it("follows a controlled value", () => {
    const { rerender } = render(<Combobox aria-label="Region" options={regions} value="west" />);
    expect(screen.getByRole("combobox", { name: "Region" })).toHaveTextContent("West");
    rerender(<Combobox aria-label="Region" options={regions} value="export" />);
    expect(screen.getByRole("combobox", { name: "Region" })).toHaveTextContent("Export");
    rerender(<Combobox aria-label="Region" options={regions} value={null} placeholder="Pick" />);
    expect(screen.getByRole("combobox", { name: "Region" })).toHaveTextContent("Pick");
  });

  it("leaves filtering to the caller when shouldFilter is false, and reports the search text", async () => {
    const user = userEvent.setup();
    const onSearchChange = vi.fn();
    render(<Combobox aria-label="Region" options={regions} shouldFilter={false} onSearchChange={onSearchChange} />);
    await user.click(screen.getByRole("combobox", { name: "Region" }));
    await user.keyboard("zz");
    expect(onSearchChange.mock.calls.map(([text]) => text)).toEqual(["z", "zz"]);
    expect(screen.getAllByRole("option")).toHaveLength(4);
  });

  it("shows a loading row instead of the empty text while loading", async () => {
    const user = userEvent.setup();
    render(<Combobox aria-label="Region" options={[]} loading emptyText="No region found." />);
    await user.click(screen.getByRole("combobox", { name: "Region" }));
    expect(screen.getByRole("status")).toHaveTextContent("Loading…");
    expect(screen.queryByText("No region found.")).not.toBeInTheDocument();
  });

  it("is labelled, described and marked invalid/required by its Field", () => {
    render(
      <Field label="Region" required error="Pick a region to continue.">
        <Combobox options={regions} />
      </Field>
    );
    const trigger = screen.getByLabelText(/Region/);
    expect(trigger).toHaveAttribute("role", "combobox");
    expect(trigger).toHaveAttribute("aria-invalid", "true");
    expect(trigger).toHaveAttribute("aria-required", "true");
    expect(trigger).toHaveAccessibleDescription("Pick a region to continue.");
  });

  it("is described by the Field hint when there is no error", () => {
    render(
      <Field label="Region" hint="Where the order ships from.">
        <Combobox options={regions} />
      </Field>
    );
    const trigger = screen.getByRole("combobox", { name: "Region" });
    expect(trigger).not.toHaveAttribute("aria-invalid");
    expect(trigger).toHaveAccessibleDescription("Where the order ships from.");
  });

  it("posts its value through a hidden input", async () => {
    const user = userEvent.setup();
    const { container } = render(<Combobox aria-label="Region" name="region" options={regions} />);
    expect(hidden(container, "region")).toEqual([""]);
    await user.click(screen.getByRole("combobox", { name: "Region" }));
    await user.click(screen.getByRole("option", { name: "West" }));
    expect(hidden(container, "region")).toEqual(["west"]);
  });

  it("forwards its ref to the trigger button", () => {
    const ref = React.createRef<HTMLButtonElement>();
    render(<Combobox ref={ref} aria-label="Region" options={regions} />);
    expect(ref.current).toBe(screen.getByRole("combobox", { name: "Region" }));
  });

  // axe runs on aria-label'd triggers: jest-axe bundles axe-core 4.9, whose
  // `button-name` rule does not yet count <label for> as a name for a
  // <button role="combobox"> (the Field tests above assert the name itself).
  // Open, the trigger and the portalled popup are checked separately — axe on
  // document.body would only add the page-level `region` rule.
  it("has no axe violations closed", async () => {
    const { container } = render(
      <>
        <Combobox aria-label="Empty" options={regions} placeholder="Pick a region" />
        <Combobox aria-label="Filled" options={regions} defaultValue="west" clearable />
        <Combobox aria-label="Invalid" options={regions} state="error" />
        <Combobox aria-label="Disabled" options={regions} defaultValue="south" disabled />
      </>
    );
    expect(await axe(container)).toHaveNoViolations();
  });

  it("has no axe violations open", async () => {
    const user = userEvent.setup();
    const { container } = render(<Combobox aria-label="Region" options={regions} defaultValue="west" />);
    await user.click(screen.getByRole("combobox", { name: "Region" }));
    expect(screen.getByRole("listbox")).toBeInTheDocument();
    expect(await axe(container)).toHaveNoViolations();
    expect(await axe(screen.getByRole("dialog", { name: "Options" }))).toHaveNoViolations();
  });
});

describe("MultiCombobox", () => {
  it("adds and removes values as options are toggled, staying open", async () => {
    const user = userEvent.setup();
    const onValueChange = vi.fn();
    render(<MultiCombobox aria-label="Regions" options={regions} placeholder="Any" onValueChange={onValueChange} />);
    const trigger = screen.getByRole("combobox", { name: "Regions" });
    expect(trigger).toHaveTextContent("Any");

    await user.click(trigger);
    expect(screen.getByRole("listbox")).toHaveAttribute("aria-multiselectable", "true");
    await user.click(screen.getByRole("option", { name: "West" }));
    expect(onValueChange).toHaveBeenLastCalledWith(["west"]);
    await user.click(screen.getByRole("option", { name: /Export/ }));
    expect(onValueChange).toHaveBeenLastCalledWith(["west", "export"]);
    expect(screen.getByRole("listbox")).toBeInTheDocument();
    expect(screen.getByRole("option", { name: "West" })).toHaveAttribute("aria-checked", "true");
    expect(trigger).toHaveTextContent("West, Export");

    await user.click(screen.getByRole("option", { name: "West" }));
    expect(onValueChange).toHaveBeenLastCalledWith(["export"]);
    expect(screen.getByRole("option", { name: "West" })).toHaveAttribute("aria-checked", "false");
    expect(trigger).toHaveTextContent("Export");
  });

  it("shows each selection as a tag that can be removed", async () => {
    const user = userEvent.setup();
    const onValueChange = vi.fn();
    render(
      <MultiCombobox aria-label="Regions" options={regions} defaultValue={["west", "south"]} onValueChange={onValueChange} />
    );
    const trigger = screen.getByRole("combobox", { name: "Regions" });
    expect(screen.getByRole("button", { name: "Remove West" })).toBeInTheDocument();

    await user.click(screen.getByRole("button", { name: "Remove South" }));
    expect(onValueChange).toHaveBeenCalledExactlyOnceWith(["west"]);
    expect(screen.queryByRole("button", { name: "Remove South" })).not.toBeInTheDocument();
    expect(screen.getByRole("button", { name: "Remove West" })).toBeInTheDocument();
    // Removing a tag is not a request to open the list.
    expect(screen.queryByRole("listbox")).not.toBeInTheDocument();
    expect(trigger).toHaveFocus();
  });

  it('collapses tags beyond maxTags into "+N"', () => {
    const { rerender } = render(
      <MultiCombobox aria-label="Regions" options={regions} defaultValue={["west", "south", "export"]} />
    );
    expect(screen.getAllByRole("button", { name: /^Remove / })).toHaveLength(2);
    expect(screen.getByText("+1")).toBeInTheDocument();
    // The trigger still exposes the whole selection.
    expect(screen.getByRole("combobox", { name: "Regions" })).toHaveTextContent("West, South, Export");

    rerender(
      <MultiCombobox aria-label="Regions" options={regions} defaultValue={["west", "south", "export"]} maxTags={3} />
    );
    expect(screen.getAllByRole("button", { name: /^Remove / })).toHaveLength(3);
    expect(screen.queryByText(/^\+\d/)).not.toBeInTheDocument();
  });

  it("clears every value with the clear button", async () => {
    const user = userEvent.setup();
    const onValueChange = vi.fn();
    render(
      <MultiCombobox
        aria-label="Regions"
        options={regions}
        defaultValue={["west", "south"]}
        clearable
        onValueChange={onValueChange}
      />
    );
    await user.click(screen.getByRole("button", { name: "Clear selection" }));
    expect(onValueChange).toHaveBeenCalledExactlyOnceWith([]);
    expect(screen.queryByRole("button", { name: /^Remove / })).not.toBeInTheDocument();
  });

  it("posts one hidden input per value", () => {
    const { container } = render(
      <MultiCombobox aria-label="Regions" name="regions" options={regions} defaultValue={["west", "export"]} />
    );
    expect(hidden(container, "regions")).toEqual(["west", "export"]);
  });

  it("is wired to its Field", () => {
    render(
      <Field label="Regions" error="Pick at least one.">
        <MultiCombobox options={regions} />
      </Field>
    );
    const trigger = screen.getByRole("combobox", { name: "Regions" });
    expect(trigger).toHaveAttribute("aria-invalid", "true");
    expect(trigger).toHaveAccessibleDescription("Pick at least one.");
  });

  it("has no axe violations closed with tags", async () => {
    const { container } = render(
      <MultiCombobox aria-label="Regions" options={regions} defaultValue={["west", "south", "export"]} clearable />
    );
    expect(await axe(container)).toHaveNoViolations();
  });

  it("has no axe violations open", async () => {
    const user = userEvent.setup();
    const { container } = render(<MultiCombobox aria-label="Regions" options={regions} defaultValue={["west"]} />);
    await user.click(screen.getByRole("combobox", { name: "Regions" }));
    expect(screen.getByRole("listbox")).toBeInTheDocument();
    expect(await axe(container)).toHaveNoViolations();
    expect(await axe(screen.getByRole("dialog", { name: "Options" }))).toHaveNoViolations();
  });
});

// ── DatePicker ────────────────────────────────────────────
// Every test pins the month and "today" to August 2026.

const AUGUST = new Date(2026, 7, 1);
const TODAY = new Date(2026, 7, 14);
const pinned = { defaultMonth: AUGUST, today: TODAY };
// Day buttons are named "14, Friday, August 2026" (the visible number first).
const day = (n: number, month = "August") => screen.getByRole("button", { name: new RegExp(`^${n}, \\w+, ${month} 2026`) });

describe("date formatting", () => {
  it("formats for display as dd MMM yyyy and for forms as yyyy-MM-dd", () => {
    expect(formatDisplayDate(new Date(2026, 7, 5))).toBe("05 Aug 2026");
    expect(formatDisplayDate(new Date(2026, 8, 30))).toBe("30 Sep 2026");
    expect(toISODate(new Date(2026, 7, 5))).toBe("2026-08-05");
    expect(toISODate(new Date(2026, 11, 31, 23, 59))).toBe("2026-12-31");
  });
});

describe("DatePicker", () => {
  it("is a collapsed dialog trigger showing its placeholder", () => {
    render(<DatePicker {...pinned} placeholder="Pick a delivery date" />);
    const trigger = screen.getByRole("button", { name: "Pick a delivery date" });
    expect(trigger).toHaveAttribute("aria-haspopup", "dialog");
    expect(trigger).toHaveAttribute("aria-expanded", "false");
    expect(screen.queryByRole("dialog")).not.toBeInTheDocument();
  });

  it("opens a labelled dialog on the pinned month", async () => {
    const user = userEvent.setup();
    render(<DatePicker {...pinned} aria-label="Delivery date" />);
    const trigger = screen.getByRole("button", { name: /^Delivery date/ });
    await user.click(trigger);
    expect(trigger).toHaveAttribute("aria-expanded", "true");
    const dialog = screen.getByRole("dialog", { name: "Choose date" });
    expect(within(dialog).getByRole("grid", { name: "August 2026" })).toBeInTheDocument();
    expect(dialog).toContainElement(document.activeElement as HTMLElement);
  });

  it("calls back with the picked day, closes, shows it formatted and returns focus", async () => {
    const user = userEvent.setup();
    const onValueChange = vi.fn();
    render(<DatePicker {...pinned} aria-label="Delivery date" onValueChange={onValueChange} />);
    await user.click(screen.getByRole("button", { name: /^Delivery date/ }));
    await user.click(day(20));

    expect(onValueChange).toHaveBeenCalledTimes(1);
    expect(toISODate(onValueChange.mock.calls[0][0])).toBe("2026-08-20");
    expect(screen.queryByRole("dialog")).not.toBeInTheDocument();
    const trigger = screen.getByRole("button", { name: "Delivery date, 20 Aug 2026" });
    expect(trigger).toHaveTextContent("20 Aug 2026");
    expect(trigger).toHaveFocus();
  });

  it("opens on the month of its value and marks that day selected", async () => {
    const user = userEvent.setup();
    render(<DatePicker today={TODAY} aria-label="Delivery date" defaultValue={new Date(2026, 9, 9)} />);
    await user.click(screen.getByRole("button", { name: /Delivery date/ }));
    expect(screen.getByRole("grid", { name: "October 2026" })).toBeInTheDocument();
    expect(screen.getByRole("gridcell", { selected: true })).toHaveTextContent("9");
  });

  it("uses a custom formatter", () => {
    render(<DatePicker {...pinned} defaultValue={new Date(2026, 7, 20)} formatDate={(d) => `day ${d.getDate()}`} />);
    expect(screen.getByRole("button", { name: "day 20" })).toBeInTheDocument();
  });

  it("disables days outside min and max", async () => {
    const user = userEvent.setup();
    const onValueChange = vi.fn();
    render(
      <DatePicker
        {...pinned}
        aria-label="Delivery date"
        min={new Date(2026, 7, 5)}
        max={new Date(2026, 7, 25)}
        onValueChange={onValueChange}
      />
    );
    await user.click(screen.getByRole("button", { name: /^Delivery date/ }));
    expect(day(4)).toBeDisabled();
    expect(day(5)).toBeEnabled();
    expect(day(25)).toBeEnabled();
    expect(day(26)).toBeDisabled();

    await user.click(day(4));
    expect(onValueChange).not.toHaveBeenCalled();
    expect(screen.getByRole("dialog")).toBeInTheDocument();
    // No month to go to on either side of the allowed window.
    expect(screen.getByRole("button", { name: /previous month/i })).toHaveAttribute("aria-disabled", "true");
    expect(screen.getByRole("button", { name: /next month/i })).toHaveAttribute("aria-disabled", "true");
  });

  it("disables days matched by disabledDates", async () => {
    const user = userEvent.setup();
    render(<DatePicker {...pinned} aria-label="Delivery date" disabledDates={{ dayOfWeek: [0] }} />);
    await user.click(screen.getByRole("button", { name: /^Delivery date/ }));
    expect(day(16)).toBeDisabled(); // a Sunday
    expect(day(17)).toBeEnabled();
  });

  it("clears the value with the clear button", async () => {
    const user = userEvent.setup();
    const onValueChange = vi.fn();
    render(
      <DatePicker
        {...pinned}
        aria-label="Delivery date"
        placeholder="Pick a date"
        defaultValue={new Date(2026, 7, 20)}
        clearable
        onValueChange={onValueChange}
      />
    );
    await user.click(screen.getByRole("button", { name: "Clear date" }));
    expect(onValueChange).toHaveBeenCalledExactlyOnceWith(null);
    const trigger = screen.getByRole("button", { name: /^Delivery date/ });
    expect(trigger).toHaveTextContent("Pick a date");
    expect(trigger).toHaveFocus();
    expect(screen.queryByRole("button", { name: "Clear date" })).not.toBeInTheDocument();
    expect(screen.queryByRole("dialog")).not.toBeInTheDocument();
  });

  it("keeps the value when the selected day is clicked again, unless clearable", async () => {
    const user = userEvent.setup();
    const onValueChange = vi.fn();
    const { rerender } = render(
      <DatePicker {...pinned} aria-label="Delivery date" value={new Date(2026, 7, 20)} onValueChange={onValueChange} />
    );
    await user.click(screen.getByRole("button", { name: /Delivery date/ }));
    await user.click(day(20));
    expect(onValueChange).not.toHaveBeenCalled();
    expect(screen.queryByRole("dialog")).not.toBeInTheDocument();

    rerender(
      <DatePicker
        {...pinned}
        aria-label="Delivery date"
        value={new Date(2026, 7, 20)}
        clearable
        onValueChange={onValueChange}
      />
    );
    await user.click(screen.getByRole("button", { name: /Delivery date/ }));
    await user.click(day(20));
    expect(onValueChange).toHaveBeenCalledExactlyOnceWith(null);
  });

  it("closes on Escape without a change and returns focus to the trigger", async () => {
    const user = userEvent.setup();
    const onValueChange = vi.fn();
    render(<DatePicker {...pinned} aria-label="Delivery date" onValueChange={onValueChange} />);
    const trigger = screen.getByRole("button", { name: /^Delivery date/ });
    await user.click(trigger);
    await user.keyboard("{Escape}");
    expect(screen.queryByRole("dialog")).not.toBeInTheDocument();
    expect(onValueChange).not.toHaveBeenCalled();
    expect(trigger).toHaveFocus();
  });

  it("does not open when disabled", async () => {
    const user = userEvent.setup();
    render(<DatePicker {...pinned} aria-label="Delivery date" disabled />);
    const trigger = screen.getByRole("button", { name: /^Delivery date/ });
    expect(trigger).toBeDisabled();
    await user.click(trigger);
    expect(screen.queryByRole("dialog")).not.toBeInTheDocument();
  });

  it("posts an ISO date through a hidden input", async () => {
    const user = userEvent.setup();
    const { container } = render(<DatePicker {...pinned} aria-label="Delivery date" name="delivery" />);
    expect(hidden(container, "delivery")).toEqual([""]);
    await user.click(screen.getByRole("button", { name: /^Delivery date/ }));
    await user.click(day(3));
    expect(hidden(container, "delivery")).toEqual(["2026-08-03"]);
  });

  it("is labelled, described and marked invalid by its Field, and its name carries the date", async () => {
    const user = userEvent.setup();
    render(
      <Field label="Delivery date" required error="Choose a date.">
        <DatePicker {...pinned} />
      </Field>
    );
    const trigger = screen.getByLabelText(/Delivery date/);
    expect(trigger).toHaveAttribute("aria-haspopup", "dialog");
    // A plain button does not support aria-invalid / aria-required: the error is
    // marked for styling and announced through the description.
    expect(trigger).toHaveAttribute("data-invalid");
    expect(trigger).not.toHaveAttribute("aria-invalid");
    expect(trigger).not.toHaveAttribute("aria-required");
    expect(trigger).toHaveAccessibleDescription("Choose a date.");

    await user.click(trigger);
    await user.click(day(20));
    expect(trigger).toHaveAccessibleName("Delivery date 20 Aug 2026");
  });

  it("has no axe violations closed", async () => {
    const { container } = render(
      <>
        <Field label="Delivery date" hint="Working days only.">
          <DatePicker {...pinned} defaultValue={new Date(2026, 7, 20)} clearable />
        </Field>
        <Field label="Dispatch date" error="Choose a date.">
          <DatePicker {...pinned} />
        </Field>
        <DatePicker {...pinned} aria-label="Disabled" disabled />
      </>
    );
    expect(await axe(container)).toHaveNoViolations();
  });

  it("has no axe violations open", async () => {
    const user = userEvent.setup();
    const { container } = render(
      <Field label="Delivery date">
        <DatePicker {...pinned} defaultValue={new Date(2026, 7, 20)} min={new Date(2026, 7, 5)} />
      </Field>
    );
    await user.click(screen.getByLabelText(/Delivery date/));
    // Trigger and portalled popup separately: axe on document.body would only add the page-level `region` rule.
    expect(await axe(container)).toHaveNoViolations();
    expect(await axe(screen.getByRole("dialog", { name: "Choose date" }))).toHaveNoViolations();
  });
});

describe("DateRangePicker", () => {
  const presets = [
    { label: "First week", range: { from: new Date(2026, 7, 1), to: new Date(2026, 7, 7) } },
    { label: "Mid month", range: { from: new Date(2026, 7, 10), to: new Date(2026, 7, 20) } }
  ];
  const iso = (range: { from?: Date; to?: Date } | null) =>
    range && [range.from && toISODate(range.from), range.to && toISODate(range.to)];

  it("shows two months and stays open after the first pick, calling back once both ends are chosen", async () => {
    const user = userEvent.setup();
    const onValueChange = vi.fn();
    render(<DateRangePicker {...pinned} aria-label="Period" onValueChange={onValueChange} />);
    await user.click(screen.getByRole("button", { name: /^Period/ }));
    const dialog = screen.getByRole("dialog", { name: "Choose date range" });
    expect(within(dialog).getAllByRole("grid").map((g) => g.getAttribute("aria-label"))).toEqual([
      "August 2026",
      "September 2026"
    ]);

    await user.click(day(10));
    expect(onValueChange).not.toHaveBeenCalled();
    expect(screen.getByRole("dialog")).toBeInTheDocument();

    await user.click(day(16));
    expect(onValueChange).toHaveBeenCalledTimes(1);
    expect(iso(onValueChange.mock.calls[0][0])).toEqual(["2026-08-10", "2026-08-16"]);
    expect(screen.queryByRole("dialog")).not.toBeInTheDocument();
    expect(screen.getByRole("button", { name: /Period/ })).toHaveTextContent("10 Aug 2026 – 16 Aug 2026");
  });

  it("orders the ends when the second pick is earlier than the first", async () => {
    const user = userEvent.setup();
    const onValueChange = vi.fn();
    render(<DateRangePicker {...pinned} aria-label="Period" onValueChange={onValueChange} />);
    await user.click(screen.getByRole("button", { name: /^Period/ }));
    await user.click(day(16));
    await user.click(day(10));
    expect(iso(onValueChange.mock.calls[0][0])).toEqual(["2026-08-10", "2026-08-16"]);
  });

  it("accepts a one-day range", async () => {
    const user = userEvent.setup();
    const onValueChange = vi.fn();
    render(<DateRangePicker {...pinned} aria-label="Period" onValueChange={onValueChange} />);
    await user.click(screen.getByRole("button", { name: /^Period/ }));
    await user.click(day(12));
    await user.click(day(12));
    expect(iso(onValueChange.mock.calls[0][0])).toEqual(["2026-08-12", "2026-08-12"]);
  });

  it("starts a new range when a complete one exists", async () => {
    const user = userEvent.setup();
    const onValueChange = vi.fn();
    render(
      <DateRangePicker
        {...pinned}
        aria-label="Period"
        defaultValue={{ from: new Date(2026, 7, 10), to: new Date(2026, 7, 16) }}
        onValueChange={onValueChange}
      />
    );
    await user.click(screen.getByRole("button", { name: /Period/ }));
    await user.click(day(3));
    expect(onValueChange).not.toHaveBeenCalled();
    await user.click(day(5));
    expect(iso(onValueChange.mock.calls[0][0])).toEqual(["2026-08-03", "2026-08-05"]);
  });

  it("discards a half-picked range when closed", async () => {
    const user = userEvent.setup();
    const onValueChange = vi.fn();
    render(
      <DateRangePicker
        {...pinned}
        aria-label="Period"
        defaultValue={{ from: new Date(2026, 7, 10), to: new Date(2026, 7, 16) }}
        onValueChange={onValueChange}
      />
    );
    const trigger = screen.getByRole("button", { name: /Period/ });
    await user.click(trigger);
    await user.click(day(3));
    await user.keyboard("{Escape}");
    expect(onValueChange).not.toHaveBeenCalled();
    expect(trigger).toHaveTextContent("10 Aug 2026 – 16 Aug 2026");

    await user.click(trigger);
    expect(screen.getAllByRole("gridcell", { selected: true })).toHaveLength(7);
  });

  it("applies a preset and closes", async () => {
    const user = userEvent.setup();
    const onValueChange = vi.fn();
    render(<DateRangePicker {...pinned} aria-label="Period" presets={presets} onValueChange={onValueChange} />);
    const trigger = screen.getByRole("button", { name: /^Period/ });
    await user.click(trigger);
    const list = screen.getByRole("group", { name: "Presets" });
    expect(within(list).getAllByRole("button").map((b) => b.textContent)).toEqual(["First week", "Mid month"]);

    await user.click(within(list).getByRole("button", { name: "Mid month" }));
    expect(onValueChange).toHaveBeenCalledTimes(1);
    expect(iso(onValueChange.mock.calls[0][0])).toEqual(["2026-08-10", "2026-08-20"]);
    expect(screen.queryByRole("dialog")).not.toBeInTheDocument();
    expect(trigger).toHaveTextContent("10 Aug 2026 – 20 Aug 2026");

    await user.click(trigger);
    expect(screen.getByRole("button", { name: "Mid month" })).toHaveAttribute("aria-pressed", "true");
    expect(screen.getByRole("button", { name: "First week" })).toHaveAttribute("aria-pressed", "false");
  });

  it("shows one month when asked", async () => {
    const user = userEvent.setup();
    render(<DateRangePicker {...pinned} aria-label="Period" numberOfMonths={1} />);
    await user.click(screen.getByRole("button", { name: /^Period/ }));
    expect(screen.getAllByRole("grid")).toHaveLength(1);
  });

  it("disables days outside min and max", async () => {
    const user = userEvent.setup();
    render(
      <DateRangePicker {...pinned} aria-label="Period" min={new Date(2026, 7, 5)} max={new Date(2026, 8, 10)} />
    );
    await user.click(screen.getByRole("button", { name: /^Period/ }));
    expect(day(4)).toBeDisabled();
    expect(day(5)).toBeEnabled();
    expect(day(11, "September")).toBeDisabled();
  });

  it("clears the range with the clear button", async () => {
    const user = userEvent.setup();
    const onValueChange = vi.fn();
    render(
      <DateRangePicker
        {...pinned}
        aria-label="Period"
        placeholder="Any time"
        defaultValue={{ from: new Date(2026, 7, 10), to: new Date(2026, 7, 16) }}
        clearable
        onValueChange={onValueChange}
      />
    );
    await user.click(screen.getByRole("button", { name: "Clear date" }));
    expect(onValueChange).toHaveBeenCalledExactlyOnceWith(null);
    expect(screen.getByRole("button", { name: /^Period/ })).toHaveTextContent("Any time");
  });

  it("posts both ends through hidden inputs", () => {
    const { container } = render(
      <DateRangePicker
        {...pinned}
        aria-label="Period"
        name="period"
        defaultValue={{ from: new Date(2026, 7, 10), to: new Date(2026, 7, 16) }}
      />
    );
    expect(hidden(container, "period_from")).toEqual(["2026-08-10"]);
    expect(hidden(container, "period_to")).toEqual(["2026-08-16"]);
  });

  it("is wired to its Field", () => {
    render(
      <Field label="Period" error="Choose a period.">
        <DateRangePicker {...pinned} />
      </Field>
    );
    const trigger = screen.getByLabelText("Period");
    expect(trigger).toHaveAttribute("data-invalid");
    expect(trigger).toHaveAccessibleDescription("Choose a period.");
  });

  it("has no axe violations closed", async () => {
    const { container } = render(
      <Field label="Period">
        <DateRangePicker {...pinned} defaultValue={{ from: new Date(2026, 7, 10), to: new Date(2026, 7, 16) }} />
      </Field>
    );
    expect(await axe(container)).toHaveNoViolations();
  });

  it("has no axe violations open with presets", async () => {
    const user = userEvent.setup();
    const { container } = render(
      <Field label="Period">
        <DateRangePicker
          {...pinned}
          presets={presets}
          defaultValue={{ from: new Date(2026, 7, 10), to: new Date(2026, 7, 16) }}
        />
      </Field>
    );
    await user.click(screen.getByLabelText("Period"));
    expect(await axe(container)).toHaveNoViolations();
    expect(await axe(screen.getByRole("dialog", { name: "Choose date range" }))).toHaveNoViolations();
  });
});

// ── NumberInput ───────────────────────────────────────────

describe("NumberInput", () => {
  it("is a spinbutton exposing its value and bounds", () => {
    render(<NumberInput aria-label="Quantity" defaultValue={5} min={1} max={10} />);
    const input = screen.getByRole("spinbutton", { name: "Quantity" });
    expect(input).toHaveValue("5");
    expect(input).toHaveAttribute("aria-valuenow", "5");
    expect(input).toHaveAttribute("aria-valuemin", "1");
    expect(input).toHaveAttribute("aria-valuemax", "10");
    expect(input).toHaveAttribute("inputmode", "decimal");
    expect(input).not.toHaveAttribute("type", "number");
  });

  it("has no aria-valuenow while empty", () => {
    render(<NumberInput aria-label="Quantity" />);
    expect(screen.getByRole("spinbutton", { name: "Quantity" })).not.toHaveAttribute("aria-valuenow");
  });

  it("calls back with the number as it is typed", async () => {
    const user = userEvent.setup();
    const onValueChange = vi.fn();
    render(<NumberInput aria-label="Quantity" onValueChange={onValueChange} />);
    const input = screen.getByRole("spinbutton", { name: "Quantity" });
    await user.type(input, "42");
    expect(onValueChange.mock.calls.map(([n]) => n)).toEqual([4, 42]);
    expect(input).toHaveValue("42");
    expect(input).toHaveAttribute("aria-valuenow", "42");
  });

  it("accepts negatives and decimals", async () => {
    const user = userEvent.setup();
    const onValueChange = vi.fn();
    render(<NumberInput aria-label="Offset" onValueChange={onValueChange} />);
    await user.type(screen.getByRole("spinbutton", { name: "Offset" }), "-1.5");
    expect(onValueChange).toHaveBeenLastCalledWith(-1.5);
  });

  it("ignores non-numeric typing and keeps the last valid value", async () => {
    const user = userEvent.setup();
    const onValueChange = vi.fn();
    render(<NumberInput aria-label="Quantity" onValueChange={onValueChange} />);
    const input = screen.getByRole("spinbutton", { name: "Quantity" });
    await user.type(input, "1a2b!c");
    expect(input).toHaveValue("12");
    expect(onValueChange).toHaveBeenLastCalledWith(12);
    expect(onValueChange.mock.calls.every(([n]) => typeof n === "number" && !Number.isNaN(n))).toBe(true);
  });

  it("rejects a minus sign when min is not negative, and a decimal point when precision is 0", async () => {
    const user = userEvent.setup();
    render(<NumberInput aria-label="Quantity" min={0} precision={0} />);
    const input = screen.getByRole("spinbutton", { name: "Quantity" });
    await user.type(input, "-3.7");
    expect(input).toHaveValue("37");
  });

  it("falls back to the last valid value when a half-typed number is abandoned", async () => {
    const user = userEvent.setup();
    const onValueChange = vi.fn();
    render(<NumberInput aria-label="Offset" defaultValue={5} onValueChange={onValueChange} />);
    const input = screen.getByRole("spinbutton", { name: "Offset" });
    await user.tripleClick(input);
    await user.keyboard("-");
    expect(input).toHaveValue("-");
    await user.tab();
    expect(input).toHaveValue("5");
    expect(onValueChange).not.toHaveBeenCalled();
  });

  it("calls back with null when cleared", async () => {
    const user = userEvent.setup();
    const onValueChange = vi.fn();
    render(<NumberInput aria-label="Quantity" defaultValue={7} onValueChange={onValueChange} />);
    const input = screen.getByRole("spinbutton", { name: "Quantity" });
    await user.clear(input);
    expect(onValueChange).toHaveBeenLastCalledWith(null);
    await user.tab();
    expect(input).toHaveValue("");
  });

  it("steps with the arrow keys", async () => {
    const user = userEvent.setup();
    const onValueChange = vi.fn();
    render(<NumberInput aria-label="Quantity" defaultValue={5} step={2} onValueChange={onValueChange} />);
    const input = screen.getByRole("spinbutton", { name: "Quantity" });
    await user.click(input);
    await user.keyboard("{ArrowUp}");
    expect(onValueChange).toHaveBeenLastCalledWith(7);
    expect(input).toHaveValue("7");
    await user.keyboard("{ArrowDown}{ArrowDown}");
    expect(onValueChange).toHaveBeenLastCalledWith(3);
    expect(input).toHaveValue("3");
  });

  it("steps by ten times the step with Shift and with PageUp/PageDown", async () => {
    const user = userEvent.setup();
    const onValueChange = vi.fn();
    render(<NumberInput aria-label="Quantity" defaultValue={5} onValueChange={onValueChange} />);
    await user.click(screen.getByRole("spinbutton", { name: "Quantity" }));
    await user.keyboard("{Shift>}{ArrowUp}{/Shift}");
    expect(onValueChange).toHaveBeenLastCalledWith(15);
    await user.keyboard("{Shift>}{ArrowDown}{/Shift}");
    expect(onValueChange).toHaveBeenLastCalledWith(5);
    await user.keyboard("{PageUp}");
    expect(onValueChange).toHaveBeenLastCalledWith(15);
    await user.keyboard("{PageDown}{PageDown}");
    expect(onValueChange).toHaveBeenLastCalledWith(-5);
  });

  it("jumps to min and max with Home and End, and stops stepping at the bounds", async () => {
    const user = userEvent.setup();
    const onValueChange = vi.fn();
    render(<NumberInput aria-label="Quantity" defaultValue={5} min={1} max={10} onValueChange={onValueChange} />);
    const input = screen.getByRole("spinbutton", { name: "Quantity" });
    await user.click(input);
    await user.keyboard("{End}");
    expect(onValueChange).toHaveBeenLastCalledWith(10);
    await user.keyboard("{ArrowUp}{PageUp}");
    expect(input).toHaveValue("10");
    await user.keyboard("{Home}");
    expect(onValueChange).toHaveBeenLastCalledWith(1);
    await user.keyboard("{PageDown}");
    expect(input).toHaveValue("1");
    expect(onValueChange).toHaveBeenCalledTimes(2);
  });

  it("steps from zero when empty, landing inside the bounds", async () => {
    const user = userEvent.setup();
    const onValueChange = vi.fn();
    render(<NumberInput aria-label="Quantity" min={5} onValueChange={onValueChange} />);
    await user.click(screen.getByRole("spinbutton", { name: "Quantity" }));
    await user.keyboard("{ArrowUp}");
    expect(onValueChange).toHaveBeenLastCalledWith(5);
  });

  it("does not drift when stepping by a fraction", async () => {
    const user = userEvent.setup();
    const onValueChange = vi.fn();
    render(<NumberInput aria-label="Weight" defaultValue={0.1} step={0.1} onValueChange={onValueChange} />);
    await user.click(screen.getByRole("spinbutton", { name: "Weight" }));
    await user.keyboard("{ArrowUp}{ArrowUp}");
    expect(onValueChange).toHaveBeenLastCalledWith(0.3);
  });

  it("clamps to the bounds on blur", async () => {
    const user = userEvent.setup();
    const onValueChange = vi.fn();
    render(<NumberInput aria-label="Quantity" min={1} max={100} onValueChange={onValueChange} />);
    const input = screen.getByRole("spinbutton", { name: "Quantity" });
    await user.type(input, "150");
    expect(input).toHaveValue("150");
    await user.tab();
    expect(onValueChange).toHaveBeenLastCalledWith(100);
    expect(input).toHaveValue("100");

    await user.clear(input);
    await user.type(input, "0");
    await user.tab();
    expect(onValueChange).toHaveBeenLastCalledWith(1);
    expect(input).toHaveValue("1");
  });

  it("rounds to the precision on blur and shows it padded", async () => {
    const user = userEvent.setup();
    const onValueChange = vi.fn();
    render(<NumberInput aria-label="Price" precision={2} onValueChange={onValueChange} />);
    const input = screen.getByRole("spinbutton", { name: "Price" });
    await user.type(input, "1.239");
    await user.tab();
    expect(onValueChange).toHaveBeenLastCalledWith(1.24);
    expect(input).toHaveValue("1.24");

    await user.clear(input);
    await user.type(input, "12.5");
    await user.tab();
    expect(input).toHaveValue("12.50");
  });

  it("steps with the Increase and Decrease buttons, which stay out of the tab order", async () => {
    const user = userEvent.setup();
    const onValueChange = vi.fn();
    render(<NumberInput aria-label="Quantity" defaultValue={5} onValueChange={onValueChange} />);
    const input = screen.getByRole("spinbutton", { name: "Quantity" });
    const increase = screen.getByRole("button", { name: "Increase" });
    const decrease = screen.getByRole("button", { name: "Decrease" });
    expect(increase).toHaveAttribute("tabindex", "-1");
    expect(decrease).toHaveAttribute("tabindex", "-1");

    await user.click(increase);
    expect(onValueChange).toHaveBeenLastCalledWith(6);
    expect(input).toHaveValue("6");
    expect(input).toHaveFocus();
    await user.click(decrease);
    await user.click(decrease);
    expect(onValueChange).toHaveBeenLastCalledWith(4);

    await user.tab();
    expect(increase).not.toHaveFocus();
    expect(decrease).not.toHaveFocus();
  });

  it("disables each button at its bound", async () => {
    const user = userEvent.setup();
    render(<NumberInput aria-label="Quantity" defaultValue={1} min={1} max={2} />);
    const increase = screen.getByRole("button", { name: "Increase" });
    const decrease = screen.getByRole("button", { name: "Decrease" });
    expect(decrease).toBeDisabled();
    expect(increase).toBeEnabled();
    await user.click(increase);
    expect(increase).toBeDisabled();
    expect(decrease).toBeEnabled();
  });

  it("follows a controlled value", () => {
    const { rerender } = render(<NumberInput aria-label="Quantity" value={3} />);
    expect(screen.getByRole("spinbutton", { name: "Quantity" })).toHaveValue("3");
    rerender(<NumberInput aria-label="Quantity" value={8} />);
    expect(screen.getByRole("spinbutton", { name: "Quantity" })).toHaveValue("8");
    rerender(<NumberInput aria-label="Quantity" value={null} />);
    expect(screen.getByRole("spinbutton", { name: "Quantity" })).toHaveValue("");
  });

  it("does nothing when disabled or read-only", async () => {
    const user = userEvent.setup();
    const onValueChange = vi.fn();
    const { rerender } = render(<NumberInput aria-label="Quantity" defaultValue={5} disabled onValueChange={onValueChange} />);
    expect(screen.getByRole("spinbutton", { name: "Quantity" })).toBeDisabled();
    expect(screen.getByRole("button", { name: "Increase" })).toBeDisabled();
    expect(screen.getByRole("button", { name: "Decrease" })).toBeDisabled();

    rerender(<NumberInput aria-label="Quantity" defaultValue={5} readOnly onValueChange={onValueChange} />);
    await user.click(screen.getByRole("spinbutton", { name: "Quantity" }));
    await user.keyboard("{ArrowUp}9");
    expect(screen.getByRole("button", { name: "Increase" })).toBeDisabled();
    expect(onValueChange).not.toHaveBeenCalled();
    expect(screen.getByRole("spinbutton", { name: "Quantity" })).toHaveValue("5");
  });

  it("shows prefix and suffix and announces the unit with the value", () => {
    render(<NumberInput aria-label="Weight" defaultValue={12} suffix="kg" prefix="≈" />);
    expect(screen.getByText("kg")).toBeInTheDocument();
    expect(screen.getByText("≈")).toBeInTheDocument();
    expect(screen.getByRole("spinbutton", { name: "Weight" })).toHaveAttribute("aria-valuetext", "≈ 12 kg");
  });

  it("is labelled, described and marked invalid/required by its Field", () => {
    render(
      <Field label="Quantity" required error="Enter a quantity.">
        <NumberInput />
      </Field>
    );
    const input = screen.getByLabelText(/Quantity/);
    expect(input).toHaveAttribute("role", "spinbutton");
    expect(input).toHaveAttribute("aria-invalid", "true");
    expect(input).toHaveAttribute("aria-required", "true");
    expect(input).toHaveAccessibleDescription("Enter a quantity.");
  });

  it("posts its numeric value through a hidden input", async () => {
    const user = userEvent.setup();
    const { container } = render(<NumberInput aria-label="Price" name="price" defaultValue={12.5} precision={2} />);
    expect(hidden(container, "price")).toEqual(["12.5"]);
    await user.click(screen.getByRole("button", { name: "Increase" }));
    expect(hidden(container, "price")).toEqual(["13.5"]);
  });

  it("forwards its ref to the input", () => {
    const ref = React.createRef<HTMLInputElement>();
    render(<NumberInput ref={ref} aria-label="Quantity" />);
    expect(ref.current).toBe(screen.getByRole("spinbutton", { name: "Quantity" }));
  });

  it("has no axe violations", async () => {
    const { container } = render(
      <>
        <Field label="Quantity" hint="Cartons of 50.">
          <NumberInput defaultValue={1} min={1} max={10} suffix="pcs" />
        </Field>
        <Field label="Price" error="Enter a price.">
          <NumberInput prefix="₹" precision={2} />
        </Field>
        <NumberInput aria-label="Disabled" disabled defaultValue={3} />
      </>
    );
    expect(await axe(container)).toHaveNoViolations();
  });
});
