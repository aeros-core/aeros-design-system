import * as React from "react";
import { describe, expect, it, vi } from "vitest";
import { render, screen, within } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { axe } from "jest-axe";
import {
  Checkbox,
  Field,
  Label,
  RadioGroup,
  RadioGroupItem,
  Select,
  SelectContent,
  SelectGroup,
  SelectItem,
  SelectLabel,
  SelectSeparator,
  SelectTrigger,
  SelectValue,
  Switch,
  Textarea
} from "../src";

// Behaviour + semantics only. No class-name or pixel assertions: the redesign
// is free to change every class string in these components.

function RegionSelect(
  props: React.ComponentProps<typeof Select> & {
    triggerProps?: Partial<React.ComponentProps<typeof SelectTrigger>>;
  }
) {
  const { triggerProps, ...rootProps } = props;
  return (
    <Select {...rootProps}>
      <SelectTrigger aria-label="Region" {...triggerProps}>
        <SelectValue placeholder="Pick a region" />
      </SelectTrigger>
      <SelectContent>
        <SelectGroup>
          <SelectLabel>India</SelectLabel>
          <SelectItem value="west">West</SelectItem>
          <SelectItem value="south">South</SelectItem>
          <SelectItem value="north" disabled>
            North
          </SelectItem>
        </SelectGroup>
        <SelectSeparator />
        <SelectItem value="export">Export</SelectItem>
      </SelectContent>
    </Select>
  );
}

