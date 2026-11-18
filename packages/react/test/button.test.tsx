import { render, screen } from "@testing-library/react";
import { axe } from "jest-axe";
import { describe, expect, it } from "vitest";
import { Button, Field, FieldGroup, Input } from "../src";

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
