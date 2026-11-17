"use client";

import { Group } from "./kit";

// Type-scale utility classes shipped by @aeros-core/tokens (tokens.css).
const SCALE: Array<{ cls: string; sample: string }> = [
  { cls: "aeros-text-display-xl", sample: "Run everything." },
  { cls: "aeros-text-display-lg", sample: "Run everything." },
  { cls: "aeros-text-display-md", sample: "Built for operators." },
  { cls: "aeros-text-h1", sample: "Today's production" },
  { cls: "aeros-text-h2", sample: "Pending approvals" },
  { cls: "aeros-text-h3", sample: "Live shipments" },
  { cls: "aeros-text-h4", sample: "RFQ-0042 · Pacific Pack Co." },
  { cls: "aeros-text-title-lg", sample: "Order #1042" },
  { cls: "aeros-text-body-lg", sample: "Designed for the operator who can't pause for slow software." },
  { cls: "aeros-text-body-md", sample: "Designed for the operator who can't pause for slow software." },
  { cls: "aeros-text-body-sm", sample: "Updated 3 minutes ago by Priya Sharma." },
  { cls: "aeros-text-label-md", sample: "Field label" },
  { cls: "aeros-text-label-sm", sample: "Field label" },
  { cls: "aeros-text-label-xs", sample: "Field label" },
  { cls: "aeros-text-caption", sample: "Auto-refreshed at 14:02 IST" },
  { cls: "aeros-text-overline", sample: "Section label" },
  { cls: "aeros-text-mono-lg", sample: "RFQ-0042 · ₹1,24,000" },
  { cls: "aeros-text-mono-md", sample: "RFQ-0042 · ₹1,24,000" },
  { cls: "aeros-text-mono-sm", sample: "0xA94F-LINE-3-SENSOR-02" },
  { cls: "aeros-text-mono-xs", sample: "0xA94F-LINE-3-SENSOR-02" },
];

export default function FoundationsTypeFixture() {
  return (
    <>
      <Group label="Type scale (aeros-text-*)" className="flex-col items-stretch gap-0">
        {SCALE.map((t) => (
          <div key={t.cls} className="border-b border-border-default py-3">
            <div className="mb-1 font-mono text-[11px] text-fg-secondary">{t.cls}</div>
            <div className={t.cls + " text-fg-primary"}>{t.sample}</div>
          </div>
        ))}
      </Group>
      <Group label="Text colours" className="flex-col items-start gap-1">
        <p className="text-sm text-fg-primary">fg-primary — The quick brown fox jumps over the lazy dog.</p>
        <p className="text-sm text-fg-secondary">fg-secondary — The quick brown fox jumps over the lazy dog.</p>
        <p className="text-sm text-fg-muted">fg-muted — The quick brown fox jumps over the lazy dog.</p>
        <p className="text-sm text-fg-brand">fg-brand — The quick brown fox jumps over the lazy dog.</p>
        <p className="rounded-md bg-bg-inverse px-2 py-1 text-sm text-fg-inverse">
          fg-inverse on bg-inverse — The quick brown fox.
        </p>
      </Group>
      <Group label="Font families + weights" className="flex-col items-start gap-1">
        <p className="font-sans text-base font-normal text-fg-primary">Inter 400 — 0123456789 ₹1,24,000</p>
        <p className="font-sans text-base font-medium text-fg-primary">Inter 500 — 0123456789 ₹1,24,000</p>
        <p className="font-sans text-base font-semibold text-fg-primary">Inter 600 — 0123456789 ₹1,24,000</p>
        <p className="font-sans text-base font-bold text-fg-primary">Inter 700 — 0123456789 ₹1,24,000</p>
        <p className="font-mono text-base font-normal text-fg-primary">IBM Plex Mono 400 — 0123456789 ₹1,24,000</p>
        <p className="font-mono text-base font-medium text-fg-primary">IBM Plex Mono 500 — 0123456789 ₹1,24,000</p>
      </Group>
      <Group label="Wordmark (aeros-logo)">
        <div className="aeros-logo text-[44px] text-fg-primary">Aeros</div>
        <div className="aeros-logo text-[20px] text-fg-primary">Aeros</div>
      </Group>
    </>
  );
}
