import type { Metadata } from "next";
import { Alert } from "@aeros-core/react";
import { ExternalLink } from "lucide-react";
import { CodeBlock } from "../../_site/code-block";
import { LinkButton } from "../../_site/link-button";
import { Code, PageIntro, Section } from "../../_site/prose";
import { MIGRATION_GUIDE_URL } from "../../_site/routes";

export const metadata: Metadata = { title: "Migrating to 3.0" };

const BEFORE_AFTER = `// 2.x
<Button size="icon-md" variant="danger"><Trash2 /></Button>
<TopNav>…</TopNav>
<div className="rounded-2xl shadow-md">…</div>

// 3.0
<Button size="md" iconOnly variant="danger-subtle" aria-label="Delete"><Trash2 /></Button>
<AppHeader>…</AppHeader>
<div className="rounded-surface border border-border-default">…</div>`;

const CHANGES: Array<{ title: string; body: React.ReactNode }> = [
  {
    title: "Only Aeros tokens compile",
    body: (
      <>
        The theme is generated from <Code>tokens.json</Code> and resets Tailwind&apos;s default palette, radii,
        shadows and easings. <Code>bg-blue-500</Code>, <Code>shadow-2xl</Code> and <Code>ease-out</Code> now generate
        nothing — use the alias classes.
      </>
    ),
  },
  {
    title: "Shadows became three elevation intents",
    body: (
      <>
        The <Code>xs</Code>–<Code>xl</Code> shadow scale is gone. Resting surfaces take a hairline border; floating
        layers use <Code>shadow-raised</Code>, <Code>shadow-overlay</Code> or <Code>shadow-modal</Code>.
      </>
    ),
  },
  {
    title: "Radii are semantic and tighter",
    body: (
      <>
        <Code>2xl</Code>–<Code>4xl</Code> are removed and the scale tightened. Use <Code>rounded-item</Code>,{" "}
        <Code>rounded-control</Code>, <Code>rounded-surface</Code>, <Code>rounded-modal</Code> or{" "}
        <Code>rounded-pill</Code>.
      </>
    ),
  },
  {
    title: "Type is set by role",
    body: (
      <>
        The <Code>.aeros-text-*</Code> classes are removed. <Code>text-body-sm</Code>, <Code>text-h2</Code> and the
        rest set size, line height, tracking and weight in one class.
      </>
    ),
  },
  {
    title: "Fonts are no longer fetched for you",
    body: (
      <>
        <Code>styles.css</Code> does not load Google Fonts. Import <Code>@aeros-core/react/fonts.css</Code> for the
        self-hosted faces, or load them yourself.
      </>
    ),
  },
  {
    title: "Button sizes and variants",
    body: (
      <>
        <Code>size=&quot;icon-md&quot;</Code> becomes <Code>size=&quot;md&quot; iconOnly</Code>. <Code>danger</Code>{" "}
        is now solid; the old tinted look is <Code>danger-subtle</Code>. Every control is one step shorter.
      </>
    ),
  },
  {
    title: "TopNav is AppHeader; the sidebar follows the theme",
    body: (
      <>
        <Code>TopNav*</Code> is renamed <Code>AppHeader*</Code>. The sidebar is no longer permanently dark — put{" "}
        <Code>data-theme=&quot;dark&quot;</Code> on it if you want dark chrome — and its parts now sit inside{" "}
        <Code>SidebarHeader</Code>, <Code>SidebarContent</Code> and <Code>SidebarFooter</Code>.
      </>
    ),
  },
  {
    title: "Field has no margin",
    body: (
      <>
        Spacing between fields is the parent&apos;s decision: wrap them in <Code>FieldGroup</Code>.{" "}
        <Code>TabsContent</Code> lost its top margin for the same reason.
      </>
    ),
  },
  {
    title: "One focus ring",
    body: (
      <>
        Components no longer draw their own ring; the global <Code>:focus-visible</Code> outline does. Remove any{" "}
        <Code>ring-offset-*</Code> overrides you added to match the old one.
      </>
    ),
  },
];

export default function MigrationPage() {
  return (
    <>
      <PageIntro section="Overview">
        3.0 is a redesign, not a patch: every value moved and several names changed. These are the changes most
        likely to need a code edit. The full guide, with every rename and a suggested order of work, lives in the
        repository.
      </PageIntro>

      <Alert variant="info" role="note" title="This page is a summary" className="mb-10 max-w-prose">
        The migration guide in <Code>docs/migration.md</Code> is the reference. Review each app visually after
        upgrading — sizes, radii and colours all shifted.
        <div className="mt-3">
          <LinkButton href={MIGRATION_GUIDE_URL} variant="secondary" size="sm" trailingIcon={<ExternalLink />}>
            Read the full migration guide
          </LinkButton>
        </div>
      </Alert>

      <Section title="Headline breaking changes">
        <ol className="grid gap-px overflow-hidden rounded-surface border border-border-default bg-border-default">
          {CHANGES.map((change, index) => (
            <li key={change.title} className="grid gap-x-4 gap-y-1 bg-bg-surface p-4 sm:grid-cols-[2rem_minmax(0,1fr)]">
              <span className="font-mono text-mono-sm text-fg-muted">{String(index + 1).padStart(2, "0")}</span>
              <div className="min-w-0">
                <h3 className="text-h4 text-fg-primary">{change.title}</h3>
                <p className="mt-1 max-w-prose text-body-sm text-fg-secondary">{change.body}</p>
              </div>
            </li>
          ))}
        </ol>
      </Section>

      <Section title="Before and after" description="Three of the most common edits.">
        <CodeBlock title="Before and after" code={BEFORE_AFTER} />
      </Section>
    </>
  );
}
