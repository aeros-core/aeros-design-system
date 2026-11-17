"use client";

import { Alert } from "@aeros-core/react";
import { Bell } from "lucide-react";
import { Group } from "./kit";

export default function AlertFixture() {
  return (
    <>
      <Group label="Variants" className="max-w-xl flex-col items-stretch gap-2">
        <Alert variant="info" title="Heads up">A new RFQ is available for review.</Alert>
        <Alert variant="success" title="Approved">Order passed QC. Ready for dispatch.</Alert>
        <Alert variant="warning" title="Delayed">Shipment running 2 hours behind schedule.</Alert>
        <Alert variant="danger" title="Failed">Line 4 halted — check sensor 2.</Alert>
      </Group>
      <Group label="Without title / custom icon / long copy" className="max-w-xl flex-col items-stretch gap-2">
        <Alert variant="info">A new RFQ is available for review.</Alert>
        <Alert variant="warning" icon={<Bell className="h-[18px] w-[18px]" />} title="Custom icon">
          Three purchase orders are waiting on your approval.
        </Alert>
        <Alert variant="success" title="Long copy wraps">
          Order #1042 passed incoming QC at the Pune warehouse and has been released to dispatch. The
          carrier will collect it on Friday morning; tracking details follow by email.
        </Alert>
      </Group>
    </>
  );
}
