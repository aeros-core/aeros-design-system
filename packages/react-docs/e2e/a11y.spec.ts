import AxeBuilder from "@axe-core/playwright";
import { expect, test } from "@playwright/test";
import { FIXTURE_SLUGS, THEMES, openFixture } from "./fixture-page";
import { KNOWN_VIOLATIONS, WCAG_TAGS } from "./known-violations";


for (const slug of FIXTURE_SLUGS) {
  for (const theme of THEMES) {
    test(`${slug} · ${theme}`, async ({ page }) => {
      await openFixture(page, slug, theme);

      const { violations } = await new AxeBuilder({ page }).withTags(WCAG_TAGS).analyze();

      const known = new Set(KNOWN_VIOLATIONS[slug]?.[theme] ?? []);
      const found = new Set(violations.map((v) => v.id));

      const unexpected = violations
        .filter((v) => !known.has(v.id))
        .map((v) => ({
          rule: v.id,
          impact: v.impact,
          help: v.help,
          nodes: v.nodes.map((n) => ({ target: n.target.join(" "), summary: n.failureSummary })),
        }));
      const fixed = [...known].filter((id) => !found.has(id));

      expect(unexpected, "new accessibility violations (not in KNOWN_VIOLATIONS)").toEqual([]);
      expect(
        fixed,
        "listed in KNOWN_VIOLATIONS but no longer occurring — delete the entry"
      ).toEqual([]);
    });
  }
}
