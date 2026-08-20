"use client";
import * as React from "react";
import { cn } from "../lib/cn";
import { useFieldControl, type FieldControlSize } from "./input";

export interface TextareaProps extends React.TextareaHTMLAttributes<HTMLTextAreaElement> {
  state?: "default" | "error" | "success";
  /** Matches the field ladder — affects padding + text size. */
  size?: FieldControlSize;
}

const sizeClasses: Record<FieldControlSize, string> = {
  sm: "min-h-[72px] px-3 py-2 text-[13px]",
  md: "min-h-[84px] px-3.5 py-2.5 text-sm",
  lg: "min-h-[96px] px-4 py-3 text-sm"
};

export const Textarea = React.forwardRef<HTMLTextAreaElement, TextareaProps>(
  ({ className, state, size = "md", ...props }, ref) => {
    const { fieldProps, state: resolvedState } = useFieldControl(props, state);
    return (
      <textarea
        ref={ref}
        className={cn(
          "w-full font-medium rounded-md border bg-bg-surface text-fg-primary",
          sizeClasses[size],
          "placeholder:text-fg-muted placeholder:font-normal",
          "transition-[border-color,box-shadow] duration-(--aeros-duration-fast) resize-y",
          "focus:outline-none disabled:opacity-40 disabled:cursor-not-allowed",
          resolvedState === "default" && "border-border-default hover:border-border-strong focus:border-border-focus focus:shadow-focus",
          resolvedState === "error"   && "border-danger focus:shadow-focus-danger",
          resolvedState === "success" && "border-success focus:shadow-focus-success",
          className
        )}
        {...props}
        {...fieldProps}
      />
    );
  }
);
Textarea.displayName = "Textarea";
