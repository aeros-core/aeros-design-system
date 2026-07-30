import * as React from "react";
import { TooltipProvider, Tooltip, TooltipTrigger, TooltipContent, Button } from "@aeros-core/react";
import { Info } from "lucide-react";

// `open` forces the tooltip visible for a static card.
export const WithTooltip = () => (
  <TooltipProvider>
    <Tooltip open>
      <TooltipTrigger asChild>
        <Button variant="secondary">
          <Info size={16} /> Hover me
        </Button>
      </TooltipTrigger>
      <TooltipContent>Shows extra context on hover.</TooltipContent>
    </Tooltip>
  </TooltipProvider>
);
