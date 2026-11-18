"use client";

import * as React from "react";
import { cn } from "@aeros-core/react";

/**
 * Chrome-less shell every fixture renders in: canvas background, fixed padding,
 * fixed max width. `data-fixture-ready` flips to "true" one frame after mount
 * (child effects have run by then), which is what the Playwright specs wait on.
 */
export function FixtureFrame({ slug, children }: { slug: string; children: React.ReactNode }) {
  const [ready, setReady] = React.useState(false);
  React.useEffect(() => {
    const id = requestAnimationFrame(() => setReady(true));
    return () => cancelAnimationFrame(id);
  }, []);
  return (
    <main
      data-fixture={slug}
      data-fixture-ready={ready ? "true" : "false"}
      className="min-h-screen bg-bg-canvas p-6"
    >
      <div className="mx-auto w-full max-w-[960px]">{children}</div>
    </main>
  );
}

/** A labelled row of variants. The label is fixture scaffolding, not DS output. */
export function Group({
  label,
  children,
  className,
}: {
  label: string;
  children: React.ReactNode;
  className?: string;
}) {
  return (
    <div className="mb-8 last:mb-0">
      <div className="mb-3 font-mono text-[11px] font-medium uppercase tracking-wider text-fg-secondary">
        {label}
      </div>
      <div className={cn("flex flex-wrap items-center gap-3", className)}>{children}</div>
    </div>
  );
}

/** Fixed "now" for anything date-shaped. Never use `new Date()` in a fixture. */
export const FIXED_TODAY = new Date(2026, 7, 14);
export const FIXED_MONTH = new Date(2026, 7, 1);
