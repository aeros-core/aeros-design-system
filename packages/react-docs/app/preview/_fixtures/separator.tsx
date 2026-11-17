"use client";

import { Separator } from "@aeros-core/react";
import { Group } from "./kit";

export default function SeparatorFixture() {
  return (
    <>
      <Group label="Horizontal" className="max-w-sm flex-col items-stretch gap-0">
        <p className="text-sm text-fg-secondary">Above the separator</p>
        <Separator className="my-4" />
        <p className="text-sm text-fg-secondary">Below the separator</p>
      </Group>
      <Group label="Vertical">
        <div className="flex h-6 items-center gap-3 text-sm text-fg-secondary">
          <span>Orders</span>
          <Separator orientation="vertical" />
          <span>Shipments</span>
          <Separator orientation="vertical" />
          <span>Invoices</span>
        </div>
      </Group>
      <Group label="Semantic (decorative={false})" className="max-w-sm flex-col items-stretch">
        <Separator decorative={false} />
      </Group>
    </>
  );
}
