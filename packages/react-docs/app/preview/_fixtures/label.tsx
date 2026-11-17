"use client";

import { Checkbox, Input, Label } from "@aeros-core/react";
import { Group } from "./kit";

export default function LabelFixture() {
  return (
    <>
      <Group label="Label + input" className="max-w-sm flex-col items-stretch gap-1.5">
        <Label htmlFor="po-ref">PO reference</Label>
        <Input id="po-ref" placeholder="PO-2026-…" />
      </Group>
      <Group label="Label after a control (peer)">
        <div className="flex items-center gap-2">
          <Checkbox id="terms" checked />
          <Label htmlFor="terms">I agree to the terms</Label>
        </div>
      </Group>
      <Group label="Label after a disabled control (peer-disabled)">
        <div className="flex items-center gap-2">
          <Checkbox id="terms-disabled" disabled checked={false} />
          <Label htmlFor="terms-disabled">Unavailable option</Label>
        </div>
      </Group>
    </>
  );
}
