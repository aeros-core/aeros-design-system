import * as React from "react";
import { describe, expect, it } from "vitest";
import { render, screen } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { axe } from "jest-axe";
import {
  Accordion,
  AccordionContent,
  AccordionItem,
  AccordionTrigger,
  AlertDialog,
  AlertDialogAction,
  AlertDialogCancel,
  AlertDialogContent,
  AlertDialogDescription,
  AlertDialogFooter,
  AlertDialogHeader,
  AlertDialogTitle,
  AlertDialogTrigger,
  Button,
  Drawer,
  DrawerBody,
  DrawerContent,
  DrawerHeader,
  DrawerTitle,
  DrawerTrigger,
  Popover,
  PopoverContent,
  PopoverTrigger,
  toast,
  Toaster
} from "../src";

describe("Accordion", () => {
  it("expands on click with correct ARIA and passes axe", async () => {
    const user = userEvent.setup();
    const { container } = render(
      <Accordion type="single" collapsible>
        <AccordionItem value="a">
          <AccordionTrigger>Shipping policy</AccordionTrigger>
          <AccordionContent>Dispatch within 48 hours.</AccordionContent>
        </AccordionItem>
      </Accordion>
    );
    const trigger = screen.getByRole("button", { name: "Shipping policy" });
    expect(trigger).toHaveAttribute("aria-expanded", "false");
    await user.click(trigger);
    expect(trigger).toHaveAttribute("aria-expanded", "true");
    expect(screen.getByText("Dispatch within 48 hours.")).toBeVisible();
    expect(await axe(container)).toHaveNoViolations();
  });
});

describe("Popover", () => {
  it("opens from its trigger and closes on Escape", async () => {
    const user = userEvent.setup();
    render(
      <Popover>
        <PopoverTrigger asChild>
          <Button variant="secondary">Filters</Button>
        </PopoverTrigger>
        <PopoverContent>Filter options</PopoverContent>
      </Popover>
    );
    await user.click(screen.getByRole("button", { name: "Filters" }));
    expect(screen.getByText("Filter options")).toBeInTheDocument();
    await user.keyboard("{Escape}");
    expect(screen.queryByText("Filter options")).not.toBeInTheDocument();
  });
});

describe("AlertDialog", () => {
  it("is a modal alertdialog with no corner close and passes axe", async () => {
    const user = userEvent.setup();
    render(
      <AlertDialog>
        <AlertDialogTrigger asChild>
          <Button variant="danger">Delete</Button>
        </AlertDialogTrigger>
        <AlertDialogContent>
          <AlertDialogHeader>
            <AlertDialogTitle>Delete industry?</AlertDialogTitle>
            <AlertDialogDescription>This cannot be undone.</AlertDialogDescription>
          </AlertDialogHeader>
          <AlertDialogFooter>
            <AlertDialogCancel asChild><Button variant="secondary">Cancel</Button></AlertDialogCancel>
            <AlertDialogAction asChild><Button variant="danger">Delete</Button></AlertDialogAction>
          </AlertDialogFooter>
        </AlertDialogContent>
      </AlertDialog>
    );
    await user.click(screen.getByRole("button", { name: "Delete" }));
    const dialog = screen.getByRole("alertdialog", { name: "Delete industry?" });
    expect(dialog).toHaveAccessibleDescription("This cannot be undone.");
    expect(screen.queryByText("Close")).not.toBeInTheDocument();
    expect(await axe(dialog)).toHaveNoViolations();
  });
});

describe("Drawer", () => {
  it("opens as a dialog with a labelled title", async () => {
    const user = userEvent.setup();
    render(
      <Drawer>
        <DrawerTrigger asChild>
          <Button variant="secondary">Open details</Button>
        </DrawerTrigger>
        <DrawerContent>
          <DrawerHeader>
            <DrawerTitle>Order details</DrawerTitle>
          </DrawerHeader>
          <DrawerBody>Contents</DrawerBody>
        </DrawerContent>
      </Drawer>
    );
    await user.click(screen.getByRole("button", { name: "Open details" }));
    expect(screen.getByRole("dialog", { name: "Order details" })).toBeInTheDocument();
    await user.keyboard("{Escape}");
    expect(screen.queryByRole("dialog")).not.toBeInTheDocument();
  });
});

describe("Toast", () => {
  it("renders queued toasts as polite status content", async () => {
    render(<Toaster />);
    React.act(() => {
      toast({ title: "Saved", description: "Catalog updated.", variant: "success" });
    });
    expect(await screen.findByText("Saved")).toBeInTheDocument();
    expect(screen.getByText("Catalog updated.")).toBeInTheDocument();
    expect(screen.getByRole("button", { name: "Dismiss" })).toBeInTheDocument();
  });
});
