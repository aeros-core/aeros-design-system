import * as React from "react";
import { describe, expect, it, vi } from "vitest";
import { render, screen, within } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { axe } from "jest-axe";
import {
  Avatar,
  AvatarStack,
  Badge,
  Button,
  Card,
  CardBody,
  CardFooter,
  CardHeader,
  CardSubtitle,
  CardTitle,
  DotMatrix,
  EmptyState,
  Progress,
  Separator,
  StatCard,
  Tag
} from "../src";

// Behaviour + semantics only. No class-name or pixel assertions.

describe("Progress", () => {
  it("is a progressbar reporting its value on a 0-100 scale", () => {
    render(<Progress aria-label="Upload" value={42} />);
    const bar = screen.getByRole("progressbar", { name: "Upload" });
    expect(bar).toHaveAttribute("aria-valuenow", "42");
    expect(bar).toHaveAttribute("aria-valuemin", "0");
    expect(bar).toHaveAttribute("aria-valuemax", "100");
  });

  it("defaults to 0 and tracks value changes up to complete", () => {
    const { rerender } = render(<Progress aria-label="Upload" />);
    const bar = screen.getByRole("progressbar", { name: "Upload" });
    expect(bar).toHaveAttribute("aria-valuenow", "0");
    rerender(<Progress aria-label="Upload" value={100} />);
    expect(bar).toHaveAttribute("aria-valuenow", "100");
  });

  it("honours a custom max", () => {
    render(<Progress aria-label="Steps" value={3} max={5} />);
    const bar = screen.getByRole("progressbar", { name: "Steps" });
    expect(bar).toHaveAttribute("aria-valuenow", "3");
    expect(bar).toHaveAttribute("aria-valuemax", "5");
  });

  it("value=null is indeterminate: no aria-valuenow", () => {
    render(<Progress aria-label="Syncing" value={null} />);
    expect(screen.getByRole("progressbar", { name: "Syncing" })).not.toHaveAttribute("aria-valuenow");
  });

  it.each(["brand", "success", "warning", "danger"] as const)(
    "variant=%s keeps progressbar semantics and does not leak to the DOM",
    (variant) => {
      render(<Progress aria-label="Upload" value={10} variant={variant} />);
      const bar = screen.getByRole("progressbar", { name: "Upload" });
      expect(bar).toHaveAttribute("aria-valuenow", "10");
      expect(bar).not.toHaveAttribute("variant");
    }
  );

  it("has no axe violations", async () => {
    const { container } = render(<Progress aria-label="Upload" value={42} />);
    expect(await axe(container)).toHaveNoViolations();
  });
});

describe("Avatar", () => {
  it("renders fallback initials when there is no image", () => {
    render(<Avatar fallback="PP" />);
    expect(screen.getByText("PP")).toBeInTheDocument();
    expect(screen.queryByRole("img")).not.toBeInTheDocument();
  });

  it("shows the fallback while a src has not loaded (jsdom never loads images)", () => {
    render(<Avatar src="https://example.com/p.png" alt="Parth Panchal" fallback="PP" />);
    expect(screen.getByText("PP")).toBeInTheDocument();
  });

  it("accepts a non-text fallback node", () => {
    render(<Avatar fallback={<svg data-testid="glyph" aria-hidden="true" />} />);
    expect(screen.getByTestId("glyph")).toBeInTheDocument();
  });

  it.each(["xs", "sm", "md", "lg", "xl"] as const)("size=%s still renders the fallback", (size) => {
    render(<Avatar size={size} variant="inverse" fallback="AB" data-testid="avatar" />);
    const avatar = screen.getByTestId("avatar");
    expect(avatar).toHaveTextContent("AB");
    expect(avatar).not.toHaveAttribute("size");
    expect(avatar).not.toHaveAttribute("variant");
  });

  it("forwards ref and arbitrary props to the root", () => {
    const ref = React.createRef<HTMLSpanElement>();
    render(<Avatar ref={ref} fallback="PP" aria-label="Parth Panchal" role="img" />);
    expect(screen.getByRole("img", { name: "Parth Panchal" })).toBe(ref.current);
  });

  it("has no axe violations", async () => {
    const { container } = render(<Avatar fallback="PP" />);
    expect(await axe(container)).toHaveNoViolations();
  });
});

