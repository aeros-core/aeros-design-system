"use client";

import { Breadcrumb } from "@aeros-core/react";
import { Group } from "./kit";

export default function BreadcrumbFixture() {
  return (
    <>
      <Group label="Default separator">
        <Breadcrumb
          items={[
            { label: "Operations", href: "#" },
            { label: "RFQs", href: "#" },
            { label: "RFQ-0042" },
          ]}
        />
      </Group>
      <Group label="Custom separator">
        <Breadcrumb
          separator="/"
          items={[
            { label: "Operations", href: "#" },
            { label: "RFQs", href: "#" },
            { label: "RFQ-0042" },
          ]}
        />
      </Group>
      <Group label="Non-link ancestor / single item">
        <Breadcrumb items={[{ label: "Settings" }, { label: "Team" }]} />
        <Breadcrumb items={[{ label: "Dashboard" }]} />
      </Group>
    </>
  );
}
