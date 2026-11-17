"use client";

import {
  Button,
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuGroup,
  DropdownMenuItem,
  DropdownMenuLabel,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from "@aeros-core/react";
import { ChevronDown, Copy, LogOut, Plus, Settings } from "lucide-react";
import { Group } from "./kit";

export default function DropdownMenuFixture() {
  return (
    <Group label="Dropdown menu — open (label, items, disabled, destructive)">
      <DropdownMenu open>
        <DropdownMenuTrigger asChild>
          <Button variant="secondary" trailingIcon={<ChevronDown className="h-4 w-4" />}>
            Actions
          </Button>
        </DropdownMenuTrigger>
        <DropdownMenuContent align="start">
          <DropdownMenuLabel>Workspace</DropdownMenuLabel>
          <DropdownMenuGroup>
            <DropdownMenuItem>
              <Settings className="h-4 w-4" /> Settings
            </DropdownMenuItem>
            <DropdownMenuItem>
              <Plus className="h-4 w-4" /> New RFQ
            </DropdownMenuItem>
            <DropdownMenuItem disabled>
              <Copy className="h-4 w-4" /> Duplicate (disabled)
            </DropdownMenuItem>
          </DropdownMenuGroup>
          <DropdownMenuSeparator />
          <DropdownMenuItem destructive>
            <LogOut className="h-4 w-4" /> Sign out
          </DropdownMenuItem>
        </DropdownMenuContent>
      </DropdownMenu>
    </Group>
  );
}
