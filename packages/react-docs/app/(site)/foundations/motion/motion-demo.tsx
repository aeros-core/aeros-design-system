"use client";

import * as React from "react";
import { Alert, Button, SegmentedControl, SegmentedControlItem, cn } from "@aeros-core/react";
import { Play } from "lucide-react";

/**
 * A marker travels along a track with each duration token. The timing comes
 * from the CSS variables, so the demo always shows the shipped values. Under
 * `prefers-reduced-motion` the marker jumps to its end position instead.
 */
export function MotionDemo({
  durations,
  eases,
}: {
  durations: Array<{ name: string; ms: number }>;
  eases: string[];
}) {
  const [ease, setEase] = React.useState(eases[0] ?? "standard");
  const [atEnd, setAtEnd] = React.useState(false);
  const [reduced, setReduced] = React.useState(false);

  React.useEffect(() => {
    if (typeof window.matchMedia !== "function") return;
    const query = window.matchMedia("(prefers-reduced-motion: reduce)");
    const sync = () => setReduced(query.matches);
    sync();
    query.addEventListener("change", sync);
    return () => query.removeEventListener("change", sync);
  }, []);

  return (
    <div className="rounded-surface border border-border-default bg-bg-surface">
      <div className="flex flex-wrap items-center justify-between gap-3 border-b border-border-default px-4 py-3">
        <SegmentedControl value={ease} onValueChange={setEase} aria-label="Easing">
          {eases.map((name) => (
            <SegmentedControlItem key={name} value={name}>
              {name}
            </SegmentedControlItem>
          ))}
        </SegmentedControl>
        <Button variant="secondary" leadingIcon={<Play />} onClick={() => setAtEnd((value) => !value)}>
          {atEnd ? "Replay back" : "Play"}
        </Button>
      </div>
      <div className="grid gap-3 p-4">
        {durations.map(({ name, ms }) => (
          <div key={name} className="grid grid-cols-[5.5rem_minmax(0,1fr)] items-center gap-3">
            <div>
              <div className="text-label-sm text-fg-primary">{name}</div>
              <div className="font-mono text-mono-xs text-fg-muted">{ms}ms</div>
            </div>
            <div className="relative h-8 rounded-control bg-bg-inset">
              <div
                aria-hidden
                className={cn(
                  "absolute inset-y-1 w-6 rounded-item bg-bg-inverse transition-[left] motion-reduce:transition-none",
                  atEnd ? "left-[calc(100%-1.75rem)]" : "left-1"
                )}
                style={{
                  transitionDuration: `var(--aeros-duration-${name})`,
                  transitionTimingFunction: `var(--aeros-ease-${ease})`,
                }}
              />
            </div>
          </div>
        ))}
      </div>
      {reduced && (
        <div className="border-t border-border-default p-4">
          <Alert variant="info" title="Reduced motion is on">
            Your system asks for less motion, so the markers jump instead of travelling — exactly what the components
            do.
          </Alert>
        </div>
      )}
    </div>
  );
}
