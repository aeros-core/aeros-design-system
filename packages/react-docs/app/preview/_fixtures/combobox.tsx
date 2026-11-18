"use client";

import { Combobox, Field, MultiCombobox, type ComboboxOption } from "@aeros-core/react";
import { Group } from "./kit";

const vendors: ComboboxOption[] = [
  { value: "trimurti", label: "Trimurti Packaging" },
  { value: "shakti", label: "Shakti Bearings" },
  { value: "everest", label: "Everest Polymers" },
  { value: "meridian", label: "Meridian Logistics" },
];

// Closed triggers only — the open list is captured by the combobox-open fixture.
export default function ComboboxFixture() {
  return (
    <>
      <Group label="Sizes" className="max-w-xl flex-col items-stretch">
        <Combobox size="sm" aria-label="Small" options={vendors} placeholder="sm · 28" />
        <Combobox size="md" aria-label="Medium" options={vendors} placeholder="md · 32" />
        <Combobox size="lg" aria-label="Large" options={vendors} placeholder="lg · 36" />
      </Group>
      <Group label="States" className="max-w-xl flex-col items-stretch">
        <Combobox aria-label="Default" options={vendors} placeholder="Choose a vendor" />
        <Combobox aria-label="Filled" options={vendors} defaultValue="shakti" />
        <Combobox aria-label="Filled, clearable" options={vendors} defaultValue="shakti" clearable />
        <Combobox aria-label="Error" options={vendors} defaultValue="shakti" state="error" />
        <Combobox aria-label="Disabled empty" options={vendors} placeholder="Disabled" disabled />
        <Combobox aria-label="Disabled filled" options={vendors} defaultValue="everest" disabled />
      </Group>
      <Group label="Multiple — tags, +N overflow, clearable" className="max-w-xl flex-col items-stretch">
        <MultiCombobox aria-label="No vendors" options={vendors} placeholder="Any vendor" />
        <MultiCombobox aria-label="One vendor" options={vendors} defaultValue={["trimurti"]} />
        <MultiCombobox
          aria-label="Four vendors"
          options={vendors}
          defaultValue={["trimurti", "shakti", "everest", "meridian"]}
          clearable
        />
        <MultiCombobox
          size="sm"
          aria-label="Three tags, small"
          options={vendors}
          defaultValue={["shakti", "everest", "meridian"]}
          maxTags={3}
        />
        <MultiCombobox aria-label="Disabled with tags" options={vendors} defaultValue={["trimurti", "shakti"]} disabled />
      </Group>
      <Group label="Field wrapper" className="max-w-xl flex-col items-stretch gap-4">
        <Field label="Vendor" hint="Only approved vendors are listed.">
          <Combobox options={vendors} placeholder="Choose a vendor" />
        </Field>
        <Field label="Vendor" required error="Pick a vendor to continue.">
          <Combobox options={vendors} placeholder="Choose a vendor" />
        </Field>
        <Field label="Vendors" hint="Quotes are requested from each one.">
          <MultiCombobox options={vendors} defaultValue={["trimurti", "everest"]} />
        </Field>
      </Group>
    </>
  );
}
