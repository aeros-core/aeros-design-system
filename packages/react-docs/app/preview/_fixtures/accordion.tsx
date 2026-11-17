"use client";

import { Accordion, AccordionContent, AccordionItem, AccordionTrigger } from "@aeros-core/react";
import { Group } from "./kit";

export default function AccordionFixture() {
  return (
    <>
      <Group label="Single — first item open" className="max-w-md flex-col items-stretch">
        <Accordion type="single" collapsible value="ship">
          <AccordionItem value="ship">
            <AccordionTrigger>Shipping policy</AccordionTrigger>
            <AccordionContent>Orders dispatch within 48 hours of QC clearance.</AccordionContent>
          </AccordionItem>
          <AccordionItem value="returns">
            <AccordionTrigger>Returns</AccordionTrigger>
            <AccordionContent>Manufacturing defects are replaced free within 30 days.</AccordionContent>
          </AccordionItem>
          <AccordionItem value="warranty" disabled>
            <AccordionTrigger>Warranty (disabled)</AccordionTrigger>
            <AccordionContent>Twelve months from dispatch.</AccordionContent>
          </AccordionItem>
        </Accordion>
      </Group>
      <Group label="Multiple — two open" className="max-w-md flex-col items-stretch">
        <Accordion type="multiple" value={["a", "c"]}>
          <AccordionItem value="a">
            <AccordionTrigger>Payment terms</AccordionTrigger>
            <AccordionContent>Net 30 from invoice date for approved buyers.</AccordionContent>
          </AccordionItem>
          <AccordionItem value="b">
            <AccordionTrigger>Minimum order</AccordionTrigger>
            <AccordionContent>One carton per SKU.</AccordionContent>
          </AccordionItem>
          <AccordionItem value="c">
            <AccordionTrigger>Samples</AccordionTrigger>
            <AccordionContent>Free samples ship with the first quotation.</AccordionContent>
          </AccordionItem>
        </Accordion>
      </Group>
      <Group label="All collapsed" className="max-w-md flex-col items-stretch">
        <Accordion type="single" collapsible>
          <AccordionItem value="x">
            <AccordionTrigger>Collapsed item</AccordionTrigger>
            <AccordionContent>Hidden content.</AccordionContent>
          </AccordionItem>
          <AccordionItem value="y">
            <AccordionTrigger>Another collapsed item</AccordionTrigger>
            <AccordionContent>Hidden content.</AccordionContent>
          </AccordionItem>
        </Accordion>
      </Group>
    </>
  );
}
