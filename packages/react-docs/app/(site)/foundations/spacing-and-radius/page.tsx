import type { Metadata } from "next";
import { rawTokens, tokens } from "@aeros-core/tokens";
import { Code, PageIntro, Section, SpecCell, SpecTable } from "../../../_site/prose";

export const metadata: Metadata = { title: "Spacing and radius" };

const SPACE = Object.entries(tokens.space)
  .map(([step, px]) => ({ step, px }))
  .sort((a, b) => a.px - b.px);

const RADIUS = Object.entries(tokens.radius).map(([step, px]) => ({ step, px }));

type Shape = keyof typeof tokens.shape;

/** Written out so Tailwind generates each class; typed so a new shape cannot be missed. */
const SHAPE: Record<Shape, { className: string; use: string }> = {
  item: { className: "rounded-item", use: "Rows inside a container: menu items, nav rows, segments, inline code." },
  control: { className: "rounded-control", use: "Anything you click or type in: buttons, fields, chips." },
  surface: { className: "rounded-surface", use: "Cards, tables, popovers and menus." },
  modal: { className: "rounded-modal", use: "Dialogs — the largest floating surface." },
  pill: { className: "rounded-pill", use: "Badges, counts, avatars and switches." },
};

const reference = (raw: string) => raw.replace(/^\{|\}$/g, "");
const px = (value: number) => (value >= 9999 ? "full" : `${value}px`);

export default function SpacingAndRadiusPage() {
  return (
    <>
      <PageIntro section="Foundations">
        Space is a 4-based scale with a few half steps for tight control interiors. Radius is tight and chosen by
        role: you pick what the thing is — a row, a control, a surface — and the token decides the number.
      </PageIntro>

      <Section
        title="Spacing scale"
        description={
          <>
            The Tailwind spacing utilities map straight onto it: <Code>gap-2</Code> is {tokens.space[2]}px,{" "}
            <Code>p-4</Code> is {tokens.space[4]}px.
          </>
        }
      >
        <div className="overflow-hidden rounded-surface border border-border-default bg-bg-surface">
          {SPACE.map(({ step, px: value }) => (
            <div
              key={step}
              className="grid grid-cols-[3rem_3.5rem_minmax(0,1fr)] items-center gap-3 border-b border-border-subtle px-4 py-1.5 last:border-b-0"
            >
              <span className="font-mono text-mono-sm text-fg-primary">{step}</span>
              <span className="font-mono text-mono-sm text-fg-muted">{value}px</span>
              <span className="min-w-0 overflow-hidden">
                <span aria-hidden className="block h-3 rounded-item bg-bg-inverse" style={{ width: value }} />
              </span>
            </div>
          ))}
        </div>
      </Section>

      <Section
        title="Semantic radii"
        description="Use these in components. A 4px row radius nests inside an 8px surface with 4px of padding, which is why menus look aligned."
      >
        <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-5">
          {(Object.keys(tokens.shape) as Shape[]).map((shape) => (
            <div key={shape} className="rounded-surface border border-border-default bg-bg-surface p-4">
              <div
                aria-hidden
                className={`h-16 border border-border-strong bg-bg-subtle ${SHAPE[shape].className}`}
              />
              <div className="mt-3 font-mono text-mono-sm text-fg-primary">{SHAPE[shape].className}</div>
              <div className="mt-0.5 font-mono text-mono-xs text-fg-muted">
                {px(tokens.shape[shape])} · {reference(rawTokens.shape[shape])}
              </div>
              <p className="mt-2 text-caption text-fg-secondary">{SHAPE[shape].use}</p>
            </div>
          ))}
        </div>
      </Section>

      <Section
        title="Radius scale"
        description="The raw scale the semantic radii point at. It exists for the token pipeline; reach for a semantic radius in product code."
      >
        <SpecTable label="Radius scale" head={["Step", "Value", "Sample"]}>
          {RADIUS.map(({ step, px: value }) => (
            <tr key={step}>
              <SpecCell mono>{step}</SpecCell>
              <SpecCell mono>{px(value)}</SpecCell>
              <SpecCell>
                <span
                  aria-hidden
                  className="block h-8 w-16 border border-border-strong bg-bg-subtle"
                  style={{ borderRadius: `var(--aeros-radius-${step})` }}
                />
              </SpecCell>
            </tr>
          ))}
        </SpecTable>
      </Section>
    </>
  );
}