describe("Select", () => {
  it("is a collapsed combobox showing its placeholder until a value is chosen", () => {
    render(<RegionSelect />);
    const trigger = screen.getByRole("combobox", { name: "Region" });
    expect(trigger).toHaveAttribute("aria-expanded", "false");
    expect(trigger).toHaveTextContent("Pick a region");
    expect(screen.queryByRole("listbox")).not.toBeInTheDocument();
  });

  it("opens on click, lists options, and shows the chosen value", async () => {
    const user = userEvent.setup();
    const onValueChange = vi.fn();
    render(<RegionSelect onValueChange={onValueChange} />);
    const trigger = screen.getByRole("combobox", { name: "Region" });

    await user.click(trigger);
    expect(trigger).toHaveAttribute("aria-expanded", "true");
    const listbox = screen.getByRole("listbox");
    expect(within(listbox).getAllByRole("option")).toHaveLength(4);
    expect(within(listbox).getByRole("group", { name: "India" })).toBeInTheDocument();

    await user.click(within(listbox).getByRole("option", { name: "South" }));
    expect(onValueChange).toHaveBeenCalledExactlyOnceWith("south");
    expect(screen.queryByRole("listbox")).not.toBeInTheDocument();
    expect(trigger).toHaveAttribute("aria-expanded", "false");
    expect(trigger).toHaveTextContent("South");
  });

  it.each(["{Enter}", " ", "{ArrowDown}"])("opens from the keyboard with %j", async (key) => {
    const user = userEvent.setup();
    render(<RegionSelect />);
    await user.tab();
    expect(screen.getByRole("combobox", { name: "Region" })).toHaveFocus();
    await user.keyboard(key);
    expect(await screen.findByRole("listbox")).toBeInTheDocument();
  });

  it("chooses an item with arrow keys + Enter and returns focus to the trigger", async () => {
    const user = userEvent.setup();
    const onValueChange = vi.fn();
    render(<RegionSelect defaultValue="west" onValueChange={onValueChange} />);
    const trigger = screen.getByRole("combobox", { name: "Region" });
    expect(trigger).toHaveTextContent("West");

    await user.tab();
    await user.keyboard("{Enter}");
    const listbox = await screen.findByRole("listbox");
    expect(within(listbox).getByRole("option", { name: "West" })).toHaveAttribute("aria-selected", "true");
    expect(within(listbox).getByRole("option", { name: "West" })).toHaveFocus();

    await user.keyboard("{ArrowDown}");
    expect(within(listbox).getByRole("option", { name: "South" })).toHaveFocus();
    await user.keyboard("{Enter}");

    expect(onValueChange).toHaveBeenCalledExactlyOnceWith("south");
    expect(screen.queryByRole("listbox")).not.toBeInTheDocument();
    expect(trigger).toHaveTextContent("South");
    expect(trigger).toHaveFocus();
  });

  it("skips disabled items from the keyboard and ignores clicks on them", async () => {
    const user = userEvent.setup();
    const onValueChange = vi.fn();
    render(<RegionSelect defaultValue="south" onValueChange={onValueChange} />);
    await user.tab();
    await user.keyboard("{Enter}");
    const listbox = await screen.findByRole("listbox");
    const north = within(listbox).getByRole("option", { name: "North" });
    expect(north).toHaveAttribute("aria-disabled", "true");

    // South -> (North is disabled) -> Export
    await user.keyboard("{ArrowDown}");
    expect(within(listbox).getByRole("option", { name: "Export" })).toHaveFocus();

    await user.click(north);
    expect(onValueChange).not.toHaveBeenCalled();
  });

  it("closes on Escape without changing the value", async () => {
    const user = userEvent.setup();
    const onValueChange = vi.fn();
    render(<RegionSelect defaultValue="west" onValueChange={onValueChange} />);
    const trigger = screen.getByRole("combobox", { name: "Region" });
    await user.click(trigger);
    expect(screen.getByRole("listbox")).toBeInTheDocument();
    await user.keyboard("{Escape}");
    expect(screen.queryByRole("listbox")).not.toBeInTheDocument();
    expect(onValueChange).not.toHaveBeenCalled();
    expect(trigger).toHaveTextContent("West");
  });

  it("does not open when disabled", async () => {
    const user = userEvent.setup();
    render(<RegionSelect disabled />);
    const trigger = screen.getByRole("combobox", { name: "Region" });
    expect(trigger).toBeDisabled();
    await user.click(trigger);
    expect(screen.queryByRole("listbox")).not.toBeInTheDocument();
    expect(trigger).toHaveAttribute("aria-expanded", "false");
  });

  it("follows a controlled value", () => {
    const { rerender } = render(<RegionSelect value="west" onValueChange={() => {}} />);
    expect(screen.getByRole("combobox", { name: "Region" })).toHaveTextContent("West");
    rerender(<RegionSelect value="export" onValueChange={() => {}} />);
    expect(screen.getByRole("combobox", { name: "Region" })).toHaveTextContent("Export");
  });

  it.each(["sm", "md", "lg"] as const)("size=%s keeps combobox semantics and still opens", async (size) => {
    const user = userEvent.setup();
    render(<RegionSelect triggerProps={{ size }} />);
    const trigger = screen.getByRole("combobox", { name: "Region" });
    // `size` is a styling prop: it must not leak onto the DOM button.
    expect(trigger).not.toHaveAttribute("size");
    await user.click(trigger);
    expect(screen.getByRole("listbox")).toBeInTheDocument();
  });

  it("state=error marks the trigger invalid; default and success do not", () => {
    const { rerender } = render(<RegionSelect triggerProps={{ state: "error" }} />);
    expect(screen.getByRole("combobox", { name: "Region" })).toHaveAttribute("aria-invalid", "true");
    rerender(<RegionSelect triggerProps={{ state: "success" }} />);
    expect(screen.getByRole("combobox", { name: "Region" })).not.toHaveAttribute("aria-invalid");
    rerender(<RegionSelect triggerProps={{ state: "default" }} />);
    expect(screen.getByRole("combobox", { name: "Region" })).not.toHaveAttribute("state");
    expect(screen.getByRole("combobox", { name: "Region" })).not.toHaveAttribute("aria-invalid");
  });

  it("takes its name, error and required state from a wrapping Field", () => {
    render(
      <Field label="Region" error="Choose a region" required>
        <Select>
          <SelectTrigger>
            <SelectValue placeholder="Pick a region" />
          </SelectTrigger>
          <SelectContent>
            <SelectItem value="west">West</SelectItem>
          </SelectContent>
        </Select>
      </Field>
    );
    const trigger = screen.getByRole("combobox", { name: /Region/ });
    expect(trigger).toHaveAttribute("aria-invalid", "true");
    expect(trigger).toHaveAttribute("aria-required", "true");
    expect(trigger).toHaveAccessibleDescription("Choose a region");
  });

  it("has no axe violations closed or open", async () => {
    const user = userEvent.setup();
    const { container } = render(<RegionSelect defaultValue="west" />);
    expect(await axe(container)).toHaveNoViolations();
    await user.click(screen.getByRole("combobox", { name: "Region" }));
    expect(await axe(screen.getByRole("listbox"))).toHaveNoViolations();
  });
});

