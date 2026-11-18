import * as React from "react";
import { describe, expect, it, vi } from "vitest";
import { fireEvent, render, screen, within } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { axe } from "jest-axe";
import { Collapsible, CollapsibleContent, CollapsibleTrigger } from "../src/components/collapsible";
import { CountBadge } from "../src/components/count-badge";
import { FileUpload } from "../src/components/file-upload";
import { FilterChip } from "../src/components/filter-chip";
import { Field } from "../src/components/input";
import { Kbd, KbdGroup } from "../src/components/kbd";
import { PageHeader } from "../src/components/page-header";
import { ScrollArea } from "../src/components/scroll-area";
import { Stepper } from "../src/components/stepper";
import {
  SegmentedControl,
  SegmentedControlItem,
  Toggle,
  ToggleGroup,
  ToggleGroupItem
} from "../src/components/toggle";

// Behaviour + semantics only. No class-name or pixel assertions.

// ── Toggle ────────────────────────────────────────────────

describe("Toggle", () => {
  it("is a button that flips aria-pressed on click and from the keyboard", async () => {
    const user = userEvent.setup();
    const onPressedChange = vi.fn();
    render(<Toggle onPressedChange={onPressedChange}>Bold</Toggle>);
    const toggle = screen.getByRole("button", { name: "Bold" });
    expect(toggle).toHaveAttribute("aria-pressed", "false");

    await user.click(toggle);
    expect(toggle).toHaveAttribute("aria-pressed", "true");
    expect(onPressedChange).toHaveBeenLastCalledWith(true);

    await user.keyboard(" ");
    expect(toggle).toHaveAttribute("aria-pressed", "false");
    await user.keyboard("{Enter}");
    expect(toggle).toHaveAttribute("aria-pressed", "true");
  });

  it("follows a controlled pressed prop and does nothing when disabled", async () => {
    const user = userEvent.setup();
    const onPressedChange = vi.fn();
    const { rerender } = render(
      <Toggle pressed onPressedChange={onPressedChange} aria-label="Pin" iconOnly variant="outline" size="sm" />
    );
    const toggle = screen.getByRole("button", { name: "Pin" });
    expect(toggle).toHaveAttribute("aria-pressed", "true");
    // Styling props must not leak onto the DOM button.
    expect(toggle).not.toHaveAttribute("variant");
    expect(toggle).not.toHaveAttribute("size");
    expect(toggle).not.toHaveAttribute("icononly");
    await user.click(toggle);
    expect(onPressedChange).toHaveBeenCalledExactlyOnceWith(false);
    expect(toggle).toHaveAttribute("aria-pressed", "true");

    rerender(<Toggle pressed={false} disabled onPressedChange={onPressedChange} aria-label="Pin" />);
    expect(toggle).toBeDisabled();
    await user.click(toggle);
    expect(onPressedChange).toHaveBeenCalledTimes(1);
  });

  it("has no axe violations", async () => {
    const { container } = render(
      <>
        <Toggle>Bold</Toggle>
        <Toggle defaultPressed variant="outline" aria-label="Italic" iconOnly>
          <svg aria-hidden />
        </Toggle>
      </>
    );
    expect(await axe(container)).toHaveNoViolations();
  });
});

describe("ToggleGroup", () => {
  const items = (
    <>
      <ToggleGroupItem value="left">Left</ToggleGroupItem>
      <ToggleGroupItem value="center">Center</ToggleGroupItem>
      <ToggleGroupItem value="right" disabled>
        Right
      </ToggleGroupItem>
    </>
  );

  it("type=single keeps at most one item on, and lets it be turned off again", async () => {
    const user = userEvent.setup();
    const onValueChange = vi.fn();
    render(
      <ToggleGroup type="single" aria-label="Align" onValueChange={onValueChange}>
        {items}
      </ToggleGroup>
    );
    // Radix exposes a single-choice group as radios.
    const group = screen.getByRole("radiogroup", { name: "Align" });
    const left = within(group).getByRole("radio", { name: "Left" });
    const center = within(group).getByRole("radio", { name: "Center" });

    await user.click(left);
    expect(left).toBeChecked();
    await user.click(center);
    expect(center).toBeChecked();
    expect(left).not.toBeChecked();
    expect(onValueChange).toHaveBeenLastCalledWith("center");

    await user.click(center);
    expect(center).not.toBeChecked();
    expect(onValueChange).toHaveBeenLastCalledWith("");
  });

  it("type=multiple toggles items independently and skips disabled ones", async () => {
    const user = userEvent.setup();
    const onValueChange = vi.fn();
    render(
      <ToggleGroup type="multiple" aria-label="Format" variant="outline" joined onValueChange={onValueChange}>
        {items}
      </ToggleGroup>
    );
    const left = screen.getByRole("button", { name: "Left" });
    const center = screen.getByRole("button", { name: "Center" });
    const right = screen.getByRole("button", { name: "Right" });

    await user.click(left);
    await user.click(center);
    expect(left).toHaveAttribute("aria-pressed", "true");
    expect(center).toHaveAttribute("aria-pressed", "true");
    expect(onValueChange).toHaveBeenLastCalledWith(["left", "center"]);

    await user.click(left);
    expect(left).toHaveAttribute("aria-pressed", "false");
    expect(onValueChange).toHaveBeenLastCalledWith(["center"]);

    expect(right).toBeDisabled();
    await user.click(right);
    expect(onValueChange).toHaveBeenCalledTimes(3);
  });

  it("is one tab stop with arrow-key roving", async () => {
    const user = userEvent.setup();
    render(
      <ToggleGroup type="multiple" aria-label="Format">
        {items}
      </ToggleGroup>
    );
    await user.tab();
    expect(screen.getByRole("button", { name: "Left" })).toHaveFocus();
    await user.keyboard("{ArrowRight}");
    expect(screen.getByRole("button", { name: "Center" })).toHaveFocus();
    // Moving focus does not press anything.
    expect(screen.getByRole("button", { name: "Center" })).toHaveAttribute("aria-pressed", "false");
  });

  it("has no axe violations", async () => {
    const { container } = render(
      <>
        <ToggleGroup type="single" defaultValue="left" aria-label="Align">
          {items}
        </ToggleGroup>
        <ToggleGroup type="multiple" defaultValue={["center"]} aria-label="Format" variant="outline" joined>
          {items}
        </ToggleGroup>
      </>
    );
    expect(await axe(container)).toHaveNoViolations();
  });
});

