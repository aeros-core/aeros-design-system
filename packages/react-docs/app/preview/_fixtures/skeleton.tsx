"use client";

import { Skeleton } from "@aeros-core/react";
import { Group } from "./kit";

export default function SkeletonFixture() {
  return (
    <>
      <Group label="Text lines + block" className="max-w-sm flex-col items-stretch gap-2.5">
        <Skeleton className="h-4 w-3/4" />
        <Skeleton className="h-4 w-1/2" />
        <Skeleton className="h-24 w-full rounded-xl" />
      </Group>
      <Group label="List row on bg-surface" className="max-w-sm flex-col items-stretch">
        <div className="flex items-center gap-3 rounded-lg border border-border-default bg-bg-surface p-4">
          <Skeleton className="h-10 w-10 rounded-full" />
          <div className="flex-1 space-y-2">
            <Skeleton className="h-3.5 w-2/3" />
            <Skeleton className="h-3 w-1/3" />
          </div>
        </div>
      </Group>
    </>
  );
}
