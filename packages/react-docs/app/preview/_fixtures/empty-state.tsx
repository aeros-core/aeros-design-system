"use client";

import { Button, EmptyState } from "@aeros-core/react";
import { Inbox } from "lucide-react";
import { Group } from "./kit";

export default function EmptyStateFixture() {
  return (
    <>
      <Group label="Icon + description + action" className="flex-col items-stretch">
        <EmptyState
          icon={<Inbox className="h-5 w-5" />}
          title="No RFQs yet"
          description="When buyers submit requests, they'll show up here. Invite your team to get started."
          action={<Button size="sm">Invite team</Button>}
        />
      </Group>
      <Group label="Title + description" className="flex-col items-stretch">
        <EmptyState title="No results" description="Try a different search term or clear the filters." />
      </Group>
      <Group label="Title only" className="flex-col items-stretch">
        <EmptyState title="Nothing here" />
      </Group>
    </>
  );
}
