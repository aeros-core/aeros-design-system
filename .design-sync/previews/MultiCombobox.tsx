import * as React from "react";
import { Field, MultiCombobox, type ComboboxOption } from "@aeros-core/react";

const vendors: ComboboxOption[] = [
  { value: "trimurti", label: "Trimurti Packaging" },
  { value: "shakti", label: "Shakti Bearings" },
  { value: "everest", label: "Everest Polymers" },
  { value: "meridian", label: "Meridian Logistics" },
];

const col: React.CSSProperties = { display: "grid", gap: 12, maxWidth: 420 };

// `open` renders the popup statically, with two vendors already ticked.
export const OpenList = () => (
  <div style={{ maxWidth: 360, minHeight: 280 }}>
    <MultiCombobox
      open
      aria-label="Vendors"
      options={vendors}
      defaultValue={["trimurti", "everest"]}
      searchPlaceholder="Search vendors…"
    />
  </div>
);

export const TagsAndOverflow = () => (
  <div style={col}>
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
  </div>
);

export const InField = () => (
  <div style={col}>
    <Field label="Vendors" hint="Quotes are requested from each one.">
      <MultiCombobox options={vendors} defaultValue={["trimurti", "everest"]} />
    </Field>
  </div>
);
