import * as React from "react";
import { cn } from "../lib/cn";

export interface EmptyStateProps extends React.HTMLAttributes<HTMLDivElement> {
  icon?: React.ReactNode;
  title: React.ReactNode;
  description?: React.ReactNode;
  action?: React.ReactNode;
}

export function EmptyState({ icon, title, description, action, className, ...props }: EmptyStateProps) {
  return (
    <div
      className={cn(
        "text-center px-6 py-[52px] border-[1.5px] border-dashed border-border-strong rounded-xl",
        className
      )}
      {...props}
    >
      {icon && (
        <div className="mx-auto mb-4 flex h-[52px] w-[52px] items-center justify-center rounded-lg bg-bg-subtle border border-border-default text-fg-muted">
          {icon}
        </div>
      )}
      <div className="text-[15px] font-bold tracking-[-0.01em] text-fg-secondary mb-1">{title}</div>
      {description && (
        <p className="mx-auto max-w-[280px] text-[13px] text-fg-muted leading-relaxed mb-4">{description}</p>
      )}
      {action}
    </div>
  );
}
