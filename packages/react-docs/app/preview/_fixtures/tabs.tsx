"use client";

import { TabCount, Tabs, TabsContent, TabsList, TabsTrigger } from "@aeros-core/react";
import { Group } from "./kit";

export default function TabsFixture() {
  return (
    <>
      <Group label="Underline" className="flex-col items-stretch">
        <Tabs value="overview" variant="underline">
          <TabsList>
            <TabsTrigger value="overview">
              Overview <TabCount>12</TabCount>
            </TabsTrigger>
            <TabsTrigger value="orders">
              Orders <TabCount>4</TabCount>
            </TabsTrigger>
            <TabsTrigger value="team">Team</TabsTrigger>
            <TabsTrigger value="archived" disabled>Archived</TabsTrigger>
          </TabsList>
          <TabsContent value="overview" className="pt-3">
            <p className="text-sm text-fg-secondary">Overview panel.</p>
          </TabsContent>
          <TabsContent value="orders" className="pt-3">
            <p className="text-sm text-fg-secondary">Orders panel.</p>
          </TabsContent>
          <TabsContent value="team" className="pt-3">
            <p className="text-sm text-fg-secondary">Team panel.</p>
          </TabsContent>
          <TabsContent value="archived" className="pt-3">
            <p className="text-sm text-fg-secondary">Archived panel.</p>
          </TabsContent>
        </Tabs>
      </Group>
      <Group label="Pill" className="flex-col items-start">
        <Tabs value="week" variant="pill">
          <TabsList>
            <TabsTrigger value="day">Day</TabsTrigger>
            <TabsTrigger value="week">
              Week <TabCount>7</TabCount>
            </TabsTrigger>
            <TabsTrigger value="month">Month</TabsTrigger>
            <TabsTrigger value="year" disabled>Year</TabsTrigger>
          </TabsList>
          <TabsContent value="day" className="pt-3">
            <p className="text-sm text-fg-secondary">Day range selected.</p>
          </TabsContent>
          <TabsContent value="week" className="pt-3">
            <p className="text-sm text-fg-secondary">Week range selected.</p>
          </TabsContent>
          <TabsContent value="month" className="pt-3">
            <p className="text-sm text-fg-secondary">Month range selected.</p>
          </TabsContent>
          <TabsContent value="year" className="pt-3">
            <p className="text-sm text-fg-secondary">Year range selected.</p>
          </TabsContent>
        </Tabs>
      </Group>
      <Group label="TabCount standalone (active override)">
        <span className="text-sm text-fg-secondary">
          Inactive <TabCount active={false}>3</TabCount>
        </span>
        <span className="text-sm text-fg-secondary">
          Active <TabCount active>3</TabCount>
        </span>
      </Group>
    </>
  );
}