describe("AvatarStack", () => {
  it("renders every avatar's fallback in order", () => {
    render(
      <AvatarStack data-testid="stack">
        <Avatar fallback="AA" />
        <Avatar fallback="BB" />
        <Avatar fallback="CC" />
      </AvatarStack>
    );
    const stack = screen.getByTestId("stack");
    expect(stack.children).toHaveLength(3);
    expect(Array.from(stack.children).map((c) => c.textContent)).toEqual(["AA", "BB", "CC"]);
  });

  it("can be named as a group by the caller, with no axe violations", async () => {
    const { container } = render(
      <AvatarStack role="group" aria-label="Assignees">
        <Avatar fallback="AA" />
        <Avatar fallback="BB" />
      </AvatarStack>
    );
    expect(within(screen.getByRole("group", { name: "Assignees" })).getByText("BB")).toBeInTheDocument();
    expect(await axe(container)).toHaveNoViolations();
  });
});

describe("Badge", () => {
  it("renders its children", () => {
    render(<Badge>Packed</Badge>);
    expect(screen.getByText("Packed")).toBeInTheDocument();
  });

  it("adds exactly one extra child for the dot, and none without it", () => {
    const { rerender } = render(<Badge data-testid="badge">Packed</Badge>);
    const badge = screen.getByTestId("badge");
    expect(badge.childElementCount).toBe(0);
    rerender(
      <Badge data-testid="badge" dot>
        Packed
      </Badge>
    );
    expect(badge.childElementCount).toBe(1);
    // The dot is decorative: the badge's text is unchanged.
    expect(badge).toHaveTextContent(/^Packed$/);
    expect(badge).not.toHaveAttribute("dot");
  });

  it.each(["success", "warning", "danger", "info", "neutral", "inverse"] as const)(
    "variant=%s renders children and dot without leaking props",
    (variant) => {
      render(
        <Badge data-testid="badge" variant={variant} dot>
          Status
        </Badge>
      );
      const badge = screen.getByTestId("badge");
      expect(badge).toHaveTextContent("Status");
      expect(badge.childElementCount).toBe(1);
      expect(badge).not.toHaveAttribute("variant");
    }
  );

  it("forwards ref and arbitrary props", () => {
    const ref = React.createRef<HTMLSpanElement>();
    render(
      <Badge ref={ref} title="3 unread">
        3
      </Badge>
    );
    expect(screen.getByTitle("3 unread")).toBe(ref.current);
  });

  it("has no axe violations", async () => {
    const { container } = render(
      <Badge variant="success" dot>
        Packed
      </Badge>
    );
    expect(await axe(container)).toHaveNoViolations();
  });
});

describe("Tag", () => {
  it.each([undefined, "info", "neutral", "inverse"] as const)("variant=%s renders its children", (variant) => {
    render(
      <Tag data-testid="tag" variant={variant}>
        Paper cups
      </Tag>
    );
    const tag = screen.getByTestId("tag");
    expect(tag).toHaveTextContent("Paper cups");
    expect(tag).not.toHaveAttribute("variant");
  });

  it("forwards ref and props, with no axe violations", async () => {
    const ref = React.createRef<HTMLSpanElement>();
    const { container } = render(
      <Tag ref={ref} title="Category">
        Paper cups
      </Tag>
    );
    expect(screen.getByTitle("Category")).toBe(ref.current);
    expect(await axe(container)).toHaveNoViolations();
  });
});