describe("Checkbox", () => {
  it("toggles with click and Space and reports the new state", async () => {
    const user = userEvent.setup();
    const onCheckedChange = vi.fn();
    render(<Checkbox aria-label="Accept terms" onCheckedChange={onCheckedChange} />);
    const box = screen.getByRole("checkbox", { name: "Accept terms" });
    expect(box).toHaveAttribute("aria-checked", "false");

    await user.click(box);
    expect(box).toHaveAttribute("aria-checked", "true");
    expect(onCheckedChange).toHaveBeenLastCalledWith(true);

    await user.keyboard(" ");
    expect(box).toHaveAttribute("aria-checked", "false");
    expect(onCheckedChange).toHaveBeenLastCalledWith(false);
    expect(onCheckedChange).toHaveBeenCalledTimes(2);
  });

  it("exposes indeterminate as aria-checked=mixed and resolves to checked on click", async () => {
    const user = userEvent.setup();
    const onCheckedChange = vi.fn();
    render(<Checkbox aria-label="Select all" defaultChecked="indeterminate" onCheckedChange={onCheckedChange} />);
    const box = screen.getByRole("checkbox", { name: "Select all" });
    expect(box).toHaveAttribute("aria-checked", "mixed");
    await user.click(box);
    expect(box).toHaveAttribute("aria-checked", "true");
    expect(onCheckedChange).toHaveBeenLastCalledWith(true);
  });

  it("follows a controlled checked prop, including indeterminate", () => {
    const { rerender } = render(<Checkbox aria-label="Rows" checked={false} onCheckedChange={() => {}} />);
    const box = screen.getByRole("checkbox", { name: "Rows" });
    rerender(<Checkbox aria-label="Rows" checked="indeterminate" onCheckedChange={() => {}} />);
    expect(box).toHaveAttribute("aria-checked", "mixed");
    rerender(<Checkbox aria-label="Rows" checked onCheckedChange={() => {}} />);
    expect(box).toHaveAttribute("aria-checked", "true");
  });

  it("is inert when disabled", async () => {
    const user = userEvent.setup();
    const onCheckedChange = vi.fn();
    render(<Checkbox aria-label="Accept terms" disabled onCheckedChange={onCheckedChange} />);
    const box = screen.getByRole("checkbox", { name: "Accept terms" });
    expect(box).toBeDisabled();
    await user.click(box);
    expect(box).toHaveAttribute("aria-checked", "false");
    expect(onCheckedChange).not.toHaveBeenCalled();
    await user.tab();
    expect(box).not.toHaveFocus();
  });

  it("is named and toggled by an associated Label", async () => {
    const user = userEvent.setup();
    render(
      <div>
        <Checkbox id="terms" />
        <Label htmlFor="terms">Accept terms</Label>
      </div>
    );
    const box = screen.getByRole("checkbox", { name: "Accept terms" });
    await user.click(screen.getByText("Accept terms"));
    expect(box).toHaveAttribute("aria-checked", "true");
  });

  // axe runs on aria-label'd controls: jest-axe bundles axe-core 4.9, whose
  // `button-name` rule does not yet count <label for> as a name for the
  // <button role="checkbox|radio|switch"> Radix renders (the name itself is
  // computed correctly, as the Label tests here assert).
  it("has no axe violations unchecked, checked, indeterminate or disabled", async () => {
    const { container } = render(
      <div>
        <Checkbox aria-label="Unchecked" />
        <Checkbox aria-label="Checked" defaultChecked />
        <Checkbox aria-label="Mixed" defaultChecked="indeterminate" />
        <Checkbox aria-label="Disabled" disabled />
      </div>
    );
    expect(await axe(container)).toHaveNoViolations();
  });

  it("submits its value with a form", async () => {
    const user = userEvent.setup();
    let submitted: FormData | undefined;
    render(
      <form
        onSubmit={(e) => {
          e.preventDefault();
          submitted = new FormData(e.currentTarget);
        }}
      >
        <Checkbox aria-label="Subscribe" name="subscribe" value="yes" />
        <button type="submit">Save</button>
      </form>
    );
    await user.click(screen.getByRole("checkbox", { name: "Subscribe" }));
    await user.click(screen.getByRole("button", { name: "Save" }));
    expect(submitted?.get("subscribe")).toBe("yes");
  });
});

