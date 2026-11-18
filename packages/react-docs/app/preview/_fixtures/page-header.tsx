"use client";

import { Breadcrumb, Button, PageHeader, Tabs, TabsContent,
  TabsList, TabsTrigger } from "@aeros-core/react";
import { Download, Plus } from "lucide-react";
import { Group } from "./kit";

const CRUMBS = [{ label: "Home", href: "#home" }, { label: "Orders", href: "#orders" }, { label: "PO-1042" }];

const actions = (
  <>
    <Button variant="secondary" leadingIcon={<Download />}>Export</Button>
    <Button leadingIcon={<Plus />}>New order</Button>
  </>
);

export default function PageHeaderFixture() {
  return (
    <>
      <Group label="Title only" className="flex-col items-stretch">
        <PageHeader title="Orders" />
      </Group>
      <Group label="Title + description + actions" className="flex-col items-stretch">
        <PageHeader title="Orders" description="Purchase orders raised by your buyers." actions={actions} />
      </Group>
      <Group label="Breadcrumb + back link + actions" className="flex-col items-stretch">
        <PageHeader
          as="h2"
          title="PO-1042"
          description="Raised 14 Aug 2026 by Priya Sharma."
          breadcrumb={<Breadcrumb items={CRUMBS} />}
          back={{ href: "#orders", label: "Back to orders" }}
          actions={actions}
        />
      </Group>
      <Group label="Back button + tabs" className="flex-col items-stretch">
        <PageHeader
          as="h2"
          title="Acme Paper Products"
          description="Vendor since 2021 · Pune"
          back={{ onClick: () => {} }}
          actions={<Button variant="secondary">Edit vendor</Button>}
          tabs={
            <Tabs value="overview">
              <TabsList>
                <TabsTrigger value="overview">Overview</TabsTrigger>
                <TabsTrigger value="orders">Orders</TabsTrigger>
                <TabsTrigger value="documents">Documents</TabsTrigger>
              </TabsList>
              {/* Each tab needs its panel, or aria-controls points at nothing. */}
              <TabsContent value="overview" className="pt-3 text-body-sm text-fg-secondary">Overview panel.</TabsContent>
              <TabsContent value="orders" />
              <TabsContent value="documents" />
            </Tabs>
          }
        />
      </Group>
      <Group label="Narrow (390px) — actions wrap under the title" className="flex-col items-start">
        <div className="w-[358px] max-w-full rounded-surface border border-border-default bg-bg-surface p-4">
          <PageHeader
            as="h2"
            title="Quarterly packaging procurement review"
            description="A long title wraps; the actions drop to their own row."
            back={{ href: "#back" }}
            actions={actions}
          />
        </div>
      </Group>
    </>
  );
}