// ── SegmentedControl ──────────────────────────────────────

describe("SegmentedControl", () => {
  const segments = (
    <>
      <SegmentedControlItem value="day">Day</SegmentedControlItem>
      <SegmentedControlItem value="week" icon={<svg aria-hidden data-testid="week-icon" />}>
        Week
      </SegmentedControlItem>
      <SegmentedControlItem value="month">Month</SegmentedControlItem>
    </>
  );

  it("is a radio group whose items are radios with aria-checked", () => {
    render(
      <SegmentedControl defaultValue="week" aria-label="Range" size="sm" fullWidth>
        {segments}
      </SegmentedControl>
    );
    const group = screen.getByRole("radiogroup", { name: "Range" });
    expect(group).not.toHaveAttribute("size");
    expect(group).not.toHaveAttribute("fullwidth");
    expect(within(group).getAllByRole("radio")).toHaveLength(3);
    expect(within(group).getByRole("radio", { name: "Week" })).toHaveAttribute("aria-checked", "true");
    expect(within(group).getByRole("radio", { name: "Day" })).toHaveAttribute("aria-checked", "false");
    expect(screen.getByTestId("week-icon")).toBeInTheDocument();
  });

  it("selects on click and never empties when the selected segment is clicked again", async () => {
    const user = userEvent.setup();
    const onValueChange = vi.fn();
    render(
      <SegmentedControl defaultValue="day" aria-label="Range" onValueChange={onValueChange}>
        {segments}
      </SegmentedControl>
    );
    const day = screen.getByRole("radio", { name: "Day" });
    const month = screen.getByRole("radio", { name: "Month" });

    await user.click(month);
    expect(month).toBeChecked();
    expect(day).not.toBeChecked();
    expect(onValueChange).toHaveBeenCalledExactlyOnceWith("month");

    await user.click(month);
    expect(month).toBeChecked();
    expect(onValueChange).toHaveBeenCalledTimes(1);
  });

  it("tabs to the selected segment and moves the selection with arrow keys", async () => {
    const user = userEvent.setup();
    const onValueChange = vi.fn();
    render(
      <SegmentedControl defaultValue="week" aria-label="Range" onValueChange={onValueChange}>
        {segments}
      </SegmentedControl>
    );
    await user.tab();
    expect(screen.getByRole("radio", { name: "Week" })).toHaveFocus();
    // Arriving on the selected segment is not a change.
    expect(onValueChange).not.toHaveBeenCalled();

    await user.keyboard("{ArrowRight}");
    expect(screen.getByRole("radio", { name: "Month" })).toHaveFocus();
    expect(screen.getByRole("radio", { name: "Month" })).toBeChecked();
    expect(onValueChange).toHaveBeenLastCalledWith("month");

    await user.keyboard("{ArrowLeft}{ArrowLeft}");
    expect(screen.getByRole("radio", { name: "Day" })).toBeChecked();
    expect(onValueChange).toHaveBeenLastCalledWith("day");
    expect(screen.getAllByRole("radio", { checked: true })).toHaveLength(1);
  });

  it("follows a controlled value", async () => {
    const user = userEvent.setup();
    const onValueChange = vi.fn();
    const { rerender } = render(
      <SegmentedControl value="day" aria-label="Range" onValueChange={onValueChange}>
        {segments}
      </SegmentedControl>
    );
    await user.click(screen.getByRole("radio", { name: "Week" }));
    expect(onValueChange).toHaveBeenCalledExactlyOnceWith("week");
    // The parent did not accept the change.
    expect(screen.getByRole("radio", { name: "Day" })).toBeChecked();

    rerender(
      <SegmentedControl value="week" aria-label="Range" onValueChange={onValueChange}>
        {segments}
      </SegmentedControl>
    );
    expect(screen.getByRole("radio", { name: "Week" })).toBeChecked();
  });

  it("ignores a disabled segment", async () => {
    const user = userEvent.setup();
    const onValueChange = vi.fn();
    render(
      <SegmentedControl defaultValue="day" aria-label="Range" onValueChange={onValueChange}>
        <SegmentedControlItem value="day">Day</SegmentedControlItem>
        <SegmentedControlItem value="year" disabled>
          Year
        </SegmentedControlItem>
      </SegmentedControl>
    );
    await user.click(screen.getByRole("radio", { name: "Year" }));
    expect(onValueChange).not.toHaveBeenCalled();
    expect(screen.getByRole("radio", { name: "Day" })).toBeChecked();
  });

  it("has no axe violations", async () => {
    const { container } = render(
      <SegmentedControl defaultValue="week" aria-label="Range">
        {segments}
      </SegmentedControl>
    );
    expect(await axe(container)).toHaveNoViolations();
  });
});

