"use client";

import { Button } from "@aeros-core/react";
import { ChevronDown, Plus, Settings } from "lucide-react";
import { Group } from "./kit";

const VARIANTS = ["primary", "secondary", "ghost", "danger", "danger-subtle", "link"] as const;

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
        <Button size="xs" iconOnly aria-label="Settings"><Settings /></Button>
        <Button size="sm" iconOnly aria-label="Settings"><Settings /></Button>
        <Button size="md" iconOnly aria-label="Settings"><Settings /></Button>
        <Button size="lg" iconOnly aria-label="Settings"><Settings /></Button>
        <Button variant="secondary" size="md" iconOnly aria-label="Settings"><Settings /></Button>
        <Button variant="ghost" size="md" iconOnly aria-label="Settings"><Settings /></Button>
      </Group>
      <Group label="With icons">
        <Button leadingIcon={<Plus />}>Create RFQ</Button>
        <Button variant="secondary" trailingIcon={<ChevronDown />}>Filter</Button>
        <Button variant="ghost" leadingIcon={<Settings />}>Settings</Button>
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
      <Group label="asChild — a link styled as a button">
        <Button asChild leadingIcon={<Plus />}>
          <a href="#new">New order</a>
        </Button>
        <Button asChild variant="secondary" trailingIcon={<ChevronDown />}>
          <a href="#more">More</a>
        </Button>
      </Group>
    </>
  );
}
