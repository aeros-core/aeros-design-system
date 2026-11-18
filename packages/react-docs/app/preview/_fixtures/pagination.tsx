"use client";

import { Pagination } from "@aeros-core/react";
import { Group } from "./kit";

export default function PaginationFixture() {
  return (
    <>
      <Group label="First page (previous disabled)">
        <Pagination page={1} count={20} />
      </Group>
      <Group label="Middle page (both ellipses)">
        <Pagination page={10} count={20} />
      </Group>
      <Group label="Last page (next disabled)">
        <Pagination page={20} count={20} />
      </Group>
      <Group label="Short list (no ellipsis)">
        <Pagination page={2} count={5} />
      </Group>
      <Group label="siblings={2}">
        <Pagination page={10} count={20} siblings={2} />
      </Group>
      <Group label="Single page">
        <Pagination page={1} count={1} />
      </Group>
    </>
  );
}