// ── Collapsible ───────────────────────────────────────────

describe("Collapsible", () => {
  const Example = (props: React.ComponentProps<typeof Collapsible>) => (
    <Collapsible {...props}>
      <CollapsibleTrigger>Shipping details</CollapsibleTrigger>
      <CollapsibleContent>Dispatched from Pune.</CollapsibleContent>
    </Collapsible>
  );

  it("opens and closes from its trigger, tracking aria-expanded", async () => {
    const user = userEvent.setup();
    const onOpenChange = vi.fn();
    render(<Example onOpenChange={onOpenChange} />);
    const trigger = screen.getByRole("button", { name: "Shipping details" });
    expect(trigger).toHaveAttribute("aria-expanded", "false");
    expect(screen.queryByText("Dispatched from Pune.")).not.toBeInTheDocument();

    await user.click(trigger);
    expect(trigger).toHaveAttribute("aria-expanded", "true");
    expect(screen.getByText("Dispatched from Pune.")).toBeVisible();
    expect(trigger).toHaveAttribute("aria-controls", screen.getByText("Dispatched from Pune.").id);
    expect(onOpenChange).toHaveBeenLastCalledWith(true);

    await user.keyboard("{Enter}");
    expect(trigger).toHaveAttribute("aria-expanded", "false");
    expect(onOpenChange).toHaveBeenLastCalledWith(false);
  });

  it("starts open with defaultOpen and stays shut when disabled", async () => {
    const user = userEvent.setup();
    const { rerender } = render(<Example defaultOpen />);
    expect(screen.getByText("Dispatched from Pune.")).toBeVisible();

    rerender(<Example key="disabled" disabled />);
    const trigger = screen.getByRole("button", { name: "Shipping details" });
    expect(trigger).toBeDisabled();
    await user.click(trigger);
    expect(trigger).toHaveAttribute("aria-expanded", "false");
  });

  it("has no axe violations, open or closed", async () => {
    const { container } = render(
      <>
        <Example />
        <Example defaultOpen />
      </>
    );
    expect(await axe(container)).toHaveNoViolations();
  });
});

// ── ScrollArea ────────────────────────────────────────────

describe("ScrollArea", () => {
  it("exposes a focusable, labelled region holding the content", async () => {
    const user = userEvent.setup();
    render(
      <ScrollArea aria-label="Order history" orientation="both">
        <p>Order 1</p>
      </ScrollArea>
    );
    const region = screen.getByRole("region", { name: "Order history" });
    expect(region).toHaveAttribute("tabindex", "0");
    expect(within(region).getByText("Order 1")).toBeInTheDocument();
    await user.tab();
    expect(region).toHaveFocus();
  });

  it("can be named by another element, and stays focusable without a name", () => {
    const { container, rerender } = render(
      <>
        <h2 id="log-title">Activity log</h2>
        <ScrollArea aria-labelledby="log-title">
          <p>Entry</p>
        </ScrollArea>
      </>
    );
    expect(screen.getByRole("region", { name: "Activity log" })).toHaveAttribute("tabindex", "0");

    rerender(
      <ScrollArea>
        <p>Entry</p>
      </ScrollArea>
    );
    // No name, so no (nameless) landmark — but still a keyboard stop.
    expect(screen.queryByRole("region")).not.toBeInTheDocument();
    expect(container.querySelector("[tabindex='0']")).toContainElement(screen.getByText("Entry"));
  });

  it("has no axe violations", async () => {
    const { container } = render(
      <ScrollArea aria-label="Order history">
        <p>Order 1</p>
      </ScrollArea>
    );
    expect(await axe(container)).toHaveNoViolations();
  });
});

// ── CountBadge ────────────────────────────────────────────