describe("Card", () => {
  function Full(props: React.ComponentProps<typeof Card>) {
    return (
      <Card data-testid="card" {...props}>
        <CardHeader>
          <div>
            <CardTitle>Order #1042</CardTitle>
            <CardSubtitle>Placed 3 Nov</CardSubtitle>
          </div>
        </CardHeader>
        <CardBody>24 cartons</CardBody>
        <CardFooter>
          <Button>View</Button>
        </CardFooter>
      </Card>
    );
  }

  it("CardTitle is a heading and the other slots render their content", () => {
    render(<Full />);
    expect(screen.getByRole("heading", { name: "Order #1042" })).toBeInTheDocument();
    expect(screen.getByText("Placed 3 Nov")).toBeInTheDocument();
    expect(screen.getByText("24 cartons")).toBeInTheDocument();
    expect(screen.getByRole("button", { name: "View" })).toBeInTheDocument();
  });

  it("a plain card adds no role of its own and can be named as a region", () => {
    const { rerender } = render(<Full />);
    expect(screen.getByTestId("card")).not.toHaveAttribute("role");
    rerender(<Full role="region" aria-label="Order summary" />);
    expect(screen.getByRole("region", { name: "Order summary" })).toBeInTheDocument();
  });

  it("an interactive card forwards clicks and does not leak the prop to the DOM", async () => {
    const user = userEvent.setup();
    const onClick = vi.fn();
    render(<Full interactive onClick={onClick} />);
    const card = screen.getByTestId("card");
    expect(card).not.toHaveAttribute("interactive");
    await user.click(screen.getByText("24 cartons"));
    expect(onClick).toHaveBeenCalledTimes(1);
  });

  it("an interactive card can be made a keyboard-operable link by the caller", async () => {
    const user = userEvent.setup();
    const onKeyDown = vi.fn();
    render(
      <Card interactive role="link" tabIndex={0} aria-label="Open order" onKeyDown={onKeyDown}>
        <CardBody>24 cartons</CardBody>
      </Card>
    );
    await user.tab();
    expect(screen.getByRole("link", { name: "Open order" })).toHaveFocus();
    await user.keyboard("{Enter}");
    expect(onKeyDown).toHaveBeenCalledTimes(1);
  });

  // DEFECT (a11y, WCAG 2.1.1 Keyboard): `interactive` advertises the card as
  // clickable (pointer cursor + hover lift, "use for clickable cards") but adds
  // no tabIndex/role and no Enter/Space handling, so <Card interactive onClick>
  // is mouse-only unless every caller wires keyboard access by hand.
  // Cause: packages/react/src/components/card.tsx:10-20.
  it.fails("an interactive card with onClick is reachable and operable from the keyboard", async () => {
    const user = userEvent.setup();
    const onClick = vi.fn();
    render(<Full interactive onClick={onClick} />);
    const card = screen.getByTestId("card");
    await user.tab();
    expect(card).toHaveFocus();
    await user.keyboard("{Enter}");
    expect(onClick).toHaveBeenCalledTimes(1);
  });

  it("forwards refs on every part", () => {
    const refs = {
      card: React.createRef<HTMLDivElement>(),
      header: React.createRef<HTMLDivElement>(),
      title: React.createRef<HTMLHeadingElement>(),
      subtitle: React.createRef<HTMLParagraphElement>(),
      body: React.createRef<HTMLDivElement>(),
      footer: React.createRef<HTMLDivElement>()
    };
    render(
      <Card ref={refs.card}>
        <CardHeader ref={refs.header}>
          <CardTitle ref={refs.title}>T</CardTitle>
          <CardSubtitle ref={refs.subtitle}>S</CardSubtitle>
        </CardHeader>
        <CardBody ref={refs.body}>B</CardBody>
        <CardFooter ref={refs.footer}>F</CardFooter>
      </Card>
    );
    Object.values(refs).forEach((r) => expect(r.current).toBeInstanceOf(HTMLElement));
    expect(refs.title.current).toBe(screen.getByRole("heading", { name: "T" }));
  });

  it("has no axe violations", async () => {
    const { container } = render(<Full />);
    expect(await axe(container)).toHaveNoViolations();
  });
});

describe("StatCard", () => {
  it("renders label and value, and no delta unless given", () => {
    render(<StatCard data-testid="stat" label="Orders" value="1,284" />);
    const stat = screen.getByTestId("stat");
    expect(within(stat).getByText("Orders")).toBeInTheDocument();
    expect(within(stat).getByText("1,284")).toBeInTheDocument();
    expect(stat.querySelector("svg")).toBeNull();
  });

  it("accepts a node as the value", () => {
    render(<StatCard label="Uptime" value={<span data-testid="v">99.9%</span>} />);
    expect(screen.getByTestId("v")).toHaveTextContent("99.9%");
  });

  it.each([
    ["up", "+12%"],
    ["down", "-4%"],
    ["flat", "0%"],
    [undefined, "n/a"]
  ] as const)("delta direction=%s shows its value with exactly one icon", (direction, value) => {
    render(<StatCard data-testid="stat" label="Orders" value="1,284" delta={{ value, direction }} />);
    const stat = screen.getByTestId("stat");
    expect(within(stat).getByText(value)).toBeInTheDocument();
    expect(stat.querySelectorAll("svg")).toHaveLength(1);
    // The icon contributes no text of its own.
    expect(stat).toHaveTextContent(new RegExp(`${value.replace(/[+]/g, "\\+")}$`));
  });

  it("each delta direction renders a different icon", () => {
    const iconFor = (direction?: "up" | "down" | "flat") => {
      const { container, unmount } = render(
        <StatCard label="Orders" value="1" delta={{ value: "x", direction }} />
      );
      const html = container.querySelector("svg")!.innerHTML;
      unmount();
      return html;
    };
    const [up, down, flat, none] = [iconFor("up"), iconFor("down"), iconFor("flat"), iconFor()];
    expect(new Set([up, down, flat]).size).toBe(3);
    expect(none).toBe(flat);
  });

  it("mono and other styling props do not leak to the DOM", () => {
    render(<StatCard data-testid="stat" label="SKU" value="AX-204" mono />);
    const stat = screen.getByTestId("stat");
    expect(stat).not.toHaveAttribute("mono");
    expect(stat).not.toHaveAttribute("label");
    expect(stat).not.toHaveAttribute("value");
    expect(stat).not.toHaveAttribute("delta");
  });

  // The arrow and colour are decorative; the direction is also said in words.
  it("announces the delta direction to assistive tech", () => {
    render(<StatCard data-testid="stat" label="Orders" value="1,284" delta={{ value: "12%", direction: "down" }} />);
    expect(screen.getByTestId("stat")).toHaveTextContent(/down|decrease/i);
  });

  it("has no axe violations", async () => {
    const { container } = render(
      <StatCard label="Orders" value="1,284" delta={{ value: "+12%", direction: "up" }} />
    );
    expect(await axe(container)).toHaveNoViolations();
  });
});

