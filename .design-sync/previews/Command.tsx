import * as React from "react";
import {
  Command,
  CommandEmpty,
  CommandGroup,
  CommandInput,
  CommandItem,
  CommandList,
  CommandSeparator,
} from "@aeros-core/react";
import { Box, Settings, Truck } from "lucide-react";

// Rendered inline (not inside a Popover) so the list is always visible.
const shell = "overflow-hidden rounded-surface border border-border-default shadow-overlay";
const frame: React.CSSProperties = { maxWidth: 320 };

export const GroupedMenu = () => (
  <div className={shell} style={frame}>
    <Command label="Command menu">
      <CommandInput placeholder="Search vendors…" />
      <CommandList>
        <CommandEmpty>No vendor found.</CommandEmpty>
        <CommandGroup heading="Vendors">
          <CommandItem>Trimurti Packaging</CommandItem>
          <CommandItem>Shakti Bearings</CommandItem>
          <CommandItem disabled>Everest Polymers (disabled)</CommandItem>
        </CommandGroup>
        <CommandSeparator />
        <CommandGroup heading="Go to">
          <CommandItem><Box className="h-4 w-4" /> Orders</CommandItem>
          <CommandItem><Truck className="h-4 w-4" /> Shipments</CommandItem>
          <CommandItem><Settings className="h-4 w-4" /> Settings</CommandItem>
        </CommandGroup>
      </CommandList>
    </Command>
  </div>
);

export const Filtered = () => (
  <div className={shell} style={frame}>
    <Command label="Filtered command menu">
      <CommandInput value="shak" readOnly placeholder="Search vendors…" />
      <CommandList>
        <CommandEmpty>No vendor found.</CommandEmpty>
        <CommandGroup heading="Vendors">
          <CommandItem>Trimurti Packaging</CommandItem>
          <CommandItem>Shakti Bearings</CommandItem>
          <CommandItem>Everest Polymers</CommandItem>
        </CommandGroup>
      </CommandList>
    </Command>
  </div>
);

export const EmptyResult = () => (
  <div className={shell} style={frame}>
    <Command label="Empty command menu">
      <CommandInput value="zzz" readOnly placeholder="Search vendors…" />
      <CommandList>
        <CommandEmpty>No vendor found.</CommandEmpty>
        <CommandGroup heading="Vendors">
          <CommandItem>Trimurti Packaging</CommandItem>
          <CommandItem>Shakti Bearings</CommandItem>
        </CommandGroup>
      </CommandList>
    </Command>
  </div>
);
