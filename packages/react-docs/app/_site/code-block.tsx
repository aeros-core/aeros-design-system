"use client";

import * as React from "react";
import { Button, cn } from "@aeros-core/react";
import { Check, Copy } from "lucide-react";

export interface CodeBlockProps {
  code: string;
  /** Shown in the bar above the code: a file name, a language, "Usage". */
  title: string;
  className?: string;
}

/** Monospace on a hairline surface with a copy button. No syntax highlighting. */
export function CodeBlock({ code, title, className }: CodeBlockProps) {
  const [copied, setCopied] = React.useState(false);
  const [scrollable, setScrollable] = React.useState(false);
  const scroller = React.useRef<HTMLDivElement>(null);
  const timer = React.useRef<ReturnType<typeof setTimeout> | undefined>(undefined);

  // A region that scrolls must be reachable from the keyboard — but only then,
  // so a page of short snippets does not add a tab stop per snippet.
  React.useEffect(() => {
    const el = scroller.current;
    if (!el) return;
    const measure = () => setScrollable(el.scrollWidth > el.clientWidth);
    measure();
    if (typeof ResizeObserver !== "function") return;
    const observer = new ResizeObserver(measure);
    observer.observe(el);
    return () => observer.disconnect();
  }, [code]);

  React.useEffect(() => () => clearTimeout(timer.current), []);

  const copy = async () => {
    try {
      await navigator.clipboard.writeText(code);
      setCopied(true);
      clearTimeout(timer.current);
      timer.current = setTimeout(() => setCopied(false), 1600);
    } catch {
      /* clipboard unavailable (insecure origin, denied) — the text can still be selected */
    }
  };

  return (
    <div className={cn("min-w-0 overflow-hidden rounded-surface border border-border-default bg-bg-surface", className)}>
      <div className="flex h-control-lg items-center justify-between gap-3 border-b border-border-default pl-3 pr-1.5">
        <span className="truncate text-caption text-fg-muted">{title}</span>
        <Button variant="ghost" size="xs" onClick={copy} leadingIcon={copied ? <Check /> : <Copy />}>
          <span aria-live="polite">{copied ? "Copied" : "Copy"}</span>
        </Button>
      </div>
      <div
        ref={scroller}
        role="group"
        aria-label={`${title} — code`}
        tabIndex={scrollable ? 0 : undefined}
        className="overflow-x-auto focus-ring-inset"
      >
        <pre className="w-max min-w-full p-3 font-mono text-mono-md text-fg-primary">
          <code>{code}</code>
        </pre>
      </div>
    </div>
  );
}
