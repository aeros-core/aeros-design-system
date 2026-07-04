import * as React from "react";
import { StatCard } from "@aeros-core/react";

export const Stats = () => (
  <div style={{ display: "grid", gridTemplateColumns: "repeat(3, minmax(150px, 1fr))", gap: 16 }}>
    <StatCard label="Output" value="4,820" delta={{ value: "+8%", direction: "up" }} />
    <StatCard label="RFQ value" value="₹1,24,000" mono delta={{ value: "-2%", direction: "down" }} />
    <StatCard label="Attendance" value="96%" delta={{ value: "Steady", direction: "flat" }} />
  </div>
);
