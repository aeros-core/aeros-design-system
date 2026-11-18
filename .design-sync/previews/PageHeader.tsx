import * as React from "react";
import { Breadcrumb, Button, PageHeader, Tabs, TabsContent, TabsList, TabsTrigger } from "@aeros-core/react";
import { Download, Plus } from "lucide-react";

const CRUMBS = [{ label: "Home", href: "#home" }, { label: "Orders", href: "#orders" }, { label: "PO-1042" }];

const actions = (
  <>
    <Button variant="secondary" leadingIcon={<Download />}>Export</Button>
    <Button leadingIcon={<Plus />}>New order</Button>
  </>
);

export const TitleAndActions = () => (
  <PageHeader title="Orders" description="Purchase orders raised by your buyers." actions={actions} />
);

export const BreadcrumbAndBack = () => (
  <PageHeader
    as="h2"
    title="PO-1042"
    description="Raised 14 Aug 2026 by Priya Sharma."
    breadcrumb={<Breadcrumb items={CRUMBS} />}
    back={{ href: "#orders", label: "Back to orders" }}
    actions={actions}
  />
);

export const WithTabs = () => (
  <PageHeader
    as="h2"
    title="Acme Paper Products"
    description="Vendor since 2021 · Pune"
    back={{ onClick: () => {} }}
    actions={<Button variant="secondary">Edit vendor</Button>}
    tabs={
      <Tabs defaultValue="overview">
        <TabsList>
          <TabsTrigger value="overview">Overview</TabsTrigger>
          <TabsTrigger value="orders">Orders</TabsTrigger>
          <TabsTrigger value="documents">Documents</TabsTrigger>
        </TabsList>
        <TabsContent value="overview" className="pt-3 text-body-sm text-fg-secondary">Overview panel.</TabsContent>
        <TabsContent value="orders" />
        <TabsContent value="documents" />
      </Tabs>
    }
  />
);

// At phone width a long title wraps and the actions drop to their own row.
export const Narrow = () => (
  <div className="rounded-surface border border-border-default bg-bg-surface p-4" style={{ width: 358, maxWidth: "100%" }}>
    <PageHeader
      as="h2"
      title="Quarterly packaging procurement review"
      description="A long title wraps; the actions drop to their own row."
      back={{ href: "#back" }}
      actions={actions}
    />
  </div>
);
