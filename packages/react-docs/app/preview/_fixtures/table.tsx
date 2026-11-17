"use client";

import {
  Badge,
  Table,
  TableEmptyRow,
  TableLoadingRow,
  Tbody,
  Td,
  TdMono,
  TdMuted,
  TdStrong,
  Th,
  Thead,
  Tr,
} from "@aeros-core/react";
import { Group } from "./kit";

const noop = () => {};

export default function TableFixture() {
  return (
    <>
      <Group label="Rows — cell helpers, selected row" className="flex-col items-stretch">
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
            <Tr>
              <Td><TdMono>RFQ-0042</TdMono></Td>
              <Td>
                <TdStrong>Pacific Pack Co.</TdStrong>
                <br />
                <TdMuted>Pune</TdMuted>
              </Td>
              <Td><TdMono>₹1,24,000</TdMono></Td>
              <Td><Badge variant="success" dot>Approved</Badge></Td>
            </Tr>
            <Tr selected>
              <Td><TdMono>RFQ-0043</TdMono></Td>
              <Td>
                <TdStrong>Coastal Foods</TdStrong>
                <br />
                <TdMuted>Selected row</TdMuted>
              </Td>
              <Td><TdMono>₹68,500</TdMono></Td>
              <Td><Badge variant="warning" dot>Pending</Badge></Td>
            </Tr>
            <Tr>
              <Td><TdMono>RFQ-0044</TdMono></Td>
              <Td>
                <TdStrong>Meridian Logistics</TdStrong>
                <br />
                <TdMuted>Mumbai</TdMuted>
              </Td>
              <Td><TdMono>₹2,10,000</TdMono></Td>
              <Td><Badge variant="danger" dot>Rejected</Badge></Td>
            </Tr>
          </Tbody>
        </Table>
      </Group>
      <Group label="Sortable headers — asc, desc, unsorted, plain" className="flex-col items-stretch">
        <Table>
          <Thead>
            <Tr>
              <Th sortable sortDirection="asc" onSort={noop}>Order</Th>
              <Th sortable sortDirection="desc" onSort={noop}>Vendor</Th>
              <Th sortable sortDirection={false} onSort={noop}>Value</Th>
              <Th>Status</Th>
            </Tr>
          </Thead>
          <Tbody>
            <Tr>
              <Td>#1042</Td>
              <Td>Trimurti Packaging</Td>
              <Td>₹1,24,000</Td>
              <Td>Dispatched</Td>
            </Tr>
            <Tr>
              <Td>#1043</Td>
              <Td>Shakti Bearings</Td>
              <Td>₹68,500</Td>
              <Td>In QC</Td>
            </Tr>
          </Tbody>
        </Table>
      </Group>
      <Group label="Loading row" className="flex-col items-stretch">
        <Table>
          <Thead>
            <Tr>
              <Th>Order</Th>
              <Th>Vendor</Th>
              <Th>Status</Th>
            </Tr>
          </Thead>
          <Tbody>
            <TableLoadingRow colSpan={3} />
          </Tbody>
        </Table>
      </Group>
      <Group label="Empty row" className="flex-col items-stretch">
        <Table>
          <Thead>
            <Tr>
              <Th>Order</Th>
              <Th>Vendor</Th>
              <Th>Status</Th>
            </Tr>
          </Thead>
          <Tbody>
            <TableEmptyRow colSpan={3}>No orders match the current filters.</TableEmptyRow>
          </Tbody>
        </Table>
      </Group>
      <Group label="shell={false}" className="flex-col items-stretch">
        <Table shell={false}>
          <Thead>
            <Tr>
              <Th>Order</Th>
              <Th>Vendor</Th>
            </Tr>
          </Thead>
          <Tbody>
            <Tr>
              <Td>#1042</Td>
              <Td>Trimurti Packaging</Td>
            </Tr>
            <Tr>
              <Td>#1043</Td>
              <Td>Shakti Bearings</Td>
            </Tr>
          </Tbody>
        </Table>
      </Group>
    </>
  );
}
