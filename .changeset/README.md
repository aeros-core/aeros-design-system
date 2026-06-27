# Changesets

This folder is managed by [Changesets](https://github.com/changesets/changesets). It versions and publishes `@aeros-core/tokens` and `@aeros-core/react` to GitHub Packages.

**To record a change:** run `pnpm changeset`, pick the packages and bump type (patch / minor / major), and write a short summary. Commit the generated file in this folder alongside your PR.

`@aeros-core/tokens` and `@aeros-core/react` are **linked** — they move to the same version when either changes. `@aeros-core/react-docs` is private and never published.

See [`docs/releasing.md`](../docs/releasing.md) for the full release flow.