describe("CountBadge", () => {
  it("shows the count, capped at max", () => {
    const { rerender } = render(<CountBadge count={7} data-testid="badge" />);
    expect(screen.getByTestId("badge")).toHaveTextContent(/^7$/);
    rerender(<CountBadge count={99} data-testid="badge" />);
    expect(screen.getByTestId("badge")).toHaveTextContent(/^99$/);
    rerender(<CountBadge count={100} data-testid="badge" />);
    expect(screen.getByTestId("badge")).toHaveTextContent(/^99\+$/);
    rerender(<CountBadge count={12} max={9} tone="danger" data-testid="badge" />);
    expect(screen.getByTestId("badge")).toHaveTextContent(/^9\+$/);
    expect(screen.getByTestId("badge")).not.toHaveAttribute("tone");
    expect(screen.getByTestId("badge")).not.toHaveAttribute("max");
  });

  it("renders nothing at zero unless showZero", () => {
    const { container, rerender } = render(<CountBadge count={0} />);
    expect(container).toBeEmptyDOMElement();
    rerender(<CountBadge count={0} showZero data-testid="badge" />);
    expect(screen.getByTestId("badge")).toHaveTextContent(/^0$/);
  });

  it("reads its aria-label as text instead of the bare digits", () => {
    render(<CountBadge count={3} aria-label="3 unread" data-testid="badge" />);
    expect(screen.getByText("3 unread")).toBeInTheDocument();
    expect(screen.getByText("3", { selector: "[aria-hidden]" })).toBeInTheDocument();
    // aria-label is not valid on a role-less span.
    expect(screen.getByTestId("badge")).not.toHaveAttribute("aria-label");
  });

  it("has no axe violations", async () => {
    const { container } = render(
      <>
        <CountBadge count={3} aria-label="3 unread" />
        <CountBadge count={120} tone="muted" />
        <CountBadge count={0} showZero tone="danger" />
      </>
    );
    expect(await axe(container)).toHaveNoViolations();
  });
});

// ── FilterChip ────────────────────────────────────────────

describe("FilterChip", () => {
  it("is a toggle button that reports clicks and its active state", async () => {
    const user = userEvent.setup();
    const onClick = vi.fn();
    const { rerender } = render(<FilterChip label="Overdue" onClick={onClick} />);
    const chip = screen.getByRole("button", { name: "Overdue" });
    expect(chip).toHaveAttribute("aria-pressed", "false");
    await user.click(chip);
    expect(onClick).toHaveBeenCalledTimes(1);

    rerender(<FilterChip label="Overdue" active tone="warning" onClick={onClick} />);
    expect(chip).toHaveAttribute("aria-pressed", "true");
    expect(chip).not.toHaveAttribute("tone");
  });

  it("shows the value after the label, and the count", () => {
    render(<FilterChip label="Status" value="Open" count={2} dropdown />);
    const chip = screen.getByRole("button", { name: /Status/ });
    expect(chip).toHaveTextContent(/Status:\s*Open/);
    expect(chip).toHaveTextContent("2");
    // A dropdown chip is not a pressed/unpressed toggle.
    expect(chip).not.toHaveAttribute("aria-pressed");
  });

  it("puts clear in its own button, which does not trigger the chip's click", async () => {
    const user = userEvent.setup();
    const onClick = vi.fn();
    const onClear = vi.fn();
    render(<FilterChip label="Status" value="Open" active onClick={onClick} onClear={onClear} />);
    const chip = screen.getByRole("button", { name: /^Status:/ });
    const clear = screen.getByRole("button", { name: "Clear Status" });
    expect(chip).not.toContainElement(clear);
    expect(screen.getAllByRole("button")).toHaveLength(2);

    await user.click(clear);
    expect(onClear).toHaveBeenCalledTimes(1);
    expect(onClick).not.toHaveBeenCalled();

    await user.click(chip);
    expect(onClick).toHaveBeenCalledTimes(1);
    expect(onClear).toHaveBeenCalledTimes(1);
  });

  it("has no clear button without onClear, and disables both when disabled", async () => {
    const user = userEvent.setup();
    const onClick = vi.fn();
    const onClear = vi.fn();
    const { rerender } = render(<FilterChip label="Region" onClick={onClick} />);
    expect(screen.queryByRole("button", { name: "Clear Region" })).not.toBeInTheDocument();

    rerender(<FilterChip label="Region" disabled onClick={onClick} onClear={onClear} />);
    await user.click(screen.getByRole("button", { name: "Region" }));
    await user.click(screen.getByRole("button", { name: "Clear Region" }));
    expect(onClick).not.toHaveBeenCalled();
    expect(onClear).not.toHaveBeenCalled();
  });

  it("asChild renders the child element as the control, with the chip's content", async () => {
    const user = userEvent.setup();
    const onClick = vi.fn();
    const ref = React.createRef<HTMLButtonElement>();
    render(
      <FilterChip asChild label="Vendor" value="Acme" ref={ref} onClick={onClick}>
        <a href="#vendor">ignored</a>
      </FilterChip>
    );
    const link = screen.getByRole("link", { name: /Vendor/ });
    expect(link).toHaveAttribute("href", "#vendor");
    expect(link).toHaveTextContent(/Vendor:\s*Acme/);
    expect(link).not.toHaveTextContent("ignored");
    expect(ref.current).toBe(link);
    await user.click(link);
    expect(onClick).toHaveBeenCalledTimes(1);
  });

  it("has no axe violations", async () => {
    const { container } = render(
      <>
        <FilterChip label="Overdue" />
        <FilterChip label="Status" value="Open" active count={2} dropdown onClear={() => {}} />
        <FilterChip label="Late" tone="warning" active onClear={() => {}} />
      </>
    );
    expect(await axe(container)).toHaveNoViolations();
  });
});

