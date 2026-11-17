import { readdirSync } from "node:fs";
import path from "node:path";
import { expect, type Page } from "@playwright/test";
import { FIXTURE_SLUGS, type FixtureSlug } from "../app/preview/_fixtures/slugs";

export { FIXTURE_SLUGS, type FixtureSlug };

export const THEMES = ["light", "dark"] as const;
export type Theme = (typeof THEMES)[number];

/** Web fonts the docs site self-hosts; a fixture must never be captured in a fallback face. */
const REQUIRED_FONT_FAMILIES = ["Inter", "IBM Plex Mono"];

/**
 * Navigate to a fixture and settle it: theme applied, fonts loaded, network
 * idle, React mounted, and every finite (enter) animation finished.
 */
export async function openFixture(page: Page, slug: FixtureSlug, theme: Theme): Promise<void> {
  // Belt and braces — fixtures pin their own dates, this pins `new Date()` too.
  await page.clock.setFixedTime(new Date("2026-08-14T10:00:00Z"));

  await page.goto(`/preview/${slug}`, { waitUntil: "networkidle" });
  await page.evaluate((t) => {
    document.documentElement.dataset.theme = t;
  }, theme);

  await page.locator(`[data-fixture="${slug}"][data-fixture-ready="true"]`).waitFor({ state: "attached" });
  await page.evaluate(() => document.fonts.ready);
  await page.waitForLoadState("networkidle");

  const fonts = await page.evaluate(() =>
    Array.from(document.fonts, (f) => ({ family: f.family.replace(/["']/g, ""), status: f.status }))
  );
  expect(
    fonts.filter((f) => f.status === "error"),
    "a web font failed to load"
  ).toEqual([]);
  const families = new Set(fonts.map((f) => f.family));
  for (const family of REQUIRED_FONT_FAMILIES) {
    expect(families, `@font-face for ${family} is missing`).toContain(family);
  }

  // Overlays fade/zoom/slide in on mount. Wait for those to end so neither the
  // screenshot nor axe's colour-contrast check sees a half-transparent frame.
  // Infinite animations (spinner, skeleton, dot-matrix) never finish — skip them.
  await page.evaluate(async () => {
    const finite = document
      .getAnimations()
      .filter((a) => a.effect?.getComputedTiming().iterations !== Infinity);
    await Promise.allSettled(finite.map((a) => a.finished));
    await new Promise((resolve) => requestAnimationFrame(() => requestAnimationFrame(resolve)));
  });
}

/**
 * The registry is the source of truth, but check the build agrees with it:
 * every slug was exported, and nothing was exported that the specs don't cover.
 */
export function builtFixtureSlugs(): string[] {
  const dir = path.join(__dirname, "..", "out", "preview");
  return readdirSync(dir)
    .filter((f) => f.endsWith(".html"))
    .map((f) => f.replace(/\.html$/, ""))
    .sort();
}
