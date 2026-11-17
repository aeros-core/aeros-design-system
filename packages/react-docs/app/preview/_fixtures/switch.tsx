"use client";

import { Switch } from "@aeros-core/react";
import { Group } from "./kit";

const row = "inline-flex items-center gap-3 text-sm text-fg-secondary";

export default function SwitchFixture() {
  return (
    <>
      <Group label="States">
        <label className={row}><Switch checked={false} /> Off</label>
        <label className={row}><Switch checked /> On</label>
      </Group>
      <Group label="Disabled">
        <label className={row}><Switch disabled checked={false} /> Off</label>
        <label className={row}><Switch disabled checked /> On</label>
      </Group>
    </>
  );
}
