import * as React from "react";
import { Pagination } from "@aeros-core/react";

const stack: React.CSSProperties = { display: "grid", gap: 16, justifyItems: "start" };

// First page disables "previous", last page disables "next".
export const Positions = () => (
  <div style={stack}>
    <Pagination page={1} count={20} />
    <Pagination page={10} count={20} />
    <Pagination page={20} count={20} />
  </div>
);

export const ShortAndSinglePage = () => (
  <div style={stack}>
    <Pagination page={2} count={5} />
    <Pagination page={1} count={1} />
  </div>
);

export const WiderSiblings = () => <Pagination page={10} count={20} siblings={2} />;

export const Interactive = () => {
  const [page, setPage] = React.useState(4);
  return <Pagination page={page} count={12} onPageChange={setPage} />;
};
