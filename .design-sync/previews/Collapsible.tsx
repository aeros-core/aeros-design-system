import * as React from "react";
import { Button, Collapsible, CollapsibleContent, CollapsibleTrigger } from "@aeros-core/react";
import { ChevronsUpDown } from "lucide-react";

const ShippingDetails = (props: { defaultOpen?: boolean; disabled?: boolean }) => (
  <Collapsible className="rounded-surface border border-border-default bg-bg-surface" style={{ maxWidth: 448 }} {...props}>
    <div className="flex items-center justify-between gap-3 py-2 pl-4 pr-2">
      <span className="text-body-md font-medium text-fg-primary">Shipping details</span>
      <CollapsibleTrigger asChild>
        <Button variant="ghost" size="sm" iconOnly aria-label="Toggle shipping details">
          <ChevronsUpDown />
        </Button>
      </CollapsibleTrigger>
    </div>
    <CollapsibleContent>
      <div className="border-t border-border-default px-4 py-3 text-body-md text-fg-secondary">
        Dispatched from Pune in 3 cartons. Carrier: BlueDart Surface. Expected delivery 18 Aug 2026.
      </div>
    </CollapsibleContent>
  </Collapsible>
);

export const Open = () => <ShippingDetails defaultOpen />;

export const Closed = () => <ShippingDetails />;

export const Disabled = () => (
  <div style={{ display: "grid", gap: 12 }}>
    <ShippingDetails disabled />
    <ShippingDetails disabled defaultOpen />
  </div>
);

export const PlainTextTrigger = () => (
  <Collapsible defaultOpen style={{ maxWidth: 448 }}>
    <CollapsibleTrigger className="text-body-md font-medium text-fg-primary underline underline-offset-4">
      3 line items
    </CollapsibleTrigger>
    <CollapsibleContent>
      <ul className="mt-2 grid gap-1 text-body-md text-fg-secondary">
        <li>250 ml double-wall cup × 5,000</li>
        <li>Sip lid, black × 5,000</li>
        <li>Kraft sleeve × 2,500</li>
      </ul>
    </CollapsibleContent>
  </Collapsible>
);
