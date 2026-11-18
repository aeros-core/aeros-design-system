"use client";

import { Combobox, type ComboboxOption } from "@aeros-core/react";
import { Group } from "./kit";

const vendors: ComboboxOption[] = [
  { value: "trimurti", label: "Trimurti Packaging", group: "Packaging" },
  { value: "everest", label: "Everest Polymers", description: "Granules and film", group: "Packaging" },
  { value: "shakti", label: "Shakti Bearings", group: "Engineering" },
  { value: "meridian", label: "Meridian Logistics", group: "Engineering", disabled: true },
];

export default function ComboboxOpenFixture() {
  return (
    <Group label="Combobox — open (search, groups, selected item, disabled item)" className="max-w-xs flex-col items-stretch">
      <Combobox
        open
        aria-label="Vendor"
        options={vendors}
        defaultValue="shakti"
        placeholder="Choose a vendor"
        searchPlaceholder="Search vendors…"
      />
    </Group>
  );
}
