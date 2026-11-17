import { tokens } from "@aeros-core/tokens";
import { clsx, type ClassValue } from "clsx";
import { extendTailwindMerge } from "tailwind-merge";

// tailwind-merge only knows Tailwind's default theme. Teach it the Aeros names
// — straight from the tokens, so it can never fall out of step — otherwise it
// mistakes `text-body-sm` for a text colour and drops it next to
// `text-fg-muted`, and cannot resolve `rounded-control` against `rounded-md`.
const keys = (o: object) => Object.keys(o);
const sizeNames = Object.entries(tokens.size).flatMap(([name, value]) =>
  "pointer" in value ? [name] : keys(value).map((k) => `${name}-${k}`)
);

const twMerge = extendTailwindMerge<"z" | "duration">({
  extend: {
    theme: {
      text: keys(tokens.text),
      radius: [...keys(tokens.radius), ...keys(tokens.shape)],
      shadow: [...keys(tokens.shadow), ...keys(tokens.elevation.light)],
      ease: keys(tokens.motion.ease),
      spacing: [...sizeNames, "sidebar", "sidebar-rail", "sidebar-mobile"]
    },
    classGroups: {
      z: [{ z: keys(tokens.z) }],
      duration: [{ duration: keys(tokens.motion.duration) }]
    }
  }
});

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}
