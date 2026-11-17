import * as React from "react";
import { describe, expect, it, vi } from "vitest";
import { render, screen, waitFor, within } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { axe } from "jest-axe";
import {
  Button,
  Dialog,
  DialogBody,
  DialogClose,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
  Tooltip,
  TooltipContent,
  TooltipProvider,
  TooltipTrigger
} from "../src";

// Behaviour + semantics only. No class-name or pixel assertions.

function EditDialog({
  showClose,
  ...rootProps
}: React.ComponentProps<typeof Dialog> & { showClose?: boolean }) {
  return (
    <Dialog {...rootProps}>
      <DialogTrigger asChild>
        <Button variant="secondary">Edit profile</Button>
      </DialogTrigger>
      <DialogContent showClose={showClose}>
        <DialogHeader>
          <DialogTitle>Edit profile</DialogTitle>
          <DialogDescription>Changes apply to every workspace.</DialogDescription>
        </DialogHeader>
        <DialogBody>
          <label htmlFor="display-name">Display name</label>
          <input id="display-name" />
        </DialogBody>
        <DialogFooter>
          <DialogClose asChild>
            <Button variant="secondary">Cancel</Button>
          </DialogClose>
          <Button>Save</Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  );
}

describe("Dialog", () => {
  it("is closed until its trigger is clicked", async () => {
    const user = userEvent.setup();
    render(<EditDialog />);
    const trigger = screen.getByRole("button", { name: "Edit profile" });
    expect(trigger).toHaveAttribute("aria-haspopup", "dialog");
    expect(trigger).toHaveAttribute("aria-expanded", "false");
    expect(screen.queryByRole("dialog")).not.toBeInTheDocument();

    await user.click(trigger);
    expect(screen.getByRole("dialog")).toBeInTheDocument();
    expect(trigger).toHaveAttribute("aria-expanded", "true");
  });

  it("takes its accessible name from DialogTitle and description from DialogDescription", async () => {
    const user = userEvent.setup();
    render(<EditDialog />);
    await user.click(screen.getByRole("button", { name: "Edit profile" }));
    const dialog = screen.getByRole("dialog", { name: "Edit profile" });
    expect(dialog).toHaveAccessibleDescription("Changes apply to every workspace.");
    expect(within(dialog).getByRole("heading", { name: "Edit profile" })).toBeInTheDocument();
  });

  it("moves focus into the dialog and hides the rest of the page from assistive tech", async () => {
    const user = userEvent.setup();
    render(
      <>
        <main data-testid="page">
          <a href="/elsewhere">Elsewhere</a>
        </main>
        <EditDialog />
      </>
    );
    await user.click(screen.getByRole("button", { name: "Edit profile" }));
    const dialog = screen.getByRole("dialog");
    expect(dialog).toContainElement(document.activeElement as HTMLElement);
    expect(screen.getByTestId("page").closest('[aria-hidden="true"]')).not.toBeNull();
    expect(dialog.closest('[aria-hidden="true"]')).toBeNull();
    expect(screen.queryByRole("link", { name: "Elsewhere" })).not.toBeInTheDocument();
  });

  it("traps Tab inside the dialog in both directions", async () => {
    const user = userEvent.setup();
    render(
      <>
        <a href="/elsewhere">Elsewhere</a>
        <EditDialog />
      </>
    );
    await user.click(screen.getByRole("button", { name: "Edit profile" }));
    const dialog = screen.getByRole("dialog");
    for (let i = 0; i < 6; i++) {
      await user.tab();
      expect(dialog).toContainElement(document.activeElement as HTMLElement);
    }
    for (let i = 0; i < 6; i++) {
      await user.tab({ shift: true });
      expect(dialog).toContainElement(document.activeElement as HTMLElement);
    }
  });

  it("closes on Escape and returns focus to the trigger", async () => {
    const user = userEvent.setup();
    const onOpenChange = vi.fn();
    render(<EditDialog onOpenChange={onOpenChange} />);
    const trigger = screen.getByRole("button", { name: "Edit profile" });
    await user.click(trigger);
    expect(onOpenChange).toHaveBeenLastCalledWith(true);

    await user.keyboard("{Escape}");
    expect(screen.queryByRole("dialog")).not.toBeInTheDocument();
    expect(onOpenChange).toHaveBeenLastCalledWith(false);
    expect(trigger).toHaveFocus();
  });

  it("has a corner Close button by default that closes the dialog", async () => {
    const user = userEvent.setup();
    render(<EditDialog />);
    await user.click(screen.getByRole("button", { name: "Edit profile" }));
    await user.click(screen.getByRole("button", { name: "Close" }));
    expect(screen.queryByRole("dialog")).not.toBeInTheDocument();
  });

  it("the corner Close button is keyboard-operable", async () => {
    const user = userEvent.setup();
    render(<EditDialog />);
    await user.click(screen.getByRole("button", { name: "Edit profile" }));
    screen.getByRole("button", { name: "Close" }).focus();
    await user.keyboard("{Enter}");
    expect(screen.queryByRole("dialog")).not.toBeInTheDocument();
  });

  it("showClose=false removes the corner button but Escape and DialogClose still work", async () => {
    const user = userEvent.setup();
    render(<EditDialog showClose={false} />);
    const trigger = screen.getByRole("button", { name: "Edit profile" });
    await user.click(trigger);
    const dialog = screen.getByRole("dialog");
    expect(within(dialog).queryByRole("button", { name: "Close" })).not.toBeInTheDocument();
    // `showClose` is a behaviour prop: it must not leak onto the DOM.
    expect(dialog).not.toHaveAttribute("showclose");

    await user.click(within(dialog).getByRole("button", { name: "Cancel" }));
    expect(screen.queryByRole("dialog")).not.toBeInTheDocument();

    await user.click(trigger);
    await user.keyboard("{Escape}");
    expect(screen.queryByRole("dialog")).not.toBeInTheDocument();
  });

  it("closes when the backdrop is pressed, unless the caller prevents it", async () => {
    const user = userEvent.setup({ pointerEventsCheck: 0 });
    const { unmount } = render(<EditDialog />);
    await user.click(screen.getByRole("button", { name: "Edit profile" }));
    await user.click(document.body);
    expect(screen.queryByRole("dialog")).not.toBeInTheDocument();
    unmount();

    render(
      <Dialog defaultOpen>
        <DialogContent onInteractOutside={(e) => e.preventDefault()}>
          <DialogTitle>Sticky</DialogTitle>
          <DialogDescription>Must be answered.</DialogDescription>
        </DialogContent>
      </Dialog>
    );
    await user.click(document.body);
    expect(screen.getByRole("dialog", { name: "Sticky" })).toBeInTheDocument();
  });

  it("follows a controlled `open` prop and reports close requests without closing itself", async () => {
    const user = userEvent.setup();
    const onOpenChange = vi.fn();
    const { rerender } = render(<EditDialog open={false} onOpenChange={onOpenChange} />);
    expect(screen.queryByRole("dialog")).not.toBeInTheDocument();

    rerender(<EditDialog open onOpenChange={onOpenChange} />);
    expect(screen.getByRole("dialog", { name: "Edit profile" })).toBeInTheDocument();

    await user.keyboard("{Escape}");
    expect(onOpenChange).toHaveBeenCalledExactlyOnceWith(false);
    expect(screen.getByRole("dialog")).toBeInTheDocument();
  });

  it("opens immediately with defaultOpen", () => {
    render(<EditDialog defaultOpen />);
    expect(screen.getByRole("dialog", { name: "Edit profile" })).toBeInTheDocument();
  });

  it("content inside the dialog stays interactive", async () => {
    const user = userEvent.setup();
    render(<EditDialog defaultOpen />);
    const input = screen.getByLabelText("Display name");
    await user.type(input, "Parth");
    expect(input).toHaveValue("Parth");
    expect(screen.getByRole("dialog")).toBeInTheDocument();
  });

  it("the open dialog has no axe violations, with and without the corner close", async () => {
    const { unmount } = render(<EditDialog defaultOpen />);
    expect(await axe(screen.getByRole("dialog"))).toHaveNoViolations();
    unmount();
    render(<EditDialog defaultOpen showClose={false} />);
    expect(await axe(screen.getByRole("dialog"))).toHaveNoViolations();
  });
});

