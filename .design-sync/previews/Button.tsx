import * as React from "react";
import { Button } from "@aeros-core/react";
import { Plus, ChevronDown } from "lucide-react";

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
    <Button variant="dark">Dark</Button>
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
    <Button leadingIcon={<Plus size={16} />}>Create RFQ</Button>
    <Button variant="secondary" trailingIcon={<ChevronDown size={16} />}>
      Filter
    </Button>
    <Button loading>Saving…</Button>
    <Button disabled>Disabled</Button>
  </div>
);
