"use client";

import { Field, NumberInput } from "@aeros-core/react";
import { Group } from "./kit";

export default function NumberInputFixture() {
  return (
    <>
      <Group label="Sizes" className="max-w-xl flex-col items-stretch">
        <NumberInput size="sm" aria-label="Small" placeholder="sm · 28" />
        <NumberInput size="md" aria-label="Medium" placeholder="md · 32" />
        <NumberInput size="lg" aria-label="Large" placeholder="lg · 36" />
      </Group>
      <Group label="Prefix / suffix" className="max-w-xl flex-col items-stretch">
        <NumberInput aria-label="Price" prefix="₹" defaultValue={1250} precision={2} step={50} />
        <NumberInput aria-label="Weight" suffix="kg" defaultValue={12.5} step={0.5} />
        <NumberInput aria-label="Unit price" prefix="INR" suffix="/ pc" defaultValue={48} />
      </Group>
      <Group label="States" className="max-w-xl flex-col items-stretch">
        <NumberInput aria-label="Filled" defaultValue={24} />
        <NumberInput aria-label="At min — decrease disabled" defaultValue={1} min={1} max={10} />
        <NumberInput aria-label="At max — increase disabled" defaultValue={10} min={1} max={10} />
        <NumberInput aria-label="Error" state="error" defaultValue={0} />
        <NumberInput aria-label="Disabled empty" disabled placeholder="Disabled" />
        <NumberInput aria-label="Disabled filled" disabled defaultValue={500} suffix="pcs" />
        <NumberInput aria-label="Read only" readOnly defaultValue={500} />
      </Group>
      <Group label="Field wrapper" className="max-w-xl flex-col items-stretch gap-4">
        <Field label="Quantity" hint="Sold in cartons of 50.">
          <NumberInput defaultValue={50} min={50} step={50} suffix="pcs" />
        </Field>
        <Field label="Quantity" required error="Enter a quantity of at least 50.">
          <NumberInput defaultValue={20} min={50} step={50} suffix="pcs" />
        </Field>
      </Group>
    </>
  );
}
