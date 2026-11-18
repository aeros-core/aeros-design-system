import * as React from "react";
import { Separator } from "@aeros-core/react";

export const Horizontal = () => (
  <div style={{ maxWidth: 384 }}>
    <p className="text-body-md text-fg-secondary">Order PO-1042 · Trimurti Packaging</p>
    <Separator className="my-4" />
    <p className="text-body-md text-fg-secondary">12,000 units · ₹1,24,000</p>
  </div>
);

export const Vertical = () => (
  <div className="text-body-md text-fg-secondary" style={{ display: "flex", alignItems: "center", gap: 12, height: 24 }}>
    <span>Orders</span>
    <Separator orientation="vertical" />
    <span>Shipments</span>
    <Separator orientation="vertical" />
    <span>Invoices</span>
  </div>
);