function Tip({
  onOpenChange,
  disabled,
  disableHoverableContent
}: {
  onOpenChange?: (open: boolean) => void;
  disabled?: boolean;
  disableHoverableContent?: boolean;
}) {
  return (
    <TooltipProvider delayDuration={0} skipDelayDuration={0} disableHoverableContent={disableHoverableContent}>
      <button type="button">Before</button>
      <Tooltip onOpenChange={onOpenChange}>
        <TooltipTrigger asChild>
          <Button variant="secondary" aria-label="Copy link" disabled={disabled}>
            ⧉
          </Button>
        </TooltipTrigger>
        <TooltipContent>Copy to clipboard</TooltipContent>
      </Tooltip>
    </TooltipProvider>
  );
}

describe("Tooltip", () => {
  it("is not rendered until the trigger is focused or hovered", () => {
    render(<Tip />);
    expect(screen.queryByRole("tooltip")).not.toBeInTheDocument();
    expect(screen.queryByText("Copy to clipboard")).not.toBeInTheDocument();
    expect(screen.getByRole("button", { name: "Copy link" })).not.toHaveAttribute("aria-describedby");
  });

  it("shows on keyboard focus with role=tooltip and describes its trigger", async () => {
    const user = userEvent.setup();
    const onOpenChange = vi.fn();
    render(<Tip onOpenChange={onOpenChange} />);
    await user.tab();
    await user.tab();
    const trigger = screen.getByRole("button", { name: "Copy link" });
    expect(trigger).toHaveFocus();

    const tooltip = await screen.findByRole("tooltip");
    expect(tooltip).toHaveTextContent("Copy to clipboard");
    expect(trigger).toHaveAttribute("aria-describedby", tooltip.id);
    expect(trigger).toHaveAccessibleDescription("Copy to clipboard");
    // The tooltip adds a description; it must not replace the trigger's name.
    expect(trigger).toHaveAccessibleName("Copy link");
    expect(onOpenChange).toHaveBeenLastCalledWith(true);
  });

  it("hides when focus leaves the trigger", async () => {
    const user = userEvent.setup();
    const onOpenChange = vi.fn();
    render(<Tip onOpenChange={onOpenChange} />);
    await user.tab();
    await user.tab();
    expect(await screen.findByRole("tooltip")).toBeInTheDocument();
    await user.tab({ shift: true });
    expect(screen.queryByRole("tooltip")).not.toBeInTheDocument();
    expect(onOpenChange).toHaveBeenLastCalledWith(false);
  });

  it("dismisses on Escape while keeping focus on the trigger", async () => {
    const user = userEvent.setup();
    render(<Tip />);
    await user.tab();
    await user.tab();
    expect(await screen.findByRole("tooltip")).toBeInTheDocument();
    await user.keyboard("{Escape}");
    expect(screen.queryByRole("tooltip")).not.toBeInTheDocument();
    expect(screen.getByRole("button", { name: "Copy link" })).toHaveFocus();
  });

  it("shows on pointer hover", async () => {
    const user = userEvent.setup();
    render(<Tip />);
    await user.hover(screen.getByRole("button", { name: "Copy link" }));
    expect(await screen.findByRole("tooltip")).toHaveTextContent("Copy to clipboard");
  });

  // With hoverable content (the default) Radix keeps the tooltip open while the
  // pointer crosses a "grace polygon" computed from element rects, which jsdom
  // cannot lay out; pointer-leave is therefore asserted with that feature off.
  it("hides on pointer leave when hoverable content is disabled", async () => {
    const user = userEvent.setup();
    render(<Tip disableHoverableContent />);
    const trigger = screen.getByRole("button", { name: "Copy link" });
    await user.hover(trigger);
    expect(await screen.findByRole("tooltip")).toBeInTheDocument();
    await user.unhover(trigger);
    await waitFor(() => expect(screen.queryByRole("tooltip")).not.toBeInTheDocument());
  });

  it("does not open for a disabled trigger", async () => {
    const user = userEvent.setup();
    render(<Tip disabled />);
    await user.tab();
    await user.tab();
    expect(screen.getByRole("button", { name: "Copy link" })).not.toHaveFocus();
    expect(screen.queryByRole("tooltip")).not.toBeInTheDocument();
  });

  it("hides when the trigger is activated", async () => {
    const user = userEvent.setup();
    render(<Tip />);
    const trigger = screen.getByRole("button", { name: "Copy link" });
    await user.hover(trigger);
    expect(await screen.findByRole("tooltip")).toBeInTheDocument();
    await user.click(trigger);
    expect(screen.queryByRole("tooltip")).not.toBeInTheDocument();
  });

  it("follows a controlled `open` prop", () => {
    const { rerender } = render(
      <TooltipProvider>
        <Tooltip open>
          <TooltipTrigger>Info</TooltipTrigger>
          <TooltipContent>Details</TooltipContent>
        </Tooltip>
      </TooltipProvider>
    );
    expect(screen.getByRole("tooltip")).toHaveTextContent("Details");
    rerender(
      <TooltipProvider>
        <Tooltip open={false}>
          <TooltipTrigger>Info</TooltipTrigger>
          <TooltipContent>Details</TooltipContent>
        </Tooltip>
      </TooltipProvider>
    );
    expect(screen.queryByRole("tooltip")).not.toBeInTheDocument();
  });

  it("the open tooltip and its trigger have no axe violations", async () => {
    const user = userEvent.setup();
    const { container } = render(<Tip />);
    await user.tab();
    await user.tab();
    const tooltip = await screen.findByRole("tooltip");
    expect(await axe(container)).toHaveNoViolations();
    // The tooltip is portalled out of the container: check its content node too.
    expect(await axe(tooltip.parentElement as HTMLElement)).toHaveNoViolations();
  });
});
