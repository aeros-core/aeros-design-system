"use client";

import { Stepper } from "@aeros-core/react";
import { Group } from "./kit";

const STEPS = [
  { label: "Cart" },
  { label: "Shipping" },
  { label: "Payment" },
  { label: "Review" }
];

const DETAILED = [
  { label: "Company details", description: "Legal name and GSTIN" },
  { label: "Bank account", description: "For payouts" },
  { label: "Catalogue", description: "Add your first product" },
  { label: "Go live", description: "Publish your storefront" }
];

export default function StepperFixture() {
  return (
    <>
      <Group label="Horizontal — first / middle / last / all done" className="flex-col items-stretch gap-6">
        <Stepper steps={STEPS} current={0} aria-label="Checkout, step 1" />
        <Stepper steps={STEPS} current={2} aria-label="Checkout, step 3" />
        <Stepper steps={STEPS} current={3} aria-label="Checkout, step 4" />
        <Stepper steps={STEPS} current={4} aria-label="Checkout, complete" />
      </Group>
      <Group label="Horizontal — with descriptions" className="flex-col items-stretch">
        <Stepper steps={DETAILED} current={1} aria-label="Seller onboarding" />
      </Group>
      <Group label="Horizontal — completed steps clickable" className="flex-col items-stretch">
        <Stepper steps={DETAILED} current={2} onStepClick={() => {}} aria-label="Seller onboarding, clickable" />
      </Group>
      <Group label="Vertical" className="items-start gap-12">
        <Stepper steps={STEPS} current={1} orientation="vertical" aria-label="Checkout, vertical" />
        <Stepper steps={DETAILED} current={2} orientation="vertical" aria-label="Seller onboarding, vertical" />
        <Stepper
          steps={DETAILED}
          current={3}
          orientation="vertical"
          onStepClick={() => {}}
          aria-label="Seller onboarding, vertical clickable"
        />
      </Group>
      <Group label="Narrow (390px) — labels truncate" className="flex-col items-start">
        <div className="w-[358px] max-w-full rounded-lg border border-border-default bg-bg-surface p-4">
          <Stepper steps={DETAILED} current={1} aria-label="Seller onboarding, narrow" />
        </div>
      </Group>
    </>
  );
}
