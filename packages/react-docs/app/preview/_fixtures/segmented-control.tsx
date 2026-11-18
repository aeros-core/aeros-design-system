"use client";

import { SegmentedControl, SegmentedControlItem } from "@aeros-core/react";
import { LayoutGrid, List, Rows3 } from "lucide-react";
import { Group } from "./kit";

export default function SegmentedControlFixture() {
  return (
    <>
      <Group label="Sizes — md / sm">
        <SegmentedControl defaultValue="week" aria-label="Range (md)">
          <SegmentedControlItem value="day">Day</SegmentedControlItem>
          <SegmentedControlItem value="week">Week</SegmentedControlItem>
          <SegmentedControlItem value="month">Month</SegmentedControlItem>
        </SegmentedControl>
        <SegmentedControl size="sm" defaultValue="week" aria-label="Range (sm)">
          <SegmentedControlItem value="day">Day</SegmentedControlItem>
          <SegmentedControlItem value="week">Week</SegmentedControlItem>
          <SegmentedControlItem value="month">Month</SegmentedControlItem>
        </SegmentedControl>
      </Group>
      <Group label="With icons">
        <SegmentedControl defaultValue="list" aria-label="View">
          <SegmentedControlItem value="list" icon={<List />}>List</SegmentedControlItem>
          <SegmentedControlItem value="grid" icon={<LayoutGrid />}>Grid</SegmentedControlItem>
          <SegmentedControlItem value="rows" icon={<Rows3 />}>Rows</SegmentedControlItem>
        </SegmentedControl>
        <SegmentedControl size="sm" defaultValue="grid" aria-label="View (icons only)">
          <SegmentedControlItem value="list" icon={<List />} aria-label="List" />
          <SegmentedControlItem value="grid" icon={<LayoutGrid />} aria-label="Grid" />
          <SegmentedControlItem value="rows" icon={<Rows3 />} aria-label="Rows" />
        </SegmentedControl>
      </Group>
      <Group label="Full width" className="max-w-xl flex-col items-stretch">
        <SegmentedControl fullWidth defaultValue="buyer" aria-label="Account type">
          <SegmentedControlItem value="buyer">Buyer</SegmentedControlItem>
          <SegmentedControlItem value="seller">Seller</SegmentedControlItem>
          <SegmentedControlItem value="both">Both</SegmentedControlItem>
        </SegmentedControl>
      </Group>
      <Group label="One disabled segment / whole control disabled">
        <SegmentedControl defaultValue="day" aria-label="Range, year unavailable">
          <SegmentedControlItem value="day">Day</SegmentedControlItem>
          <SegmentedControlItem value="week">Week</SegmentedControlItem>
          <SegmentedControlItem value="year" disabled>Year</SegmentedControlItem>
        </SegmentedControl>
        <SegmentedControl disabled defaultValue="week" aria-label="Range, disabled">
          <SegmentedControlItem value="day">Day</SegmentedControlItem>
          <SegmentedControlItem value="week">Week</SegmentedControlItem>
          <SegmentedControlItem value="month">Month</SegmentedControlItem>
        </SegmentedControl>
      </Group>
      <Group label="On bg-surface">
        <div className="rounded-surface border border-border-default bg-bg-surface p-4">
          <SegmentedControl defaultValue="open" aria-label="Order status">
            <SegmentedControlItem value="open">Open</SegmentedControlItem>
            <SegmentedControlItem value="shipped">Shipped</SegmentedControlItem>
            <SegmentedControlItem value="closed">Closed</SegmentedControlItem>
          </SegmentedControl>
        </div>
      </Group>
    </>
  );
}
