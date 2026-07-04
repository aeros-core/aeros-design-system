import * as React from "react";
import {
  Tabs,
  TabsList,
  TabsTrigger,
  TabsContent,
  TabCount,
} from "@aeros-core/react";

const panel: React.CSSProperties = {
  fontSize: 14,
  color: "var(--aeros-fg-muted)",
  paddingTop: 12,
  margin: 0,
};

export const Underline = () => (
  <Tabs defaultValue="rfqs" variant="underline">
    <TabsList>
      <TabsTrigger value="rfqs">
        Open RFQs <TabCount>18</TabCount>
      </TabsTrigger>
      <TabsTrigger value="quotes">
        Quotes <TabCount>7</TabCount>
      </TabsTrigger>
      <TabsTrigger value="orders">Orders</TabsTrigger>
      <TabsTrigger value="buyers">Buyers</TabsTrigger>
    </TabsList>
    <TabsContent value="rfqs">
      <p style={panel}>18 requests awaiting a quote from your factory.</p>
    </TabsContent>
    <TabsContent value="quotes">
      <p style={panel}>7 quotes sent this week, 3 pending buyer response.</p>
    </TabsContent>
    <TabsContent value="orders">
      <p style={panel}>Accepted orders ready for pickup and dispatch.</p>
    </TabsContent>
    <TabsContent value="buyers">
      <p style={panel}>Buyer accounts and resale certificates on file.</p>
    </TabsContent>
  </Tabs>
);

export const Pill = () => (
  <Tabs defaultValue="week" variant="pill">
    <TabsList>
      <TabsTrigger value="day">Day</TabsTrigger>
      <TabsTrigger value="week">Week</TabsTrigger>
      <TabsTrigger value="month">Month</TabsTrigger>
      <TabsTrigger value="quarter">Quarter</TabsTrigger>
    </TabsList>
    <TabsContent value="day">
      <p style={panel}>Fulfilment throughput for the last 24 hours.</p>
    </TabsContent>
    <TabsContent value="week">
      <p style={panel}>Fulfilment throughput for the last 7 days.</p>
    </TabsContent>
    <TabsContent value="month">
      <p style={panel}>Fulfilment throughput for the last 30 days.</p>
    </TabsContent>
    <TabsContent value="quarter">
      <p style={panel}>Fulfilment throughput for the quarter to date.</p>
    </TabsContent>
  </Tabs>
);
