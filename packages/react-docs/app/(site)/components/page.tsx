import type { Metadata } from "next";
import Link from "next/link";
import { Card, CardBody } from "@aeros-core/react";
import { COMPONENT_SLUGS, componentsByFamily, getComponent } from "../../_registry";
import { PageIntro, Section } from "../../_site/prose";
import { componentHref } from "../../_site/routes";

export const metadata: Metadata = { title: "Components" };

/** The first sentence of a description, for the card. */
const firstSentence = (text: string) => text.match(/^.*?[.!?](?=\s|$)/)?.[0] ?? text;

export default function ComponentsIndexPage() {
  return (
    <>
      <PageIntro section="Components">
        {COMPONENT_SLUGS.length} components in <code className="font-mono text-mono-md">@aeros-core/react</code>,
        grouped by what they are for. Each page shows the component in every state, the import line and a usage
        snippet.
      </PageIntro>

      {componentsByFamily().map(({ family, slugs }) => (
        <Section key={family} title={family}>
          <div className="grid gap-3 sm:grid-cols-2 lg:grid-cols-3">
            {slugs.map((slug) => {
              const doc = getComponent(slug);
              return (
                <Link key={slug} href={componentHref(slug)} className="block rounded-surface">
                  <Card interactive className="h-full">
                    <CardBody>
                      <h3 className="text-h4 text-fg-primary">{doc.title}</h3>
                      <p className="mt-1 text-body-sm text-fg-secondary">{firstSentence(doc.description)}</p>
                    </CardBody>
                  </Card>
                </Link>
              );
            })}
          </div>
        </Section>
      ))}
    </>
  );
}
