import { defineConfig } from "tsup";

export default defineConfig({
  // `cn` is its own entry without "use client", so Server Components can call it.
  entry: { index: "src/index.ts", cn: "src/lib/cn.ts" },
  format: ["esm"],
  dts: false,
  sourcemap: true,
  clean: true,
  external: ["react", "react-dom"],
  treeshake: true
  // NOTE: the rollup treeshake pass strips "use client" directives (and any
  // configured banner). scripts/preserve-use-client.mjs re-prepends it after
  // the build — keep it in the build script.
});
