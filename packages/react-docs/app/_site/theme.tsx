"use client";

import * as React from "react";
import { SegmentedControl, SegmentedControlItem } from "@aeros-core/react";
import { Hand, Monitor, Moon, MousePointer2, Sun } from "lucide-react";
import { DENSITY_KEY, THEME_KEY } from "./theme-script";

const THEMES = ["light", "dark", "system"] as const;
type Theme = (typeof THEMES)[number];
const DENSITIES = ["pointer", "touch"] as const;
type Density = (typeof DENSITIES)[number];

function save(key: string, value: string) {
  try {
    window.localStorage.setItem(key, value);
  } catch {
    /* storage unavailable — the choice still applies for this visit */
  }
}

const isTheme = (value: string | undefined): value is Theme => (THEMES as readonly string[]).includes(value ?? "");
const isDensity = (value: string | undefined): value is Density => (DENSITIES as readonly string[]).includes(value ?? "");

/** Light / dark / system. Sets `data-theme` on `<html>`. */
export function ThemeSwitch() {
  // The inline script has already set the attribute; read it back after mount
  // so the server render and the first client render agree.
  const [theme, setTheme] = React.useState<Theme>("system");
  React.useEffect(() => {
    const current = document.documentElement.dataset.theme;
    if (isTheme(current)) setTheme(current);
  }, []);

  const choose = (next: string) => {
    if (!isTheme(next)) return;
    setTheme(next);
    document.documentElement.dataset.theme = next;
    save(THEME_KEY, next);
  };

  return (
    <SegmentedControl size="sm" value={theme} onValueChange={choose} aria-label="Theme">
      <SegmentedControlItem value="light" icon={<Sun />} aria-label="Light" title="Light" />
      <SegmentedControlItem value="dark" icon={<Moon />} aria-label="Dark" title="Dark" />
      <SegmentedControlItem value="system" icon={<Monitor />} aria-label="System" title="System" />
    </SegmentedControl>
  );
}

/** Pointer / touch. Sets `data-density` on `<html>`. */
export function DensitySwitch() {
  const [density, setDensity] = React.useState<Density>("pointer");
  React.useEffect(() => {
    const current = document.documentElement.dataset.density;
    if (isDensity(current)) setDensity(current);
  }, []);

  const choose = (next: string) => {
    if (!isDensity(next)) return;
    setDensity(next);
    document.documentElement.dataset.density = next;
    save(DENSITY_KEY, next);
  };

  return (
    <SegmentedControl size="sm" value={density} onValueChange={choose} aria-label="Density">
      <SegmentedControlItem value="pointer" icon={<MousePointer2 />} aria-label="Pointer density" title="Pointer density" />
      <SegmentedControlItem value="touch" icon={<Hand />} aria-label="Touch density" title="Touch density" />
    </SegmentedControl>
  );
}
