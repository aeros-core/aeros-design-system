# Design principles

Aeros is built for **operators** — people running factories, buying teams, warehouses, stores. Every decision in this system traces back to those people and their day.

## 1. Operators first

Our users aren't shopping. They're deciding. Interfaces should be read like a dashboard instrument, not a magazine. Information density is a feature, not a bug. Whitespace exists to separate meaningful groups, not to decorate.

## 2. Clarity over decoration

No gradients. No textures. No shadows unless they carry signal (a modal lifted from the page, a focus ring earning attention). When in doubt, remove it.

## 3. Authority through weight

Headings are **ExtraBold**, with negative letter-spacing. Numbers are **Semibold or Bold**. Buttons are Semibold. Aeros speaks with confidence — its type shows it.

## 4. Monospace for data

Anything a computer produced — IDs, timestamps, currency, counts, tokens — goes in **IBM Plex Mono**. This is a visual promise: if it's in mono, it's canonical. If it's in Jakarta, it's written by a person.

## 5. Quiet color with decisive accents

The canvas is white (or near-black). The body is grey. **Royal Blue `#2347D9`** is the only brand color, used sparingly — primary actions, selected state, critical data. Semantic colors (green/amber/red) only where an operator needs to act.

## 6. One grid, four radii

Spacing is a 4-based scale. Radii are `6, 8, 12, 16, 20` — small for controls, medium for cards, large for modals. No freestyle values.

## 7. Accessible by default

- Minimum 4.5:1 contrast on all foreground/background pairs (WCAG AA).
- Every interactive element has `:focus-visible` state.
- All Radix primitives keep keyboard and screen reader behavior.
- Respect `prefers-reduced-motion`.

## 8. Two platforms, one language

A button in Next.js and an `AerosButton` in Flutter should feel identical: same height rhythm, same color, same weight, same padding. Token parity is enforced — the same `tokens.json` generates CSS variables, Tailwind utilities, and Dart constants.

## 9. Boring is fine

We'd rather ship a system that's boring and consistent than one that's clever and brittle. When you find yourself about to do something novel, ask: does the operator care? If no, don't.
