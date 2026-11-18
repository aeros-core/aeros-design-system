import * as React from "react";
import {
  Toast,
  ToastAction,
  ToastClose,
  ToastDescription,
  ToastProvider,
  ToastTitle,
  ToastViewport,
} from "@aeros-core/react";

// Static composition of what <Toaster /> renders for each queued toast():
// `open` + `duration={Infinity}` keeps every surface on screen. The viewport
// is fixed to the bottom-right of the frame.
const Body = ({ title, description }: { title: string; description: string }) => (
  <div style={{ flex: 1, minWidth: 0 }}>
    <ToastTitle>{title}</ToastTitle>
    <ToastDescription>{description}</ToastDescription>
  </div>
);

export const ToastStack = () => (
  <div style={{ minHeight: 420 }}>
    <ToastProvider duration={Infinity}>
      <Toast open>
        <Body title="Heads up" description="3 RFQs awaiting review." />
        <ToastClose />
      </Toast>
      <Toast open variant="success">
        <Body title="Saved" description="Catalog updated." />
        <ToastAction altText="Undo the catalog update">Undo</ToastAction>
        <ToastClose />
      </Toast>
      <Toast open variant="warning">
        <Body title="Delayed" description="Shipment running 2 hours behind schedule." />
        <ToastClose />
      </Toast>
      <Toast open variant="danger">
        <Body title="Line 4 halted" description="Check sensor 2." />
        <ToastClose />
      </Toast>
      <ToastViewport />
    </ToastProvider>
  </div>
);

export const SuccessWithAction = () => (
  <div style={{ minHeight: 140 }}>
    <ToastProvider duration={Infinity}>
      <Toast open variant="success">
        <Body title="Quote sent" description="RFQ-0042 · Pacific Pack Co. · ₹1,24,000" />
        <ToastAction altText="View the sent quote">View</ToastAction>
        <ToastClose />
      </Toast>
      <ToastViewport />
    </ToastProvider>
  </div>
);
