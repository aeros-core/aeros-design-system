"use client";

import { Group } from "./kit";

// Class names are written out literally so Tailwind's scanner generates them.
const SURFACES = [
  ["bg-bg-canvas", "bg-canvas"],
  ["bg-bg-surface", "bg-surface"],
  ["bg-bg-elevated", "bg-elevated"],
  ["bg-bg-subtle", "bg-subtle"],
  ["bg-bg-inverse", "bg-inverse"],
  ["bg-brand-primary", "brand-primary"],
  ["bg-brand-primary-hover", "brand-primary-hover"],
  ["bg-brand-primary-muted", "brand-primary-muted"],
] as const;

const STATUS = [
  ["bg-success", "success"],
  ["bg-success-bg", "success-bg"],
  ["bg-success-border", "success-border"],
  ["bg-success-text", "success-text"],
  ["bg-warning", "warning"],
  ["bg-warning-bg", "warning-bg"],
  ["bg-warning-border", "warning-border"],
  ["bg-warning-text", "warning-text"],
  ["bg-danger", "danger"],
  ["bg-danger-bg", "danger-bg"],
  ["bg-danger-border", "danger-border"],
  ["bg-danger-text", "danger-text"],
  ["bg-info", "info"],
  ["bg-info-bg", "info-bg"],
  ["bg-info-border", "info-border"],
  ["bg-info-text", "info-text"],
] as const;

const INK = [
  ["bg-ink-0", "ink-0"],
  ["bg-ink-50", "ink-50"],
  ["bg-ink-100", "ink-100"],
  ["bg-ink-200", "ink-200"],
  ["bg-ink-300", "ink-300"],
  ["bg-ink-400", "ink-400"],
  ["bg-ink-500", "ink-500"],
  ["bg-ink-600", "ink-600"],
  ["bg-ink-700", "ink-700"],
  ["bg-ink-800", "ink-800"],
  ["bg-ink-900", "ink-900"],
  ["bg-ink-950", "ink-950"],
] as const;

const BORDERS = [
  ["border-border-subtle", "border-subtle"],
  ["border-border-default", "border-default"],
  ["border-border-strong", "border-strong"],
  ["border-border-focus", "border-focus"],
] as const;

// Elevation intents — resting surfaces carry a hairline and no shadow.
const SHADOWS = [
  ["border border-border-default", "resting (hairline)"],
  ["shadow-raised", "shadow-raised"],
  ["shadow-overlay", "shadow-overlay"],
  ["shadow-modal", "shadow-modal"],
] as const;

// Semantic radii — what components use.
const RADII = [
  ["rounded-item", "item · 4"],
  ["rounded-control", "control · 6"],
  ["rounded-surface", "surface · 8"],
  ["rounded-modal", "modal · 12"],
  ["rounded-pill", "pill"],
] as const;

function Swatch({ cls, name }: { cls: string; name: string }) {
  return (
    <div className="flex flex-col gap-1.5">
      <div className={"h-14 w-full rounded-surface border border-border-default " + cls} />
      <div className="font-mono text-[11px] text-fg-primary">{name}</div>
    </div>
  );
}

export default function FoundationsSurfacesFixture() {
  return (
    <>
      <Group label="Surfaces + brand" className="grid grid-cols-2 items-stretch gap-4 sm:grid-cols-4">
        {SURFACES.map(([cls, name]) => (
          <Swatch key={cls} cls={cls} name={name} />
        ))}
      </Group>
      <Group label="Status" className="grid grid-cols-2 items-stretch gap-4 sm:grid-cols-4">
        {STATUS.map(([cls, name]) => (
          <Swatch key={cls} cls={cls} name={name} />
        ))}
      </Group>
      <Group label="Ink ramp (static)" className="grid grid-cols-3 items-stretch gap-4 sm:grid-cols-6">
        {INK.map(([cls, name]) => (
          <Swatch key={cls} cls={cls} name={name} />
        ))}
      </Group>
      <Group label="Borders" className="grid grid-cols-2 items-stretch gap-4 sm:grid-cols-4">
        {BORDERS.map(([cls, name]) => (
          <div key={cls} className="flex flex-col gap-1.5">
            <div className={"h-14 w-full rounded-surface border-2 bg-bg-surface " + cls} />
            <div className="font-mono text-[11px] text-fg-primary">{name}</div>
          </div>
        ))}
      </Group>
      <Group label="Shadows (on bg-surface)" className="grid grid-cols-2 items-stretch gap-8 p-4 sm:grid-cols-3">
        {SHADOWS.map(([cls, name]) => (
          <div key={cls} className="flex flex-col gap-3">
            <div className={"h-16 w-full rounded-surface bg-bg-surface " + cls} />
            <div className="font-mono text-[11px] text-fg-primary">{name}</div>
          </div>
        ))}
      </Group>
      <Group label="Radius" className="grid grid-cols-3 items-stretch gap-4 sm:grid-cols-9">
        {RADII.map(([cls, name]) => (
          <div key={cls} className="flex flex-col gap-1.5">
            <div className={"h-14 w-14 border border-border-strong bg-bg-subtle " + cls} />
            <div className="font-mono text-[11px] text-fg-primary">{name}</div>
          </div>
        ))}
      </Group>
    </>
  );
}
