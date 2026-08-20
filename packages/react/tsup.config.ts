import { defineConfig } from "tsup";

export default defineConfig({
  entry: ["src/index.ts"],
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
