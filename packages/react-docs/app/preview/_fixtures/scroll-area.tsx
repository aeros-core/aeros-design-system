"use client";

import { ScrollArea } from "@aeros-core/react";
import { Group } from "./kit";

const ORDERS = Array.from({ length: 24 }, (_, i) => `PO-${1042 + i} · 250 ml double-wall cup × ${(i + 1) * 500}`);
const COLUMNS = Array.from({ length: 14 }, (_, i) => `Column ${i + 1}`);

export default function ScrollAreaFixture() {
  return (
    <>
      <Group label="Vertical" className="flex-col items-start">
        <ScrollArea
          type="always"
          aria-label="Recent orders"
          className="h-48 w-full max-w-md rounded-surface border border-border-default bg-bg-surface"
        >
          <ul className="grid gap-2 p-3 text-body-md text-fg-secondary">
            {ORDERS.map((order) => (
              <li key={order}>{order}</li>
            ))}
          </ul>
        </ScrollArea>
      </Group>
      <Group label="Horizontal" className="flex-col items-start">
        <ScrollArea
          type="always"
          orientation="horizontal"
          aria-label="Columns"
          className="w-full max-w-md rounded-surface border border-border-default bg-bg-surface"
        >
          <div className="flex w-max gap-2 p-3">
            {COLUMNS.map((column) => (
              <div
                key={column}
                className="flex h-16 w-28 shrink-0 items-center justify-center rounded-control border border-border-default text-body-md text-fg-secondary"
              >
                {column}
              </div>
            ))}
          </div>
        </ScrollArea>
      </Group>
      <Group label="Both axes" className="flex-col items-start">
        <ScrollArea
          type="always"
          orientation="both"
          aria-label="Order grid"
          className="h-48 w-full max-w-md rounded-surface border border-border-default bg-bg-surface"
        >
          <div className="grid w-max gap-2 p-3 text-body-md text-fg-secondary">
            {ORDERS.map((order) => (
              <div key={order} className="whitespace-nowrap">
                {order} · Dispatched from Pune · BlueDart Surface · Expected 18 Aug 2026
              </div>
            ))}
          </div>
        </ScrollArea>
      </Group>
      <Group label="Content shorter than the area (no scrollbar)" className="flex-col items-start">
        <ScrollArea
          type="always"
          aria-label="Short list"
          className="h-32 w-full max-w-md rounded-surface border border-border-default bg-bg-surface"
        >
          <ul className="grid gap-2 p-3 text-body-md text-fg-secondary">
            {ORDERS.slice(0, 2).map((order) => (
              <li key={order}>{order}</li>
            ))}
          </ul>
        </ScrollArea>
      </Group>
    </>
  );
}
