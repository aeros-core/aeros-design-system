"use client";

import { Button, Tooltip, TooltipContent, TooltipProvider, TooltipTrigger } from "@aeros-core/react";
import { Info } from "lucide-react";
import { Group } from "./kit";

export default function TooltipFixture() {
  return (
    <Group label="Tooltip — open" className="pt-10">
      <TooltipProvider>
        <Tooltip open>
          <TooltipTrigger asChild>
            <Button variant="secondary">
              <Info className="h-4 w-4" />
              Hover me
            </Button>
          </TooltipTrigger>
          <TooltipContent>This is a tooltip.</TooltipContent>
        </Tooltip>
      </TooltipProvider>
    </Group>
  );
}
