import * as React from "react";
import { Skeleton } from "@aeros-core/react";

// Skeleton has no size props: shape it with height / width / radius classes.
export const TextAndBlock = () => (
  <div style={{ display: "grid", gap: 10, maxWidth: 384 }}>
    <Skeleton className="h-4 w-3/4" />
    <Skeleton className="h-4 w-1/2" />
    <Skeleton className="h-24 w-full rounded-xl" />
  </div>
);

export const ListRow = () => (
  <div
    className="rounded-surface border border-border-default bg-bg-surface p-4"
    style={{ display: "flex", alignItems: "center", gap: 12, maxWidth: 384 }}
  >
    <Skeleton className="h-10 w-10 rounded-full" />
    <div style={{ flex: 1, display: "grid", gap: 8 }}>
      <Skeleton className="h-3.5 w-2/3" />
      <Skeleton className="h-3 w-1/3" />
    </div>
  </div>
);
