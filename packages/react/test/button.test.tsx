import { render, screen } from "@testing-library/react";
import { axe } from "jest-axe";
import { describe, expect, it, vi } from "vitest";
import { Button, Field, FieldGroup, Input } from "../src";
import { lazyChild } from "./lazy-child";

describe("Button", () => {
  it("asChild renders the child element as the button, with icons inside it", () => {
    render(
      <Button asChild leadingIcon={<svg data-testid="lead" />} trailingIcon={<svg data-testid="trail" />}>
        <a href="/orders/new">New order</a>
      </Button>
    );
    const link = screen.getByRole("link", { name: "New order" });
    expect(link).toHaveAttribute("href", "/orders/new");
    expect(link).toContainElement(screen.getByTestId("lead"));
    expect(link).toContainElement(screen.getByTestId("trail"));
    expect(screen.queryByRole("button")).toBeNull();
  });

  // From a Server Component the child arrives as a lazy reference, not an
  // element. Regression: with an icon the button used to render nothing at all.
  it("asChild renders a child that arrives as a lazy (server) reference, icons included", () => {
    const ref = { current: null as HTMLButtonElement | null };
    render(
      <Button asChild ref={ref} className="extra" leadingIcon={<svg data-testid="lead" />} trailingIcon={<svg data-testid="trail" />}>
        {lazyChild(
          <a href="/orders/new" className="own">
            New order
          </a>
        )}
      </Button>
    );
    const link = screen.getByRole("link", { name: "New order" });
    expect(link).toHaveAttribute("href", "/orders/new");
    expect(link).toHaveClass("extra", "own");
    expect(link).toContainElement(screen.getByTestId("lead"));
    expect(link).toContainElement(screen.getByTestId("trail"));
    expect(ref.current).toBe(link);
  });

  it("asChild merges the child's own handlers and keeps icon order around the label", async () => {
    const onButton = vi.fn();
    const onChild = vi.fn();
    render(
      <Button asChild onClick={onButton} leadingIcon={<svg data-testid="lead" />} trailingIcon={<svg data-testid="trail" />}>
        <a href="#x" onClick={onChild}>
          Go
        </a>
      </Button>
    );
    const link = screen.getByRole("link", { name: "Go" });
    link.click();
    expect(onButton).toHaveBeenCalledTimes(1);
    expect(onChild).toHaveBeenCalledTimes(1);
    expect(link.firstElementChild).toBe(screen.getByTestId("lead"));
    expect(link.lastElementChild).toBe(screen.getByTestId("trail"));
  });

  it("iconOnly keeps the accessible name from aria-label", async () => {
    const { container } = render(
      <Button iconOnly aria-label="Settings">
        <svg aria-hidden />
      </Button>
    );
    expect(screen.getByRole("button", { name: "Settings" })).toBeInTheDocument();
    expect(await axe(container)).toHaveNoViolations();
  });

  it("loading disables the button, marks it busy and announces once", () => {
    render(<Button loading leadingIcon={<svg data-testid="lead" />}>Save</Button>);
    const button = screen.getByRole("button", { name: /save/i });
    expect(button).toBeDisabled();
    expect(button).toHaveAttribute("aria-busy", "true");
    expect(screen.getAllByText("Loading")).toHaveLength(1);
    expect(screen.queryByTestId("lead")).toBeNull();
  });

  it("every variant renders a button", () => {
    for (const variant of ["primary", "secondary", "ghost", "danger", "danger-subtle", "link"] as const) {
      const { unmount } = render(<Button variant={variant}>{variant}</Button>);
      expect(screen.getByRole("button", { name: variant })).toBeEnabled();
      unmount();
    }
  });
});

describe("FieldGroup", () => {
  it("stacks fields that stay wired to their labels", () => {
    render(
      <FieldGroup data-testid="group">
        <Field label="Name"><Input /></Field>
        <Field label="Email" error="Required"><Input /></Field>
      </FieldGroup>
    );
    expect(screen.getByTestId("group").children).toHaveLength(2);
    expect(screen.getByLabelText("Name")).toBeInTheDocument();
    expect(screen.getByLabelText("Email")).toHaveAttribute("aria-invalid", "true");
  });
});
