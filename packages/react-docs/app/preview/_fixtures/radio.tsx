"use client";

import { RadioGroup, RadioGroupItem } from "@aeros-core/react";
import { Group } from "./kit";

const row = "inline-flex items-center gap-2 text-sm text-fg-secondary";

export default function RadioFixture() {
  return (
    <>
      <Group label="Horizontal">
        <RadioGroup value="monthly" aria-label="Billing" className="flex gap-5">
          <label className={row}><RadioGroupItem value="monthly" /> Monthly</label>
          <label className={row}><RadioGroupItem value="annual" /> Annual</label>
          <label className={row}><RadioGroupItem value="never" disabled /> Never (disabled)</label>
        </RadioGroup>
      </Group>
      <Group label="Vertical (default grid)">
        <RadioGroup value="road" aria-label="Shipping mode">
          <label className={row}><RadioGroupItem value="road" /> Road freight</label>
          <label className={row}><RadioGroupItem value="rail" /> Rail freight</label>
          <label className={row}><RadioGroupItem value="air" /> Air freight</label>
        </RadioGroup>
      </Group>
      <Group label="Disabled group">
        <RadioGroup value="a" disabled aria-label="Disabled group" className="flex gap-5">
          <label className={row}><RadioGroupItem value="a" /> Selected</label>
          <label className={row}><RadioGroupItem value="b" /> Unselected</label>
        </RadioGroup>
      </Group>
      <Group label="Nothing selected">
        <RadioGroup aria-label="Empty group" className="flex gap-5">
          <label className={row}><RadioGroupItem value="a" /> Option A</label>
          <label className={row}><RadioGroupItem value="b" /> Option B</label>
        </RadioGroup>
      </Group>
    </>
  );
}
