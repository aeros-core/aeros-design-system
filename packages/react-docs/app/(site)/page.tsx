import type { Metadata } from "next";
import Link from "next/link";
import {
  Badge,
  Button,
  Card,
  CardBody,
  CardFooter,
  CardHeader,
  CardSubtitle,
  CardTitle,
  Table,
  Tbody,
  Td,
  TdMono,
  TdStrong,
  Th,
  Thead,
  Tr,
} from "@aeros-core/react";
import { tokens } from "@aeros-core/tokens";
import { ArrowRight } from "lucide-react";
import { COMPONENT_SLUGS } from "../_registry";
import { CodeBlock } from "../_site/code-block";
import { Code, Section } from "../_site/prose";
import { routesIn } from "../_site/routes";

export const metadata: Metadata = { title: "Introduction" };

const control = tokens.size.control.md;
const row = tokens.size.row;

const PRINCIPLES: Array<{ title: string; body: string }> = [
  {
    title: "Hairlines, not shadows",
    body: "A resting surface is white on the canvas with a one-pixel border. Only layers that float — menus, popovers, dialogs — have elevation.",
  },
  {
    title: "Monochrome",
    body: "Black, white and grey. Primary actions, selection and focus are ink. Status colours appear only where they report state.",
  },
  {
    title: "Compact by default",
    body: `Sized for the mouse: ${control.pointer}px controls and ${row.pointer}px rows. Touch density raises them to ${control.touch}px and ${row.touch}px without a second set of components.`,
  },
  {
    title: "Colour-only state changes",
    body: "Hover, press and selection change a fill or a border. Nothing lifts, scales or gains a shadow.",
  },
  {
    title: "Semantic radii",
    body: `Radius is chosen by role, not by taste: ${tokens.shape.item}px for rows, ${tokens.shape.control}px for controls, ${tokens.shape.surface}px for surfaces, ${tokens.shape.modal}px for modals.`,
  },
  {
    title: "Mono for data",
    body: "Ids, quantities, amounts and timestamps are set in IBM Plex Mono. Everything a person wrote is Inter.",
  },
];

const INSTALL = `pnpm add @aeros-core/react @aeros-core/tokens`;

const STYLES = `/* app/globals.css — Tailwind v4 */
@import "@aeros-core/react/styles.css"; /* Tailwind + tokens + the Aeros theme */
@import "@aeros-core/react/fonts.css";  /* self-hosted Inter, Nunito Sans, IBM Plex Mono */`;

const FIRST_USE = `import { Button, Field, Input } from "@aeros-core/react";

export function InviteForm() {
  return (
    <form className="grid gap-4">
      <Field label="Email" required>
        <Input type="email" placeholder="priya@example.com" />
      </Field>
      <Button type="submit">Send invite</Button>
    </form>
  );
}`;

const ORDERS = [
  { id: "PO-1042", vendor: "Trimurti Packaging", value: "1,24,000", status: "Dispatched", tone: "success" },
  { id: "PO-1043", vendor: "Shakti Bearings", value: "68,500", status: "In QC", tone: "info" },
  { id: "PO-1044", vendor: "Coastal Foods", value: "2,10,000", status: "Pending", tone: "warning" },
  { id: "PO-1045", vendor: "Meridian Logistics", value: "9,200", status: "Rejected", tone: "danger" },
] as const;

const SECTIONS = [
  {
    href: "/foundations/color",
    title: "Foundations",
    body: `${routesIn("Foundations").length} pages generated from the tokens: colour, type, spacing, elevation, motion and density.`,
  },
  {
    href: "/components",
    title: "Components",
    body: `${COMPONENT_SLUGS.length} components, each with its live states, an import line and a usage snippet.`,
  },
  {
    href: "/patterns/app-shell",
    title: "Patterns",
    body: "Whole screens composed from the components: the app shell, a data table, a form and settings.",
  },
  {
    href: "/migration",
    title: "Migrating to 3.0",
    body: "The headline breaking changes of the redesign, with a link to the full guide.",
  },
];

