"use client";

import { Spinner } from "@aeros-core/react";
import { Group } from "./kit";

export default function SpinnerFixture() {
  return (
    <>
      <Group label="Sizes">
        <Spinner size="sm" />
        <Spinner />
        <Spinner size="lg" />
      </Group>
      <Group label="Inline with text">
        <span className="inline-flex items-center gap-2 text-sm text-fg-secondary">
          <Spinner size="sm" label="Loading orders" /> Loading orders…
        </span>
      </Group>
      <Group label="On bg-inverse">
        <div className="rounded-lg bg-bg-inverse p-4">
          <Spinner />
        </div>
      </Group>
    </>
  );
}
