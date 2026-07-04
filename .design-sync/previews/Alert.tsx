import * as React from "react";
import { Alert } from "@aeros-core/react";

export const Statuses = () => (
  <div style={{ display: "grid", gap: 8, maxWidth: 460 }}>
    <Alert variant="blue" title="Heads up">A new RFQ is available for review.</Alert>
    <Alert variant="green" title="Approved">Order passed QC. Ready for dispatch.</Alert>
    <Alert variant="amber" title="Delayed">Shipment running 2 hours behind schedule.</Alert>
    <Alert variant="red" title="Failed">Line 4 halted — check sensor 2.</Alert>
  </div>
);

export const BodyOnly = () => (
  <div style={{ display: "grid", gap: 8, maxWidth: 460 }}>
    <Alert variant="blue">Buyer Meridian Textiles requested a revised quote.</Alert>
    <Alert variant="amber">3 catalog items are missing HSN codes.</Alert>
  </div>
);
