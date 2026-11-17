import type { Metadata } from "next";
import { notFound } from "next/navigation";
import { FIXTURES } from "../_fixtures";
import { FixtureFrame } from "../_fixtures/kit";
import { FIXTURE_SLUGS, type FixtureSlug } from "../_fixtures/slugs";

// Visual-regression fixtures: one chrome-less page per component family.
// Screenshotted by e2e/visual.spec.ts and scanned by e2e/a11y.spec.ts.

export const dynamicParams = false;

export function generateStaticParams() {
  return FIXTURE_SLUGS.map((slug) => ({ slug }));
}

export async function generateMetadata({
  params,
}: {
  params: Promise<{ slug: string }>;
}): Promise<Metadata> {
  const { slug } = await params;
  return { title: `Preview — ${slug}`, robots: { index: false } };
}

export default async function PreviewPage({ params }: { params: Promise<{ slug: string }> }) {
  const { slug } = await params;
  if (!(FIXTURE_SLUGS as readonly string[]).includes(slug)) notFound();
  const Fixture = FIXTURES[slug as FixtureSlug];
  return (
    <FixtureFrame slug={slug}>
      <Fixture />
    </FixtureFrame>
  );
}
