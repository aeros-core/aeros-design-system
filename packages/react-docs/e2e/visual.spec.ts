import { expect, test } from "@playwright/test";
import { FIXTURE_SLUGS, THEMES, builtFixtureSlugs, openFixture } from "./fixture-page";

// One full-page screenshot per fixture × theme, per viewport project
// (desktop 1280×800, mobile 390×844 — see playwright.config.ts).
// Baselines: e2e/__screenshots__/{platform}/{project}/{slug}-{theme}.png

test("every exported preview page is in the fixture registry", () => {
  expect(builtFixtureSlugs()).toEqual([...FIXTURE_SLUGS].sort());
});

for (const slug of FIXTURE_SLUGS) {
  for (const theme of THEMES) {
    test(`${slug} · ${theme}`, async ({ page }) => {
      await openFixture(page, slug, theme);
      await expect(page).toHaveScreenshot(`${slug}-${theme}.png`, { fullPage: true });
    });
  }
}
