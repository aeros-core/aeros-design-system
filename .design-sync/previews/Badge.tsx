import * as React from "react";
import { Badge } from "@aeros-core/react";

export const Variants = () => (
  <div style={{ display: "flex", flexWrap: "wrap", gap: 8, alignItems: "center" }}>
    <Badge variant="green" dot>Active</Badge>
    <Badge variant="amber" dot>Pending</Badge>
    <Badge variant="red" dot>Failed</Badge>
    <Badge variant="blue" dot>Info</Badge>
    <Badge variant="grey" dot>Neutral</Badge>
    <Badge variant="dark" dot>Dark</Badge>
  </div>
);

export const WithoutDot = () => (
  <div style={{ display: "flex", flexWrap: "wrap", gap: 8, alignItems: "center" }}>
    <Badge variant="green">Paid</Badge>
    <Badge variant="amber">In review</Badge>
    <Badge variant="blue">New RFQ</Badge>
    <Badge variant="grey">Draft</Badge>
  </div>
);
