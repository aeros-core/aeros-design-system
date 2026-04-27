import * as React from "react";
import { cn } from "../lib/cn";

export interface DotMatrixProps extends React.HTMLAttributes<HTMLDivElement> {
  rings?: number;
  dotSize?: number;
  gap?: number;
  falloff?: number;
  color?: string;
  background?: string;
  variant?: "ripple" | "pulse";
  speed?: number;
  size?: number;
}

interface HexPoint {
  x: number;
  y: number;
  ring: number;
}

function buildHexPoints(rings: number, gap: number): HexPoint[] {
  const points: HexPoint[] = [];
  const sqrt3Over2 = Math.sqrt(3) / 2;
  for (let q = -rings; q <= rings; q++) {
    const rMin = Math.max(-rings, -q - rings);
    const rMax = Math.min(rings, -q + rings);
    for (let r = rMin; r <= rMax; r++) {
      points.push({
        x: gap * (q + r / 2),
        y: gap * (r * sqrt3Over2),
        ring: Math.max(Math.abs(q), Math.abs(r), Math.abs(q + r)),
      });
    }
  }
  return points;
}

const STEP_MS = 120;

const keyframesCss = `
@keyframes aeros-dotmatrix-ripple {
  0%, 100% { transform: scale(0.6); opacity: 0.55; }
  50%      { transform: scale(1.2); opacity: 1; }
}
.aeros-dotmatrix circle {
  transform-box: fill-box;
  transform-origin: center;
  animation-name: aeros-dotmatrix-ripple;
  animation-duration: var(--aeros-dotmatrix-dur);
  animation-timing-function: cubic-bezier(0.2, 0, 0, 1);
  animation-iteration-count: infinite;
  will-change: transform, opacity;
}
.aeros-dotmatrix[data-variant="pulse"] circle {
  animation-delay: 0ms !important;
}
@media (prefers-reduced-motion: reduce) {
  .aeros-dotmatrix circle {
    animation: none !important;
    transform: scale(1);
    opacity: 1;
  }
}
`;

export const DotMatrix = React.forwardRef<HTMLDivElement, DotMatrixProps>(
  (
    {
      rings = 5,
      dotSize = 6,
      gap = 22,
      falloff = 0.55,
      color = "var(--color-ink-50)",
      background = "var(--color-ink-900)",
      variant = "ripple",
      speed = 2400,
      size,
      className,
      style,
      ...props
    },
    ref,
  ) => {
    const points = React.useMemo(
      () => buildHexPoints(rings, gap),
      [rings, gap],
    );

    const extent = rings * gap + dotSize * 2;
    const viewBox = `${-extent} ${-extent} ${extent * 2} ${extent * 2}`;
    const resolvedSize = size ?? extent * 2;

    return (
      <div
        ref={ref}
        aria-hidden="true"
        data-variant={variant}
        className={cn("aeros-dotmatrix", className)}
        style={{
          width: resolvedSize,
          height: resolvedSize,
          background,
          ["--aeros-dotmatrix-dur" as string]: `${speed}ms`,
          ...style,
        }}
        {...props}
      >
        <style>{keyframesCss}</style>
        <svg
          viewBox={viewBox}
          width="100%"
          height="100%"
          xmlns="http://www.w3.org/2000/svg"
        >
          {points.map((p, i) => {
            const radius = dotSize * (1 - (p.ring / rings) * falloff);
            const delay = variant === "ripple" ? -p.ring * STEP_MS : 0;
            return (
              <circle
                key={i}
                cx={p.x}
                cy={p.y}
                r={radius}
                fill={color}
                style={{
                  animationDelay: `${delay}ms`,
                }}
              />
            );
          })}
        </svg>
      </div>
    );
  },
);
DotMatrix.displayName = "DotMatrix";
