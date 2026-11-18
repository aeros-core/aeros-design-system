import * as React from "react";
import { ArrowLeft } from "lucide-react";
import { cn } from "../lib/cn";
import { Button } from "./button";

export interface PageHeaderBack {
  /** Renders a link. Without it the control is a button calling `onClick`. */
  href?: string;
  onClick?: () => void;
  /** Accessible name. Defaults to "Back". */
  label?: string;
}

export interface PageHeaderProps extends Omit<React.HTMLAttributes<HTMLDivElement>, "title"> {
  title: React.ReactNode;
  description?: React.ReactNode;
  /** Rendered above the title — usually a `<Breadcrumb>`. */
  breadcrumb?: React.ReactNode;
  /** Buttons on the title row. They wrap under the title when the row runs out of width. */
  actions?: React.ReactNode;
  back?: PageHeaderBack;
  /** Rendered below the title row — usually a `<TabsList>`. */
  tabs?: React.ReactNode;
  /** Heading level of the title. One `h1` per page; use `h2` for a header inside a page. */
  as?: "h1" | "h2";
}

export const PageHeader = React.forwardRef<HTMLDivElement, PageHeaderProps>(
  ({ title, description, breadcrumb, actions, back, tabs, as: Heading = "h1", className, ...props }, ref) => {
    const backLabel = back?.label ?? "Back";
    return (
      <div ref={ref} className={cn("flex min-w-0 flex-col gap-3", className)} {...props}>
        {breadcrumb}
        <div className="flex flex-wrap items-start justify-between gap-x-4 gap-y-3">
          {/* A real basis (not 0) is what lets the actions wrap below instead of squeezing the title. */}
          <div className="flex min-w-0 grow basis-64 items-start gap-2">
            {back &&
              (back.href != null ? (
                <Button asChild variant="ghost" size="sm" iconOnly aria-label={backLabel} className="-ml-1.5">
                  <a href={back.href} onClick={back.onClick}>
                    <ArrowLeft aria-hidden />
                  </a>
                </Button>
              ) : (
                <Button
                  type="button"
                  variant="ghost"
                  size="sm"
                  iconOnly
                  aria-label={backLabel}
                  className="-ml-1.5"
                  onClick={back.onClick}
                >
                  <ArrowLeft aria-hidden />
                </Button>
              ))}
            <div className="min-w-0 flex-1">
              <Heading className="text-h2 break-words text-fg-primary">{title}</Heading>
              {description != null && <p className="mt-1 text-body-sm text-fg-secondary">{description}</p>}
            </div>
          </div>
          {actions != null && <div className="flex max-w-full flex-wrap items-center gap-2">{actions}</div>}
        </div>
        {tabs}
      </div>
    );
  }
);
PageHeader.displayName = "PageHeader";
