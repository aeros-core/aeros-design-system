import type { Metadata } from "next";
import { rawTokens, tokens } from "@aeros-core/tokens";
import { Code, PageIntro, Section, SpecCell, SpecTable, SubHeading, Swatch } from "../../../_site/prose";

export const metadata: Metadata = { title: "Color" };

// Everything on this page is read from @aeros-core/tokens at build time.

const INK = Object.entries(tokens.color.ink)
  .map(([stop, token]) => ({ stop, value: token.$value }))
  .sort((a, b) => Number(a.stop) - Number(b.stop));

type AliasName = keyof typeof tokens.alias.light;
const ALIASES = Object.keys(tokens.alias.light) as AliasName[];

const ALIAS_GROUPS: Array<{ title: string; match: (name: string) => boolean }> = [
  { title: "Backgrounds", match: (name) => name.startsWith("bg-") },
  { title: "Text", match: (name) => name.startsWith("fg-") },
  { title: "Borders", match: (name) => name.startsWith("border-") },
  { title: "Brand and focus", match: (name) => name.startsWith("brand-") || name.startsWith("focus-") },
  { title: "State overlays and scrim", match: (name) => name.startsWith("state-") || name === "scrim" },
];
const UNGROUPED = ALIASES.filter((name) => !ALIAS_GROUPS.some((group) => group.match(name)));

/** "{color.ink.900 / 0.05}" → "ink-900 / 0.05" */
const reference = (raw: string) => raw.replace(/^\{|\}$/g, "").replace(/^color\.ink\./, "ink-").replace(/^color\./, "");

const STATUSES = ["success", "warning", "danger", "info"] as const;
const STATUS_PARTS = ["", "-bg", "-text", "-border"] as const;
type SemanticName = keyof typeof tokens.color.semantic;

/** Static class names so Tailwind generates them. */
const STATUS_CLASS: Record<(typeof STATUSES)[number], { chip: string; solid: string }> = {
  success: { chip: "border-success-border bg-success-bg text-success-text", solid: "bg-success" },
  warning: { chip: "border-warning-border bg-warning-bg text-warning-text", solid: "bg-warning" },
  danger: { chip: "border-danger-border bg-danger-bg text-danger-text", solid: "bg-danger" },
  info: { chip: "border-info-border bg-info-bg text-info-text", solid: "bg-info" },
};

function AliasRows({ names }: { names: AliasName[] }) {
  return (
    <>
      {names.map((name) => (
        <tr key={name}>
          <SpecCell mono>{name}</SpecCell>
          <SpecCell mono className="text-fg-secondary">{reference(rawTokens.alias.light[name])}</SpecCell>
          <SpecCell mono>
            <span className="inline-flex items-center gap-2">
              <Swatch color={tokens.alias.light[name]} />
              {tokens.alias.light[name]}
            </span>
          </SpecCell>
          <SpecCell mono className="text-fg-secondary">{reference(rawTokens.alias.dark[name])}</SpecCell>
          <SpecCell mono>
            <span className="inline-flex items-center gap-2">
              <Swatch color={tokens.alias.dark[name]} />
              {tokens.alias.dark[name]}
            </span>
          </SpecCell>
        </tr>
      ))}
    </>
  );
}

function StatusPanel({ theme }: { theme: "light" | "dark" }) {
  return (
    <div data-theme={theme} className="rounded-surface border border-border-default bg-bg-surface p-4 text-fg-primary">
      <div className="text-caption text-fg-muted">{theme === "light" ? "Light" : "Dark"}</div>
      <div className="mt-3 grid gap-2">
        {STATUSES.map((status) => (
          <div key={status} className="flex items-center gap-3">
            <span aria-hidden className={`size-3 shrink-0 rounded-pill ${STATUS_CLASS[status].solid}`} />
            <span className={`inline-flex h-6 items-center rounded-pill border px-2 text-label-xs ${STATUS_CLASS[status].chip}`}>
              {status}
            </span>
            <span className="text-body-sm text-fg-secondary">on the surface</span>
          </div>
        ))}
      </div>
    </div>
  );
}

export default function ColorPage() {
  return (
    <>
      <PageIntro section="Foundations">
        Aeros is monochrome. One neutral ramp — ink — supplies every surface, border and text colour through
        theme-aware aliases. The only hues in the system are the four status sets, and they are reserved for state.
      </PageIntro>

      <Section
        title="Ink ramp"
        description={
          <>
            {INK.length} stops from white to near-black. Components never use a stop directly — they use an alias,
            which points at a different stop in each theme.
          </>
        }
      >
        <div className="overflow-hidden rounded-surface border border-border-default bg-bg-surface">
          {/* Cells draw their own right and bottom hairline; the negative margin tucks the outer ones under the frame. */}
          <div className="-mb-px -mr-px grid grid-cols-2 sm:grid-cols-4 lg:grid-cols-7">
            {INK.map(({ stop, value }) => (
              <div key={stop} className="border-b border-r border-border-default">
                <div className="h-14 border-b border-border-default" style={{ background: `var(--aeros-color-ink-${stop})` }} />
                <div className="px-3 py-2">
                  <div className="text-label-sm text-fg-primary">ink-{stop}</div>
                  <div className="font-mono text-mono-xs text-fg-muted">{value}</div>
                </div>
              </div>
            ))}
          </div>
        </div>
      </Section>

      <Section
        title="Aliases"
        description={
          <>
            The names components are written in: <Code>bg-bg-surface</Code>, <Code>text-fg-muted</Code>,{" "}
            <Code>border-border-default</Code>. Each row shows the reference the alias holds in <Code>tokens.json</Code>{" "}
            and the value it resolves to, per theme. A reference with a slash is that stop at an opacity.
          </>
        }
      >
        <div className="grid gap-6">
          {[...ALIAS_GROUPS, ...(UNGROUPED.length ? [{ title: "Other", match: (name: string) => (UNGROUPED as string[]).includes(name) }] : [])].map(
            (group) => (
              <div key={group.title} className="min-w-0">
                <SubHeading className="mb-2">{group.title}</SubHeading>
                <SpecTable
                  label={`${group.title} aliases`}
                  head={["Alias", "Light reference", "Light value", "Dark reference", "Dark value"]}
                >
                  <AliasRows names={ALIASES.filter((name) => group.match(name))} />
                </SpecTable>
              </div>
            )
          )}
        </div>
      </Section>

      <Section
        title="Status"
        description="Success, warning, danger and info each come as a set: a solid, a tinted background, a text colour that passes contrast on that tint, and a border. Info is neutral grey — there is no blue."
      >
        <div className="grid gap-4 md:grid-cols-2">
          <StatusPanel theme="light" />
          <StatusPanel theme="dark" />
        </div>
        <div className="mt-4">
          <SpecTable label="Status colour values" head={["Token", "Light", "Dark"]}>
            {STATUSES.flatMap((status) =>
              STATUS_PARTS.map((part) => {
                const name = `${status}${part}` as SemanticName;
                return (
                  <tr key={name}>
                    <SpecCell mono>{name}</SpecCell>
                    <SpecCell mono>
                      <span className="inline-flex items-center gap-2">
                        <Swatch color={tokens.color.semantic[name].$value} />
                        {tokens.color.semantic[name].$value}
                      </span>
                    </SpecCell>
                    <SpecCell mono>
                      <span className="inline-flex items-center gap-2">
                        <Swatch color={tokens.color.semanticDark[name].$value} />
                        {tokens.color.semanticDark[name].$value}
                      </span>
                    </SpecCell>
                  </tr>
                );
              })
            )}
          </SpecTable>
        </div>
      </Section>
    </>
  );
}
