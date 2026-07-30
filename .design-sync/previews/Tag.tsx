import * as React from "react";
import { Tag } from "@aeros-core/react";

export const Variants = () => (
  <div style={{ display: "flex", flexWrap: "wrap", gap: 8, alignItems: "center" }}>
    <Tag variant="grey">v1.0.0</Tag>
    <Tag variant="blue">beta</Tag>
    <Tag variant="dark">internal</Tag>
  </div>
);

export const CatalogLabels = () => (
  <div style={{ display: "flex", flexWrap: "wrap", gap: 8, alignItems: "center" }}>
    <Tag variant="grey">SKU-4820</Tag>
    <Tag variant="blue">bulk order</Tag>
    <Tag variant="grey">cotton</Tag>
    <Tag variant="dark">wholesale</Tag>
  </div>
);
