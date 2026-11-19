import * as React from "react";
import { FilterChip } from "@aeros-core/react";

const noop = () => {};
const row: React.CSSProperties = { display: "flex", flexWrap: "wrap", gap: 12, alignItems: "center" };
const stack: React.CSSProperties = { display: "grid", gap: 12 };

export const FilterBar = () => (
  <div style={{ ...row, maxWidth: 420 }}>
    <FilterChip label="Status" value="Open" active onClear={noop} />
    <FilterChip label="Vendor" dropdown />
    <FilterChip label="Category" count={3} dropdown active onClear={noop} />
    <FilterChip label="Late" tone="warning" active />
    <FilterChip label="Created" value="Last 30 days" dropdown active onClear={noop} />
  </div>
);

export const IdleAndActive = () => (
  <div style={stack}>
    <div style={row}>
      <FilterChip label="Overdue" />
      <FilterChip label="Overdue" active />
    </div>
    <div style={row}>
      <FilterChip label="Status" value="Open" />
      <FilterChip label="Status" value="Open" active />
      <FilterChip label="Status" value="Open" active onClear={noop} />
    </div>
  </div>
);

export const DropdownAndCount = () => (
  <div style={stack}>
    <div style={row}>
      <FilterChip label="Vendor" dropdown />
      <FilterChip label="Vendor" value="Acme Paper" dropdown active />
      <FilterChip label="Vendor" value="Acme Paper" dropdown active onClear={noop} />
    </div>
    <div style={row}>
      <FilterChip label="Category" count={3} dropdown />
      <FilterChip label="Category" count={3} dropdown active />
      <FilterChip label="Category" count={128} dropdown active onClear={noop} />
    </div>
  </div>
);

export const WarningAndDisabled = () => (
  <div style={stack}>
    <div style={row}>
      <FilterChip label="Late" tone="warning" />
      <FilterChip label="Late" tone="warning" active />
      <FilterChip label="Late" tone="warning" value="12 orders" active onClear={noop} />
    </div>
    <div style={row}>
      <FilterChip label="Status" disabled />
      <FilterChip label="Status" value="Open" active disabled onClear={noop} />
      <FilterChip label="Late" tone="warning" active disabled />
    </div>
  </div>
);
