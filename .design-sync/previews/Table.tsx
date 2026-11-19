import * as React from "react";
import { Table, Thead, Tbody, Tr, Th, Td, TdStrong, TdMono, Badge } from "@aeros-core/react";

const rows: Array<{
  rfq: string;
  buyer: string;
  value: string;
  tone: "success" | "warning" | "danger";
  status: string;
}> = [
  { rfq: "RFQ-0042", buyer: "Pacific Pack Co.", value: "₹1,24,000", tone: "success", status: "Approved" },
  { rfq: "RFQ-0043", buyer: "Coastal Foods", value: "₹68,500", tone: "warning", status: "Pending" },
  { rfq: "RFQ-0044", buyer: "Meridian Logistics", value: "₹2,10,000", tone: "danger", status: "Rejected" },
];

export const OrdersTable = () => (
  <Table>
    <Thead>
      <Tr>
        <Th>RFQ</Th>
        <Th>Buyer</Th>
        <Th>Value</Th>
        <Th>Status</Th>
      </Tr>
    </Thead>
    <Tbody>
      {rows.map((r) => (
        <Tr key={r.rfq}>
          <Td>
            <TdMono>{r.rfq}</TdMono>
          </Td>
          <Td>
            <TdStrong>{r.buyer}</TdStrong>
          </Td>
          <Td>
            <TdMono>{r.value}</TdMono>
          </Td>
          <Td>
            <Badge variant={r.tone} dot>
              {r.status}
            </Badge>
          </Td>
        </Tr>
      ))}
    </Tbody>
  </Table>
);
