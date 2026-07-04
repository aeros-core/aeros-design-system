import * as React from "react";
import { EmptyState, Button } from "@aeros-core/react";
import { Inbox, PackageSearch } from "lucide-react";

export const NoRFQs = () => (
  <div style={{ maxWidth: 460 }}>
    <EmptyState
      icon={<Inbox size={20} />}
      title="No RFQs yet"
      description="When buyers submit requests for quote, they'll show up here. Invite your team to start receiving orders."
      action={<Button size="sm">Invite team</Button>}
    />
  </div>
);

export const NoResults = () => (
  <div style={{ maxWidth: 460 }}>
    <EmptyState
      icon={<PackageSearch size={20} />}
      title="No catalog items match"
      description="Try a different SKU, category, or clear your filters to see all listings."
      action={
        <Button variant="secondary" size="sm">
          Clear filters
        </Button>
      }
    />
  </div>
);
