import * as React from "react";
import { Stepper } from "@aeros-core/react";

const STEPS = [{ label: "Cart" }, { label: "Shipping" }, { label: "Payment" }, { label: "Review" }];

const DETAILED = [
  { label: "Company details", description: "Legal name and GSTIN" },
  { label: "Bank account", description: "For payouts" },
  { label: "Catalogue", description: "Add your first product" },
  { label: "Go live", description: "Publish your storefront" },
];

// `current` is the zero-based active step; current === steps.length means all done.
export const Progress = () => (
  <div style={{ display: "grid", gap: 24 }}>
    <Stepper steps={STEPS} current={0} aria-label="Checkout, step 1" />
    <Stepper steps={STEPS} current={2} aria-label="Checkout, step 3" />
    <Stepper steps={STEPS} current={4} aria-label="Checkout, complete" />
  </div>
);

export const WithDescriptions = () => (
  <Stepper steps={DETAILED} current={1} aria-label="Seller onboarding" />
);

// onStepClick makes the completed steps clickable.
export const ClickableCompleted = () => {
  const [current, setCurrent] = React.useState(2);
  return <Stepper steps={DETAILED} current={current} onStepClick={setCurrent} aria-label="Seller onboarding, clickable" />;
};

export const Vertical = () => (
  <div style={{ display: "flex", flexWrap: "wrap", gap: 48, alignItems: "flex-start" }}>
    <Stepper steps={STEPS} current={1} orientation="vertical" aria-label="Checkout, vertical" />
    <Stepper steps={DETAILED} current={2} orientation="vertical" aria-label="Seller onboarding, vertical" />
  </div>
);
