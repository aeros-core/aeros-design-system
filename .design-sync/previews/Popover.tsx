import * as React from "react";
import { Button, Popover, PopoverClose, PopoverContent, PopoverTrigger } from "@aeros-core/react";
import { ChevronDown } from "lucide-react";

// defaultOpen renders the popover in its open state for a static card.
export const OpenPopover = () => (
  <div style={{ minHeight: 200 }}>
    <Popover defaultOpen>
      <PopoverTrigger asChild>
        <Button variant="secondary" trailingIcon={<ChevronDown size={16} />}>
          Dispatch window
        </Button>
      </PopoverTrigger>
      <PopoverContent align="start">
        <div className="text-body-md font-semibold text-fg-primary">Dispatch window</div>
        <p className="mt-1 text-body-sm text-fg-secondary">
          Orders cleared by QC before 2 pm ship the same day.
        </p>
        <div className="mt-3 flex justify-end gap-2">
          <PopoverClose asChild>
            <Button size="sm" variant="secondary">Dismiss</Button>
          </PopoverClose>
          <Button size="sm">Got it</Button>
        </div>
      </PopoverContent>
    </Popover>
  </div>
);
