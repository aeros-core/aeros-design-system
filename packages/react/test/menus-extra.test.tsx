import { render, screen } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { describe, expect, it, vi } from "vitest";
import {
  DropdownMenu,
  DropdownMenuCheckboxItem,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuRadioGroup,
  DropdownMenuRadioItem,
  DropdownMenuShortcut,
  DropdownMenuTrigger,
  Tooltip,
  TooltipContent,
  TooltipProvider,
  TooltipTrigger
} from "../src";

describe("DropdownMenu — checkbox, radio and shortcut items", () => {
  it("a checkbox item reports and toggles its checked state", async () => {
    const onCheckedChange = vi.fn();
    render(
      <DropdownMenu defaultOpen>
        <DropdownMenuTrigger>Open</DropdownMenuTrigger>
        <DropdownMenuContent>
          <DropdownMenuCheckboxItem checked onCheckedChange={onCheckedChange}>
            Show archived
          </DropdownMenuCheckboxItem>
          <DropdownMenuCheckboxItem>Show drafts</DropdownMenuCheckboxItem>
        </DropdownMenuContent>
      </DropdownMenu>
    );
    const archived = screen.getByRole("menuitemcheckbox", { name: "Show archived" });
    expect(archived).toHaveAttribute("aria-checked", "true");
    expect(screen.getByRole("menuitemcheckbox", { name: "Show drafts" })).toHaveAttribute("aria-checked", "false");
    await userEvent.click(archived);
    expect(onCheckedChange).toHaveBeenCalledWith(false);
  });

  it("radio items are mutually exclusive and report the chosen value", async () => {
    const onValueChange = vi.fn();
    render(
      <DropdownMenu defaultOpen>
        <DropdownMenuTrigger>Open</DropdownMenuTrigger>
        <DropdownMenuContent>
          <DropdownMenuRadioGroup value="comfortable" onValueChange={onValueChange}>
            <DropdownMenuRadioItem value="compact">Compact</DropdownMenuRadioItem>
            <DropdownMenuRadioItem value="comfortable">Comfortable</DropdownMenuRadioItem>
          </DropdownMenuRadioGroup>
        </DropdownMenuContent>
      </DropdownMenu>
    );
    expect(screen.getByRole("menuitemradio", { name: "Comfortable" })).toHaveAttribute("aria-checked", "true");
    expect(screen.getByRole("menuitemradio", { name: "Compact" })).toHaveAttribute("aria-checked", "false");
    await userEvent.click(screen.getByRole("menuitemradio", { name: "Compact" }));
    expect(onValueChange).toHaveBeenCalledWith("compact");
  });

  it("a shortcut hint does not become part of the item's accessible name", () => {
    render(
      <DropdownMenu defaultOpen>
        <DropdownMenuTrigger>Open</DropdownMenuTrigger>
        <DropdownMenuContent>
          <DropdownMenuItem>
            Settings <DropdownMenuShortcut>⌘,</DropdownMenuShortcut>
          </DropdownMenuItem>
        </DropdownMenuContent>
      </DropdownMenu>
    );
    expect(screen.getByRole("menuitem", { name: "Settings" })).toBeInTheDocument();
  });
});

describe("Tooltip — arrow", () => {
  it("renders with an arrow without changing the tooltip's text", () => {
    render(
      <TooltipProvider>
        <Tooltip open>
          <TooltipTrigger>Trigger</TooltipTrigger>
          <TooltipContent arrow>Helpful</TooltipContent>
        </Tooltip>
      </TooltipProvider>
    );
    expect(screen.getByRole("tooltip")).toHaveTextContent("Helpful");
  });
});
