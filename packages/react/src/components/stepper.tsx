import * as React from "react";
import { Check } from "lucide-react";
import { cn } from "../lib/cn";
import { colorTransition } from "../internal/recipes";

export interface StepperStep {
  label: string;
  description?: string;
}

export type StepState = "completed" | "current" | "upcoming";

export interface StepperProps extends React.OlHTMLAttributes<HTMLOListElement> {
  steps: StepperStep[];
  /** Index of the current step (0-based). `steps.length` marks every step completed. */
  current: number;
  orientation?: "horizontal" | "vertical";
  /** When set, completed steps become buttons that call this with their index. */
  onStepClick?: (index: number) => void;
}

const stateLabel: Record<StepState, string> = {
  completed: "Completed",
  current: "Current",
  upcoming: "Upcoming"
};

const markerState: Record<StepState, string> = {
  completed: "bg-brand-primary text-fg-inverse group-hover/step:bg-brand-primary-hover",
  current: "border-2 border-fg-primary bg-bg-surface text-fg-primary",
  upcoming: "border border-border-strong bg-bg-surface text-fg-muted"
};

/** Progress through an ordered sequence. Give it an `aria-label` ("Checkout progress"). */
export const Stepper = React.forwardRef<HTMLOListElement, StepperProps>(
  ({ steps, current, orientation = "horizontal", onStepClick, className, ...props }, ref) => {
    const horizontal = orientation === "horizontal";
    return (
      <ol
        ref={ref}
        data-orientation={orientation}
        className={cn("flex min-w-0", horizontal ? "w-full items-start" : "flex-col", className)}
        {...props}
      >
        {steps.map((step, i) => {
          const state: StepState = i < current ? "completed" : i === current ? "current" : "upcoming";
          const last = i === steps.length - 1;
          const clickable = state === "completed" && onStepClick != null;

          const body = (
            <>
              <span
                aria-hidden
                className={cn(
                  `inline-flex size-5 shrink-0 items-center justify-center rounded-pill text-label-xs tabular-nums ${colorTransition}`,
                  markerState[state]
                )}
              >
                {state === "completed" ? <Check className="size-icon-xs" /> : i + 1}
              </span>
              <span className={cn("grid min-w-0", horizontal ? "w-full pr-2" : "pt-px")}>
                <span
                  className={cn("truncate text-label-sm", state === "upcoming" ? "text-fg-muted" : "text-fg-primary")}
                >
                  <span className="sr-only">{stateLabel[state]}: </span>
                  {step.label}
                </span>
                {step.description && (
                  <span className={cn("text-caption text-fg-muted", horizontal ? "truncate" : "mt-0.5")}>
                    {step.description}
                  </span>
                )}
              </span>
            </>
          );
          const bodyClass = cn(
            "flex min-w-0 text-left",
            horizontal ? "w-full flex-col items-start gap-1.5" : "items-start gap-3"
          );

          return (
            <li
              key={i}
              data-state={state}
              aria-current={state === "current" ? "step" : undefined}
              className={cn("relative min-w-0", horizontal ? "flex-1" : "pb-5 last:pb-0")}
            >
              {/* The connector to the next marker; solid once this step is done. */}
              {!last && (
                <span
                  aria-hidden
                  className={cn(
                    "absolute",
                    horizontal ? "left-7 right-2 top-2.5 h-px" : "bottom-1 left-2.5 top-6 w-px",
                    state === "completed" ? "bg-fg-primary" : "bg-border-default"
                  )}
                />
              )}
              {clickable ? (
                <button
                  type="button"
                  onClick={() => onStepClick(i)}
                  className={cn("group/step rounded-item", bodyClass)}
                >
                  {body}
                </button>
              ) : (
                <div className={bodyClass}>{body}</div>
              )}
            </li>
          );
        })}
      </ol>
    );
  }
);
Stepper.displayName = "Stepper";
