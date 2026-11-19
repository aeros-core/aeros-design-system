import * as React from "react";
import { Accordion, AccordionContent, AccordionItem, AccordionTrigger } from "@aeros-core/react";

const frame: React.CSSProperties = { maxWidth: 448 };

export const SingleOpen = () => (
  <div style={frame}>
    <Accordion type="single" collapsible defaultValue="ship">
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
  </div>
);

export const MultipleOpen = () => (
  <div style={frame}>
    <Accordion type="multiple" defaultValue={["terms", "samples"]}>
      <AccordionItem value="terms">
        <AccordionTrigger>Payment terms</AccordionTrigger>
        <AccordionContent>Net 30 from invoice date for approved buyers.</AccordionContent>
      </AccordionItem>
      <AccordionItem value="moq">
        <AccordionTrigger>Minimum order</AccordionTrigger>
        <AccordionContent>One carton per SKU.</AccordionContent>
      </AccordionItem>
      <AccordionItem value="samples">
        <AccordionTrigger>Samples</AccordionTrigger>
        <AccordionContent>Free samples ship with the first quotation.</AccordionContent>
      </AccordionItem>
    </Accordion>
  </div>
);

export const AllCollapsed = () => (
  <div style={frame}>
    <Accordion type="single" collapsible>
      <AccordionItem value="terms">
        <AccordionTrigger>Payment terms</AccordionTrigger>
        <AccordionContent>Net 30 from invoice date for approved buyers.</AccordionContent>
      </AccordionItem>
      <AccordionItem value="moq">
        <AccordionTrigger>Minimum order</AccordionTrigger>
        <AccordionContent>One carton per SKU.</AccordionContent>
      </AccordionItem>
    </Accordion>
  </div>
);
