"use client";

import { Button } from "@aeros-core/react";
import { ChevronDown, Plus, Settings } from "lucide-react";
import { Group } from "./kit";

const VARIANTS = ["primary", "secondary", "ghost", "danger", "link"] as const;

export default function ButtonFixture() {
  return (
    <>
      <Group label="Variants">
        {VARIANTS.map((v) => (
          <Button key={v} variant={v}>
            {v}
          </Button>
        ))}
      </Group>
      <Group label="Sizes">
        <Button size="xs">xs</Button>
        <Button size="sm">sm</Button>
        <Button size="md">md</Button>
        <Button size="lg">lg</Button>
        <Button size="xl">xl</Button>
      </Group>
      <Group label="Sizes — secondary">
        <Button variant="secondary" size="xs">xs</Button>
        <Button variant="secondary" size="sm">sm</Button>
        <Button variant="secondary" size="md">md</Button>
        <Button variant="secondary" size="lg">lg</Button>
        <Button variant="secondary" size="xl">xl</Button>
      </Group>
      <Group label="Icon-only sizes">
        <Button size="icon-sm" aria-label="Settings"><Settings className="h-4 w-4" /></Button>
        <Button size="icon-md" aria-label="Settings"><Settings className="h-4 w-4" /></Button>
        <Button size="icon-lg" aria-label="Settings"><Settings className="h-4 w-4" /></Button>
        <Button variant="secondary" size="icon-md" aria-label="Settings"><Settings className="h-4 w-4" /></Button>
        <Button variant="ghost" size="icon-md" aria-label="Settings"><Settings className="h-4 w-4" /></Button>
      </Group>
      <Group label="With icons">
        <Button leadingIcon={<Plus className="h-4 w-4" />}>Create RFQ</Button>
        <Button variant="secondary" trailingIcon={<ChevronDown className="h-4 w-4" />}>Filter</Button>
        <Button variant="ghost" leadingIcon={<Settings className="h-4 w-4" />}>Settings</Button>
      </Group>
      <Group label="Loading">
        {VARIANTS.map((v) => (
          <Button key={v} variant={v} loading>
            Saving…
          </Button>
        ))}
      </Group>
      <Group label="Disabled">
        {VARIANTS.map((v) => (
          <Button key={v} variant={v} disabled>
            {v}
          </Button>
        ))}
      </Group>
      {/* No asChild case: <Button asChild> currently throws ("React.Children.only
          expected to receive a single React element child") because Button passes
          [leadingIcon, children, trailingIcon] to Slot. Add one here once fixed. */}
    </>
  );
}
