import * as React from "react";
import {
  Button,
  Drawer,
  DrawerBody,
  DrawerClose,
  DrawerContent,
  DrawerDescription,
  DrawerFooter,
  DrawerHeader,
  DrawerTitle,
  DrawerTrigger,
} from "@aeros-core/react";

// defaultOpen renders the panel in its open state for a static card.
const OrderDrawer = ({ side }: { side: "right" | "left" | "bottom" }) => (
  <Drawer defaultOpen>
    <DrawerTrigger asChild>
      <Button variant="secondary">Order details</Button>
    </DrawerTrigger>
    <DrawerContent side={side}>
      <DrawerHeader>
        <DrawerTitle>Order #1042</DrawerTitle>
        <DrawerDescription>Trimurti Packaging · dispatch Friday</DrawerDescription>
      </DrawerHeader>
      <DrawerBody>
        <p className="text-body-sm text-fg-secondary">
          12,000 double-wall cups · ₹1,24,000 · dispatch Friday from Pune.
        </p>
      </DrawerBody>
      <DrawerFooter>
        <DrawerClose asChild>
          <Button variant="secondary">Close</Button>
        </DrawerClose>
        <Button>Accept order</Button>
      </DrawerFooter>
    </DrawerContent>
  </Drawer>
);

export const RightDrawer = () => <OrderDrawer side="right" />;

export const LeftDrawer = () => <OrderDrawer side="left" />;

export const BottomDrawer = () => <OrderDrawer side="bottom" />;
