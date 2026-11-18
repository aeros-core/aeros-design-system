import AxeBuilder from "@axe-core/playwright";
import { expect, test, type Page } from "@playwright/test";
import { COMPONENT_SLUGS, FRAMED_FIXTURES, getComponent } from "../app/_registry";
import { ALL_ROUTES, componentHref, type SiteRoute } from "../app/_site/routes";
import { THEMES, type Theme } from "./fixture-page";
import { KNOWN_VIOLATIONS, WCAG_TAGS } from "./known-violations";

// Smoke + accessibility for the documentation site itself (project "site").
// Every route — the static list plus one page per registry entry — is loaded
// in light and dark and must: log no console error, have exactly one <h1>,
// mark its sidebar row aria-current="page", and pass axe (WCAG 2.1 A/AA) with
// the same strictness as e2e/a11y.spec.ts.

/** Must match app/_site/theme-script.ts. */
const THEME_KEY = "aeros-docs:theme";

/**
 * Violations a page is allowed to have. Same contract as KNOWN_VIOLATIONS: a
 * violation not listed fails; a listed one that no longer occurs also fails.
 *
 * A component page renders that component's preview fixtures, so it inherits
 * their known violations — `inheritedViolations()` derives the list from the
 * registry, and the "inherited violations" test below pins it, so the pages
 * that carry component debt are spelled out here. Today there are none: the
 * two fixtures still listed (`select-open`, `dropdown-menu`) are framed.
 *
 * Only fixtures rendered inline count. A framed fixture is the `/preview/<slug>`
 * document itself, which e2e/a11y.spec.ts already scans at that URL; the scan
 * here stops at the frame boundary (the <iframe> element is still checked).
 *
 * Anything the site's own markup caused would have to be added to
 * SITE_VIOLATIONS. It is empty and should stay that way — fix the page.
 */
const SITE_VIOLATIONS: Record<string, Partial<Record<Theme, string[]>>> = {};

function inheritedViolations(theme: Theme): Record<string, string[]> {
  const byHref: Record<string, string[]> = {};
  for (const slug of COMPONENT_SLUGS) {
    const ids = getComponent(slug)
      .fixtures.filter((fixture) => !FRAMED_FIXTURES[fixture])
      .flatMap((fixture) => KNOWN_VIOLATIONS[fixture]?.[theme] ?? []);
    if (ids.length) byHref[componentHref(slug)] = [...new Set(ids)];
  }
  return byHref;
}

function knownFor(route: SiteRoute, theme: Theme): Set<string> {
  return new Set([...(inheritedViolations(theme)[route.href] ?? []), ...(SITE_VIOLATIONS[route.href]?.[theme] ?? [])]);
}

/** Collects console errors and uncaught exceptions from the page and its frames. */
function recordErrors(page: Page): string[] {
  const errors: string[] = [];
  page.on("console", (message) => {
    if (message.type() === "error") errors.push(`console: ${message.text()}`);
  });
  page.on("pageerror", (error) => errors.push(`pageerror: ${error.message}`));
  return errors;
}

async function openRoute(page: Page, route: SiteRoute, theme: Theme): Promise<void> {
  await page.clock.setFixedTime(new Date("2026-08-14T10:00:00Z"));
  // Through storage, so the pre-paint script is what applies the theme.
  await page.addInitScript(
    ([key, value]) => {
      try {
        window.localStorage.setItem(key!, value!);
      } catch {
        /* storage blocked — the test's theme assertion will say so */
      }
    },
    [THEME_KEY, theme]
  );
  await page.goto(route.href, { waitUntil: "networkidle" });
  await expect(page.locator("html")).toHaveAttribute("data-theme", theme);
  // Hydrated: effects that finish the markup (ids, aria wiring) have run.
  await page.locator('[data-page-ready="true"]').waitFor({ state: "attached" });

  // Framed examples are preview fixtures: wait for each to mount and take the theme.
  for (const frame of page.frames()) {
    if (frame === page.mainFrame()) continue;
    await frame.locator('[data-fixture-ready="true"]').waitFor({ state: "attached" });
    await expect(frame.locator("html")).toHaveAttribute("data-theme", theme);
  }

  for (const frame of page.frames()) {
    await frame.evaluate(async () => {
      await document.fonts.ready;
      const finite = document.getAnimations().filter((a) => a.effect?.getComputedTiming().iterations !== Infinity);
      await Promise.allSettled(finite.map((a) => a.finished));
      await new Promise((resolve) => requestAnimationFrame(() => requestAnimationFrame(resolve)));
    });
  }
}

