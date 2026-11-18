import * as React from "react";
import { Badge } from "@aeros-core/react";

export const Variants = () => (
  <div style={{ display: "flex", flexWrap: "wrap", gap: 8, alignItems: "center" }}>
    <Badge variant="success" dot>Active</Badge>
    <Badge variant="warning" dot>Pending</Badge>
    <Badge variant="danger" dot>Failed</Badge>
    <Badge variant="info" dot>Info</Badge>
    <Badge variant="neutral" dot>Neutral</Badge>
    <Badge variant="inverse" dot>Dark</Badge>
  </div>
);

export const WithoutDot = () => (
  <div style={{ display: "flex", flexWrap: "wrap", gap: 8, alignItems: "center" }}>
    <Badge variant="success">Paid</Badge>
    <Badge variant="warning">In review</Badge>
    <Badge variant="info">New RFQ</Badge>
    <Badge variant="neutral">Draft</Badge>
  </div>
);
