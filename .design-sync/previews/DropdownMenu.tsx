import * as React from "react";
import {
  DropdownMenu,
  DropdownMenuTrigger,
  DropdownMenuContent,
  DropdownMenuLabel,
  DropdownMenuItem,
  DropdownMenuSeparator,
  Button,
} from "@aeros-core/react";
import { Settings, Plus, LogOut, ChevronDown } from "lucide-react";

// defaultOpen renders the menu expanded for a static card.
export const ActionsMenu = () => (
  <DropdownMenu defaultOpen>
    <DropdownMenuTrigger asChild>
      <Button variant="secondary" trailingIcon={<ChevronDown size={16} />}>
        Actions
      </Button>
    </DropdownMenuTrigger>
    <DropdownMenuContent>
      <DropdownMenuLabel>Workspace</DropdownMenuLabel>
      <DropdownMenuItem>
        <Settings size={16} /> Settings
      </DropdownMenuItem>
      <DropdownMenuItem>
        <Plus size={16} /> New RFQ
      </DropdownMenuItem>
      <DropdownMenuSeparator />
      <DropdownMenuItem destructive>
        <LogOut size={16} /> Sign out
      </DropdownMenuItem>
    </DropdownMenuContent>
  </DropdownMenu>
);
