import * as React from "react";
import { SegmentedControl, SegmentedControlItem } from "@aeros-core/react";
import { LayoutGrid, List, Rows3 } from "lucide-react";

const row: React.CSSProperties = { display: "flex", flexWrap: "wrap", gap: 16, alignItems: "center" };

export const Sizes = () => (
  <div style={row}>
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
  </div>
);

export const WithIcons = () => (
  <div style={row}>
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
  </div>
);

export const FullWidth = () => (
  <div style={{ maxWidth: 480 }}>
    <SegmentedControl fullWidth defaultValue="buyer" aria-label="Account type">
      <SegmentedControlItem value="buyer">Buyer</SegmentedControlItem>
      <SegmentedControlItem value="seller">Seller</SegmentedControlItem>
      <SegmentedControlItem value="both">Both</SegmentedControlItem>
    </SegmentedControl>
  </div>
);

export const Disabled = () => (
  <div style={row}>
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
  </div>
);
