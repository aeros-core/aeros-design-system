import type { Metadata } from "next";
import { tokens } from "@aeros-core/tokens";
import { Code, PageIntro, Section, SpecCell, SpecTable } from "../../../_site/prose";

export const metadata: Metadata = { title: "Elevation" };

type Intent = keyof typeof tokens.elevation.light;

/** Written out so Tailwind generates each class; typed so a new intent cannot be missed. */
const INTENT: Record<Intent, { className: string; use: string }> = {
  raised: {
    className: "shadow-raised",
    use: "A control that sits a hair above its track: the active segment of a segmented control.",
  },
  overlay: {
    className: "shadow-overlay",
    use: "Layers anchored to a trigger: menus, selects, popovers, tooltips, toasts.",
  },
  modal: {
    className: "shadow-modal",
    use: "Layers that take over the page: dialogs, drawers, the mobile sidebar sheet.",
  },
};

const INTENTS = Object.keys(tokens.elevation.light) as Intent[];

function Panel({ theme }: { theme: "light" | "dark" }) {
  return (
    <div data-theme={theme} className="rounded-surface border border-border-default bg-bg-canvas p-4 text-fg-primary md:p-6">
      <div className="text-caption text-fg-muted">{theme === "light" ? "Light" : "Dark"}</div>
      <div className="mt-4 grid gap-6 sm:grid-cols-2">
        <div className="flex h-24 items-end rounded-surface border border-border-default bg-bg-surface p-3">
          <div>
            <div className="text-label-sm">Resting</div>
            <div className="font-mono text-mono-xs text-fg-muted">border, no shadow</div>
          </div>
        </div>
        {INTENTS.map((intent) => (
          <div key={intent} className={`flex h-24 items-end rounded-surface bg-bg-elevated p-3 ${INTENT[intent].className}`}>
            <div>
              <div className="text-label-sm capitalize">{intent}</div>
              <div className="font-mono text-mono-xs text-fg-muted">{INTENT[intent].className}</div>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}

export default function ElevationPage() {
  return (
    <>
      <PageIntro section="Foundations">
        Most of the interface is flat. A resting surface — a card, a table, the sidebar — is separated from the
        canvas by a hairline and nothing else. Shadow is kept for layers that really float, and there are exactly{" "}
        {INTENTS.length} of them, named for what they are used for.
      </PageIntro>

      <Section
        title="Intents"
        description={
          <>
            A floating layer is <Code>bg-bg-elevated</Code> plus an elevation class. The overlay and modal shadows
            carry their own one-pixel edge, so a floating surface never takes a border class. In the dark theme that
            edge is light and the fill is a step lighter than the page, because a shadow alone disappears on
            near-black.
          </>
        }
      >
        <div className="grid gap-4 lg:grid-cols-2">
          <Panel theme="light" />
          <Panel theme="dark" />
        </div>
      </Section>

      <Section title="Values" description="Generated from the tokens for each theme.">
        <SpecTable label="Elevation values" head={["Intent", "Use", "Light", "Dark"]}>
          {INTENTS.map((intent) => (
            <tr key={intent}>
              <SpecCell mono>{INTENT[intent].className}</SpecCell>
              <SpecCell className="min-w-56 text-fg-secondary">{INTENT[intent].use}</SpecCell>
              <SpecCell className="min-w-64 font-mono text-mono-xs">{tokens.elevation.light[intent]}</SpecCell>
              <SpecCell className="min-w-64 font-mono text-mono-xs">{tokens.elevation.dark[intent]}</SpecCell>
            </tr>
          ))}
        </SpecTable>
      </Section>
    </>
  );
}
