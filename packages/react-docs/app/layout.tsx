import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "Aeros DS — Playground",
  description: "Live preview of every @aeros-core/react component.",
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html
      lang="en"
      data-theme="light"
      suppressHydrationWarning
    >
      <body className="bg-bg-canvas text-fg-primary font-sans antialiased">
        {children}
      </body>
    </html>
  );
}
