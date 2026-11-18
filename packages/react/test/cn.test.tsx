import { describe, expect, it } from "vitest";
import { cn } from "../src/lib/cn";

describe("cn", () => {
  it("keeps a type role next to a text colour", () => {
    expect(cn("text-body-sm text-fg-muted")).toBe("text-body-sm text-fg-muted");
    expect(cn("text-fg-muted", "text-label-xs")).toBe("text-fg-muted text-label-xs");
  });

  it("lets a later type role, colour, radius or shadow win over an earlier one", () => {
    expect(cn("text-body-sm", "text-body-md")).toBe("text-body-md");
    expect(cn("text-sm", "text-body-md")).toBe("text-body-md");
    expect(cn("text-fg-muted", "text-fg-primary")).toBe("text-fg-primary");
    expect(cn("rounded-md", "rounded-control")).toBe("rounded-control");
    expect(cn("rounded-control", "rounded-full")).toBe("rounded-full");
    expect(cn("shadow-raised", "shadow-overlay")).toBe("shadow-overlay");
  });

  it("merges token-named sizes, z-index, duration and easing", () => {
    expect(cn("h-9", "h-control-md")).toBe("h-control-md");
    expect(cn("h-control-sm", "h-control-lg")).toBe("h-control-lg");
    expect(cn("size-4", "size-icon-md")).toBe("size-icon-md");
    expect(cn("z-10", "z-modal")).toBe("z-modal");
    expect(cn("duration-150", "duration-fast")).toBe("duration-fast");
    expect(cn("ease-standard", "ease-enter")).toBe("ease-enter");
  });

  it("still handles conditionals and unrelated classes", () => {
    const off = false as boolean;
    expect(cn("px-2", off && "px-4", ["py-1", { hidden: off }])).toBe("px-2 py-1");
    expect(cn("bg-bg-surface", "bg-state-hover")).toBe("bg-state-hover");
  });
});
