"use client";

import { Checkbox } from "@aeros-core/react";
import { Group } from "./kit";

const row = "inline-flex items-center gap-2 text-body-md text-fg-secondary";

export default function CheckboxFixture() {
  return (
    <>
      <Group label="States">
        <label className={row}><Checkbox checked={false} /> Unchecked</label>
        <label className={row}><Checkbox checked /> Checked</label>
        <label className={row}><Checkbox checked="indeterminate" /> Indeterminate</label>
      </Group>
      <Group label="Disabled">
        <label className={row}><Checkbox disabled checked={false} /> Unchecked</label>
        <label className={row}><Checkbox disabled checked /> Checked</label>
        <label className={row}><Checkbox disabled checked="indeterminate" /> Indeterminate</label>
      </Group>
      <Group label="Stacked list" className="flex-col items-start gap-2">
        <label className={row}><Checkbox checked /> Email me order updates</label>
        <label className={row}><Checkbox checked={false} /> Email me weekly summaries</label>
        <label className={row}><Checkbox checked={false} /> Email me product news</label>
      </Group>
    </>
  );
}
