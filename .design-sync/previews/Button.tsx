import * as React from "react";
import { Button } from "@aeros-core/react";
import { Plus, ChevronDown, Settings } from "lucide-react";

const row: React.CSSProperties = {
  display: "flex",
  flexWrap: "wrap",
  gap: 12,
  alignItems: "center",
};

export const Variants = () => (
  <div style={row}>
    <Button variant="primary">Primary</Button>
    <Button variant="secondary">Secondary</Button>
    <Button variant="ghost">Ghost</Button>
    <Button variant="danger">Danger</Button>
    <Button variant="danger-subtle">Danger subtle</Button>
    <Button variant="link">Link</Button>
  </div>
);

export const Sizes = () => (
  <div style={row}>
    <Button size="xs">xs</Button>
    <Button size="sm">sm</Button>
    <Button size="md">md</Button>
    <Button size="lg">lg</Button>
    <Button size="xl">xl</Button>
  </div>
);

export const IconsAndStates = () => (
  <div style={row}>
    <Button leadingIcon={<Plus />}>Create RFQ</Button>
    <Button variant="secondary" trailingIcon={<ChevronDown />}>
      Filter
    </Button>
    <Button loading>Saving…</Button>
    <Button disabled>Disabled</Button>
  </div>
);

// Icon-only: `iconOnly` on a normal size, always with an aria-label.
export const IconOnly = () => (
  <div style={row}>
    <Button size="sm" iconOnly aria-label="Settings">
      <Settings />
    </Button>
    <Button iconOnly aria-label="Settings">
      <Settings />
    </Button>
    <Button variant="secondary" iconOnly aria-label="Settings">
      <Settings />
    </Button>
    <Button variant="ghost" iconOnly aria-label="Settings">
      <Settings />
    </Button>
  </div>
);
