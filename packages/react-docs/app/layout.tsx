import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "Aeros Design System",
  description: "Foundations, components and patterns of the Aeros Design System.",
};

// Deliberately minimal: the chrome-less `/preview/*` fixtures render straight
// into this. The documentation shell is `app/(site)/layout.tsx`, which also
// sets the saved theme on <html> before paint (hence suppressHydrationWarning).
export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en" data-theme="light" suppressHydrationWarning>
      <body className="bg-bg-canvas text-fg-primary font-sans antialiased">{children}</body>
    </html>
  );
}
