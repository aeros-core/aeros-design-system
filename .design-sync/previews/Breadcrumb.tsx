import * as React from "react";
import { Breadcrumb } from "@aeros-core/react";

export const RfqTrail = () => (
  <Breadcrumb
    items={[
      { label: "Operations", href: "#" },
      { label: "RFQs", href: "#" },
      { label: "RFQ-0042" },
    ]}
  />
);

export const CatalogTrail = () => (
  <Breadcrumb
    items={[
      { label: "Catalog", href: "#" },
      { label: "Cold-Rolled Steel", href: "#" },
      { label: "CR Coil 1.2mm", href: "#" },
      { label: "Edit listing" },
    ]}
  />
);
