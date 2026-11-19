import * as React from "react";
import { ToggleGroup, ToggleGroupItem } from "@aeros-core/react";
import { AlignCenter, AlignLeft, AlignRight, Bold, Italic, Underline } from "lucide-react";

const row: React.CSSProperties = { display: "flex", flexWrap: "wrap", gap: 16, alignItems: "center" };

const Alignment = () => (
  <>
    <ToggleGroupItem value="left" iconOnly aria-label="Align left"><AlignLeft /></ToggleGroupItem>
    <ToggleGroupItem value="center" iconOnly aria-label="Align center"><AlignCenter /></ToggleGroupItem>
    <ToggleGroupItem value="right" iconOnly aria-label="Align right"><AlignRight /></ToggleGroupItem>
  </>
);

// Ghost: spaced by default, or `joined` into one strip.
export const SingleSelect = () => (
  <div style={row}>
    <ToggleGroup type="single" defaultValue="center" aria-label="Alignment">
      <Alignment />
    </ToggleGroup>
    <ToggleGroup type="single" joined defaultValue="left" aria-label="Alignment, joined">
      <Alignment />
    </ToggleGroup>
  </div>
);

export const MultipleJoined = () => (
  <div style={row}>
    <ToggleGroup type="multiple" variant="outline" joined defaultValue={["bold", "underline"]} aria-label="Text style">
      <ToggleGroupItem value="bold" iconOnly aria-label="Bold"><Bold /></ToggleGroupItem>
      <ToggleGroupItem value="italic" iconOnly aria-label="Italic"><Italic /></ToggleGroupItem>
      <ToggleGroupItem value="underline" iconOnly aria-label="Underline"><Underline /></ToggleGroupItem>
    </ToggleGroup>
    <ToggleGroup type="multiple" variant="outline" joined size="sm" defaultValue={["open"]} aria-label="Status">
      <ToggleGroupItem value="open">Open</ToggleGroupItem>
      <ToggleGroupItem value="quoted">Quoted</ToggleGroupItem>
      <ToggleGroupItem value="closed" disabled>Closed</ToggleGroupItem>
    </ToggleGroup>
  </div>
);

export const SpacedAndDisabled = () => (
  <div style={row}>
    <ToggleGroup type="multiple" variant="outline" defaultValue={["quoted"]} aria-label="Status, spaced">
      <ToggleGroupItem value="open">Open</ToggleGroupItem>
      <ToggleGroupItem value="quoted">Quoted</ToggleGroupItem>
      <ToggleGroupItem value="closed">Closed</ToggleGroupItem>
    </ToggleGroup>
    <ToggleGroup type="single" variant="outline" joined disabled defaultValue="week" aria-label="Range, disabled">
      <ToggleGroupItem value="day">Day</ToggleGroupItem>
      <ToggleGroupItem value="week">Week</ToggleGroupItem>
    </ToggleGroup>
  </div>
);
