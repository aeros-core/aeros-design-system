import * as React from "react";
import { Field, Textarea } from "@aeros-core/react";

export const Notes = () => (
  <div style={{ maxWidth: 440 }}>
    <Field label="Order notes" hint="Add context for your fulfillment team.">
      <Textarea
        placeholder="e.g. Buyer requested split shipment for RFQ-0042 — 2 pallets now, remainder next week…"
        rows={4}
      />
    </Field>
  </div>
);

export const RejectionReason = () => (
  <div style={{ maxWidth: 440 }}>
    <Field
      label="Reason for rejection"
      error="A reason is required before rejecting this quote."
    >
      <Textarea
        state="error"
        placeholder="Explain why this RFQ can't be fulfilled…"
        rows={3}
      />
    </Field>
  </div>
);
