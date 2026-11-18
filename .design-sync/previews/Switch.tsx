import * as React from "react";
import { Switch } from "@aeros-core/react";

const label: React.CSSProperties = {
  display: "inline-flex",
  alignItems: "center",
  gap: 10,
  fontSize: 14,
  color: "var(--aeros-fg-secondary)",
};

export const States = () => (
  <div style={{ display: "flex", flexDirection: "column", gap: 12 }}>
    <label style={label}>
      <Switch defaultChecked /> New RFQ email alerts
    </label>
    <label style={label}>
      <Switch /> Auto-accept repeat buyers
    </label>
    <label style={{ ...label, color: "var(--aeros-fg-muted)" }}>
      <Switch disabled /> SMS alerts (unavailable)
    </label>
  </div>
);

export const NotificationRow = () => (
  <div
    style={{
      display: "flex",
      alignItems: "center",
      justifyContent: "space-between",
      gap: 24,
      maxWidth: 380,
      paddingBottom: 12,
      borderBottom: "1px solid var(--aeros-border, rgba(0,0,0,0.08))",
    }}
  >
    <div>
      <div style={{ fontSize: 14, color: "var(--aeros-fg-primary)" }}>
        Low-stock warnings
      </div>
      <div style={{ fontSize: 12, color: "var(--aeros-fg-muted)" }}>
        Notify when a SKU drops below reorder point.
      </div>
    </div>
    <Switch defaultChecked />
  </div>
);
