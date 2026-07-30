import * as React from "react";
import { Checkbox } from "@aeros-core/react";

const label: React.CSSProperties = {
  display: "inline-flex",
  alignItems: "center",
  gap: 8,
  fontSize: 14,
  color: "var(--aeros-fg-secondary)",
};

export const States = () => (
  <div style={{ display: "flex", flexDirection: "column", gap: 12 }}>
    <label style={label}>
      <Checkbox defaultChecked /> I agree to the terms
    </label>
    <label style={label}>
      <Checkbox checked="indeterminate" /> Partial selection
    </label>
    <label style={{ ...label, color: "var(--aeros-fg-muted)" }}>
      <Checkbox disabled /> Disabled
    </label>
  </div>
);
