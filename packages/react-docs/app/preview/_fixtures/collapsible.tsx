"use client";

import * as React from "react";
import { Button, Collapsible, CollapsibleContent, CollapsibleTrigger } from "@aeros-core/react";
import { ChevronsUpDown } from "lucide-react";
import { Group } from "./kit";

function Example({ title, ...props }: { title: string } & React.ComponentProps<typeof Collapsible>) {
  return (
    <Collapsible className="w-full max-w-md rounded-lg border border-border-default bg-bg-surface" {...props}>
      <div className="flex items-center justify-between gap-3 py-2 pl-4 pr-2">
        <span className="text-sm font-medium text-fg-primary">{title}</span>
        <CollapsibleTrigger asChild>
          <Button variant="ghost" size="sm" iconOnly aria-label={`Toggle ${title}`}>
            <ChevronsUpDown />
          </Button>
        </CollapsibleTrigger>
      </div>
      <CollapsibleContent>
        <div className="border-t border-border-default px-4 py-3 text-sm text-fg-secondary">
          Dispatched from Pune in 3 cartons. Carrier: BlueDart Surface. Expected delivery 18 Aug 2026.
        </div>
      </CollapsibleContent>
    </Collapsible>
  );
}

export default function CollapsibleFixture() {
  return (
    <>
      <Group label="Closed" className="flex-col items-start">
        <Example title="Shipping details" />
      </Group>
      <Group label="Open" className="flex-col items-start">
        <Example title="Shipping details" defaultOpen />
      </Group>
      <Group label="Disabled (closed / open)" className="flex-col items-start">
        <Example title="Shipping details" disabled />
        <Example title="Shipping details" disabled defaultOpen />
      </Group>
      <Group label="Plain text trigger" className="flex-col items-start">
        <Collapsible defaultOpen className="w-full max-w-md">
          <CollapsibleTrigger className="text-sm font-medium text-fg-primary underline underline-offset-4">
            3 line items
          </CollapsibleTrigger>
          <CollapsibleContent>
            <ul className="mt-2 grid gap-1 text-sm text-fg-secondary">
              <li>250 ml double-wall cup × 5,000</li>
              <li>Sip lid, black × 5,000</li>
              <li>Kraft sleeve × 2,500</li>
            </ul>
          </CollapsibleContent>
        </Collapsible>
      </Group>
    </>
  );
}
