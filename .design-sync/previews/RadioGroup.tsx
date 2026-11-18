import * as React from "react";
import { RadioGroup, RadioGroupItem } from "@aeros-core/react";

const label: React.CSSProperties = {
  display: "inline-flex",
  alignItems: "center",
  gap: 8,
  fontSize: 14,
  color: "var(--aeros-fg-secondary)",
};

export const BillingCycle = () => (
  <RadioGroup defaultValue="annual" style={{ display: "flex", gap: 20 }}>
    <label style={label}>
      <RadioGroupItem value="monthly" id="cycle-monthly" /> Monthly
    </label>
    <label style={label}>
      <RadioGroupItem value="annual" id="cycle-annual" /> Annual
    </label>
    <label style={{ ...label, color: "var(--aeros-fg-muted)" }}>
      <RadioGroupItem value="lifetime" id="cycle-lifetime" disabled /> Lifetime
    </label>
  </RadioGroup>
);

export const ShippingSpeed = () => (
  <RadioGroup
    defaultValue="standard"
    style={{ display: "flex", flexDirection: "column", gap: 12 }}
  >
    <label style={label}>
      <RadioGroupItem value="standard" id="ship-standard" /> Standard surface
      (5-7 days)
    </label>
    <label style={label}>
      <RadioGroupItem value="express" id="ship-express" /> Express air (2 days)
    </label>
    <label style={label}>
      <RadioGroupItem value="pickup" id="ship-pickup" /> Buyer arranges pickup
    </label>
  </RadioGroup>
);
