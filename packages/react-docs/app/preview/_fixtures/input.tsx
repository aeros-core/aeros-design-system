"use client";

import { Button, Field, Input } from "@aeros-core/react";
import { Search } from "lucide-react";
import { Group } from "./kit";

export default function InputFixture() {
  return (
    <>
      <Group label="Sizes" className="max-w-xl flex-col items-stretch">
        <Input size="sm" aria-label="Small" placeholder="sm · 32" />
        <Input size="md" aria-label="Medium" placeholder="md · 36" />
        <Input size="lg" aria-label="Large" placeholder="lg · 40" />
      </Group>
      <Group label="States" className="max-w-xl flex-col items-stretch">
        <Input aria-label="Default empty" placeholder="Placeholder" />
        <Input aria-label="Default filled" defaultValue="Priya Sharma" />
        <Input aria-label="Error" state="error" defaultValue="RFQ-00" />
        <Input aria-label="Success" state="success" defaultValue="RFQ-0042" />
        <Input aria-label="Disabled empty" disabled placeholder="Disabled" />
        <Input aria-label="Disabled filled" disabled defaultValue="Disabled value" />
        <Input aria-label="Read only" readOnly defaultValue="Read-only value" />
      </Group>
      <Group label="Prefix / suffix" className="max-w-xl flex-col items-stretch">
        <Input aria-label="Search" prefix={<Search className="h-4 w-4" />} placeholder="Search by RFQ / SKU" />
        <Input
          aria-label="Coupon"
          placeholder="Coupon code"
          suffix={<Button size="xs" variant="secondary">Apply</Button>}
        />
        <Input
          aria-label="Search with action"
          prefix={<Search className="h-4 w-4" />}
          suffix={<Button size="xs" variant="ghost">Go</Button>}
          defaultValue="double-wall cups"
        />
      </Group>
      <Group label="Field wrapper" className="max-w-xl flex-col items-stretch gap-0">
        <Field label="Email" hint="We'll never share your address.">
          <Input type="email" placeholder="priya@example.com" />
        </Field>
        <Field label="Full name" required>
          <Input placeholder="Priya Sharma" />
        </Field>
        <Field label="With error" error="This field is required.">
          <Input placeholder="RFQ-0042" />
        </Field>
        <Field label="Explicit success state" hint="Looks good.">
          <Input state="success" defaultValue="RFQ-0042" />
        </Field>
        <Field label="Disabled">
          <Input disabled defaultValue="Locked" />
        </Field>
      </Group>
    </>
  );
}
