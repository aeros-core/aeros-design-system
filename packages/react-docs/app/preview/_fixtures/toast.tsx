"use client";

import * as React from "react";
import { Toaster, toast } from "@aeros-core/react";
import { Group } from "./kit";

const noop = () => {};

// Goes through the real imperative path (`toast()` → `<Toaster />`).
// `duration: Infinity` keeps Radix from auto-dismissing, so the stack is
// identical whenever the screenshot is taken.
export default function ToastFixture() {
  const fired = React.useRef(false);
  React.useEffect(() => {
    if (fired.current) return;
    fired.current = true;
    toast({ title: "Heads up", description: "3 RFQs awaiting review.", duration: Infinity });
    toast({
      title: "Saved",
      description: "Catalog updated.",
      variant: "success",
      duration: Infinity,
      action: { label: "Undo", altText: "Undo the catalog update", onClick: noop },
    });
    toast({
      title: "Delayed",
      description: "Shipment running 2 hours behind schedule.",
      variant: "warning",
      duration: Infinity,
    });
    toast({ title: "Line 4 halted", description: "Check sensor 2.", variant: "danger", duration: Infinity });
  }, []);

  return (
    <>
      <Group label="Toast — neutral, success + action, warning, danger (open, bottom-right)">
        <p className="text-sm text-fg-secondary">Toasts render in the fixed viewport.</p>
      </Group>
      <Toaster />
    </>
  );
}
