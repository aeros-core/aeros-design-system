"use client";

import {
  Field,
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@aeros-core/react";
import { Group } from "./kit";

function Options() {
  return (
    <SelectContent>
      <SelectItem value="trimurti">Trimurti Packaging</SelectItem>
      <SelectItem value="shakti">Shakti Bearings</SelectItem>
      <SelectItem value="everest">Everest Polymers</SelectItem>
    </SelectContent>
  );
}

// Closed triggers only — the open listbox is captured by the select-open fixture.
export default function SelectFixture() {
  return (
    <>
      <Group label="Sizes" className="max-w-xl flex-col items-stretch">
        <Select>
          <SelectTrigger size="sm" aria-label="Small"><SelectValue placeholder="sm · 32" /></SelectTrigger>
          <Options />
        </Select>
        <Select>
          <SelectTrigger size="md" aria-label="Medium"><SelectValue placeholder="md · 36" /></SelectTrigger>
          <Options />
        </Select>
        <Select>
          <SelectTrigger size="lg" aria-label="Large"><SelectValue placeholder="lg · 40" /></SelectTrigger>
          <Options />
        </Select>
      </Group>
      <Group label="States" className="max-w-xl flex-col items-stretch">
        <Select defaultValue="shakti">
          <SelectTrigger aria-label="With value"><SelectValue placeholder="Choose a vendor" /></SelectTrigger>
          <Options />
        </Select>
        <Select defaultValue="shakti">
          <SelectTrigger state="error" aria-label="Error"><SelectValue placeholder="Choose a vendor" /></SelectTrigger>
          <Options />
        </Select>
        <Select defaultValue="shakti">
          <SelectTrigger state="success" aria-label="Success"><SelectValue placeholder="Choose a vendor" /></SelectTrigger>
          <Options />
        </Select>
        <Select disabled>
          <SelectTrigger aria-label="Disabled empty"><SelectValue placeholder="Disabled" /></SelectTrigger>
          <Options />
        </Select>
        <Select disabled defaultValue="everest">
          <SelectTrigger aria-label="Disabled filled"><SelectValue placeholder="Disabled" /></SelectTrigger>
          <Options />
        </Select>
      </Group>
      <Group label="Field wrapper" className="max-w-xl flex-col items-stretch gap-0">
        <Field label="Vendor" hint="Only approved vendors are listed.">
          <Select>
            <SelectTrigger><SelectValue placeholder="Choose a vendor" /></SelectTrigger>
            <Options />
          </Select>
        </Field>
        <Field label="Vendor" required error="Pick a vendor to continue.">
          <Select>
            <SelectTrigger><SelectValue placeholder="Choose a vendor" /></SelectTrigger>
            <Options />
          </Select>
        </Field>
      </Group>
    </>
  );
}
