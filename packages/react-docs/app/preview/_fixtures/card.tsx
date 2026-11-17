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
            <p className="mt-3 font-mono text-xs text-fg-muted">4,820 units · 8% above yesterday</p>
          </CardBody>
          <CardFooter>
            <span className="text-xs text-fg-muted">Updated automatically</span>
            <Button variant="secondary" size="sm">View</Button>
          </CardFooter>
        </Card>
        <Card>
          <CardHeader>
            <CardTitle>Pending approvals</CardTitle>
          </CardHeader>
          <CardBody>
            <div className="space-y-2 text-sm text-fg-secondary">
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
            <p className="text-sm text-fg-secondary">A plain card with body content only.</p>
          </CardBody>
        </Card>
        <Card interactive>
          <CardBody>
            <p className="text-sm font-semibold text-fg-primary">Interactive card</p>
            <p className="mt-1 text-xs text-fg-muted">Lifts on hover (resting state shown).</p>
          </CardBody>
        </Card>
      </Group>
    </>
  );
}