// ── Kbd ───────────────────────────────────────────────────

describe("Kbd", () => {
  it("renders kbd elements, with a group wrapping the keys of a combination", () => {
    const { container } = render(
      <KbdGroup data-testid="combo">
        <Kbd>⌘</Kbd>
        <Kbd>K</Kbd>
      </KbdGroup>
    );
    const combo = screen.getByTestId("combo");
    expect(combo.tagName).toBe("KBD");
    expect(container.querySelectorAll("kbd kbd")).toHaveLength(2);
    expect(screen.getByText("K").tagName).toBe("KBD");
    expect(combo).toHaveTextContent("⌘K");
  });

  it("has no axe violations", async () => {
    const { container } = render(
      <p>
        Press <Kbd>Esc</Kbd> or{" "}
        <KbdGroup>
          <Kbd>⌘</Kbd>
          <Kbd>K</Kbd>
        </KbdGroup>
      </p>
    );
    expect(await axe(container)).toHaveNoViolations();
  });
});

// ── PageHeader ────────────────────────────────────────────

describe("PageHeader", () => {
  it("renders the title as an h1 by default, or an h2 on request", () => {
    const { rerender } = render(<PageHeader title="Orders" description="All purchase orders." />);
    expect(screen.getByRole("heading", { level: 1, name: "Orders" })).toBeInTheDocument();
    expect(screen.getByText("All purchase orders.")).toBeInTheDocument();

    rerender(<PageHeader title="Orders" as="h2" />);
    expect(screen.getByRole("heading", { level: 2, name: "Orders" })).toBeInTheDocument();
    expect(screen.queryByRole("heading", { level: 1 })).not.toBeInTheDocument();
  });

  it("renders back as a link when it has an href", () => {
    render(<PageHeader title="PO-1042" back={{ href: "/orders", label: "Back to orders" }} />);
    expect(screen.getByRole("link", { name: "Back to orders" })).toHaveAttribute("href", "/orders");
    expect(screen.queryByRole("button")).not.toBeInTheDocument();
  });

  it("renders back as a button calling onClick otherwise", async () => {
    const user = userEvent.setup();
    const onClick = vi.fn();
    render(<PageHeader title="PO-1042" back={{ onClick }} />);
    const back = screen.getByRole("button", { name: "Back" });
    expect(back).toHaveAttribute("type", "button");
    await user.click(back);
    expect(onClick).toHaveBeenCalledTimes(1);
    expect(screen.queryByRole("link")).not.toBeInTheDocument();
  });

  it("renders the breadcrumb, actions and tabs slots", () => {
    render(
      <PageHeader
        title="Orders"
        breadcrumb={<nav aria-label="Breadcrumb">Home</nav>}
        actions={<button type="button">New order</button>}
        tabs={<div data-testid="tabs">Tabs</div>}
        data-testid="header"
      />
    );
    const header = screen.getByTestId("header");
    expect(within(header).getByRole("navigation", { name: "Breadcrumb" })).toBeInTheDocument();
    expect(within(header).getByRole("button", { name: "New order" })).toBeInTheDocument();
    expect(within(header).getByTestId("tabs")).toBeInTheDocument();
    // `title` is the heading, not a tooltip attribute on the wrapper.
    expect(header).not.toHaveAttribute("title");
  });

  it("has no axe violations", async () => {
    const { container } = render(
      <main>
        <PageHeader
          title="PO-1042"
          description="Raised 14 Aug 2026."
          back={{ href: "/orders" }}
          actions={<button type="button">Approve</button>}
        />
      </main>
    );
    expect(await axe(container)).toHaveNoViolations();
  });
});

// ── FileUpload ────────────────────────────────────────────

const file = (name: string, type: string, size = 4) => new File(["x".repeat(size)], name, { type });
const fileInput = (container: HTMLElement) => container.querySelector<HTMLInputElement>("input[type='file']")!;
const dropzone = (container: HTMLElement) => fileInput(container).parentElement!;
const drop = (container: HTMLElement, files: File[]) =>
  fireEvent.drop(dropzone(container), { dataTransfer: { files } });

