import type { Metadata } from "next";
import { tokens } from "@aeros-core/tokens";
import { Code, PageIntro, Section, SpecCell, SpecTable } from "../../../_site/prose";
import { MotionDemo } from "./motion-demo";

export const metadata: Metadata = { title: "Motion" };

type Duration = keyof typeof tokens.motion.duration;
type Ease = keyof typeof tokens.motion.ease;

/** Written out so Tailwind generates each class; typed so a new token cannot be missed. */
const DURATION: Record<Duration, { className: string; use: string }> = {
  quick: { className: "duration-quick", use: "Row highlights in menus and lists, overlay exits." },
  fast: { className: "duration-fast", use: "Hover and press colour changes — the default transition." },
  base: { className: "duration-base", use: "Dialogs, accordions, the sidebar collapsing to its rail." },
  slow: { className: "duration-slow", use: "Large panels entering: drawers and the mobile sheet." },
};

const EASE: Record<Ease, { className: string; use: string }> = {
  standard: { className: "ease-standard", use: "Anything that changes in place: colour, width, position." },
  enter: { className: "ease-enter", use: "Something arriving: it decelerates into its resting place." },
  exit: { className: "ease-exit", use: "Something leaving: it accelerates away." },
};

const DURATIONS = (Object.keys(tokens.motion.duration) as Duration[]).map((name) => ({
  name,
  ms: tokens.motion.duration[name],
  ...DURATION[name],
}));
const EASES = (Object.keys(tokens.motion.ease) as Ease[]).map((name) => ({
  name,
  curve: tokens.motion.ease[name],
  ...EASE[name],
}));

export default function MotionPage() {
  return (
    <>
      <PageIntro section="Foundations">
        Motion is brief and functional. State changes are colour only, so most of it is a {tokens.motion.duration.fast}
        ms fade between two fills. Longer movement is kept for layers that enter or leave, and all of it stops when
        the operating system asks for reduced motion.
      </PageIntro>

      <Section
        title="Try it"
        description="Each bar travels with one duration and the easing you pick. Replay as often as you like."
      >
        <MotionDemo
          durations={DURATIONS.map(({ name, ms }) => ({ name, ms }))}
          eases={EASES.map(({ name }) => name)}
        />
      </Section>

      <Section title="Durations">
        <SpecTable label="Durations" head={["Token", "Class", "Value", "Use"]}>
          {DURATIONS.map((duration) => (
            <tr key={duration.name}>
              <SpecCell mono>{duration.name}</SpecCell>
              <SpecCell mono>{duration.className}</SpecCell>
              <SpecCell mono>{duration.ms}ms</SpecCell>
              <SpecCell className="min-w-56 text-fg-secondary">{duration.use}</SpecCell>
            </tr>
          ))}
        </SpecTable>
      </Section>

      <Section
        title="Easings"
        description={
          <>
            Enter with <Code>ease-enter</Code>, leave with <Code>ease-exit</Code>, and use <Code>ease-standard</Code>{" "}
            for everything else.
          </>
        }
      >
        <SpecTable label="Easings" head={["Token", "Class", "Curve", "Use"]}>
          {EASES.map((ease) => (
            <tr key={ease.name}>
              <SpecCell mono>{ease.name}</SpecCell>
              <SpecCell mono>{ease.className}</SpecCell>
              <SpecCell mono>{ease.curve}</SpecCell>
              <SpecCell className="min-w-56 text-fg-secondary">{ease.use}</SpecCell>
            </tr>
          ))}
        </SpecTable>
      </Section>
    </>
  );
}
