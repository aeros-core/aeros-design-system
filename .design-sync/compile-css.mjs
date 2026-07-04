// Compile the Aeros React DS Tailwind v4 stylesheet into a static CSS file for
// design-sync. The DS ships src/styles.css as *source* (tokens @import +
// `@import "tailwindcss"` + @source scanning the component tree + @theme); the
// consuming app normally runs Tailwind. design-sync needs the compiled result
// so preview cards render styled. Output → packages/react/dist/aeros.css, which
// .design-sync/config.json points cfg.cssEntry at.
//
// Run as part of cfg.buildCmd so re-syncs reproduce it. Resolves the Tailwind
// PostCSS plugin + a PostCSS runner from whatever is installed (the repo's own
// react-docs devDeps first, then the design-sync scratch), so it works both in
// this repo and on a fresh clone after `pnpm install`.
import { createRequire } from 'node:module';
import { readFileSync, writeFileSync, mkdirSync } from 'node:fs';
import { dirname, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

const repoRoot = resolve(process.argv[2] || '.');
const inFile = resolve(repoRoot, 'packages/react/src/styles.css');
const outFile = resolve(repoRoot, 'packages/react/dist/aeros.css');

const here = dirname(fileURLToPath(import.meta.url));
const anchors = [
  resolve(repoRoot, 'packages/react-docs/package.json'),
  resolve(repoRoot, 'packages/react/package.json'),
  resolve(here, '../.ds-sync/package.json'),
];
function tryResolve(spec) {
  for (const a of anchors) {
    try {
      const req = createRequire(a);
      return { req, path: req.resolve(spec) };
    } catch { /* try next anchor */ }
  }
  return null;
}

const tw = tryResolve('@tailwindcss/postcss');
if (!tw) throw new Error('compile-css: cannot resolve @tailwindcss/postcss — run `pnpm install`');
const twPlugin = tw.req('@tailwindcss/postcss');

// postcss is a dependency of @tailwindcss/postcss; prefer a top-level resolve,
// else load the copy bundled beside the plugin.
const pc = tryResolve('postcss');
const postcss = pc ? pc.req('postcss') : createRequire(tw.path)('postcss');

// The DS's own styles.css only @source-scans src/components, so the compiled
// CSS would contain just the utilities those components use. Rendered designs
// receive ONLY this pre-compiled CSS (no live Tailwind), so the design agent's
// usable palette = whatever is compiled here. Widen it by also scanning the
// real react-docs app (a realistic superset of Aeros layout/spacing usage) and
// the authored previews, so the agent can actually build grids, spacing, etc.
// @source paths are resolved relative to `from` (packages/react/src/styles.css).
const extraSources = [
  '@source "../../react-docs/app/**/*.{ts,tsx}";',
  '@source "../../../.design-sync/previews/**/*.tsx";',
].join('\n');
const css = readFileSync(inFile, 'utf8') + '\n' + extraSources + '\n';
const result = await postcss([twPlugin()]).process(css, { from: inFile, to: outFile });
mkdirSync(dirname(outFile), { recursive: true });
writeFileSync(outFile, result.css);
console.error(`✓ compile-css: ${outFile} (${(result.css.length / 1024).toFixed(1)} KiB)`);
