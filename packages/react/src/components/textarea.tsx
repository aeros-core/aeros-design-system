"use client";
import * as React from "react";
import { cn } from "../lib/cn";
import { fieldBase, fieldState } from "../internal/recipes";
import { useFieldControl, type FieldControlSize } from "./input";

export interface TextareaProps extends React.TextareaHTMLAttributes<HTMLTextAreaElement> {
  state?: "default" | "error" | "success";
  /** Matches the field ladder — affects padding + text size. */
  size?: FieldControlSize;
}

const sizeClasses: Record<FieldControlSize, string> = {
  sm: "min-h-18 px-2.5 py-1.5 text-body-sm",
  md: "min-h-20 px-3 py-2 text-body-sm",
  lg: "min-h-24 px-3.5 py-2.5 text-body-md"
};

export const Textarea = React.forwardRef<HTMLTextAreaElement, TextareaProps>(
  ({ className, state, size = "md", ...props }, ref) => {
    const { fieldProps, state: resolvedState } = useFieldControl(props, state);
    return (
      <textarea
        ref={ref}
        className={cn(fieldBase, "resize-y", sizeClasses[size], fieldState[resolvedState], className)}
        {...props}
        {...fieldProps}
      />
    );
  }
);
Textarea.displayName = "Textarea";
