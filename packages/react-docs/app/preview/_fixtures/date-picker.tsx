"use client";

import { DatePicker, DateRangePicker, Field } from "@aeros-core/react";
import { FIXED_MONTH, FIXED_TODAY, Group } from "./kit";

// Pinned to August 2026 (see kit.tsx) so nothing follows the clock.
const pinned = { defaultMonth: FIXED_MONTH, today: FIXED_TODAY };
const day = new Date(2026, 7, 20);
const range = { from: new Date(2026, 7, 10), to: new Date(2026, 7, 16) };

// Closed triggers only — the open calendar is captured by the date-picker-open fixture.
export default function DatePickerFixture() {
  return (
    <>
      <Group label="Single — sizes" className="max-w-xl flex-col items-stretch">
        <DatePicker {...pinned} size="sm" aria-label="Small" placeholder="sm · 28" />
        <DatePicker {...pinned} size="md" aria-label="Medium" placeholder="md · 32" />
        <DatePicker {...pinned} size="lg" aria-label="Large" placeholder="lg · 36" />
      </Group>
      <Group label="Single — states" className="max-w-xl flex-col items-stretch">
        <DatePicker {...pinned} aria-label="Empty" />
        <DatePicker {...pinned} aria-label="Filled" defaultValue={day} />
        <DatePicker {...pinned} aria-label="Filled, clearable" defaultValue={day} clearable />
        <DatePicker {...pinned} aria-label="Error" defaultValue={day} state="error" />
        <DatePicker {...pinned} aria-label="Disabled empty" disabled />
        <DatePicker {...pinned} aria-label="Disabled filled" defaultValue={day} disabled />
      </Group>
      <Group label="Range — states" className="max-w-xl flex-col items-stretch">
        <DateRangePicker {...pinned} aria-label="Range empty" />
        <DateRangePicker {...pinned} aria-label="Range filled" defaultValue={range} />
        <DateRangePicker {...pinned} aria-label="Range filled, clearable" defaultValue={range} clearable />
        <DateRangePicker {...pinned} aria-label="Range error" defaultValue={range} state="error" />
        <DateRangePicker {...pinned} aria-label="Range disabled" defaultValue={range} disabled />
      </Group>
      <Group label="Field wrapper" className="max-w-xl flex-col items-stretch gap-4">
        <Field label="Delivery date" hint="Working days only.">
          <DatePicker {...pinned} defaultValue={day} />
        </Field>
        <Field label="Delivery date" required error="Choose a delivery date.">
          <DatePicker {...pinned} />
        </Field>
        <Field label="Reporting period" hint="Both days are included.">
          <DateRangePicker {...pinned} defaultValue={range} />
        </Field>
      </Group>
    </>
  );
}
