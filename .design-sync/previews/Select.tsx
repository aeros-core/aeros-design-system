import * as React from "react";
import { Select, SelectTrigger, SelectValue, SelectContent, SelectItem } from "@aeros-core/react";

// defaultOpen + defaultValue renders the open listbox with the current selection.
export const BuyerSelect = () => (
  <div style={{ width: 260 }}>
    <Select defaultValue="pacific" defaultOpen>
      <SelectTrigger>
        <SelectValue />
      </SelectTrigger>
      <SelectContent>
        <SelectItem value="pacific">Pacific Pack Co.</SelectItem>
        <SelectItem value="coastal">Coastal Foods</SelectItem>
        <SelectItem value="meridian">Meridian Logistics</SelectItem>
      </SelectContent>
    </Select>
  </div>
);
