import * as React from "react";
import { DateRangePicker, Field } from "@aeros-core/react";

// Pinned to August 2026 so nothing follows the clock.
const pinned = { defaultMonth: new Date(2026, 7, 1), today: new Date(2026, 7, 14) };
const range = { from: new Date(2026, 7, 10), to: new Date(2026, 7, 16) };

const presets = [
  { label: "This week", range: { from: new Date(2026, 7, 10), to: new Date(2026, 7, 16) } },
  { label: "Last week", range: { from: new Date(2026, 7, 3), to: new Date(2026, 7, 9) } },
  { label: "Month to date", range: { from: new Date(2026, 7, 1), to: new Date(2026, 7, 14) } },
  { label: "Last month", range: { from: new Date(2026, 6, 1), to: new Date(2026, 6, 31) } },
];

const col: React.CSSProperties = { display: "grid", gap: 12, maxWidth: 360 };

// `open` renders the popover statically: presets rail plus two months.
export const OpenWithPresets = () => (
  <div style={{ maxWidth: 320, minHeight: 420 }}>
    <DateRangePicker {...pinned} open aria-label="Reporting period" defaultValue={range} presets={presets} />
  </div>
);

export const States = () => (
  <div style={col}>
    <DateRangePicker {...pinned} aria-label="Range empty" />
    <DateRangePicker {...pinned} aria-label="Range filled, clearable" defaultValue={range} clearable />
    <DateRangePicker {...pinned} aria-label="Range error" defaultValue={range} state="error" />
    <DateRangePicker {...pinned} aria-label="Range disabled" defaultValue={range} disabled />
  </div>
);

export const InField = () => (
  <div style={col}>
    <Field label="Reporting period" hint="Both days are included.">
      <DateRangePicker {...pinned} defaultValue={range} />
    </Field>
  </div>
);
