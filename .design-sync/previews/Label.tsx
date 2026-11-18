import * as React from "react";
import { Checkbox, Input, Label } from "@aeros-core/react";

const pair: React.CSSProperties = { display: "flex", alignItems: "center", gap: 8 };

export const WithInput = () => (
  <div style={{ display: "grid", gap: 6, maxWidth: 384 }}>
    <Label htmlFor="po-ref">PO reference</Label>
    <Input id="po-ref" placeholder="PO-2026-…" />
  </div>
);

// After a control the label is a `peer`: it dims when the control is disabled.
export const WithCheckbox = () => (
  <div style={{ display: "grid", gap: 12 }}>
    <div style={pair}>
      <Checkbox id="terms" defaultChecked />
      <Label htmlFor="terms">I agree to the terms</Label>
    </div>
    <div style={pair}>
      <Checkbox id="terms-disabled" disabled />
      <Label htmlFor="terms-disabled">Unavailable option</Label>
    </div>
  </div>
);
