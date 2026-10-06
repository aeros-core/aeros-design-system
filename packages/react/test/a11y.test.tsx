import * as React from "react";
import { describe, expect, it } from "vitest";
import { render, screen } from "@testing-library/react";
import { axe } from "jest-axe";
import {
  Alert,
  Button,
  Field,
  Input,
  Label,
  Pagination,
  SelectTrigger,
  Select,
  SidebarItem,
  SidebarSection,
  Skeleton,
  Spinner,
  Table,
  Tbody,
  Td,
  Th,
  Thead,
  Tr,
  Textarea
} from "../src";

describe("Field wiring (APG form pattern)", () => {
  it("links label, hint and control; error switches describedby and sets aria-invalid", () => {
    const { rerender } = render(
      <Field label="Email" hint="Work address preferred" required>
        <Input placeholder="you@aeros.dev" />
      </Field>
    );
    const input = screen.getByLabelText(/Email/);
    expect(input).toHaveAccessibleDescription("Work address preferred");
    expect(input).toHaveAttribute("aria-required", "true");
    expect(input).not.toHaveAttribute("aria-invalid");

    rerender(
      <Field label="Email" hint="Work address preferred" error="Enter a valid address" required>
        <Input placeholder="you@aeros.dev" />
      </Field>
    );
    const invalid = screen.getByLabelText(/Email/);
    expect(invalid).toHaveAttribute("aria-invalid", "true");
    expect(invalid).toHaveAccessibleDescription("Enter a valid address");
  });

  it("wires Textarea and SelectTrigger the same way", () => {
    render(
      <>
        <Field label="Notes" error="Required">
          <Textarea />
        </Field>
        <Field label="Region" hint="Where you ship from">
          <Select>
            <SelectTrigger>Region</SelectTrigger>
          </Select>
        </Field>
      </>
    );
    expect(screen.getByLabelText("Notes")).toHaveAttribute("aria-invalid", "true");
    expect(screen.getByLabelText("Region")).toHaveAccessibleDescription("Where you ship from");
  });

  it("form composite has no axe violations", async () => {
    const { container } = render(
      <form>
        <Field label="Name" hint="As on the GST certificate">
          <Input />
        </Field>
        <Field label="Notes" error="Required">
          <Textarea />
        </Field>
        <Button type="submit">Save</Button>
      </form>
    );
    expect(await axe(container)).toHaveNoViolations();
  });
});

describe("Alert live-region roles", () => {
  it("is a polite status region by default and assertive only for danger", () => {
    render(
      <>
        <Alert variant="info" title="Heads up">New RFQ available.</Alert>
        <Alert variant="danger" title="Failed">Line 4 halted.</Alert>
      </>
    );
    expect(screen.getByRole("status")).toHaveTextContent("Heads up");
    expect(screen.getByRole("alert")).toHaveTextContent("Failed");
  });
});

describe("Button", () => {
  it("announces the loading state and leaves the tab order", () => {
    render(<Button loading>Saving</Button>);
    const button = screen.getByRole("button", { hidden: true });
    expect(button).toHaveAttribute("aria-busy", "true");
    expect(button).toBeDisabled();
    expect(screen.getByText("Loading")).toHaveClass("sr-only");
  });

  it("link variant sheds the size box (regression: cva/tailwind-merge ordering)", () => {
    render(<Button variant="link">Docs</Button>);
    const cls = screen.getByRole("button").className;
    expect(cls).toContain("h-auto");
    expect(cls).not.toContain("h-9");
    expect(cls).toContain("px-0");
  });
});

describe("Table semantics", () => {
  it("sets scope, aria-sort and selected state", () => {
    render(
      <Table>
        <Thead>
          <Tr>
            <Th sortable sortDirection="asc" onSort={() => {}}>Order</Th>
            <Th>Status</Th>
          </Tr>
        </Thead>
        <Tbody>
          <Tr selected>
            <Td>#1042</Td>
            <Td>Packed</Td>
          </Tr>
        </Tbody>
      </Table>
    );
    const [sorted, plain] = screen.getAllByRole("columnheader");
    expect(sorted).toHaveAttribute("scope", "col");
    expect(sorted).toHaveAttribute("aria-sort", "ascending");
    expect(plain).not.toHaveAttribute("aria-sort");
    expect(screen.getByRole("row", { selected: true })).toBeInTheDocument();
  });
});

describe("Pagination", () => {
  it("marks the current page and disables the rail ends", async () => {
    const { container } = render(<Pagination page={1} count={12} />);
    expect(screen.getByRole("button", { name: "Page 1" })).toHaveAttribute("aria-current", "page");
    expect(screen.getByRole("button", { name: "Previous page" })).toBeDisabled();
    expect(screen.getByRole("button", { name: "Next page" })).toBeEnabled();
    expect(await axe(container)).toHaveNoViolations();
  });
});

describe("Navigation items", () => {
  it("renders a real button when no href is given, a link when it is", () => {
    render(
      <>
        <SidebarItem active>Dashboard</SidebarItem>
        <SidebarItem href="/orders">Orders</SidebarItem>
      </>
    );
    expect(screen.getByRole("button", { name: "Dashboard" })).toHaveAttribute("aria-current", "page");
    expect(screen.getByRole("link", { name: "Orders" })).toHaveAttribute("href", "/orders");
  });

  it("announces a count with its label, and shows none at zero", async () => {
    const { container } = render(
      <SidebarSection label="Floor">
        <SidebarItem href="/inbox" count={3}>Inbox</SidebarItem>
        <SidebarItem href="/queue" count={0}>Queue</SidebarItem>
      </SidebarSection>
    );
    expect(screen.getByRole("link", { name: /^Inbox\s*,\s*3$/ })).toBeInTheDocument();
    expect(screen.getByRole("link", { name: "Queue" })).toBeInTheDocument();
    expect(screen.getByRole("group", { name: "Floor" })).toBeInTheDocument();
    expect(await axe(container)).toHaveNoViolations();
  });
});

describe("Status affordances", () => {
  it("Spinner announces, Skeleton hides", () => {
    render(
      <>
        <Spinner label="Loading orders" />
        <Skeleton data-testid="skeleton" className="h-4 w-24" />
      </>
    );
    expect(screen.getByRole("status")).toHaveTextContent("Loading orders");
    expect(screen.getByTestId("skeleton")).toHaveAttribute("aria-hidden", "true");
  });

  it("Label associates with its control", () => {
    render(
      <>
        <Label htmlFor="qty">Quantity</Label>
        <Input id="qty" />
      </>
    );
    expect(screen.getByLabelText("Quantity")).toBeInTheDocument();
  });
});
