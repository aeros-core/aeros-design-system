import * as React from "react";
import { DatePicker, Field } from "@aeros-core/react";

// Pinned to August 2026 so nothing follows the clock.
const pinned = { defaultMonth: new Date(2026, 7, 1), today: new Date(2026, 7, 14) };
const day = new Date(2026, 7, 20);

const col: React.CSSProperties = { display: "grid", gap: 12, maxWidth: 320 };

// `open` renders the calendar popover statically.
export const OpenCalendar = () => (
  <div style={{ maxWidth: 280, minHeight: 380 }}>
    <DatePicker {...pinned} open aria-label="Delivery date" defaultValue={day} />
  </div>
);

export const Sizes = () => (
  <div style={col}>
    <DatePicker {...pinned} size="sm" aria-label="Small" placeholder="Small" />
    <DatePicker {...pinned} size="md" aria-label="Medium" placeholder="Medium" />
    <DatePicker {...pinned} size="lg" aria-label="Large" placeholder="Large" />
  </div>
);

export const States = () => (
  <div style={col}>
    <DatePicker {...pinned} aria-label="Empty" />
    <DatePicker {...pinned} aria-label="Filled, clearable" defaultValue={day} clearable />
    <DatePicker {...pinned} aria-label="Error" defaultValue={day} state="error" />
    <DatePicker {...pinned} aria-label="Disabled" defaultValue={day} disabled />
  </div>
);

export const InField = () => (
  <div style={{ ...col, gap: 16 }}>
    <Field label="Delivery date" hint="Working days only.">
      <DatePicker {...pinned} defaultValue={day} />
    </Field>
    <Field label="Delivery date" required error="Choose a delivery date.">
      <DatePicker {...pinned} />
    </Field>
  </div>
);
