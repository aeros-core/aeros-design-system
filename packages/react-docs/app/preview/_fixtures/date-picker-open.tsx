"use client";

import { DateRangePicker } from "@aeros-core/react";
import { FIXED_MONTH, FIXED_TODAY, Group } from "./kit";

const presets = [
  { label: "This week", range: { from: new Date(2026, 7, 10), to: new Date(2026, 7, 16) } },
  { label: "Last week", range: { from: new Date(2026, 7, 3), to: new Date(2026, 7, 9) } },
  { label: "Month to date", range: { from: new Date(2026, 7, 1), to: new Date(2026, 7, 14) } },
  { label: "Last month", range: { from: new Date(2026, 6, 1), to: new Date(2026, 6, 31) } },
];

// Pinned to August 2026: the value fixes the first month shown, `today` the "today" style.
export default function DatePickerOpenFixture() {
  return (
    <Group label="Date range picker — open (presets, 10th to 16th, today 14th, two months)" className="max-w-xs flex-col items-stretch">
      <DateRangePicker
        open
        aria-label="Reporting period"
        defaultMonth={FIXED_MONTH}
        today={FIXED_TODAY}
        defaultValue={{ from: new Date(2026, 7, 10), to: new Date(2026, 7, 16) }}
        presets={presets}
      />
    </Group>
  );
}
