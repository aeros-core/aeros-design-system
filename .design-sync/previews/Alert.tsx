import * as React from "react";
import { Alert } from "@aeros-core/react";

export const Statuses = () => (
  <div style={{ display: "grid", gap: 8, maxWidth: 460 }}>
    <Alert variant="info" title="Heads up">A new RFQ is available for review.</Alert>
    <Alert variant="success" title="Approved">Order passed QC. Ready for dispatch.</Alert>
    <Alert variant="warning" title="Delayed">Shipment running 2 hours behind schedule.</Alert>
    <Alert variant="danger" title="Failed">Line 4 halted — check sensor 2.</Alert>
  </div>
);

export const BodyOnly = () => (
  <div style={{ display: "grid", gap: 8, maxWidth: 460 }}>
    <Alert variant="info">Buyer Meridian Textiles requested a revised quote.</Alert>
    <Alert variant="warning">3 catalog items are missing HSN codes.</Alert>
  </div>
);
