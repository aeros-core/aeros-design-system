import * as React from "react";
import { Combobox, Field, type ComboboxOption } from "@aeros-core/react";

const vendors: ComboboxOption[] = [
  { value: "trimurti", label: "Trimurti Packaging", group: "Packaging" },
  { value: "everest", label: "Everest Polymers", description: "Granules and film", group: "Packaging" },
  { value: "shakti", label: "Shakti Bearings", group: "Engineering" },
  { value: "meridian", label: "Meridian Logistics", group: "Engineering", disabled: true },
];

const col: React.CSSProperties = { display: "grid", gap: 12, maxWidth: 360 };

// `open` renders the popup statically: search, groups, selected and disabled items.
export const OpenList = () => (
  <div style={{ maxWidth: 320, minHeight: 300 }}>
    <Combobox
      open
      aria-label="Vendor"
      options={vendors}
      defaultValue="shakti"
      placeholder="Choose a vendor"
      searchPlaceholder="Search vendors…"
    />
  </div>
);

export const Sizes = () => (
  <div style={col}>
    <Combobox size="sm" aria-label="Small" options={vendors} placeholder="Small" />
    <Combobox size="md" aria-label="Medium" options={vendors} placeholder="Medium" />
    <Combobox size="lg" aria-label="Large" options={vendors} placeholder="Large" />
  </div>
);

export const States = () => (
  <div style={col}>
    <Combobox aria-label="Empty" options={vendors} placeholder="Choose a vendor" />
    <Combobox aria-label="Filled, clearable" options={vendors} defaultValue="shakti" clearable />
    <Combobox aria-label="Error" options={vendors} defaultValue="shakti" state="error" />
    <Combobox aria-label="Disabled" options={vendors} defaultValue="everest" disabled />
  </div>
);

export const InField = () => (
  <div style={{ ...col, gap: 16 }}>
    <Field label="Vendor" hint="Only approved vendors are listed.">
      <Combobox options={vendors} placeholder="Choose a vendor" />
    </Field>
    <Field label="Vendor" required error="Pick a vendor to continue.">
      <Combobox options={vendors} placeholder="Choose a vendor" />
    </Field>
  </div>
);
