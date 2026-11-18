import * as React from "react";
import { Avatar } from "@aeros-core/react";

export const Sizes = () => (
  <div style={{ display: "flex", gap: 12, alignItems: "center" }}>
    <Avatar size="xs" fallback="PS" />
    <Avatar size="sm" fallback="PS" />
    <Avatar size="md" fallback="PS" />
    <Avatar size="lg" fallback="PS" />
    <Avatar size="xl" fallback="PS" />
  </div>
);

export const Tones = () => (
  <div style={{ display: "flex", gap: 12, alignItems: "center" }}>
    <Avatar variant="neutral" fallback="NE" />
    <Avatar variant="inverse" fallback="IN" />
    <Avatar variant="success" fallback="SU" />
    <Avatar variant="warning" fallback="WA" />
    <Avatar variant="info" fallback="IF" />
  </div>
);