function Plans(props: React.ComponentProps<typeof RadioGroup>) {
  return (
    <RadioGroup aria-label="Plan" {...props}>
      <div>
        <RadioGroupItem id="plan-starter" value="starter" />
        <Label htmlFor="plan-starter">Starter</Label>
      </div>
      <div>
        <RadioGroupItem id="plan-growth" value="growth" />
        <Label htmlFor="plan-growth">Growth</Label>
      </div>
      <div>
        <RadioGroupItem id="plan-legacy" value="legacy" disabled />
        <Label htmlFor="plan-legacy">Legacy</Label>
      </div>
      <div>
        <RadioGroupItem id="plan-scale" value="scale" />
        <Label htmlFor="plan-scale">Scale</Label>
      </div>
    </RadioGroup>
  );
}

// Radix moves roving focus in a timeout and only checks the newly focused radio
// while the arrow key is still held, as it is for a real key press. Keep the
// key down across that tick instead of user-event's instant press+release.
async function arrow(user: ReturnType<typeof userEvent.setup>, key: string) {
  await user.keyboard(`{${key}>}`);
  await user.keyboard(`{/${key}}`);
}

describe("RadioGroup", () => {
  it("is a named radiogroup with nothing selected by default", () => {
    render(<Plans />);
    const group = screen.getByRole("radiogroup", { name: "Plan" });
    const radios = within(group).getAllByRole("radio");
    expect(radios).toHaveLength(4);
    radios.forEach((r) => expect(r).toHaveAttribute("aria-checked", "false"));
  });

  it("allows only one selection at a time", async () => {
    const user = userEvent.setup();
    const onValueChange = vi.fn();
    render(<Plans onValueChange={onValueChange} />);
    await user.click(screen.getByRole("radio", { name: "Starter" }));
    expect(onValueChange).toHaveBeenLastCalledWith("starter");
    await user.click(screen.getByRole("radio", { name: "Growth" }));
    expect(onValueChange).toHaveBeenLastCalledWith("growth");
    expect(screen.getAllByRole("radio", { checked: true })).toHaveLength(1);
    expect(screen.getByRole("radio", { name: "Growth" })).toBeChecked();
    expect(screen.getByRole("radio", { name: "Starter" })).not.toBeChecked();
  });

  it("moves selection with arrow keys, skipping disabled items and wrapping", async () => {
    const user = userEvent.setup();
    const onValueChange = vi.fn();
    render(<Plans defaultValue="starter" onValueChange={onValueChange} />);

    // The group is a single tab stop on the checked item.
    await user.tab();
    expect(screen.getByRole("radio", { name: "Starter" })).toHaveFocus();

    await arrow(user, "ArrowDown");
    expect(screen.getByRole("radio", { name: "Growth" })).toHaveFocus();
    expect(screen.getByRole("radio", { name: "Growth" })).toBeChecked();

    await arrow(user, "ArrowRight");
    expect(screen.getByRole("radio", { name: "Scale" })).toHaveFocus();
    expect(screen.getByRole("radio", { name: "Scale" })).toBeChecked();
    expect(screen.getByRole("radio", { name: "Legacy" })).not.toBeChecked();

    await arrow(user, "ArrowDown");
    expect(screen.getByRole("radio", { name: "Starter" })).toBeChecked();

    await arrow(user, "ArrowUp");
    expect(screen.getByRole("radio", { name: "Scale" })).toBeChecked();
    expect(screen.getAllByRole("radio", { checked: true })).toHaveLength(1);
    expect(onValueChange.mock.calls.map((c) => c[0])).toEqual(["growth", "scale", "starter", "scale"]);

    await user.tab();
    expect(document.body).toHaveFocus();
  });

  it("disabled item cannot be chosen; disabled group disables every item", async () => {
    const user = userEvent.setup();
    const onValueChange = vi.fn();
    const { rerender } = render(<Plans onValueChange={onValueChange} />);
    const legacy = screen.getByRole("radio", { name: "Legacy" });
    expect(legacy).toBeDisabled();
    await user.click(legacy);
    expect(onValueChange).not.toHaveBeenCalled();

    rerender(<Plans disabled onValueChange={onValueChange} />);
    screen.getAllByRole("radio").forEach((r) => expect(r).toBeDisabled());
    await user.click(screen.getByRole("radio", { name: "Starter" }));
    expect(onValueChange).not.toHaveBeenCalled();
  });

  it("has no axe violations", async () => {
    const { container } = render(
      <RadioGroup aria-label="Plan" defaultValue="growth">
        <RadioGroupItem value="starter" aria-label="Starter" />
        <RadioGroupItem value="growth" aria-label="Growth" />
        <RadioGroupItem value="legacy" aria-label="Legacy" disabled />
      </RadioGroup>
    );
    expect(await axe(container)).toHaveNoViolations();
  });
});

