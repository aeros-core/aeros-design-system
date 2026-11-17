"use client";

import { DotMatrix } from "@aeros-core/react";
import { Group } from "./kit";

// The matrix animates forever. The visual spec screenshots with
// `animations: "disabled"`, which resets infinite animations to their
// un-animated base style — so the baseline is the static frame.
export default function DotMatrixFixture() {
  return (
    <>
      <Group label="Ripple (defaults) / pulse" className="items-start gap-6">
        <div className="overflow-hidden rounded-3xl shadow-lg">
          <DotMatrix variant="ripple" />
        </div>
        <div className="overflow-hidden rounded-3xl shadow-lg">
          <DotMatrix size={200} rings={4} variant="pulse" speed={1600} />
        </div>
      </Group>
      <Group label="Custom colours, tight grid" className="items-start gap-6">
        <div className="overflow-hidden rounded-3xl border border-border-default">
          <DotMatrix
            size={200}
            rings={3}
            gap={18}
            dotSize={5}
            falloff={0.3}
            color="var(--color-ink-900)"
            background="var(--color-ink-100)"
          />
        </div>
      </Group>
    </>
  );
}
