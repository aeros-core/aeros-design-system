import * as React from "react";
import { cn } from "../lib/cn";

export interface TextareaProps extends React.TextareaHTMLAttributes<HTMLTextAreaElement> {
  state?: "default" | "error" | "success";
}

export const Textarea = React.forwardRef<HTMLTextAreaElement, TextareaProps>(
  ({ className, state = "default", ...props }, ref) => {
    return (
      <textarea
        ref={ref}
        className={cn(
          "w-full min-h-[84px] px-3.5 py-2.5 text-sm font-medium rounded-md border bg-bg-surface text-fg-primary",
          "placeholder:text-ink-200 placeholder:font-normal",
          "transition-[border-color,box-shadow] duration-[120ms] resize-y",
          "focus:outline-none disabled:opacity-50 disabled:cursor-not-allowed",
          state === "default" && "border-border-default hover:border-border-strong focus:border-royal-400 focus:shadow-[0_0_0_3px_var(--aeros-focus-ring)]",
          state === "error"   && "border-danger",
          state === "success" && "border-success",
          className
        )}
        {...props}
      />
    );
  }
);
Textarea.displayName = "Textarea";
