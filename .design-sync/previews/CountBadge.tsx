import * as React from "react";
import { CountBadge } from "@aeros-core/react";

const TONES = ["solid", "muted", "danger"] as const;
const COUNTS = [1, 7, 42, 99, 100, 1250];

const row: React.CSSProperties = { display: "flex", flexWrap: "wrap", gap: 12, alignItems: "center" };

export const Tones = () => (
  <div style={{ display: "grid", gap: 12 }}>
    {TONES.map((tone) => (
      <div key={tone} style={row}>
        {COUNTS.map((count) => (
          <CountBadge key={count} tone={tone} count={count} />
        ))}
      </div>
    ))}
  </div>
);

// `max` caps the readout ("9+", "999+"); zero is hidden unless `showZero`.
export const MaxAndZero = () => (
  <div style={row}>
    <CountBadge count={12} max={9} />
    <CountBadge count={1250} max={999} />
    <CountBadge count={1250} max={999} tone="muted" />
    {TONES.map((tone) => (
      <CountBadge key={tone} tone={tone} count={0} showZero />
    ))}
  </div>
);

export const InlineWithLabel = () => (
  <div style={{ ...row, gap: 24 }}>
    <span className="inline-flex items-center gap-2 text-body-md text-fg-primary">
      Inbox <CountBadge count={3} aria-label="3 unread" />
    </span>
    <span className="inline-flex items-center gap-2 text-body-md text-fg-primary">
      Drafts <CountBadge count={12} tone="muted" aria-label="12 drafts" />
    </span>
    <span className="inline-flex items-center gap-2 text-body-md text-fg-primary">
      Failed <CountBadge count={128} tone="danger" aria-label="more than 99 failed" />
    </span>
  </div>
);
