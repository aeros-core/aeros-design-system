import * as React from "react";
import { Kbd, KbdGroup } from "@aeros-core/react";

const row: React.CSSProperties = { display: "flex", flexWrap: "wrap", gap: 12, alignItems: "center" };

export const SingleKeys = () => (
  <div style={row}>
    <Kbd>⌘</Kbd>
    <Kbd>K</Kbd>
    <Kbd>Esc</Kbd>
    <Kbd>Enter</Kbd>
    <Kbd>Shift</Kbd>
    <Kbd>↑</Kbd>
    <Kbd>↓</Kbd>
    <Kbd>/</Kbd>
  </div>
);

export const Combinations = () => (
  <div style={{ ...row, gap: 20 }}>
    <KbdGroup>
      <Kbd>⌘</Kbd>
      <Kbd>K</Kbd>
    </KbdGroup>
    <KbdGroup>
      <Kbd>Ctrl</Kbd>
      <Kbd>Shift</Kbd>
      <Kbd>P</Kbd>
    </KbdGroup>
    <KbdGroup>
      <Kbd>G</Kbd>
      <span className="text-caption text-fg-muted">then</span>
      <Kbd>O</Kbd>
    </KbdGroup>
  </div>
);

export const InContext = () => (
  <div style={{ display: "grid", gap: 16 }}>
    <p className="text-body-md text-fg-secondary">
      Press{" "}
      <KbdGroup>
        <Kbd>⌘</Kbd>
        <Kbd>K</Kbd>
      </KbdGroup>{" "}
      to search, or <Kbd>Esc</Kbd> to close.
    </p>
    <div
      className="flex items-center justify-between rounded-surface border border-border-default bg-bg-surface px-3 py-2 text-body-md text-fg-primary"
      style={{ width: 256 }}
    >
      New order
      <KbdGroup>
        <Kbd>⌘</Kbd>
        <Kbd>N</Kbd>
      </KbdGroup>
    </div>
  </div>
);
