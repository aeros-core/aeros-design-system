import * as React from "react";
import { Spinner } from "@aeros-core/react";

export const Sizes = () => (
  <div style={{ display: "flex", gap: 16, alignItems: "center" }}>
    <Spinner size="sm" />
    <Spinner />
    <Spinner size="lg" />
  </div>
);

export const InlineWithText = () => (
  <span className="inline-flex items-center gap-2 text-body-md text-fg-secondary">
    <Spinner size="sm" label="Loading orders" /> Loading orders…
  </span>
);

export const OnInverse = () => (
  <div className="inline-flex rounded-surface bg-bg-inverse p-4">
    <Spinner />
  </div>
);
