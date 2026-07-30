import * as React from "react";
import { Progress } from "@aeros-core/react";

const lineLabel: React.CSSProperties = {
  display: "flex",
  justifyContent: "space-between",
  fontSize: 12,
  marginBottom: 6,
};
const name: React.CSSProperties = { color: "var(--aeros-fg-secondary)", fontWeight: 500 };
const pct: React.CSSProperties = { color: "var(--aeros-fg-muted)", fontFamily: "var(--aeros-font-mono)" };

export const Levels = () => (
  <div style={{ maxWidth: 360, display: "flex", flexDirection: "column", gap: 16 }}>
    <div>
      <div style={lineLabel}>
        <span style={name}>Line 1</span>
        <span style={pct}>64%</span>
      </div>
      <Progress value={64} />
    </div>
    <div>
      <div style={lineLabel}>
        <span style={name}>Line 2 · warning</span>
        <span style={pct}>42%</span>
      </div>
      <Progress value={42} color="warning" />
    </div>
    <div>
      <div style={lineLabel}>
        <span style={name}>Line 3 · danger</span>
        <span style={pct}>22%</span>
      </div>
      <Progress value={22} color="danger" />
    </div>
  </div>
);
