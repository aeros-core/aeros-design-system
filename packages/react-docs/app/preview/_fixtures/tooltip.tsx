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
              <Info />
              Hover me
            </Button>
          </TooltipTrigger>
          <TooltipContent arrow>This is a tooltip.</TooltipContent>
        </Tooltip>
      </TooltipProvider>
    </Group>
  );
}