describe("Switch", () => {
  it("is a switch that toggles with click, Space and Enter", async () => {
    const user = userEvent.setup();
    const onCheckedChange = vi.fn();
    render(<Switch aria-label="Notifications" onCheckedChange={onCheckedChange} />);
    const sw = screen.getByRole("switch", { name: "Notifications" });
    expect(sw).toHaveAttribute("aria-checked", "false");

    await user.click(sw);
    expect(sw).toHaveAttribute("aria-checked", "true");
    expect(onCheckedChange).toHaveBeenLastCalledWith(true);

    await user.keyboard(" ");
    expect(sw).toHaveAttribute("aria-checked", "false");
    await user.keyboard("{Enter}");
    expect(sw).toHaveAttribute("aria-checked", "true");
    expect(onCheckedChange).toHaveBeenCalledTimes(3);
  });

  it("honours defaultChecked and a controlled checked prop", () => {
    const { rerender } = render(<Switch aria-label="A" defaultChecked />);
    expect(screen.getByRole("switch", { name: "A" })).toBeChecked();
    rerender(<Switch aria-label="A" checked={false} onCheckedChange={() => {}} />);
    expect(screen.getByRole("switch", { name: "A" })).not.toBeChecked();
  });

  it("is inert when disabled", async () => {
    const user = userEvent.setup();
    const onCheckedChange = vi.fn();
    render(<Switch aria-label="Notifications" disabled onCheckedChange={onCheckedChange} />);
    const sw = screen.getByRole("switch", { name: "Notifications" });
    expect(sw).toBeDisabled();
    await user.click(sw);
    expect(sw).toHaveAttribute("aria-checked", "false");
    expect(onCheckedChange).not.toHaveBeenCalled();
  });

  it("is named and toggled by a Label", async () => {
    const user = userEvent.setup();
    render(
      <div>
        <Switch id="notify" />
        <Label htmlFor="notify">Email me</Label>
      </div>
    );
    await user.click(screen.getByText("Email me"));
    expect(screen.getByRole("switch", { name: "Email me" })).toBeChecked();
  });

  it("has no axe violations off, on or disabled", async () => {
    const { container } = render(
      <div>
        <Switch aria-label="Off" />
        <Switch aria-label="On" defaultChecked />
        <Switch aria-label="Disabled" disabled />
      </div>
    );
    expect(await axe(container)).toHaveNoViolations();
  });
});

