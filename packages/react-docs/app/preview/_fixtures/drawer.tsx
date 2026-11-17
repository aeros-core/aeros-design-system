"use client";

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
import { Group } from "./kit";

function DrawerFixture({ side }: { side: "right" | "left" | "bottom" }) {
  return (
    <Group label={`Drawer — open, side="${side}"`}>
      <Drawer open>
        <DrawerTrigger asChild>
          <Button variant="secondary">Order details</Button>
        </DrawerTrigger>
        <DrawerContent side={side}>
          <DrawerHeader>
            {/* DrawerTitle / DrawerDescription are bare Radix primitives (no DS
                styling, unlike DialogTitle) — rendered as-is to baseline that. */}
            <DrawerTitle>Order #1042</DrawerTitle>
            <DrawerDescription>Trimurti Packaging · dispatch Friday</DrawerDescription>
          </DrawerHeader>
          <DrawerBody>
            <p className="text-[13px] leading-relaxed text-fg-secondary">
              12,000 double-wall cups · dispatch Friday · Trimurti Packaging.
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
    </Group>
  );
}

export function DrawerRightFixture() {
  return <DrawerFixture side="right" />;
}
export function DrawerLeftFixture() {
  return <DrawerFixture side="left" />;
}
export function DrawerBottomFixture() {
  return <DrawerFixture side="bottom" />;
}
