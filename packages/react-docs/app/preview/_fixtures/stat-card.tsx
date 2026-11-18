"use client";

import { StatCard } from "@aeros-core/react";
import { Group } from "./kit";

export default function StatCardFixture() {
  return (
    <Group label="Delta directions, mono, no delta" className="grid items-stretch gap-4 md:grid-cols-3">
      <StatCard label="Output" value="4,820" delta={{ value: "+8%", direction: "up" }} />
      <StatCard label="Rejects" value="112" delta={{ value: "-2%", direction: "down" }} />
      <StatCard label="Attendance" value="96%" delta={{ value: "Steady", direction: "flat" }} />
      <StatCard label="RFQ value" value="₹1,24,000" mono delta={{ value: "+12%", direction: "up" }} />
      <StatCard label="Open orders" value="38" />
      <StatCard label="Lead time" value="4.2 d" delta={{ value: "vs 4.2 d last week" }} />
    </Group>
  );
}