describe("Textarea", () => {
  it("is a multiline textbox that accepts typing", async () => {
    const user = userEvent.setup();
    const onChange = vi.fn();
    render(<Textarea aria-label="Notes" onChange={onChange} />);
    const box = screen.getByRole("textbox", { name: "Notes" });
    expect(box.tagName).toBe("TEXTAREA");
    await user.type(box, "Line 1{Enter}Line 2");
    expect(box).toHaveValue("Line 1\nLine 2");
    expect(onChange).toHaveBeenCalled();
  });

  it("is labelled by its Field and described by the hint", () => {
    render(
      <Field label="Notes" hint="Visible to the buyer">
        <Textarea />
      </Field>
    );
    const box = screen.getByLabelText("Notes");
    expect(box).toHaveAccessibleDescription("Visible to the buyer");
    expect(box).not.toHaveAttribute("aria-invalid");
    expect(box).not.toHaveAttribute("aria-required");
  });

  it("switches to the error message and aria-invalid when the Field errors", () => {
    const { rerender } = render(
      <Field label="Notes" hint="Visible to the buyer" required>
        <Textarea />
      </Field>
    );
    expect(screen.getByLabelText(/Notes/)).toHaveAttribute("aria-required", "true");
    rerender(
      <Field label="Notes" hint="Visible to the buyer" error="Notes are required" required>
        <Textarea />
      </Field>
    );
    const box = screen.getByLabelText(/Notes/);
    expect(box).toHaveAttribute("aria-invalid", "true");
    expect(box).toHaveAccessibleDescription("Notes are required");
    expect(screen.queryByText("Visible to the buyer")).not.toBeInTheDocument();
  });

  it("keeps a caller-supplied aria-describedby alongside the Field hint", () => {
    render(
      <>
        <p id="extra">Markdown supported</p>
        <Field label="Notes" hint="Visible to the buyer">
          <Textarea aria-describedby="extra" />
        </Field>
      </>
    );
    expect(screen.getByLabelText("Notes")).toHaveAccessibleDescription(
      "Markdown supported Visible to the buyer"
    );
  });

  it("stays labelled when the caller sets its own id via Field htmlFor", () => {
    render(
      <Field label="Notes" htmlFor="notes-box">
        <Textarea id="notes-box" />
      </Field>
    );
    expect(screen.getByLabelText("Notes")).toHaveAttribute("id", "notes-box");
  });

  it("state=error sets aria-invalid outside a Field; success and size do not leak", () => {
    const { rerender } = render(<Textarea aria-label="Notes" state="error" />);
    const box = screen.getByRole("textbox", { name: "Notes" });
    expect(box).toHaveAttribute("aria-invalid", "true");
    rerender(<Textarea aria-label="Notes" state="success" size="lg" />);
    expect(box).not.toHaveAttribute("aria-invalid");
    expect(box).not.toHaveAttribute("state");
    expect(box).not.toHaveAttribute("size");
  });

  it("cannot be typed into when disabled", async () => {
    const user = userEvent.setup();
    render(<Textarea aria-label="Notes" disabled />);
    const box = screen.getByRole("textbox", { name: "Notes" });
    expect(box).toBeDisabled();
    await user.type(box, "nope");
    expect(box).toHaveValue("");
  });

  it("forwards its ref to the textarea element", () => {
    const ref = React.createRef<HTMLTextAreaElement>();
    render(<Textarea aria-label="Notes" ref={ref} />);
    expect(ref.current).toBe(screen.getByRole("textbox", { name: "Notes" }));
  });

  it("has no axe violations in hint and error states", async () => {
    const { container } = render(
      <>
        <Field label="Notes" hint="Visible to the buyer">
          <Textarea />
        </Field>
        <Field label="Reason" error="Required" required>
          <Textarea />
        </Field>
      </>
    );
    expect(await axe(container)).toHaveNoViolations();
  });
});
