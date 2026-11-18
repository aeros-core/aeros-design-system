import type { Metadata } from "next";
import { tokens } from "@aeros-core/tokens";
import { Code, PageIntro, Section, SpecCell, SpecTable } from "../../../_site/prose";

export const metadata: Metadata = { title: "Typography" };

type Role = keyof typeof tokens.text;

/** Joins class names. (`cn` from @aeros-core/react is client-only; nothing here conflicts.) */
const cx = (...classes: Array<string | false | undefined>) => classes.filter(Boolean).join(" ");

/**
 * role → its utility class, written out so Tailwind generates each one.
 * Typed against the tokens: a new role without a class here fails the build.
 */
const ROLE_CLASS: Record<Role, string> = {
  "display-xl": "text-display-xl",
  "display-lg": "text-display-lg",
  "display-md": "text-display-md",
  h1: "text-h1",
  h2: "text-h2",
  h3: "text-h3",
  h4: "text-h4",
  "title-lg": "text-title-lg",
  "body-lg": "text-body-lg",
  "body-md": "text-body-md",
  "body-sm": "text-body-sm",
  "label-md": "text-label-md",
  "label-sm": "text-label-sm",
  "label-xs": "text-label-xs",
  caption: "text-caption",
  overline: "text-overline",
  "mono-lg": "text-mono-lg",
  "mono-md": "text-mono-md",
  "mono-sm": "text-mono-sm",
  "mono-xs": "text-mono-xs",
};

const SAMPLE: Array<{ match: (role: string) => boolean; text: string }> = [
  { match: (role) => role.startsWith("display"), text: "Run everything." },
  { match: (role) => /^h\d$/.test(role) || role.startsWith("title"), text: "Pending approvals" },
  { match: (role) => role.startsWith("body"), text: "Orders cleared by QC before 2 pm ship the same day." },
  { match: (role) => role.startsWith("label"), text: "Delivery date" },
  { match: (role) => role === "caption", text: "Updated 3 minutes ago" },
  { match: (role) => role === "overline", text: "Section label" },
  { match: (role) => role.startsWith("mono"), text: "PO-1042 · ₹1,24,000" },
];

const ROLES = (Object.keys(tokens.text) as Role[]).map((role) => {
  const spec = tokens.text[role] as {
    size: number;
    weight: number;
    lineHeight: number;
    tracking: string;
    family?: string;
    transform?: string;
  };
  return {
    role,
    spec,
    className: cx(ROLE_CLASS[role], spec.family === "mono" && "font-mono", spec.transform === "uppercase" && "uppercase"),
    sample: SAMPLE.find((entry) => entry.match(role))?.text ?? "The quick brown fox",
  };
});

const WEIGHTS = Object.entries(tokens.font.weight);

export default function TypographyPage() {
  return (
    <>
      <PageIntro section="Foundations">
        Type is set by role, not by size. One class — <Code>text-body-sm</Code>, <Code>text-h2</Code> — sets the
        size, line height, tracking and weight together, so two pieces of text with the same job always look the
        same.
      </PageIntro>

      <Section
        title="Families"
        description="Inter for the interface, IBM Plex Mono for anything a computer produced, and Nunito Sans at its widest for the wordmark alone."
      >
        <div className="grid gap-px overflow-hidden rounded-surface border border-border-default bg-border-default md:grid-cols-3">
          <div className="bg-bg-surface p-4">
            <div className="text-caption text-fg-muted">Interface · font-sans</div>
            <div className="mt-2 text-display-md text-fg-primary">Inter</div>
            <div className="mt-2 break-words font-mono text-mono-xs text-fg-muted">{tokens.font.family.sans}</div>
          </div>
          <div className="bg-bg-surface p-4">
            <div className="text-caption text-fg-muted">Data · font-mono</div>
            <div className="mt-2 font-mono text-display-md font-normal text-fg-primary">Plex Mono</div>
            <div className="mt-2 break-words font-mono text-mono-xs text-fg-muted">{tokens.font.family.mono}</div>
          </div>
          <div className="bg-bg-surface p-4">
            <div className="text-caption text-fg-muted">Wordmark · aeros-logo</div>
            <div className="aeros-logo mt-2 text-display-md text-fg-primary">Aeros</div>
            <div className="mt-2 break-words font-mono text-mono-xs text-fg-muted">{tokens.font.family.logo}</div>
          </div>
        </div>
        <p className="mt-3 text-body-sm text-fg-secondary">
          Weights:{" "}
          {WEIGHTS.map(([name, value], index) => (
            <span key={name}>
              {index > 0 && " · "}
              {name} <span className="font-mono text-mono-sm text-fg-primary">{value}</span>
            </span>
          ))}
          . Body text is 450 — a touch sturdier than regular.
        </p>
      </Section>

      <Section title="Roles" description="Each sample is rendered in its own class.">
        <div className="overflow-hidden rounded-surface border border-border-default bg-bg-surface">
          {ROLES.map(({ role, spec, className, sample }) => (
            <div
              key={role}
              className="grid gap-x-6 gap-y-1 border-b border-border-default px-4 py-3 last:border-b-0 md:grid-cols-[14rem_minmax(0,1fr)] md:items-baseline"
            >
              <div className="min-w-0">
                <div className="font-mono text-mono-sm text-fg-primary">{ROLE_CLASS[role]}</div>
                <div className="mt-0.5 font-mono text-mono-xs text-fg-muted">
                  {spec.size}/{Math.round(spec.size * spec.lineHeight)} · {spec.weight} · {spec.tracking}
                </div>
              </div>
              <div className={cx("min-w-0 break-words text-fg-primary", className)}>{sample}</div>
            </div>
          ))}
        </div>
      </Section>

      <Section title="Specification" description="Size and line height in pixels at the default root size.">
        <SpecTable label="Type roles" head={["Role", "Size", "Line height", "Weight", "Tracking", "Family"]}>
          {ROLES.map(({ role, spec }) => (
            <tr key={role}>
              <SpecCell mono>{role}</SpecCell>
              <SpecCell mono>{spec.size}px</SpecCell>
              <SpecCell mono>
                {Math.round(spec.size * spec.lineHeight)}px <span className="text-fg-muted">({spec.lineHeight})</span>
              </SpecCell>
              <SpecCell mono>{spec.weight}</SpecCell>
              <SpecCell mono>{spec.tracking}</SpecCell>
              <SpecCell mono>
                {spec.family ?? "sans"}
                {spec.transform ? ` · ${spec.transform}` : ""}
              </SpecCell>
            </tr>
          ))}
        </SpecTable>
      </Section>
    </>
  );
}
