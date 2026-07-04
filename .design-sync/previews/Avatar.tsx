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
    <Avatar tone="ink" fallback="IK" />
    <Avatar tone="dark" fallback="DK" />
    <Avatar tone="green" fallback="GR" />
    <Avatar tone="amber" fallback="AM" />
    <Avatar tone="royal" fallback="RY" />
  </div>
);
