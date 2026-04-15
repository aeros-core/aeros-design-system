import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  // Build as a static site (HTML in ./out) so Vercel can serve this
  // monorepo package without a Next.js framework adapter at repo root.
  // The DS playground is fully client-side (no API routes, no SSR,
  // no middleware) so static export is a clean fit.
  output: "export",
  // The DS packages live as a workspace sibling; tell Next it's fine to
  // transpile them from source via webpack's resolve.
  transpilePackages: ["@aeros/react", "@aeros/tokens"],
  experimental: {
    // Allow loading CSS from workspace packages
    externalDir: true,
  },
};

export default nextConfig;
