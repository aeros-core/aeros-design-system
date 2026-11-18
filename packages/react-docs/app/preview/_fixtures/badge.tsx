"use client";

import { Badge } from "@aeros-core/react";
import { Group } from "./kit";

const VARIANTS = ["success", "warning", "danger", "info", "neutral", "inverse"] as const;

export default function BadgeFixture() {
  return (
    <>
      <Group label="With dot">
        {VARIANTS.map((v) => (
          <Badge key={v} variant={v} dot>
            {v}
          </Badge>
        ))}
      </Group>
      <Group label="Without dot">
        {VARIANTS.map((v) => (
          <Badge key={v} variant={v}>
            {v}
          </Badge>
        ))}
      </Group>
      <Group label="Default (no variant prop) + numeric">
        <Badge>Default</Badge>
        <Badge variant="inverse">12</Badge>
        <Badge variant="danger">99+</Badge>
      </Group>
      <Group label="On bg-surface">
        <div className="flex flex-wrap gap-3 rounded-surface border border-border-default bg-bg-surface p-4">
          {VARIANTS.map((v) => (
            <Badge key={v} variant={v} dot>
              {v}
            </Badge>
          ))}
        </div>
      </Group>
    </>
  );
}
