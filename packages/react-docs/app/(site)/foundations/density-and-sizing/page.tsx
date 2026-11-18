import type { Metadata } from "next";
import { tokens } from "@aeros-core/tokens";
import { Code, PageIntro, Section, SpecCell, SpecTable } from "../../../_site/prose";
import { DensityDemo } from "./density-demo";

export const metadata: Metadata = { title: "Density and sizing" };

interface SizeRow {
  name: string;
  /** The Tailwind size key, e.g. `control-md` → `h-control-md`, `size-control-md`. */
  pointer: number;
  touch: number;
}

/** Flattens tokens.size: a leaf is either `{ pointer, touch }` or a plain number (density-independent). */
function flatten(node: unknown, path: string[] = []): SizeRow[] {
  if (typeof node === "number") return [{ name: path.join("-"), pointer: node, touch: node }];
  if (node && typeof node === "object") {
    const record = node as Record<string, unknown>;
    if (typeof record.pointer === "number" && typeof record.touch === "number") {
      return [{ name: path.join("-"), pointer: record.pointer, touch: record.touch }];
    }
    return Object.entries(record).flatMap(([key, value]) => flatten(value, [...path, key]));
  }
  return [];
}

const ROWS = flatten(tokens.size);
const DENSITY_AWARE = ROWS.filter((row) => row.pointer !== row.touch);
const FIXED = ROWS.filter((row) => row.pointer === row.touch);
const control = tokens.size.control;

export default function DensityAndSizingPage() {
  return (
    <>
      <PageIntro section="Foundations">
        Sizes are tokens too. The default density is pointer: compact controls for a desk and a mouse. Put{" "}
        <Code>data-density=&quot;touch&quot;</Code> on <Code>&lt;html&gt;</Code> or on any subtree and the same
        components grow to touch sizes — nothing else changes.
      </PageIntro>

      <Section
        title="Side by side"
        description={`The same markup in both densities. The default control is ${control.md.pointer}px under pointer and ${control.md.touch}px under touch.`}
      >
        <DensityDemo />
      </Section>

      <Section
        title="Density-aware sizes"
        description={
          <>
            Use them as size utilities: <Code>h-control-md</Code>, <Code>size-icon-button</Code>, <Code>h-row</Code>,{" "}
            <Code>h-header</Code>.
          </>
        }
      >
        <SpecTable label="Density-aware sizes" head={["Token", "Pointer", "Touch", "Difference"]}>
          {DENSITY_AWARE.map((row) => (
            <tr key={row.name}>
              <SpecCell mono>{row.name}</SpecCell>
              <SpecCell mono>{row.pointer}px</SpecCell>
              <SpecCell mono>{row.touch}px</SpecCell>
              <SpecCell mono className="text-fg-muted">+{row.touch - row.pointer}px</SpecCell>
            </tr>
          ))}
        </SpecTable>
      </Section>

      <Section title="Fixed sizes" description="Icons and avatars keep their size in both densities.">
        <SpecTable label="Fixed sizes" head={["Token", "Value"]}>
          {FIXED.map((row) => (
            <tr key={row.name}>
              <SpecCell mono>{row.name}</SpecCell>
              <SpecCell mono>{row.pointer}px</SpecCell>
            </tr>
          ))}
        </SpecTable>
      </Section>
    </>
  );
}
