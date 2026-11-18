"use client";

import * as React from "react";

/**
 * A preview fixture in its own frame — for forced-open overlays and
 * viewport-sized chrome, which cannot share a document with the site.
 * The frame loads the same `/preview/<slug>` page the visual and
 * accessibility suites test, and follows the site's theme and density.
 */
export function FixtureEmbed({
  slug,
  title,
  height,
  interactive,
}: {
  slug: string;
  title: string;
  height: number;
  interactive: boolean;
}) {
  const ref = React.useRef<HTMLIFrameElement>(null);

  React.useEffect(() => {
    const frame = ref.current;
    if (!frame) return;
    const sync = () => {
      try {
        const target = frame.contentDocument?.documentElement;
        if (!target) return;
        const source = document.documentElement.dataset;
        target.dataset.theme = source.theme ?? "light";
        if (source.density) target.dataset.density = source.density;
        else delete target.dataset.density;
      } catch {
        /* the frame is not reachable yet — the load listener runs again */
      }
    };
    sync();
    frame.addEventListener("load", sync);
    const observer = new MutationObserver(sync);
    observer.observe(document.documentElement, { attributes: true, attributeFilter: ["data-theme", "data-density"] });
    return () => {
      frame.removeEventListener("load", sync);
      observer.disconnect();
    };
  }, []);

  // `inert` keeps the pointer and the Tab key out of a forced-open overlay, but
  // the overlay's own focus trap still focuses itself from inside the frame.
  // Hand focus straight back, or a keyboard user would start trapped in it.
  React.useEffect(() => {
    if (interactive) return;
    const frame = ref.current;
    if (!frame) return;
    const release = () => {
      if (document.activeElement !== frame) return;
      try {
        (frame.contentDocument?.activeElement as HTMLElement | null)?.blur();
      } catch {
        /* frame not reachable */
      }
      frame.blur();
      window.focus();
    };
    const onBlur = () => requestAnimationFrame(release);
    window.addEventListener("blur", onBlur);
    frame.addEventListener("load", onBlur);
    release();
    return () => {
      window.removeEventListener("blur", onBlur);
      frame.removeEventListener("load", onBlur);
    };
  }, [interactive]);

  return (
    <iframe
      ref={ref}
      src={`/preview/${slug}`}
      title={title}
      inert={!interactive}
      className="block w-full rounded-surface border border-border-default bg-bg-canvas"
      style={{ height }}
    />
  );
}