export default function OverviewPage() {
  return (
    <>
      <div className="mb-10 grid items-start gap-8 lg:grid-cols-2">
        <div className="min-w-0">
          <div className="flex items-center gap-3">
            <Badge variant="inverse">v{tokens.meta.version}</Badge>
            <span className="text-caption text-fg-muted">Crisp precision</span>
          </div>
          <p className="mt-4 text-display-md text-fg-primary">
            <span className="aeros-logo">Aeros</span> Design System
          </p>
          <p className="mt-3 max-w-prose text-body-lg text-fg-secondary">
            One set of tokens, a React component library and a Flutter widget library for the Aeros products —
            software for people who run factories, buying teams and warehouses. It is dense, quiet and exact, so the
            operator&apos;s data is the loudest thing on the screen.
          </p>
          <div className="mt-6 flex flex-wrap gap-2">
            <Button asChild trailingIcon={<ArrowRight />}>
              <Link href="/components">Browse components</Link>
            </Button>
            <Button asChild variant="secondary">
              <Link href="/foundations/color">Foundations</Link>
            </Button>
          </div>
        </div>

        <Card className="min-w-0">
          <CardHeader>
            <div className="min-w-0">
              <CardTitle>Open orders</CardTitle>
              <CardSubtitle>Updated 3 minutes ago</CardSubtitle>
            </div>
            <Badge variant="success" dot>
              Live
            </Badge>
          </CardHeader>
          <Table shell={false} aria-label="Open orders">
            <Thead>
              <Tr>
                <Th>Order</Th>
                <Th>Vendor</Th>
                <Th className="text-end">Value (₹)</Th>
                <Th>Status</Th>
              </Tr>
            </Thead>
            <Tbody>
              {ORDERS.map((order) => (
                <Tr key={order.id}>
                  <Td className="whitespace-nowrap">
                    <TdMono>{order.id}</TdMono>
                  </Td>
                  <Td>
                    <TdStrong>{order.vendor}</TdStrong>
                  </Td>
                  <Td className="text-end">
                    <TdMono>{order.value}</TdMono>
                  </Td>
                  <Td>
                    <Badge variant={order.tone} dot>
                      {order.status}
                    </Badge>
                  </Td>
                </Tr>
              ))}
            </Tbody>
          </Table>
          <CardFooter>
            <span className="text-caption text-fg-muted">4 of 38 orders</span>
            <div className="flex gap-2">
              <Button variant="ghost" size="sm">
                Export
              </Button>
              <Button asChild variant="secondary" size="sm">
                <Link href="/patterns/data-table">View all</Link>
              </Button>
            </div>
          </CardFooter>
        </Card>
      </div>

      <Section title="Principles" description="Six rules decide most questions before they are asked.">
        <div className="grid gap-px overflow-hidden rounded-surface border border-border-default bg-border-default sm:grid-cols-2 lg:grid-cols-3">
          {PRINCIPLES.map((principle, index) => (
            <div key={principle.title} className="bg-bg-surface p-4">
              <div className="font-mono text-mono-xs text-fg-muted">{String(index + 1).padStart(2, "0")}</div>
              <h3 className="mt-2 text-h4 text-fg-primary">{principle.title}</h3>
              <p className="mt-1 text-body-sm text-fg-secondary">{principle.body}</p>
            </div>
          ))}
        </div>
      </Section>

      <Section
        title="Install"
        description={
          <>
            The packages are published to GitHub Packages under the <Code>@aeros-core</Code> scope. Import the
            stylesheet once; it brings Tailwind, the tokens and the Aeros theme.
          </>
        }
      >
        <div className="grid gap-4 lg:grid-cols-2">
          <div className="grid min-w-0 content-start gap-4">
            <CodeBlock title="Terminal" code={INSTALL} />
            <CodeBlock title="globals.css" code={STYLES} />
          </div>
          <CodeBlock title="invite-form.tsx" code={FIRST_USE} />
        </div>
        <p className="mt-4 max-w-prose text-body-sm text-fg-secondary">
          Set <Code>data-theme</Code> to <Code>light</Code>, <Code>dark</Code> or <Code>system</Code> on{" "}
          <Code>&lt;html&gt;</Code> — or on any element, to theme a subtree. Set <Code>data-density=&quot;touch&quot;</Code>{" "}
          for the larger touch sizes. The switches in the header of this site do exactly that.
        </p>
      </Section>

      <Section title="Where to go next">
        <div className="grid gap-4 sm:grid-cols-2">
          {SECTIONS.map((section) => (
            <Link key={section.href} href={section.href} className="group block rounded-surface">
              <Card interactive className="h-full">
                <CardBody>
                  <div className="flex items-center justify-between gap-3">
                    <h3 className="text-h3 text-fg-primary">{section.title}</h3>
                    <ArrowRight aria-hidden className="size-icon-md shrink-0 text-fg-muted" />
                  </div>
                  <p className="mt-1 text-body-sm text-fg-secondary">{section.body}</p>
                </CardBody>
              </Card>
            </Link>
          ))}
        </div>
      </Section>
    </>
  );
}
