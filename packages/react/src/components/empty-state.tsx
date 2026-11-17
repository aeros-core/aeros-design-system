import * as React from "react";
import { cn } from "../lib/cn";

export interface EmptyStateProps extends Omit<React.HTMLAttributes<HTMLDivElement>, "title"> {
  icon?: React.ReactNode;
  title: React.ReactNode;
  description?: React.ReactNode;
  action?: React.ReactNode;
}

export const EmptyState = React.forwardRef<HTMLDivElement, EmptyStateProps>(
  ({ icon, title, description, action, className, ...props }, ref) => {
  return (
    <div
      ref={ref}
      className={cn(
        "rounded-surface border border-dashed border-border-strong px-6 py-12 text-center",
        className
      )}
      {...props}
    >
      {icon && (
        <div className="mx-auto mb-3 flex size-10 items-center justify-center rounded-control bg-bg-subtle text-fg-muted [&_svg]:size-icon-lg">
          {icon}
        </div>
      )}
      <h3 className="mb-1 text-h4 text-fg-primary">{title}</h3>
      {description && (
        <p className="mx-auto mb-4 max-w-xs text-body-sm text-fg-muted">{description}</p>
      )}
      {action}
    </div>
  );
});
EmptyState.displayName = "EmptyState";