describe("EmptyState", () => {
  it("renders title only by default", () => {
    render(<EmptyState data-testid="empty" title="No orders yet" />);
    const empty = screen.getByTestId("empty");
    expect(empty).toHaveTextContent(/^No orders yet$/);
    expect(screen.queryByRole("button")).not.toBeInTheDocument();
  });

  it("renders icon, description and a working action", async () => {
    const user = userEvent.setup();
    const onCreate = vi.fn();
    render(
      <EmptyState
        icon={<svg data-testid="icon" aria-hidden="true" />}
        title="No orders yet"
        description="Orders appear here once a buyer checks out."
        action={<Button onClick={onCreate}>Create order</Button>}
      />
    );
    expect(screen.getByTestId("icon")).toBeInTheDocument();
    expect(screen.getByText("No orders yet")).toBeInTheDocument();
    expect(screen.getByText("Orders appear here once a buyer checks out.")).toBeInTheDocument();
    await user.click(screen.getByRole("button", { name: "Create order" }));
    expect(onCreate).toHaveBeenCalledTimes(1);
  });

  it("does not put the title prop on the DOM as a tooltip", () => {
    render(<EmptyState data-testid="empty" title="No orders yet" />);
    expect(screen.getByTestId("empty")).not.toHaveAttribute("title");
  });

  it("has no axe violations", async () => {
    const { container } = render(
      <EmptyState
        title="No orders yet"
        description="Orders appear here once a buyer checks out."
        action={<Button>Create order</Button>}
      />
    );
    expect(await axe(container)).toHaveNoViolations();
  });
});

describe("Separator", () => {
  it("is decorative by default: hidden from the accessibility tree", () => {
    render(<Separator data-testid="sep" />);
    expect(screen.queryByRole("separator")).not.toBeInTheDocument();
    expect(screen.getByTestId("sep")).toHaveAttribute("role", "none");
    expect(screen.getByTestId("sep")).not.toHaveAttribute("aria-orientation");
  });

  it("is a horizontal separator when semantic", () => {
    render(<Separator decorative={false} />);
    const sep = screen.getByRole("separator");
    // Horizontal is the ARIA default, so it is either omitted or stated.
    expect(sep.getAttribute("aria-orientation") ?? "horizontal").toBe("horizontal");
    expect(sep).toHaveAttribute("data-orientation", "horizontal");
  });

  it("announces vertical orientation when semantic and vertical", () => {
    render(<Separator decorative={false} orientation="vertical" />);
    const sep = screen.getByRole("separator");
    expect(sep).toHaveAttribute("aria-orientation", "vertical");
    expect(sep).toHaveAttribute("data-orientation", "vertical");
  });

  it("has no axe violations in either mode", async () => {
    const { container } = render(
      <div>
        <Separator />
        <Separator decorative={false} orientation="vertical" />
      </div>
    );
    expect(await axe(container)).toHaveNoViolations();
  });
});