describe("FileUpload", () => {
  it("is driven by a labelled button; the native input stays out of the tab order", async () => {
    const user = userEvent.setup();
    const { container } = render(<FileUpload accept=".pdf" multiple hint="PDF, up to 5 MB" />);
    const input = fileInput(container);
    expect(input).toHaveAttribute("tabindex", "-1");
    expect(input).toHaveAttribute("accept", ".pdf");
    expect(input).toHaveAttribute("multiple");

    const button = screen.getByRole("button", { name: "Choose files" });
    expect(button).toHaveAccessibleDescription("PDF, up to 5 MB");
    await user.tab();
    expect(button).toHaveFocus();

    const click = vi.spyOn(input, "click").mockImplementation(() => {});
    await user.keyboard("{Enter}");
    expect(click).toHaveBeenCalledTimes(1);
  });

  it("collects files chosen through the input and lists them with a readable size", async () => {
    const user = userEvent.setup();
    const onFilesChange = vi.fn();
    const { container } = render(<FileUpload multiple onFilesChange={onFilesChange} />);
    const quote = file("quote.pdf", "application/pdf", 2048);
    const photo = file("photo.png", "image/png", 10);

    await user.upload(fileInput(container), [quote, photo]);
    expect(onFilesChange).toHaveBeenCalledExactlyOnceWith([quote, photo]);
    const rows = within(screen.getByRole("list", { name: "Selected files" })).getAllByRole("listitem");
    expect(rows).toHaveLength(2);
    expect(rows[0]).toHaveTextContent("quote.pdf");
    expect(rows[0]).toHaveTextContent("2 KB");
    expect(rows[1]).toHaveTextContent("10 B");
    expect(screen.getByRole("alert")).toBeEmptyDOMElement();
  });

  it("appends in multiple mode and replaces in single mode", async () => {
    const user = userEvent.setup();
    const a = file("a.pdf", "application/pdf");
    const b = file("b.pdf", "application/pdf");
    const multi = render(<FileUpload multiple />);
    await user.upload(fileInput(multi.container), a);
    await user.upload(fileInput(multi.container), b);
    expect(screen.getAllByRole("listitem")).toHaveLength(2);
    multi.unmount();

    const onFilesChange = vi.fn();
    const single = render(<FileUpload onFilesChange={onFilesChange} />);
    expect(screen.getByRole("button", { name: "Choose file" })).toBeInTheDocument();
    await user.upload(fileInput(single.container), a);
    await user.upload(fileInput(single.container), b);
    expect(onFilesChange).toHaveBeenLastCalledWith([b]);
    expect(screen.getAllByRole("listitem")).toHaveLength(1);
    expect(screen.getByRole("listitem")).toHaveTextContent("b.pdf");
  });

  it("accepts dropped files", () => {
    const onFilesChange = vi.fn();
    const { container } = render(<FileUpload multiple onFilesChange={onFilesChange} />);
    const a = file("a.pdf", "application/pdf");
    fireEvent.dragEnter(dropzone(container), { dataTransfer: { files: [a] } });
    expect(dropzone(container)).toHaveAttribute("data-dragging");
    drop(container, [a]);
    expect(dropzone(container)).not.toHaveAttribute("data-dragging");
    expect(onFilesChange).toHaveBeenCalledExactlyOnceWith([a]);
  });

  it("rejects by type and announces it", () => {
    const onFilesChange = vi.fn();
    const onReject = vi.fn();
    const { container } = render(
      <FileUpload multiple accept=".pdf,image/*" onFilesChange={onFilesChange} onReject={onReject} />
    );
    const pdf = file("spec.PDF", "application/pdf");
    const png = file("photo.png", "image/png");
    const exe = file("setup.exe", "application/x-msdownload");

    drop(container, [pdf, png, exe]);
    expect(onFilesChange).toHaveBeenCalledExactlyOnceWith([pdf, png]);
    expect(onReject).toHaveBeenCalledExactlyOnceWith([{ file: exe, reason: "type" }]);
    expect(screen.getByRole("alert")).toHaveTextContent("setup.exe");
    expect(screen.getAllByRole("listitem")).toHaveLength(2);
  });

  it("rejects by size and announces it", () => {
    const onFilesChange = vi.fn();
    const onReject = vi.fn();
    const { container } = render(<FileUpload maxSize={1024} onFilesChange={onFilesChange} onReject={onReject} />);
    const big = file("big.pdf", "application/pdf", 1025);

    drop(container, [big]);
    expect(onFilesChange).not.toHaveBeenCalled();
    expect(onReject).toHaveBeenCalledExactlyOnceWith([{ file: big, reason: "size" }]);
    expect(screen.getByRole("alert")).toHaveTextContent(/big\.pdf.*1 KB/);
    expect(screen.queryByRole("list")).not.toBeInTheDocument();

    // A file exactly at the limit passes, and clears the message.
    const ok = file("ok.pdf", "application/pdf", 1024);
    drop(container, [ok]);
    expect(onFilesChange).toHaveBeenCalledExactlyOnceWith([ok]);
    expect(screen.getByRole("alert")).toBeEmptyDOMElement();
  });

  it("rejects files beyond maxFiles and announces it", () => {
    const onFilesChange = vi.fn();
    const onReject = vi.fn();
    const { container } = render(
      <FileUpload multiple maxFiles={2} onFilesChange={onFilesChange} onReject={onReject} />
    );
    const [a, b, c] = ["a.pdf", "b.pdf", "c.pdf"].map((n) => file(n, "application/pdf"));

    drop(container, [a, b, c]);
    expect(onFilesChange).toHaveBeenCalledExactlyOnceWith([a, b]);
    expect(onReject).toHaveBeenCalledExactlyOnceWith([{ file: c, reason: "count" }]);
    expect(screen.getByRole("alert")).toHaveTextContent(/c\.pdf.*2 files/);

    // Already full: everything new is turned away.
    drop(container, [c]);
    expect(onFilesChange).toHaveBeenCalledTimes(1);
    expect(onReject).toHaveBeenLastCalledWith([{ file: c, reason: "count" }]);
  });

  it("every built-in string can be replaced through `labels`", async () => {
    const user = userEvent.setup();
    const labels = {
      dropPrompt: (multiple: boolean) => (multiple ? "Dateien hierher ziehen oder" : "Datei hierher ziehen oder"),
      browse: (multiple: boolean) => (multiple ? "Dateien wählen" : "Datei wählen"),
      selectedFiles: "Gewählte Dateien",
      remove: (name: string) => `${name} entfernen`,
      rejectedType: (name: string) => `${name}: Typ nicht erlaubt.`,
      rejectedSize: (name: string, max: string | undefined) => `${name}: größer als ${max}.`,
      rejectedCount: (name: string, limit: number) => `${name}: höchstens ${limit}.`
    };
    const { container } = render(<FileUpload multiple accept=".pdf" maxSize={1024} maxFiles={1} labels={labels} />);
    expect(screen.getByText("Dateien hierher ziehen oder")).toBeInTheDocument();
    expect(screen.getByRole("button", { name: "Dateien wählen" })).toBeInTheDocument();

    drop(container, [file("a.pdf", "application/pdf"), file("b.pdf", "application/pdf"), file("c.exe", "x/y"), file("d.pdf", "application/pdf", 2000)]);
    expect(screen.getByRole("list", { name: "Gewählte Dateien" })).toBeInTheDocument();
    const alert = screen.getByRole("alert");
    expect(alert).toHaveTextContent("c.exe: Typ nicht erlaubt.");
    expect(alert).toHaveTextContent("d.pdf: größer als 1 KB.");
    expect(alert).toHaveTextContent("b.pdf: höchstens 1.");

    await user.click(screen.getByRole("button", { name: "a.pdf entfernen" }));
    expect(screen.queryByRole("list")).not.toBeInTheDocument();
  });

  it("partial `labels` keep the English defaults, and `browseLabel` still wins for the button", () => {
    const { rerender } = render(<FileUpload labels={{ browse: () => "Parcourir" }} />);
    expect(screen.getByRole("button", { name: "Parcourir" })).toBeInTheDocument();
    expect(screen.getByText("Drag a file here, or")).toBeInTheDocument();
    rerender(<FileUpload labels={{ browse: () => "Parcourir" }} browseLabel="Upload quote" />);
    expect(screen.getByRole("button", { name: "Upload quote" })).toBeInTheDocument();
  });

  it("removes a file from its row", async () => {
    const user = userEvent.setup();
    const onFilesChange = vi.fn();
    const { container } = render(<FileUpload multiple onFilesChange={onFilesChange} />);
    const a = file("a.pdf", "application/pdf");
    const b = file("b.pdf", "application/pdf");
    drop(container, [a, b]);

    await user.click(screen.getByRole("button", { name: "Remove a.pdf" }));
    expect(onFilesChange).toHaveBeenLastCalledWith([b]);
    expect(screen.getAllByRole("listitem")).toHaveLength(1);
    expect(screen.queryByRole("button", { name: "Remove a.pdf" })).not.toBeInTheDocument();
    expect(screen.getByRole("button", { name: "Remove b.pdf" })).toBeInTheDocument();
  });

  it("shows a controlled value and leaves the list to the parent", async () => {
    const user = userEvent.setup();
    const onFilesChange = vi.fn();
    const a = file("a.pdf", "application/pdf");
    const b = file("b.pdf", "application/pdf");
    const { container, rerender } = render(<FileUpload multiple value={[a]} onFilesChange={onFilesChange} />);
    expect(screen.getByRole("listitem")).toHaveTextContent("a.pdf");

    drop(container, [b]);
    expect(onFilesChange).toHaveBeenLastCalledWith([a, b]);
    expect(screen.getAllByRole("listitem")).toHaveLength(1);

    await user.click(screen.getByRole("button", { name: "Remove a.pdf" }));
    expect(onFilesChange).toHaveBeenLastCalledWith([]);
    expect(screen.getAllByRole("listitem")).toHaveLength(1);

    rerender(<FileUpload multiple value={[a, b]} onFilesChange={onFilesChange} />);
    expect(screen.getAllByRole("listitem")).toHaveLength(2);
  });

  it("does nothing when disabled", () => {
    const onFilesChange = vi.fn();
    const onReject = vi.fn();
    const a = file("a.pdf", "application/pdf");
    const { container } = render(
      <FileUpload disabled multiple value={[a]} onFilesChange={onFilesChange} onReject={onReject} />
    );
    expect(screen.getByRole("button", { name: "Choose files" })).toBeDisabled();
    expect(fileInput(container)).toBeDisabled();
    expect(screen.getByRole("button", { name: "Remove a.pdf" })).toBeDisabled();

    fireEvent.dragEnter(dropzone(container), { dataTransfer: { files: [a] } });
    expect(dropzone(container)).not.toHaveAttribute("data-dragging");
    drop(container, [file("b.pdf", "application/pdf")]);
    expect(onFilesChange).not.toHaveBeenCalled();
    expect(onReject).not.toHaveBeenCalled();
  });

  it("takes its name, error and required state from a wrapping Field", async () => {
    const user = userEvent.setup();
    const { container } = render(
      <Field label="Attachments" error="Attach the signed quote." required>
        <FileUpload />
      </Field>
    );
    const button = screen.getByRole("button", { name: /Attachments/ });
    expect(button).toHaveAccessibleDescription("Attach the signed quote.");
    // A plain button does not support aria-invalid / aria-required: the error is
    // announced through the description and marked on the dropzone for styling.
    expect(button).not.toHaveAttribute("aria-invalid");
    expect(button).not.toHaveAttribute("aria-required");
    expect(container.querySelector("[data-invalid]")).not.toBeNull();

    // Clicking the field's label opens the picker, like any labelled control.
    const click = vi.spyOn(fileInput(container), "click").mockImplementation(() => {});
    await user.click(screen.getByText("Attachments"));
    expect(click).toHaveBeenCalledTimes(1);
  });

  it("has no axe violations — empty, with files and a rejection, and inside a Field", async () => {
    const view = render(
      <>
        <FileUpload hint="PDF, up to 5 MB" />
        <Field label="Attachments" error="Attach the signed quote.">
          <FileUpload multiple maxSize={2} value={[file("a.pdf", "application/pdf")]} />
        </Field>
      </>
    );
    fireEvent.drop(view.container.querySelectorAll<HTMLInputElement>("input[type='file']")[1].parentElement!, {
      dataTransfer: { files: [file("big.pdf", "application/pdf", 10)] }
    });
    expect(screen.getAllByRole("alert")[1]).toHaveTextContent("big.pdf");
    expect(await axe(view.container)).toHaveNoViolations();
  });
});

