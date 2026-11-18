import type { Metadata } from "next";
import { notFound } from "next/navigation";
import { ExternalLink } from "lucide-react";
import { COMPONENT_SLUGS, FRAMED_FIXTURES, getComponent, isComponentSlug } from "../../../_registry";
import { FIXTURES } from "../../../preview/_fixtures";
import type { FixtureSlug } from "../../../preview/_fixtures/slugs";
import { CodeBlock } from "../../../_site/code-block";
import { FixtureEmbed } from "../../../_site/fixture-embed";
import { PageIntro, Section } from "../../../_site/prose";

// One page per registry entry. The live examples are the preview fixtures
// themselves — the same components the visual and accessibility suites test —
// so the documentation cannot drift from what is tested.

export const dynamicParams = false;

export function generateStaticParams() {
  return COMPONENT_SLUGS.map((slug) => ({ slug }));
}

export async function generateMetadata({ params }: { params: Promise<{ slug: string }> }): Promise<Metadata> {
  const { slug } = await params;
  return isComponentSlug(slug) ? { title: getComponent(slug).title } : {};
}

/** "drawer-right" on the Drawer page → "Right". */
function fixtureLabel(fixture: FixtureSlug, componentSlug: string, index: number): string {
  if (index === 0 && fixture === componentSlug) return "States and variants";
  const rest = fixture.startsWith(`${componentSlug}-`) ? fixture.slice(componentSlug.length + 1) : fixture;
  const words = rest.replace(/-/g, " ");
  return words.charAt(0).toUpperCase() + words.slice(1);
}

function importLine(names: readonly string[]): string {
  const oneLine = `import { ${names.join(", ")} } from "@aeros-core/react";`;
  if (oneLine.length <= 88) return oneLine;
  return `import {\n${names.map((name) => `  ${name},`).join("\n")}\n} from "@aeros-core/react";`;
}

function Example({ fixture, label, title }: { fixture: FixtureSlug; label: string; title: string }) {
  const frame = FRAMED_FIXTURES[fixture];
  const Fixture = FIXTURES[fixture];
  return (
    <div className="min-w-0">
      <div className="mb-2 flex items-center justify-between gap-3">
        <h3 className="text-h4 text-fg-primary">{label}</h3>
        <a
          href={`/preview/${fixture}`}
          target="_blank"
          rel="noreferrer"
          className="inline-flex shrink-0 items-center gap-1 rounded-item text-caption text-fg-muted transition-colors duration-fast hover:text-fg-primary"
        >
          Open on its own
          <ExternalLink aria-hidden className="size-icon-xs" />
        </a>
      </div>
      {frame ? (
        <FixtureEmbed
          slug={fixture}
          title={`${title} — ${label.toLowerCase()} (live example)`}
          height={frame.height}
          interactive={frame.interactive}
        />
      ) : (
        // A wide example (a data table on a phone) scrolls inside its frame, not the page.
        <div className="min-w-0 overflow-x-auto rounded-surface border border-border-default bg-bg-canvas p-4 md:p-6">
          <Fixture />
        </div>
      )}
    </div>
  );
}

export default async function ComponentPage({ params }: { params: Promise<{ slug: string }> }) {
  const { slug } = await params;
  if (!isComponentSlug(slug)) notFound();
  const doc = getComponent(slug);

  return (
    <>
      <PageIntro section={doc.family}>{doc.description}</PageIntro>

      <Section title="Import">
        <CodeBlock title="Import" code={importLine(doc.imports)} />
      </Section>

      <Section title="Usage">
        <CodeBlock title="Usage" code={doc.usage} />
      </Section>

      <Section
        title="Examples"
        description="Live, and the same fixtures the visual-regression and accessibility suites run against."
      >
        <div className="grid gap-8">
          {doc.fixtures.map((fixture, index) => (
            <Example key={fixture} fixture={fixture} title={doc.title} label={fixtureLabel(fixture, slug, index)} />
          ))}
        </div>
      </Section>
    </>
  );
}
