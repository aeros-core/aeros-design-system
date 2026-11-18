"use client";

import { Kbd, KbdGroup } from "@aeros-core/react";
import { Group } from "./kit";

export default function KbdFixture() {
  return (
    <>
      <Group label="Single keys">
        <Kbd>⌘</Kbd>
        <Kbd>K</Kbd>
        <Kbd>Esc</Kbd>
        <Kbd>Enter</Kbd>
        <Kbd>Shift</Kbd>
        <Kbd>↑</Kbd>
        <Kbd>↓</Kbd>
        <Kbd>/</Kbd>
      </Group>
      <Group label="Combinations">
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
          <span className="text-xs text-fg-muted">then</span>
          <Kbd>O</Kbd>
        </KbdGroup>
      </Group>
      <Group label="Inline in text">
        <p className="text-sm text-fg-secondary">
          Press{" "}
          <KbdGroup>
            <Kbd>⌘</Kbd>
            <Kbd>K</Kbd>
          </KbdGroup>{" "}
          to search, or <Kbd>Esc</Kbd> to close.
        </p>
      </Group>
      <Group label="As a trailing hint in a row">
        <div className="flex w-64 items-center justify-between rounded-lg border border-border-default bg-bg-surface px-3 py-2 text-sm text-fg-primary">
          New order
          <KbdGroup>
            <Kbd>⌘</Kbd>
            <Kbd>N</Kbd>
          </KbdGroup>
        </div>
      </Group>
    </>
  );
}
