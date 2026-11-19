import * as React from "react";
import { Toggle } from "@aeros-core/react";
import { Pin } from "lucide-react";

const SIZES = ["xs", "sm", "md", "lg", "xl"] as const;
const row: React.CSSProperties = { display: "flex", flexWrap: "wrap", gap: 12, alignItems: "center" };

// Each row: off / on / disabled / disabled on.
export const Variants = () => (
  <div style={{ display: "grid", gap: 12 }}>
    <div style={row}>
      <Toggle>Pinned</Toggle>
      <Toggle defaultPressed>Pinned</Toggle>
      <Toggle disabled>Pinned</Toggle>
      <Toggle disabled defaultPressed>Pinned</Toggle>
    </div>
    <div style={row}>
      <Toggle variant="outline">Pinned</Toggle>
      <Toggle variant="outline" defaultPressed>Pinned</Toggle>
      <Toggle variant="outline" disabled>Pinned</Toggle>
      <Toggle variant="outline" disabled defaultPressed>Pinned</Toggle>
    </div>
  </div>
);

export const Sizes = () => (
  <div style={row}>
    {SIZES.map((size) => (
      <Toggle key={size} size={size} variant="outline" defaultPressed={size === "md"}>
        {size}
      </Toggle>
    ))}
  </div>
);

export const WithIcons = () => (
  <div style={row}>
    {SIZES.map((size) => (
      <Toggle key={size} size={size} iconOnly aria-label={`Pin (${size})`} defaultPressed={size === "md"}>
        <Pin />
      </Toggle>
    ))}
    <Toggle variant="outline">
      <Pin /> Pin to top
    </Toggle>
    <Toggle variant="outline" defaultPressed>
      <Pin /> Pin to top
    </Toggle>
  </div>
);
