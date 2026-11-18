"use client";

import { Calendar } from "@aeros-core/react";
import { FIXED_MONTH, FIXED_TODAY, Group } from "./kit";

const box = "inline-block rounded-xl border border-border-default bg-bg-surface ";

// Everything is pinned to August 2026: `month` (controlled, so the grid can
// never drift) and `today` (so the "today" style does not follow the clock).
export default function CalendarFixture() {
  return (
    <>
      <Group label="Single — selected 20th, today 14th, days before the 5th disabled" className="items-start">
        <div className={box}>
          <Calendar
            mode="single"
            month={FIXED_MONTH}
            today={FIXED_TODAY}
            selected={new Date(2026, 7, 20)}
            disabled={{ before: new Date(2026, 7, 5) }}
          />
        </div>
      </Group>
      <Group label="Range — 10th to 16th" className="items-start">
        <div className={box}>
          <Calendar
            mode="range"
            month={FIXED_MONTH}
            today={FIXED_TODAY}
            selected={{ from: new Date(2026, 7, 10), to: new Date(2026, 7, 16) }}
          />
        </div>
      </Group>
      <Group label="No selection, outside days hidden" className="items-start">
        <div className={box}>
          <Calendar mode="single" month={FIXED_MONTH} today={FIXED_TODAY} showOutsideDays={false} />
        </div>
      </Group>
    </>
  );
}
