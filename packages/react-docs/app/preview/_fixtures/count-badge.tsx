"use client";

import { CountBadge } from "@aeros-core/react";
import { Group } from "./kit";

const TONES = ["solid", "muted", "danger"] as const;
const COUNTS = [1, 7, 42, 99, 100, 1250];

export default function CountBadgeFixture() {
  return (
    <>
      {TONES.map((tone) => (
        <Group key={tone} label={`Tone — ${tone}`}>
          {COUNTS.map((count) => (
            <CountBadge key={count} tone={tone} count={count} />
          ))}
        </Group>
      ))}
      <Group label="Custom max (9) / (999)">
        <CountBadge count={12} max={9} />
        <CountBadge count={1250} max={999} />
        <CountBadge count={1250} max={999} tone="muted" />
      </Group>
      <Group label="Zero — hidden by default, shown with showZero">
        <span className="text-body-md text-fg-secondary">
          Hidden: [<CountBadge count={0} />]
        </span>
        {TONES.map((tone) => (
          <CountBadge key={tone} tone={tone} count={0} showZero />
        ))}
      </Group>
      <Group label="Inline with a label">
        <span className="inline-flex items-center gap-2 text-body-md text-fg-primary">
          Inbox <CountBadge count={3} aria-label="3 unread" />
        </span>
        <span className="inline-flex items-center gap-2 text-body-md text-fg-primary">
          Drafts <CountBadge count={12} tone="muted" aria-label="12 drafts" />
        </span>
        <span className="inline-flex items-center gap-2 text-body-md text-fg-primary">
          Failed <CountBadge count={128} tone="danger" aria-label="more than 99 failed" />
        </span>
      </Group>
      <Group label="On bg-surface">
        <div className="flex flex-wrap gap-3 rounded-surface border border-border-default bg-bg-surface p-4">
          {TONES.map((tone) => (
            <CountBadge key={tone} tone={tone} count={8} />
          ))}
        </div>
      </Group>
    </>
  );
}
