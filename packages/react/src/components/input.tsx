import * as React from "react";
import { cn } from "../lib/cn";

type InputState = "default" | "error" | "success";

export interface InputProps extends Omit<React.InputHTMLAttributes<HTMLInputElement>, "prefix"> {
  state?: InputState;
  prefix?: React.ReactNode;
  suffix?: React.ReactNode;
  containerClassName?: string;
}

const base =
  "w-full h-10 px-3.5 text-sm font-medium rounded-md border bg-bg-surface text-fg-primary " +
  "placeholder:text-ink-200 placeholder:font-normal " +
  "transition-[border-color,box-shadow] duration-[120ms] " +
  "disabled:opacity-50 disabled:cursor-not-allowed " +
  "focus:outline-none focus-visible:outline-none";

const stateClasses: Record<InputState, string> = {
  default: "border-border-default hover:border-border-strong focus:border-royal-400 focus:shadow-[0_0_0_3px_var(--aeros-focus-ring)]",
  error:   "border-danger focus:shadow-[0_0_0_3px_rgba(220,38,38,0.15)]",
  success: "border-success focus:shadow-[0_0_0_3px_rgba(22,163,74,0.15)]"
};

export const Input = React.forwardRef<HTMLInputElement, InputProps>(
  ({ className, state = "default", prefix, suffix, containerClassName, ...props }, ref) => {
    if (!prefix && !suffix) {
      return <input ref={ref} className={cn(base, stateClasses[state], className)} {...props} />;
    }
    return (
      <div className={cn("relative", containerClassName)}>
        {prefix && (
          <span className="pointer-events-none absolute left-3 top-1/2 -translate-y-1/2 text-slate-400">
            {prefix}
          </span>
        )}
        <input
          ref={ref}
          className={cn(
            base,
            stateClasses[state],
            prefix && "pl-[38px]",
            suffix && "pr-[44px]",
            className
          )}
          {...props}
        />
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

// Field wrapper
export interface FieldProps {
  label?: React.ReactNode;
  hint?: React.ReactNode;
  error?: React.ReactNode;
  htmlFor?: string;
  required?: boolean;
  className?: string;
  children: React.ReactNode;
}

export function Field({ label, hint, error, htmlFor, required, className, children }: FieldProps) {
  return (
    <div className={cn("mb-4", className)}>
      {label && (
        <label htmlFor={htmlFor} className="mb-1.5 block text-[13px] font-semibold text-ink-800">
          {label}
          {required && <span className="text-danger ml-0.5">*</span>}
        </label>
      )}
      {children}
      {error ? (
        <p className="mt-1.5 text-xs font-medium text-danger">{error}</p>
      ) : hint ? (
        <p className="mt-1.5 text-xs text-ink-400 leading-relaxed">{hint}</p>
      ) : null}
    </div>
  );
}