describe("DotMatrix", () => {
  const circles = (el: HTMLElement) => Array.from(el.querySelectorAll("circle"));
  const hexCount = (rings: number) => 3 * rings * (rings + 1) + 1;

  it("renders a decorative hex grid hidden from assistive tech", () => {
    render(<DotMatrix data-testid="dm" />);
    const dm = screen.getByTestId("dm");
    expect(dm).toHaveAttribute("aria-hidden", "true");
    expect(dm.querySelector("svg")).not.toBeNull();
    expect(circles(dm)).toHaveLength(hexCount(5));
  });

  it.each([1, 2, 3, 8])("rings=%i draws a full hexagon of dots", (rings) => {
    render(<DotMatrix data-testid="dm" rings={rings} />);
    expect(circles(screen.getByTestId("dm"))).toHaveLength(hexCount(rings));
  });

  it("dots shrink towards the edge according to dotSize and falloff", () => {
    render(<DotMatrix data-testid="dm" rings={2} dotSize={10} falloff={0.5} />);
    const radii = circles(screen.getByTestId("dm")).map((c) => Number(c.getAttribute("r")));
    expect(Math.max(...radii)).toBe(10);
    expect(Math.min(...radii)).toBe(5);
    radii.forEach((r) => expect(r).toBeGreaterThan(0));
  });

  it("falloff=0 keeps every dot the same size", () => {
    render(<DotMatrix data-testid="dm" rings={2} dotSize={4} falloff={0} />);
    const radii = new Set(circles(screen.getByTestId("dm")).map((c) => c.getAttribute("r")));
    expect([...radii]).toEqual(["4"]);
  });

  it("applies color to every dot and exposes the variant", () => {
    const { rerender } = render(<DotMatrix data-testid="dm" rings={1} color="red" />);
    const dm = screen.getByTestId("dm");
    circles(dm).forEach((c) => expect(c).toHaveAttribute("fill", "red"));
    expect(dm).toHaveAttribute("data-variant", "ripple");
    rerender(<DotMatrix data-testid="dm" rings={1} color="red" variant="pulse" />);
    expect(dm).toHaveAttribute("data-variant", "pulse");
  });

  it("ripple staggers dots by ring; pulse animates them together", () => {
    const delays = (el: HTMLElement) => new Set(circles(el).map((c) => c.style.animationDelay));
    const { rerender } = render(<DotMatrix data-testid="dm" rings={3} variant="ripple" />);
    expect(delays(screen.getByTestId("dm")).size).toBe(4);
    rerender(<DotMatrix data-testid="dm" rings={3} variant="pulse" />);
    expect(delays(screen.getByTestId("dm")).size).toBe(1);
  });

  it("size overrides the computed box and speed drives the animation duration", () => {
    render(<DotMatrix data-testid="dm" size={120} speed={900} />);
    const dm = screen.getByTestId("dm");
    expect(dm.style.width).toBe("120px");
    expect(dm.style.height).toBe("120px");
    expect(dm.style.getPropertyValue("--aeros-dotmatrix-dur")).toBe("900ms");
  });

  it("caller style and props are merged, and option props do not leak to the DOM", () => {
    render(<DotMatrix data-testid="dm" style={{ opacity: 0.5 }} title="decor" gap={10} />);
    const dm = screen.getByTestId("dm");
    expect(dm.style.opacity).toBe("0.5");
    expect(dm).toHaveAttribute("title", "decor");
    for (const prop of ["rings", "dotSize", "gap", "falloff", "color", "background", "variant", "speed", "size"]) {
      expect(dm).not.toHaveAttribute(prop);
    }
  });

  it("forwards its ref", () => {
    const ref = React.createRef<HTMLDivElement>();
    render(<DotMatrix data-testid="dm" ref={ref} />);
    expect(ref.current).toBe(screen.getByTestId("dm"));
  });

  it("does not throw for extreme props", () => {
    expect(() =>
      render(
        <>
          <DotMatrix rings={0} />
          <DotMatrix rings={12} gap={1} dotSize={1} />
          <DotMatrix falloff={1} speed={0} size={0} />
        </>
      )
    ).not.toThrow();
  });

  // DEFECT: with rings=0 the radius is dotSize * (1 - (0 / 0) * falloff) = NaN,
  // so the single centre dot renders with r="NaN" (invisible, plus a React
  // "Received NaN for the `r` attribute" warning).
  // Cause: packages/react/src/components/dot-matrix.tsx:93 (ring / rings).
  it.fails("rings=0 renders a single dot with a finite radius", () => {
    const error = vi.spyOn(console, "error").mockImplementation(() => {});
    try {
      render(<DotMatrix data-testid="dm" rings={0} />);
      const dots = circles(screen.getByTestId("dm"));
      expect(dots).toHaveLength(1);
      expect(Number.isFinite(Number(dots[0].getAttribute("r")))).toBe(true);
    } finally {
      error.mockRestore();
    }
  });

  it("has no axe violations", async () => {
    const { container } = render(<DotMatrix />);
    expect(await axe(container)).toHaveNoViolations();
  });
});
