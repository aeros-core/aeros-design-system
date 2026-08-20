// Single-entry bundling drops per-file "use client" directives (tsup's rollup
// treeshake pass strips even a configured banner). Without the directive at the
// top of dist/index.js, Next.js App Router consumers crash importing any
// Radix-based component from a Server Component. CI asserts this stays true.
import { readFileSync, writeFileSync } from "node:fs";

const target = new URL("../dist/index.js", import.meta.url);
const src = readFileSync(target, "utf8");
if (!src.startsWith('"use client"')) {
  writeFileSync(target, '"use client";\n' + src);
  console.log('✓ prepended "use client" to dist/index.js');
} else {
  console.log('✓ dist/index.js already starts with "use client"');
}
