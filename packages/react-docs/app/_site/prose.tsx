"use client";

import * as React from "react";
import { cn } from "@aeros-core/react";

// The site's own page furniture. The page title is the <h1> in the app header,
// so content starts at <h2>.
//
// "use client" only because `cn` is: @aeros-core/react ships as one client
// bundle, so its `cn()` cannot be called from a server component. There are no
// hooks here; server pages render these and pass plain props.

/** The opening block of a page: which section it belongs to and what it covers. */
export function PageIntro({ section, children }: { section: string; children: React.ReactNode }) {
  return (
    <div className="mb-8 max-w-prose">
      <div className="text-overline uppercase text-fg-muted">{section}</div>
      <p className="mt-2 text-body-lg text-fg-secondary">{children}</p>
    </div>
  );
}

export function Section({
  title,
  description,
  children,
  className,
}: {
  title: string;
  description?: React.ReactNode;
  children: React.ReactNode;
  className?: string;
}) {
  return (
    <section className={cn("mb-10 min-w-0 last:mb-0", className)}>
      <h2 className="text-h2 text-fg-primary">{title}</h2>
      {description != null && <p className="mt-1 max-w-prose text-body-md text-fg-secondary">{description}</p>}
      <div className="mt-4 min-w-0">{children}</div>
    </section>
  );
}

export function SubHeading({ children, className }: { children: React.ReactNode; className?: string }) {
  return <h3 className={cn("text-h4 text-fg-primary", className)}>{children}</h3>;
}

export function Prose({ children, className }: { children: React.ReactNode; className?: string }) {
  return <p className={cn("max-w-prose text-body-md text-fg-secondary", className)}>{children}</p>;
}

/** Inline code: a class name, a prop, a token. */
export function Code({ children }: { children: React.ReactNode }) {
  return (
    <code className="rounded-item bg-bg-subtle px-1 py-0.5 font-mono text-mono-sm text-fg-primary">{children}</code>
  );
}

/** A hairline frame for a live example. */
export function Demo({ children, className }: { children: React.ReactNode; className?: string }) {
  return (
    <div className={cn("min-w-0 rounded-surface border border-border-default bg-bg-canvas p-4 md:p-6", className)}>
      {children}
    </div>
  );
}

/** A token table: hairline rows on a surface, scrolls sideways on a narrow screen. */
export function SpecTable({
  label,
  head,
  children,
}: {
  label: string;
  head: React.ReactNode[];
  children: React.ReactNode;
}) {
  return (
    <div
      role="group"
      aria-label={label}
      tabIndex={0}
      className="overflow-x-auto rounded-surface border border-border-default bg-bg-surface focus-ring-inset"
    >
      <table className="w-full border-collapse text-left text-body-sm">
        <thead>
          <tr className="border-b border-border-default">
            {head.map((cell, i) => (
              <th key={i} scope="col" className="whitespace-nowrap px-3 py-2 text-caption font-medium text-fg-muted">
                {cell}
              </th>
            ))}
          </tr>
        </thead>
        <tbody className="[&>tr:last-child]:border-b-0 [&>tr]:border-b [&>tr]:border-border-default">{children}</tbody>
      </table>
    </div>
  );
}

export function SpecCell({
  children,
  mono,
  className,
}: {
  children?: React.ReactNode;
  mono?: boolean;
  className?: string;
}) {
  return (
    <td className={cn("px-3 py-2 align-middle text-fg-primary", mono && "whitespace-nowrap font-mono text-mono-sm", className)}>
      {children}
    </td>
  );
}

/** A colour chip. The value always comes from the tokens, never from this file. */
export function Swatch({ color, className }: { color: string; className?: string }) {
  return (
    <span
      aria-hidden
      className={cn("inline-block size-5 shrink-0 rounded-item border border-border-default align-middle", className)}
      style={{ background: color }}
    />
  );
}
