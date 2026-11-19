import * as React from "react";
import { Tag } from "@aeros-core/react";

export const Variants = () => (
  <div style={{ display: "flex", flexWrap: "wrap", gap: 8, alignItems: "center" }}>
    <Tag variant="neutral">v1.0.0</Tag>
    <Tag variant="info">beta</Tag>
    <Tag variant="inverse">internal</Tag>
  </div>
);

export const CatalogLabels = () => (
  <div style={{ display: "flex", flexWrap: "wrap", gap: 8, alignItems: "center" }}>
    <Tag variant="neutral">SKU-4820</Tag>
    <Tag variant="info">bulk order</Tag>
    <Tag variant="neutral">cotton</Tag>
    <Tag variant="inverse">wholesale</Tag>
  </div>
);
