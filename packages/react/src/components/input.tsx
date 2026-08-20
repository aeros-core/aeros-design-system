"use client";
import * as React from "react";
import { cn } from "../lib/cn";

type InputState = "default" | "error" | "success";
export type FieldControlSize = "sm" | "md" | "lg";

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
  /** Control height — matches the Button ladder (sm 32 / md 36 / lg 40). */
  size?: FieldControlSize;
  prefix?: React.ReactNode;
  suffix?: React.ReactNode;
  containerClassName?: string;
}

const base =
  "w-full font-medium rounded-md border bg-bg-surface text-fg-primary " +
  "placeholder:text-fg-muted placeholder:font-normal " +
  "transition-[border-color,box-shadow] duration-(--aeros-duration-fast) " +
  "disabled:opacity-40 disabled:cursor-not-allowed " +
  "focus:outline-none focus-visible:outline-none";

const sizeClasses: Record<FieldControlSize, string> = {
  sm: "h-8 px-3 text-[13px]",
  md: "h-9 px-3.5 text-sm",
  lg: "h-10 px-4 text-sm"
};

const stateClasses: Record<InputState, string> = {
  default: "border-border-default hover:border-border-strong focus:border-border-focus focus:shadow-focus",
  error:   "border-danger focus:shadow-focus-danger",
  success: "border-success focus:shadow-focus-success"
};

export const Input = React.forwardRef<HTMLInputElement, InputProps>(
  ({ className, state, size = "md", prefix, suffix, containerClassName, ...props }, ref) => {
    const { fieldProps, state: resolvedState } = useFieldControl(props, state);
    const input = (extra?: string) => (
      <input
        ref={ref}
        className={cn(base, sizeClasses[size], stateClasses[resolvedState], extra, className)}
        {...props}
        {...fieldProps}
      />
    );
    if (!prefix && !suffix) return input();
    return (
      <div className={cn("relative", containerClassName)}>
        {prefix && (
          <span className="pointer-events-none absolute left-3 top-1/2 -translate-y-1/2 text-fg-muted">
            {prefix}
          </span>
        )}
        {input(cn(prefix && "pl-[38px]", suffix && "pr-[44px]"))}
        {suffix && (
          <span className="absolute right-2 top-1/2 -translate-y-1/2 flex items-center">
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
        <div ref={ref} className={cn("mb-4", className)} {...props}>
          {label && (
            <label htmlFor={ctx.inputId} className="mb-1.5 block text-[13px] font-medium text-fg-primary">
              {label}
              {required && <span aria-hidden className="text-danger ml-0.5">*</span>}
            </label>
          )}
          {children}
          {error ? (
            <p id={ctx.errorId} className="mt-1.5 text-xs font-medium text-danger-text">{error}</p>
          ) : hint ? (
            <p id={ctx.hintId} className="mt-1.5 text-xs text-fg-muted leading-relaxed">{hint}</p>
          ) : null}
        </div>
      </FieldContext.Provider>
    );
  }
);
Field.displayName = "Field";
