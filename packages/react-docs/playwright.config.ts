import { defineConfig } from "@playwright/test";

// Visual-regression + accessibility safety net for @aeros-core/react.
// Serves the static export in ./out — build it first (see README.md).

const PORT = Number(process.env.PREVIEW_PORT ?? 4173);
const BASE_URL = `http://localhost:${PORT}`;

export default defineConfig({
  testDir: "./e2e",
  outputDir: "./test-results",
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: 0,
  reporter: [["list"], ["html", { open: "never", outputFolder: "playwright-report" }]],

  // Linux is the canonical platform: only e2e/__screenshots__/linux is
  // committed (darwin/win32 baselines are git-ignored local scratch).
  snapshotPathTemplate: "{testDir}/__screenshots__/{platform}/{projectName}/{arg}{ext}",

  expect: {
    toHaveScreenshot: {
      animations: "disabled",
      caret: "hide",
      scale: "css",
      // Strict on purpose. Playwright's defaults (threshold 0.2) treat a subtle
      // colour shift — e.g. a warm grey becoming a cool grey — as "no change",
      // and a ratio allowance hides a 2px radius change on a small control.
      // A handful of pixels is allowed: on Linux CI one anti-aliased pixel of a
      // rotated icon can differ between two runs of identical code.
      threshold: 0.01,
      maxDiffPixels: 10,
    },
  },

  use: {
    baseURL: BASE_URL,
    browserName: "chromium",
    deviceScaleFactor: 1,
    locale: "en-US",
    timezoneId: "UTC",
    colorScheme: "light", // the theme is driven by data-theme, not the OS setting
  },

  projects: [
    {
      name: "desktop",
      testMatch: /visual\.spec\.ts$/,
      use: { viewport: { width: 1280, height: 800 } },
    },
    {
      name: "mobile",
      testMatch: /visual\.spec\.ts$/,
      use: { viewport: { width: 390, height: 844 } },
    },
    {
      name: "a11y",
      testMatch: /a11y\.spec\.ts$/,
      use: { viewport: { width: 1280, height: 800 } },
    },
    {
      // The documentation site itself: every route, smoke + axe (e2e/site.spec.ts).
      name: "site",
      testMatch: /site\.spec\.ts$/,
      use: { viewport: { width: 1280, height: 800 } },
    },
  ],

  webServer: {
    // `serve` maps /preview/button → out/preview/button.html (clean URLs).
    command: `pnpm exec serve out --listen ${PORT} --no-clipboard --no-request-logging --no-port-switching`,
    url: `${BASE_URL}/preview/button`,
    reuseExistingServer: !process.env.CI,
    timeout: 30_000,
  },
});
