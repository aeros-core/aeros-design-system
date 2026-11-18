"use client";

import { Tag } from "@aeros-core/react";
import { Group } from "./kit";

export default function TagFixture() {
  return (
    <>
      <Group label="Variants">
        <Tag variant="neutral">v1.0.0</Tag>
        <Tag variant="info">beta</Tag>
        <Tag variant="inverse">internal</Tag>
        <Tag>default</Tag>
      </Group>
      <Group label="On bg-surface">
        <div className="flex flex-wrap gap-3 rounded-surface border border-border-default bg-bg-surface p-4">
          <Tag variant="neutral">v1.0.0</Tag>
          <Tag variant="info">beta</Tag>
          <Tag variant="inverse">internal</Tag>
        </div>
      </Group>
    </>
  );
}
