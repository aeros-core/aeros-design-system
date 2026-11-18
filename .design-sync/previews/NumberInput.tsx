import * as React from "react";
import { Field, NumberInput } from "@aeros-core/react";

const col: React.CSSProperties = { display: "grid", gap: 12, maxWidth: 320 };

export const Sizes = () => (
  <div style={col}>
    <NumberInput size="sm" aria-label="Small" placeholder="Small" />
    <NumberInput size="md" aria-label="Medium" placeholder="Medium" />
    <NumberInput size="lg" aria-label="Large" placeholder="Large" />
  </div>
);

export const PrefixAndSuffix = () => (
  <div style={col}>
    <NumberInput aria-label="Price" prefix="₹" defaultValue={1250} precision={2} step={50} />
    <NumberInput aria-label="Weight" suffix="kg" defaultValue={12.5} step={0.5} />
    <NumberInput aria-label="Unit price" prefix="INR" suffix="/ pc" defaultValue={48} />
  </div>
);

// At min / max the matching stepper button disables itself.
export const States = () => (
  <div style={col}>
    <NumberInput aria-label="At min" defaultValue={1} min={1} max={10} />
    <NumberInput aria-label="At max" defaultValue={10} min={1} max={10} />
    <NumberInput aria-label="Error" state="error" defaultValue={0} />
    <NumberInput aria-label="Disabled" disabled defaultValue={500} suffix="pcs" />
    <NumberInput aria-label="Read only" readOnly defaultValue={500} />
  </div>
);

export const InField = () => (
  <div style={{ ...col, gap: 16 }}>
    <Field label="Quantity" hint="Sold in cartons of 50.">
      <NumberInput defaultValue={50} min={50} step={50} suffix="pcs" />
    </Field>
    <Field label="Quantity" required error="Enter a quantity of at least 50.">
      <NumberInput defaultValue={20} min={50} step={50} suffix="pcs" />
    </Field>
  </div>
);
