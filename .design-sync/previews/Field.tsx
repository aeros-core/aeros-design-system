import * as React from "react";
import { Field, Input } from "@aeros-core/react";

export const Variations = () => (
  <div style={{ display: "grid", gap: 16, maxWidth: 420 }}>
    <Field label="Buyer email" hint="Quote updates are sent here.">
      <Input type="email" placeholder="priya@acmesteel.in" />
    </Field>
    <Field label="Company name" required>
      <Input placeholder="Acme Steel Works Pvt Ltd" />
    </Field>
    <Field label="Quoted amount" error="Enter a valid amount.">
      <Input state="error" placeholder="₹1,24,000" />
    </Field>
  </div>
);

export const RfqForm = () => (
  <div style={{ display: "grid", gap: 16, maxWidth: 420 }}>
    <Field label="SKU / HSN code" hint="Used for tax slab lookup.">
      <Input placeholder="CR-COIL-1.2" />
    </Field>
    <Field label="Quantity (MT)" required>
      <Input type="number" placeholder="25" />
    </Field>
  </div>
);
