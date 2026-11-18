"use client";

import * as React from "react";

/**
 * Wraps each page of the site (a template, so it mounts with the page — the
 * shell in the layout can hydrate before the page does). `data-page-ready`
 * flips one frame after the page's own effects have run; e2e/site.spec.ts
 * waits on it, like `data-fixture-ready` on the previews.
 */
export default function SiteTemplate({ children }: { children: React.ReactNode }) {
  const [ready, setReady] = React.useState(false);
  React.useEffect(() => {
    const id = requestAnimationFrame(() => setReady(true));
    return () => cancelAnimationFrame(id);
  }, []);
  return (
    <div className="contents" data-page-ready={ready ? "true" : "false"}>
      {children}
    </div>
  );
}
