"use client";

import { FilterChip } from "@aeros-core/react";
import { Group } from "./kit";

const noop = () => {};

export default function FilterChipFixture() {
  return (
    <>
      <Group label="Neutral — idle / active">
        <FilterChip label="Overdue" />
        <FilterChip label="Overdue" active />
      </Group>
      <Group label="With value">
        <FilterChip label="Status" value="Open" />
        <FilterChip label="Status" value="Open" active />
        <FilterChip label="Status" value="Open" active onClear={noop} />
      </Group>
      <Group label="Dropdown">
        <FilterChip label="Vendor" dropdown />
        <FilterChip label="Vendor" value="Acme Paper" dropdown active />
        <FilterChip label="Vendor" value="Acme Paper" dropdown active onClear={noop} />
      </Group>
      <Group label="With count">
        <FilterChip label="Category" count={3} dropdown />
        <FilterChip label="Category" count={3} dropdown active />
        <FilterChip label="Category" count={128} dropdown active onClear={noop} />
      </Group>
      <Group label="Warning tone — idle / active / clearable">
        <FilterChip label="Late" tone="warning" />
        <FilterChip label="Late" tone="warning" active />
        <FilterChip label="Late" tone="warning" value="12 orders" active onClear={noop} />
      </Group>
      <Group label="Disabled">
        <FilterChip label="Status" disabled />
        <FilterChip label="Status" value="Open" active disabled onClear={noop} />
        <FilterChip label="Late" tone="warning" active disabled />
      </Group>
      <Group label="asChild — a link as the chip">
        <FilterChip asChild label="Region" value="West" active>
          <a href="#region">Region</a>
        </FilterChip>
      </Group>
      <Group label="A filter bar (wraps)" className="max-w-sm">
        <FilterChip label="Status" value="Open" active onClear={noop} />
        <FilterChip label="Vendor" dropdown />
        <FilterChip label="Category" count={3} dropdown active onClear={noop} />
        <FilterChip label="Late" tone="warning" active />
        <FilterChip label="Created" value="Last 30 days" dropdown active onClear={noop} />
      </Group>
    </>
  );
}