test("the route list has no duplicates", () => {
  const hrefs = ALL_ROUTES.map((route) => route.href);
  expect(new Set(hrefs).size).toBe(hrefs.length);
});

test("inherited violations are exactly the ones listed above", () => {
  const expected = {};
  for (const theme of THEMES) expect(inheritedViolations(theme), theme).toEqual(expected);
});

for (const route of ALL_ROUTES) {
  for (const theme of THEMES) {
    test(`${route.href} · ${theme}`, async ({ page }) => {
      const errors = recordErrors(page);
      await openRoute(page, route, theme);

      await expect(page.locator("h1")).toHaveCount(1);
      await expect(page.locator("h1")).toHaveText(route.title);

      const current = page.locator('nav[aria-label="Site"] [aria-current="page"]');
      await expect(current).toHaveCount(1);
      await expect(current).toHaveAttribute("href", route.href);

      // options() replaces the builder's options, so it must come before withTags().
      const { violations } = await new AxeBuilder({ page })
        .options({ iframes: false })
        .withTags(WCAG_TAGS)
        .analyze();
      const known = knownFor(route, theme);
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

      expect(unexpected, "new accessibility violations (not inherited from a fixture)").toEqual([]);
      expect(fixed, "inherited from a fixture's KNOWN_VIOLATIONS but no longer occurring — update the list").toEqual([]);
      expect(errors, "console errors").toEqual([]);
    });
  }
}

test.describe("at 390px", () => {
  test.use({ viewport: { width: 390, height: 844 } });

  for (const route of ALL_ROUTES) {
    test(`${route.href} · no horizontal overflow`, async ({ page }) => {
      await openRoute(page, route, "light");
      const { scrollWidth, clientWidth } = await page.evaluate(() => ({
        scrollWidth: document.documentElement.scrollWidth,
        clientWidth: document.documentElement.clientWidth,
      }));
      expect(scrollWidth, "the page is wider than the viewport").toBeLessThanOrEqual(clientWidth);
    });
  }

  test("the sidebar is a sheet that opens from the header and closes on navigation", async ({ page }) => {
    await openRoute(page, ALL_ROUTES[0]!, "light");
    const nav = page.locator('nav[aria-label="Site"]');
    await expect(nav).toBeHidden();

    await page.getByRole("button", { name: "Toggle sidebar" }).click();
    await expect(nav).toBeVisible();
    await expect(nav.locator('[aria-current="page"]')).toHaveAttribute("href", "/");

    await nav.getByRole("link", { name: "Typography" }).click();
    await expect(page).toHaveURL(/\/foundations\/typography$/);
    await expect(page.locator("h1")).toHaveText("Typography");
    await expect(nav).toBeHidden();
  });
});

test("the sidebar collapses to a rail and keeps the current page marked", async ({ page }) => {
  await openRoute(page, ALL_ROUTES[0]!, "light");
  const nav = page.locator('nav[aria-label="Site"]');
  const expanded = (await nav.boundingBox())!.width;

  await page.getByRole("button", { name: "Toggle sidebar" }).click();
  await expect(nav).toHaveAttribute("data-collapsed", "true");
  await expect.poll(async () => (await nav.boundingBox())!.width).toBeLessThan(expanded / 2);
  await expect(nav.locator('[aria-current="page"]')).toHaveAttribute("href", "/");
  // In the rail a label is still there for assistive tech, but takes no room.
  await expect(nav.getByRole("link", { name: "Typography" })).toBeVisible();
});

test("the theme and density switches set the attributes on <html> and persist", async ({ page }) => {
  await page.goto("/", { waitUntil: "networkidle" });
  await page.locator('[data-page-ready="true"]').waitFor({ state: "attached" });
  const html = page.locator("html");
  await expect(html).toHaveAttribute("data-theme", "system");

  await page.getByRole("radio", { name: "Dark" }).click();
  await expect(html).toHaveAttribute("data-theme", "dark");
  await page.getByRole("radio", { name: "Touch density" }).click();
  await expect(html).toHaveAttribute("data-density", "touch");

  await page.reload({ waitUntil: "networkidle" });
  await page.locator('[data-page-ready="true"]').waitFor({ state: "attached" });
  await expect(html).toHaveAttribute("data-theme", "dark");
  await expect(html).toHaveAttribute("data-density", "touch");
  await expect(page.getByRole("radio", { name: "Dark" })).toBeChecked();
});
