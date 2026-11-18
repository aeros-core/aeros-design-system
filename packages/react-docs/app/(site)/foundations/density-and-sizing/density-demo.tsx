"use client";

import {
  Badge,
  Button,
  Checkbox,
  Field,
  Input,
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
  Table,
  Tbody,
  Td,
  TdMono,
  Th,
  Thead,
  Tr,
} from "@aeros-core/react";
import { Plus, Search } from "lucide-react";

function Controls({ density }: { density: "pointer" | "touch" }) {
  return (
    <div data-density={density} className="min-w-0 rounded-surface border border-border-default bg-bg-surface">
      <div className="flex h-header items-center justify-between border-b border-border-default px-4">
        <span className="text-h4 capitalize text-fg-primary">{density}</span>
        <span className="font-mono text-mono-xs text-fg-muted">data-density=&quot;{density}&quot;</span>
      </div>
      <div className="grid gap-4 p-4">
        <div className="flex flex-wrap items-center gap-2">
          <Button size="sm" variant="secondary">
            Small
          </Button>
          <Button leadingIcon={<Plus />}>Medium</Button>
          <Button size="lg" variant="secondary">
            Large
          </Button>
          <Button variant="ghost" iconOnly aria-label="Search">
            <Search />
          </Button>
        </div>
        <Field label="Reference">
          <Input defaultValue="PO-1042" />
        </Field>
        <Field label="Payment terms">
          <Select defaultValue="net-30">
            <SelectTrigger>
              <SelectValue />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="net-15">Net 15</SelectItem>
              <SelectItem value="net-30">Net 30</SelectItem>
            </SelectContent>
          </Select>
        </Field>
        <label className="inline-flex items-center gap-2 text-body-sm text-fg-secondary">
          <Checkbox defaultChecked /> Email me order updates
        </label>
        <Table aria-label={`Orders at ${density} density`}>
          <Thead>
            <Tr>
              <Th>Order</Th>
              <Th>Status</Th>
            </Tr>
          </Thead>
          <Tbody>
            <Tr>
              <Td>
                <TdMono>PO-1042</TdMono>
              </Td>
              <Td>
                <Badge variant="success" dot>
                  Dispatched
                </Badge>
              </Td>
            </Tr>
            <Tr>
              <Td>
                <TdMono>PO-1043</TdMono>
              </Td>
              <Td>
                <Badge variant="warning" dot>
                  Pending
                </Badge>
              </Td>
            </Tr>
          </Tbody>
        </Table>
      </div>
    </div>
  );
}

/** The same controls under each density, regardless of the site-wide switch. */
export function DensityDemo() {
  return (
    <div className="grid items-start gap-4 lg:grid-cols-2">
      <Controls density="pointer" />
      <Controls density="touch" />
    </div>
  );
}
