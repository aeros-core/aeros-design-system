# Releasing

Versioning and publishing run on [Changesets](https://github.com/changesets/changesets) + GitHub Actions. `@aeros-core/tokens` and `@aeros-core/react` publish to **GitHub Packages**; they are **linked** (same version when either changes). `@aeros-core/react-docs` is private and never published.

## Cutting a web release

1. **Record the change** in your feature PR:
   ```bash
   pnpm changeset      # pick packages + bump (patch/minor/major), write a summary
   ```
   Commit the generated file in `.changeset/`.

2. **Merge the PR to `main`.** The [`Release`](../.github/workflows/release.yml) workflow opens (or updates) a **"chore: version packages"** PR that consumes the changesets, bumps versions, and writes `CHANGELOG.md`s.

3. **Merge the "version packages" PR.** The next `Release` run finds no pending changesets and **publishes** the bumped packages to GitHub Packages, and pushes git tags (`@aeros-core/react@x.y.z`).

No tokens or secrets to manage — publishing uses the workflow's `GITHUB_TOKEN` (`packages: write`).

### One-time repo setup
- GitHub Packages is enabled for the `aeros-core` org (default).
- Actions has `contents: write` + `pull-requests: write` + `packages: write` (declared in the workflow). If org settings restrict the default `GITHUB_TOKEN`, allow these scopes.

## Cutting a Flutter release

The Flutter package versions in [`packages/flutter/pubspec.yaml`](../packages/flutter/pubspec.yaml). After a web release (or independently), tag the repo so apps can pin it:

```bash
git tag v$(node -p "require('./packages/react/package.json').version")
git push origin --tags
```

Consumers pin `ref: vX.Y.Z` (see [consuming.md](./consuming.md)); the Renovate custom manager there bumps that `ref` when a new `vX.Y.Z` tag appears.

## Versioning rules

- **patch** — bug fix, no visual change.
- **minor** — new component/token, or a visual refinement that doesn't break existing layouts.
- **major** — removed/renamed token or prop, or a visual change that will shift consumer layouts (e.g. control-height or default-radius changes). Treat layout-affecting DS changes as breaking so apps opt in deliberately.
