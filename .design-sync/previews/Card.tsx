import * as React from "react";
import {
  Card,
  CardHeader,
  CardTitle,
  CardSubtitle,
  CardBody,
  CardFooter,
  Badge,
  Progress,
  Button,
} from "@aeros-core/react";

const mono: React.CSSProperties = {
  fontFamily: "var(--aeros-font-mono)",
  color: "var(--aeros-fg-primary)",
};

export const ProductionCard = () => (
  <div style={{ maxWidth: 380 }}>
    <Card>
      <CardHeader>
        <div>
          <CardTitle>Today's production</CardTitle>
          <CardSubtitle>Line 3 · updated 3 min ago</CardSubtitle>
        </div>
        <Badge variant="green" dot>
          Live
        </Badge>
      </CardHeader>
      <CardBody>
        <Progress value={64} />
        <p style={{ marginTop: 12, fontSize: 12, ...mono, color: "var(--aeros-fg-muted)" }}>
          4,820 units · 8% above yesterday
        </p>
      </CardBody>
      <CardFooter>
        <span style={{ fontSize: 12, color: "var(--aeros-fg-muted)" }}>
          Updated automatically
        </span>
        <Button variant="secondary" size="sm">
          View
        </Button>
      </CardFooter>
    </Card>
  </div>
);

export const ApprovalsCard = () => (
  <div style={{ maxWidth: 380 }}>
    <Card>
      <CardHeader>
        <CardTitle>Pending approvals</CardTitle>
      </CardHeader>
      <CardBody>
        <div style={{ display: "flex", flexDirection: "column", gap: 8, fontSize: 14, color: "var(--aeros-fg-secondary)" }}>
          {[
            ["RFQ-0042", "₹1,24,000"],
            ["RFQ-0043", "₹68,500"],
            ["RFQ-0044", "₹2,10,000"],
          ].map(([id, amt]) => (
            <div key={id} style={{ display: "flex", justifyContent: "space-between" }}>
              <span>{id}</span>
              <span style={mono}>{amt}</span>
            </div>
          ))}
        </div>
      </CardBody>
    </Card>
  </div>
);
