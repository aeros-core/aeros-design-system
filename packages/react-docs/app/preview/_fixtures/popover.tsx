"use client";

import { Button, Popover, PopoverClose, PopoverContent, PopoverTrigger } from "@aeros-core/react";
import { ChevronDown } from "lucide-react";
import { Group } from "./kit";

export default function PopoverFixture() {
  return (
    <Group label="Popover — open">
      <Popover open>
        <PopoverTrigger asChild>
          <Button variant="secondary" trailingIcon={<ChevronDown className="h-4 w-4" />}>
            Dispatch window
          </Button>
        </PopoverTrigger>
        <PopoverContent align="start">
          <div className="text-sm font-semibold text-fg-primary">Dispatch window</div>
          <p className="mt-1 text-[13px] leading-relaxed text-fg-secondary">
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
    </Group>
  );
}
