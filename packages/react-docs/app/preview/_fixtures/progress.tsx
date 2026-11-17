"use client";

import { Progress } from "@aeros-core/react";
import { Group } from "./kit";

export default function ProgressFixture() {
  return (
    <>
      <Group label="Variants" className="max-w-md flex-col items-stretch gap-4">
        <Progress value={64} aria-label="Brand 64%" />
        <Progress value={80} variant="success" aria-label="Success 80%" />
        <Progress value={42} variant="warning" aria-label="Warning 42%" />
        <Progress value={22} variant="danger" aria-label="Danger 22%" />
      </Group>
      <Group label="Extremes" className="max-w-md flex-col items-stretch gap-4">
        <Progress value={0} aria-label="Empty" />
        <Progress value={100} aria-label="Full" />
      </Group>
      <Group label="On bg-surface" className="max-w-md flex-col items-stretch">
        <div className="rounded-lg border border-border-default bg-bg-surface p-4">
          <div className="mb-1.5 flex justify-between text-xs">
            <span className="font-medium text-fg-secondary">Line 1</span>
            <span className="font-mono text-fg-muted">64%</span>
          </div>
          <Progress value={64} aria-label="Line 1" />
        </div>
      </Group>
    </>
  );
}
