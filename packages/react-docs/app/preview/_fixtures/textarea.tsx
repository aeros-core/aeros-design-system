"use client";

import { Field, Textarea } from "@aeros-core/react";
import { Group } from "./kit";

export default function TextareaFixture() {
  return (
    <>
      <Group label="Sizes" className="max-w-xl flex-col items-stretch">
        <Textarea size="sm" aria-label="Small" placeholder="sm" />
        <Textarea size="md" aria-label="Medium" placeholder="md" />
        <Textarea size="lg" aria-label="Large" placeholder="lg" />
      </Group>
      <Group label="States" className="max-w-xl flex-col items-stretch">
        <Textarea aria-label="Filled" defaultValue="12,000 double-wall cups, dispatch Friday." />
        <Textarea aria-label="Error" state="error" defaultValue="Too short" />
        <Textarea aria-label="Success" state="success" defaultValue="Looks good." />
        <Textarea aria-label="Disabled" disabled defaultValue="Disabled value" />
      </Group>
      <Group label="Field wrapper" className="max-w-xl flex-col items-stretch gap-4">
        <Field label="Notes" hint="Visible to your team only.">
          <Textarea placeholder="Add context for your team…" rows={3} />
        </Field>
        <Field label="Reason" required error="Tell us why the order was rejected.">
          <Textarea rows={3} />
        </Field>
      </Group>
    </>
  );
}