// ── Stepper ───────────────────────────────────────────────

const STEPS = [
  { label: "Cart" },
  { label: "Shipping", description: "Address and carrier" },
  { label: "Payment" },
  { label: "Review" }
];

describe("Stepper", () => {
  it("is an ordered list with aria-current on the current step only", () => {
    render(<Stepper steps={STEPS} current={1} aria-label="Checkout" />);
    const list = screen.getByRole("list", { name: "Checkout" });
    expect(list.tagName).toBe("OL");
    const items = within(list).getAllByRole("listitem");
    expect(items).toHaveLength(4);
    expect(items.map((li) => li.getAttribute("aria-current"))).toEqual([null, "step", null, null]);
    expect(items[1]).toHaveTextContent("Address and carrier");
  });

  it("tells assistive tech the state of each step", () => {
    render(<Stepper steps={STEPS} current={2} orientation="vertical" aria-label="Checkout" />);
    const items = screen.getAllByRole("listitem");
    expect(items[0]).toHaveTextContent("Completed: Cart");
    expect(items[1]).toHaveTextContent("Completed: Shipping");
    expect(items[2]).toHaveTextContent("Current: Payment");
    expect(items[3]).toHaveTextContent("Upcoming: Review");
    expect(screen.getByRole("list")).not.toHaveAttribute("orientation");
  });

  it("marks every step completed once current passes the end", () => {
    render(<Stepper steps={STEPS} current={STEPS.length} />);
    const items = screen.getAllByRole("listitem");
    expect(items.every((li) => li.textContent?.includes("Completed:"))).toBe(true);
    expect(items.some((li) => li.hasAttribute("aria-current"))).toBe(false);
  });

  it("has no buttons without onStepClick", () => {
    render(<Stepper steps={STEPS} current={2} />);
    expect(screen.queryByRole("button")).not.toBeInTheDocument();
  });

  it("makes only completed steps clickable", async () => {
    const user = userEvent.setup();
    const onStepClick = vi.fn();
    render(<Stepper steps={STEPS} current={2} onStepClick={onStepClick} />);
    const buttons = screen.getAllByRole("button");
    expect(buttons).toHaveLength(2);
    expect(buttons[0]).toHaveAccessibleName("Completed: Cart");
    expect(buttons[1]).toHaveAccessibleName(/Completed: Shipping/);

    await user.click(buttons[1]);
    expect(onStepClick).toHaveBeenCalledExactlyOnceWith(1);
    await user.tab({ shift: true });
    expect(buttons[0]).toHaveFocus();
    await user.keyboard("{Enter}");
    expect(onStepClick).toHaveBeenLastCalledWith(0);
    expect(onStepClick).toHaveBeenCalledTimes(2);

    // Current and upcoming steps are plain text.
    await user.click(screen.getByText("Payment"));
    await user.click(screen.getByText("Review"));
    expect(onStepClick).toHaveBeenCalledTimes(2);
  });

  it("has no axe violations in either orientation", async () => {
    const { container } = render(
      <>
        <Stepper steps={STEPS} current={1} aria-label="Checkout" onStepClick={() => {}} />
        <Stepper steps={STEPS} current={3} orientation="vertical" aria-label="Onboarding" />
      </>
    );
    expect(await axe(container)).toHaveNoViolations();
  });
});
