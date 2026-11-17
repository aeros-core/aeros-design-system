"use client";

import {
  Select,
  SelectContent,
  SelectGroup,
  SelectItem,
  SelectLabel,
  SelectSeparator,
  SelectTrigger,
  SelectValue,
} from "@aeros-core/react";
import { Group } from "./kit";

export default function SelectOpenFixture() {
  return (
    <Group label="Select — open (checked item, disabled item, groups)" className="max-w-xs flex-col items-stretch">
      <Select open defaultValue="shakti">
        <SelectTrigger aria-label="Vendor">
          <SelectValue placeholder="Choose a vendor" />
        </SelectTrigger>
        <SelectContent>
          <SelectGroup>
            <SelectLabel>Packaging</SelectLabel>
            <SelectItem value="trimurti">Trimurti Packaging</SelectItem>
            <SelectItem value="everest">Everest Polymers</SelectItem>
          </SelectGroup>
          <SelectSeparator />
          <SelectGroup>
            <SelectLabel>Engineering</SelectLabel>
            <SelectItem value="shakti">Shakti Bearings</SelectItem>
            <SelectItem value="meridian" disabled>Meridian Logistics</SelectItem>
          </SelectGroup>
        </SelectContent>
      </Select>
    </Group>
  );
}
