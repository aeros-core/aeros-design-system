"use client";

import {
  Badge,
  Button,
  Card,
  CardBody,
  CardFooter,
  CardHeader,
  CardSubtitle,
  CardTitle,
  Progress,
} from "@aeros-core/react";
import { Group } from "./kit";

export default function CardFixture() {
  return (
    <>
      <Group label="Header + body + footer" className="grid items-start gap-5 md:grid-cols-2">
        <Card>
          <CardHeader>
            <div>
              <CardTitle>Today's production</CardTitle>
              <CardSubtitle>Line 3 · updated 3 min ago</CardSubtitle>
            </div>
            <Badge variant="success" dot>Live</Badge>
          </CardHeader>
          <CardBody>
            <Progress value={64} aria-label="Line 3 progress" />
            <p className="mt-3 font-mono text-caption text-fg-muted">4,820 units · 8% above yesterday</p>
          </CardBody>
          <CardFooter>
            <span className="text-caption text-fg-muted">Updated automatically</span>
            <Button variant="secondary" size="sm">View</Button>
          </CardFooter>
        </Card>
        <Card>
          <CardHeader>
            <CardTitle>Pending approvals</CardTitle>
          </CardHeader>
          <CardBody>
            <div className="space-y-2 text-body-md text-fg-secondary">
              <div className="flex justify-between">
                <span>RFQ-0042</span>
                <span className="font-mono text-fg-primary">₹1,24,000</span>
              </div>
              <div className="flex justify-between">
                <span>RFQ-0043</span>
                <span className="font-mono text-fg-primary">₹68,500</span>
              </div>
            </div>
          </CardBody>
        </Card>
      </Group>
      <Group label="Body only / interactive" className="grid items-start gap-5 md:grid-cols-2">
        <Card>
          <CardBody>
            <p className="text-body-md text-fg-secondary">A plain card with body content only.</p>
          </CardBody>
        </Card>
        <Card interactive>
          <CardBody>
            <p className="text-body-md font-semibold text-fg-primary">Interactive card</p>
            <p className="mt-1 text-caption text-fg-muted">Lifts on hover (resting state shown).</p>
          </CardBody>
        </Card>
      </Group>
      <Group label="The whole card as the control" className="grid items-start gap-5 md:grid-cols-2">
        {/* onClick: the card is a button — focusable, Enter and Space activate it. No other control inside. */}
        <Card interactive onClick={() => {}}>
          <CardBody>
            <p className="text-body-md font-semibold text-fg-primary">Clickable card</p>
            <p className="mt-1 text-caption text-fg-muted">interactive + onClick — a button.</p>
          </CardBody>
        </Card>
        {/* asChild: the card is your element — here a real link. */}
        <Card asChild interactive>
          <a href="#order-1042">
            <CardBody>
              <p className="text-body-md font-semibold text-fg-primary">Order #1042</p>
              <p className="mt-1 text-caption text-fg-muted">interactive + asChild — a link.</p>
            </CardBody>
          </a>
        </Card>
      </Group>
    </>
  );
}
