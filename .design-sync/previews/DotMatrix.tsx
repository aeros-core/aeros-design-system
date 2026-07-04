import * as React from "react";
import { DotMatrix } from "@aeros-core/react";

export const Halftone = () => (
  <div style={{ display: "flex", gap: 20, flexWrap: "wrap", alignItems: "center" }}>
    <div style={{ borderRadius: 24, overflow: "hidden" }}>
      <DotMatrix size={220} rings={5} variant="ripple" />
    </div>
    <div style={{ borderRadius: 24, overflow: "hidden" }}>
      <DotMatrix size={220} rings={4} variant="pulse" speed={1600} />
    </div>
  </div>
);
