# Releasing

How a change becomes a version. `@aeros-core/tokens` and `@aeros-core/react` are versioned and published by [Changesets](https://github.com/changesets/changesets) and GitHub Actions. `aeros_design_system` (Flutter) is versioned by hand in its `pubspec.yaml` and released as a git tag.

## Versions

- `@aeros-core/tokens` and `@aeros-core/react` are **linked**: they always move to the same version (`.changeset/config.json`).
- `aeros_design_system` shares their **major** version. Its minor and patch numbers are its own.
- `@aeros-core/react-docs` is private and never published.

`pnpm check:versions` enforces the first two rules.

### What counts as major, minor, patch

| Bump | When |
|---|---|
| patch | A fix with no visual change |
| minor | A new component, token or prop; a visual refinement that does not move layouts |
| major | A removed or renamed token, class, prop or export; a visual change that shifts layouts (control heights, default radius, default widths, type sizes) |

Treat a layout-shifting change as breaking, so apps adopt it deliberately.

## Recording a change

Every pull request that changes a published package carries a changeset:

```bash
pnpm changeset   # choose the packages and the bump, write the summary
```

Commit the generated file in `.changeset/`. Write the summary for an app developer: what changed and what they must do. Start a line that requires action with **Breaking:**.

A change to the Flutter package is recorded in [`packages/flutter/CHANGELOG.md`](../packages/flutter/CHANGELOG.md) under the unreleased heading, with a "Breaking" subsection when it applies.

A breaking change also needs a row in [migration.md](./migration.md).

## The 3.0 integration branch

The 3.0 work is too large for one pull request and must not publish in pieces. It is collected on the integration branch `next/3.0`:

1. Each step is a pull request into `next/3.0`, with its changeset. CI runs on every pull request, whatever its base.
2. The `Release` workflow runs only on pushes to `main`, so nothing is versioned or published while the work sits on `next/3.0`. The changesets accumulate.
3. When 3.0 is complete, `next/3.0` is merged into `main`. The pending changesets, including the minor and patch ones written before 3.0 began, collapse into one major bump: 3.0.0 for both npm packages.

Before that merge, set the Flutter version to 3.0.0 (see [Releasing the Flutter package](#releasing-the-flutter-package)); `check:versions` fails if the Flutter major differs from the npm major.

## Publishing the npm packages

1. A pull request with changesets is merged to `main`.
2. The [`Release`](../.github/workflows/release.yml) workflow opens or updates a pull request titled "chore: version packages". It consumes the changesets, bumps the versions and writes each package's `CHANGELOG.md`.
3. Merging that pull request publishes. The next `Release` run finds no pending changesets, runs `pnpm release` (build tokens, build React, `changeset publish`) and pushes to GitHub Packages.

Publishing uses the workflow's `GITHUB_TOKEN` with `contents: write`, `pull-requests: write` and `packages: write`. There are no other secrets.

## Releasing the Flutter package

1. Set `version:` in [`packages/flutter/pubspec.yaml`](../packages/flutter/pubspec.yaml).
2. In `packages/flutter/CHANGELOG.md`, replace "(unreleased)" with the date.
3. Merge to `main`.
4. Tag the merge commit `v<pubspec version>` and push the tag:

```bash
git tag "v$(grep '^version:' packages/flutter/pubspec.yaml | awk '{print $2}')"
git push origin --tags
```

Apps pin `ref: v<version>` ([consuming.md](./consuming.md#1-pin-the-package-by-git-tag)), and their Renovate configuration picks up a new tag.

## CI

[`ci.yml`](../.github/workflows/ci.yml) runs four jobs on every pull request and on every push to `main`.

| Job | What it does |
|---|---|
| `web` | Builds tokens and React, then runs the gates below |
| `visual` | Builds the showcase, compares screenshots with the committed baselines, then runs axe |
| `flutter` | `dart analyze lib test`, then `flutter test --exclude-tags golden` |
| `flutter-goldens` | `flutter test --tags golden` against the committed baselines |

Flutter is pinned to one version in `ci.yml`. Golden images are only stable on a fixed engine: bump the version deliberately and regenerate the baselines in the same pull request.

### Gates in the `web` job

| Gate | Enforces |
|---|---|
| `pnpm build:tokens` then `git diff --exit-code` | The generated files are committed fresh: the Dart token files in `packages/flutter/lib/src/tokens/` and the token reference `docs/tokens.md` |
| "use client" assertion | `packages/react/dist/index.js` still starts with `"use client"`. Without it every Radix-based component fails in a Next.js server component |
| `pnpm test:tokens` | The token resolver and every emitter (CSS, Tailwind theme, JS, Dart, docs), against the real `tokens.json` |
| `pnpm lint:react` | ESLint with `jsx-a11y` on the React source |
| `pnpm test:react` | Behaviour tests with Testing Library and `jest-axe` |
| `pnpm check:contrast` | WCAG AA in both themes: every text tier on every surface it is used on (4.5:1), status text on its tint, on the surface and on the canvas (4.5:1), status icons (3:1), the solid danger button resting and hovered, and text over the hover / pressed / selected overlays |
| `pnpm check:hardcoded` | `packages/react/src` uses tokens only. Fails on raw hex or `rgb()`, arbitrary text sizes, radii, shadows, durations and z-indexes, the old `z-(--aeros-…)` forms, raw `ink` / `white` / `black` classes, Tailwind's default palette, scale radius and shadow steps, default text sizes, per-component focus rings, and backdrop blur |
| `pnpm check:flutter-drift` | Every value in `tokens.json` appears in the generated Dart, and the hand-written Flutter token files alias the generated constants with no colour or shadow literals |
| `pnpm check:versions` | tokens and React share one version; Flutter shares their major |

The freshness check for `docs/tokens.md` is one line in the `web` job, after `pnpm build:tokens`:

```yaml
      - name: Assert generated token docs are committed
        run: git diff --exit-code docs/tokens.md
```

`pnpm test:tokens` also compares the committed `docs/tokens.md` with the generator's output, so a stale file fails there too.

All of these run locally with the same commands.

## Image baselines

Two suites compare rendered images with committed baselines:

| Suite | Baselines | Artifact on failure |
|---|---|---|
| React screenshots (`visual` job) | `packages/react-docs/e2e/__screenshots__/linux` | `react-screenshots-linux` |
| Flutter goldens (`flutter-goldens` job) | `packages/flutter/test/golden/goldens/linux` | `flutter-goldens-linux` |

**Linux is the canonical platform.** Text rendering differs between operating systems, so images made on a Mac never match CI. Only the `linux` folders are compared in CI.

**Never generate baselines on a developer machine.** They come from CI.

### Updating baselines after an intended visual change

1. Push the change. The comparing job fails. That is expected.
2. On failure the job regenerates the images on Linux and uploads them as an artifact.
3. Download the artifact for that run:

```bash
gh run download <run-id> -n react-screenshots-linux -D /tmp/react-screenshots
gh run download <run-id> -n flutter-goldens-linux  -D /tmp/flutter-goldens
```

4. Copy the images over the committed baselines. Each artifact holds the baseline folder and a report folder (`playwright-report`, or `failures` with the Flutter diffs); copy only the baselines. Paths inside an artifact start at the common parent of the uploaded folders, so check the layout after downloading:

```bash
cp -R /tmp/react-screenshots/e2e/__screenshots__/linux/. packages/react-docs/e2e/__screenshots__/linux/
cp -R /tmp/flutter-goldens/goldens/linux/.               packages/flutter/test/golden/goldens/linux/
```

5. Review the image diff in the pull request. Every changed image should be one you meant to change.
6. Commit and push. The job passes.

`<run-id>` is in the URL of the failed run, or from `gh run list --branch <branch>`.

A new fixture or scene has no baseline, so its first run fails the same way and is adopted the same way.

### Why the comparison is strict

The screenshot comparison in [`playwright.config.ts`](../packages/react-docs/playwright.config.ts) uses `threshold: 0.01` and `maxDiffPixels: 10`. Playwright's default threshold of 0.2 treats a warm grey becoming a cool grey as no change, and a ratio allowance hides a 2px radius change on a small control. Those are exactly the changes this suite exists to catch. Ten pixels are allowed because one anti-aliased pixel of a rotated icon can differ between two CI runs of identical code.

Screenshots are taken with animations disabled, the caret hidden, a device scale factor of 1, the `en-US` locale and the UTC time zone, at 1280×800 and 390×844, in light and dark.

Flutter goldens load the real bundled fonts and paint real shadows, for light and dark at pointer and touch density.

### Accessibility suite

`pnpm test:a11y` runs axe (WCAG 2.1 A and AA) on every fixture in light and dark. A violation not listed in `KNOWN_VIOLATIONS` in [`a11y.spec.ts`](../packages/react-docs/e2e/a11y.spec.ts) fails. A listed violation that no longer occurs also fails, so the entry must be deleted when the component is fixed. Do not add an entry to make a failure go away.

## Checklist for a release

- [ ] Every change has a changeset or a Flutter changelog entry.
- [ ] Every breaking change has a row in [migration.md](./migration.md).
- [ ] `docs/tokens.md` and the generated Dart are fresh (`pnpm build:tokens`, no diff).
- [ ] [components.md](./components.md) matches the two barrel files.
- [ ] CI is green, with baselines taken from CI.
- [ ] The Flutter `pubspec.yaml` version and changelog date are set, and the tag is pushed after the merge.
