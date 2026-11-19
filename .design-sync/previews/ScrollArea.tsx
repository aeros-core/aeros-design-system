import * as React from "react";
import { ScrollArea } from "@aeros-core/react";

const ORDERS = Array.from({ length: 24 }, (_, i) => `PO-${1042 + i} · 250 ml double-wall cup × ${(i + 1) * 500}`);
const COLUMNS = Array.from({ length: 14 }, (_, i) => `Column ${i + 1}`);

const surface = "rounded-surface border border-border-default bg-bg-surface";
const frame: React.CSSProperties = { height: 192, maxWidth: 448 };

// type="always" keeps the scrollbar visible without hovering.
export const Vertical = () => (
  <ScrollArea type="always" aria-label="Recent orders" className={surface} style={frame}>
    <ul className="grid gap-2 p-3 text-body-md text-fg-secondary">
      {ORDERS.map((order) => (
        <li key={order}>{order}</li>
      ))}
    </ul>
  </ScrollArea>
);

export const Horizontal = () => (
  <ScrollArea type="always" orientation="horizontal" aria-label="Columns" className={surface} style={{ maxWidth: 448 }}>
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
);

export const BothAxes = () => (
  <ScrollArea type="always" orientation="both" aria-label="Order grid" className={surface} style={frame}>
    <div className="grid w-max gap-2 p-3 text-body-md text-fg-secondary">
      {ORDERS.map((order) => (
        <div key={order} className="whitespace-nowrap">
          {order} · Dispatched from Pune · BlueDart Surface · Expected 18 Aug 2026
        </div>
      ))}
    </div>
  </ScrollArea>
);
