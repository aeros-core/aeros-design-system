import type { Metadata } from "next";
import { tokens } from "@aeros-core/tokens";
import { SiteShell } from "../_site/shell";
import { THEME_SCRIPT } from "../_site/theme-script";

export const metadata: Metadata = {
  title: { default: "Aeros Design System", template: "%s — Aeros Design System" },
  description: "Foundations, components and patterns of the Aeros Design System.",
};

// The documentation site: every page under this group renders inside the app
// shell. The chrome-less `/preview/*` fixtures live outside it.
export default function SiteLayout({ children }: { children: React.ReactNode }) {
  return (
    <>
      {/* Applies the saved theme and density before the shell paints. */}
      <script dangerouslySetInnerHTML={{ __html: THEME_SCRIPT }} />
      <SiteShell version={tokens.meta.version}>{children}</SiteShell>
    </>
  );
}
