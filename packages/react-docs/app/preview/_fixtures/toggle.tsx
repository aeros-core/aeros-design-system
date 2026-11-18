"use client";

import { Toggle, ToggleGroup, ToggleGroupItem } from "@aeros-core/react";
import { AlignCenter, AlignLeft, AlignRight, Bold, Italic, Pin, Underline } from "lucide-react";
import { Group } from "./kit";

const SIZES = ["xs", "sm", "md", "lg", "xl"] as const;

export default function ToggleFixture() {
  return (
    <>
      <Group label="Ghost — off / on / disabled / disabled on">
        <Toggle>Pinned</Toggle>
        <Toggle defaultPressed>Pinned</Toggle>
        <Toggle disabled>Pinned</Toggle>
        <Toggle disabled defaultPressed>Pinned</Toggle>
      </Group>
      <Group label="Outline — off / on / disabled / disabled on">
        <Toggle variant="outline">Pinned</Toggle>
        <Toggle variant="outline" defaultPressed>Pinned</Toggle>
        <Toggle variant="outline" disabled>Pinned</Toggle>
        <Toggle variant="outline" disabled defaultPressed>Pinned</Toggle>
      </Group>
      <Group label="Sizes">
        {SIZES.map((size) => (
          <Toggle key={size} size={size} variant="outline" defaultPressed={size === "md"}>
            {size}
          </Toggle>
        ))}
      </Group>
      <Group label="Icon-only sizes">
        {SIZES.map((size) => (
          <Toggle key={size} size={size} iconOnly aria-label={`Pin (${size})`} defaultPressed={size === "md"}>
            <Pin />
          </Toggle>
        ))}
        <Toggle variant="outline" iconOnly aria-label="Pin (outline)">
          <Pin />
        </Toggle>
        <Toggle variant="outline" iconOnly aria-label="Pin (outline, on)" defaultPressed>
          <Pin />
        </Toggle>
      </Group>
      <Group label="With icon and label">
        <Toggle variant="outline">
          <Pin /> Pin to top
        </Toggle>
        <Toggle variant="outline" defaultPressed>
          <Pin /> Pin to top
        </Toggle>
      </Group>
      <Group label="ToggleGroup — single, ghost, spaced">
        <ToggleGroup type="single" defaultValue="center" aria-label="Alignment">
          <ToggleGroupItem value="left" iconOnly aria-label="Align left"><AlignLeft /></ToggleGroupItem>
          <ToggleGroupItem value="center" iconOnly aria-label="Align center"><AlignCenter /></ToggleGroupItem>
          <ToggleGroupItem value="right" iconOnly aria-label="Align right"><AlignRight /></ToggleGroupItem>
        </ToggleGroup>
      </Group>
      <Group label="ToggleGroup — multiple, outline, joined">
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
      </Group>
      <Group label="ToggleGroup — outline, spaced / ghost, joined / disabled">
        <ToggleGroup type="multiple" variant="outline" defaultValue={["quoted"]} aria-label="Status, spaced">
          <ToggleGroupItem value="open">Open</ToggleGroupItem>
          <ToggleGroupItem value="quoted">Quoted</ToggleGroupItem>
          <ToggleGroupItem value="closed">Closed</ToggleGroupItem>
        </ToggleGroup>
        <ToggleGroup type="single" joined defaultValue="left" aria-label="Alignment, joined">
          <ToggleGroupItem value="left" iconOnly aria-label="Align left"><AlignLeft /></ToggleGroupItem>
          <ToggleGroupItem value="center" iconOnly aria-label="Align center"><AlignCenter /></ToggleGroupItem>
          <ToggleGroupItem value="right" iconOnly aria-label="Align right"><AlignRight /></ToggleGroupItem>
        </ToggleGroup>
        <ToggleGroup type="single" variant="outline" joined disabled defaultValue="week" aria-label="Range, disabled">
          <ToggleGroupItem value="day">Day</ToggleGroupItem>
          <ToggleGroupItem value="week">Week</ToggleGroupItem>
        </ToggleGroup>
      </Group>
    </>
  );
}
