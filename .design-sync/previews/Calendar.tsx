import * as React from "react";
import { Calendar } from "@aeros-core/react";

// Pinned to August 2026: `month` fixes the grid, `today` the "today" style.
const month = new Date(2026, 7, 1);
const today = new Date(2026, 7, 14);
const box = "inline-block rounded-xl border border-border-default bg-bg-surface";

export const SingleDate = () => (
  <div className={box}>
    <Calendar
      mode="single"
      month={month}
      today={today}
      selected={new Date(2026, 7, 20)}
      disabled={{ before: new Date(2026, 7, 5) }}
    />
  </div>
);

export const DateRange = () => (
  <div className={box}>
    <Calendar
      mode="range"
      month={month}
      today={today}
      selected={{ from: new Date(2026, 7, 10), to: new Date(2026, 7, 16) }}
    />
  </div>
);

export const NoSelection = () => (
  <div className={box}>
    <Calendar mode="single" month={month} today={today} showOutsideDays={false} />
  </div>
);
