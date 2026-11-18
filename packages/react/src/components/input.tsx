"use client";
import * as React from "react";
import { cn } from "../lib/cn";
import { fieldBase, fieldSize, fieldState, type FieldSize, type FieldState } from "../internal/recipes";

type InputState = FieldState;
export type FieldControlSize = FieldSize;

// ── Field context ─────────────────────────────────────────
// Field provides generated ids + validation state; Input/Textarea/SelectTrigger
// consume them so label, hint and error are wired for assistive tech without
// the caller managing ids by hand.

interface FieldContextValue {
  inputId: string;
  hintId: string;
  errorId: string;
  required?: boolean;
  hasHint: boolean;
  hasError: boolean;
}

const FieldContext = React.createContext<FieldContextValue | null>(null);

export interface FieldControlProps {
  id?: string;
  "aria-describedby"?: string;
  "aria-invalid"?: React.AriaAttributes["aria-invalid"];
  "aria-required"?: React.AriaAttributes["aria-required"];
}

/** Resolve id/aria wiring for a control rendered inside a `<Field>`. */
export function useFieldControl(
  props: FieldControlProps,
  state?: InputState
): { fieldProps: FieldControlProps; state: InputState } {
  const ctx = React.useContext(FieldContext);
  const describedBy =
    [
      props["aria-describedby"],
      ctx?.hasError ? ctx.errorId : ctx?.hasHint ? ctx.hintId : undefined
    ]
      .filter(Boolean)
      .join(" ") || undefined;
  const resolvedState = state ?? (ctx?.hasError ? "error" : "default");
  return {
    fieldProps: {
      id: props.id ?? ctx?.inputId,
      "aria-describedby": describedBy,
      "aria-invalid": props["aria-invalid"] ?? (resolvedState === "error" ? true : undefined),
      "aria-required": props["aria-required"] ?? (ctx?.required ? true : undefined)
    },
    state: resolvedState
  };
}

// ── Input ─────────────────────────────────────────────────

export interface InputProps
  extends Omit<React.InputHTMLAttributes<HTMLInputElement>, "prefix" | "size"> {
  state?: InputState;
  /** Control height — the shared ladder (sm 28 / md 32 / lg 36; larger under touch density). */
  size?: FieldControlSize;
  prefix?: React.ReactNode;
  suffix?: React.ReactNode;
  containerClassName?: string;
}

export const Input = React.forwardRef<HTMLInputElement, InputProps>(
  ({ className, state, size = "md", prefix, suffix, containerClassName, ...props }, ref) => {
    const { fieldProps, state: resolvedState } = useFieldControl(props, state);
    const input = (extra?: string) => (
      <input
        ref={ref}
        className={cn(fieldBase, fieldSize[size], fieldState[resolvedState], extra, className)}
        {...props}
        {...fieldProps}
      />
    );
    if (!prefix && !suffix) return input();
    return (
      <div className={cn("relative", containerClassName)}>
        {prefix && (
          <span className="pointer-events-none absolute left-2.5 top-1/2 flex -translate-y-1/2 items-center text-fg-muted [&_svg]:size-icon-md">
            {prefix}
          </span>
        )}
        {input(cn(prefix && "pl-8", suffix && "pr-9"))}
        {suffix && (
          <span className="absolute right-1.5 top-1/2 flex -translate-y-1/2 items-center text-fg-muted [&_svg]:size-icon-md">
            {suffix}
          </span>
        )}
      </div>
    );
  }
);
Input.displayName = "Input";

// ── Field wrapper ─────────────────────────────────────────

export interface FieldProps extends React.HTMLAttributes<HTMLDivElement> {
  label?: React.ReactNode;
  hint?: React.ReactNode;
  error?: React.ReactNode;
  /** Overrides the generated control id (only needed when the control sets its own `id`). */
  htmlFor?: string;
  required?: boolean;
}

export const Field = React.forwardRef<HTMLDivElement, FieldProps>(
  ({ label, hint, error, htmlFor, required, className, children, ...props }, ref) => {
    const autoId = React.useId();
    const ctx: FieldContextValue = {
      inputId: htmlFor ?? `${autoId}-control`,
      hintId: `${autoId}-hint`,
      errorId: `${autoId}-error`,
      required,
      hasHint: hint != null,
      hasError: error != null
    };
    return (
      <FieldContext.Provider value={ctx}>
        <div ref={ref} className={cn("grid gap-1.5", className)} {...props}>
          {label && (
            <label htmlFor={ctx.inputId} className="text-label-sm text-fg-primary">
              {label}
              {required && <span aria-hidden className="text-danger ml-0.5">*</span>}
            </label>
          )}
          {children}
          {error ? (
            <p id={ctx.errorId} className="text-caption text-danger-text">{error}</p>
          ) : hint ? (
            <p id={ctx.hintId} className="text-caption text-fg-muted">{hint}</p>
          ) : null}
        </div>
      </FieldContext.Provider>
    );
  }
);
Field.displayName = "Field";

// ── Field group ───────────────────────────────────────────

/**
 * Stacks fields with the standard gap. `Field` carries no outer margin of its
 * own, so spacing is always the parent's decision.
 */
export const FieldGroup = React.forwardRef<HTMLDivElement, React.HTMLAttributes<HTMLDivElement>>(
  ({ className, ...props }, ref) => <div ref={ref} className={cn("grid gap-4", className)} {...props} />
);
FieldGroup.displayName = "FieldGroup";
