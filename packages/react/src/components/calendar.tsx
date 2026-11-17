"use client";
import * as React from "react";
import { DayPicker, getDefaultClassNames } from "react-day-picker";
import { ChevronLeft, ChevronRight } from "lucide-react";
import { cn } from "../lib/cn";

export type CalendarProps = React.ComponentProps<typeof DayPicker>;

/**
 * Date grid (react-day-picker v9, fully token-styled — no stylesheet import
 * needed). Compose inside a `<Popover>` for a date picker; see the docs page.
 */
export function Calendar({ className, classNames, showOutsideDays = true, ...props }: CalendarProps) {
  const d = getDefaultClassNames();
  return (
    <DayPicker
      showOutsideDays={showOutsideDays}
      className={cn("p-3", className)}
      classNames={{
        months: cn(d.months, "relative flex flex-col gap-4 sm:flex-row"),
        month: cn(d.month, "flex flex-col gap-3"),
        month_caption: cn(d.month_caption, "flex h-control-md items-center justify-center"),
        caption_label: cn(d.caption_label, "text-label-md text-fg-primary"),
        nav: cn(d.nav, "absolute inset-x-0 top-0 flex h-control-md items-center justify-between"),
        button_previous: cn(
          d.button_previous,
          "inline-flex size-control-sm items-center justify-center rounded-control text-fg-muted transition-colors duration-quick hover:bg-state-hover hover:text-fg-primary disabled:opacity-disabled"
        ),
        button_next: cn(
          d.button_next,
          "inline-flex size-control-sm items-center justify-center rounded-control text-fg-muted transition-colors duration-quick hover:bg-state-hover hover:text-fg-primary disabled:opacity-disabled"
        ),
        month_grid: cn(d.month_grid, "border-collapse"),
        weekdays: cn(d.weekdays, "flex"),
        weekday: cn(d.weekday, "w-control-md text-label-xs text-fg-muted"),
        week: cn(d.week, "mt-1 flex"),
        day: cn(d.day, "p-0 text-center"),
        day_button: cn(
          d.day_button,
          "inline-flex size-control-md items-center justify-center rounded-control text-body-sm text-fg-primary",
          "hover:bg-bg-subtle hover:text-fg-primary transition-colors duration-quick",
          ""
        ),
        selected: cn(
          d.selected,
          "[&>button]:bg-brand-primary [&>button]:font-medium [&>button]:text-fg-inverse [&>button:hover]:bg-brand-primary [&>button:hover]:text-fg-inverse"
        ),
        today: cn(d.today, "[&>button]:font-semibold [&>button]:underline [&>button]:underline-offset-4"),
        // Full-strength muted, not an opacity fade — outside days are still
        // interactive text and must hold WCAG AA against the surface.
        outside: cn(d.outside, "[&>button]:text-fg-muted [&>button]:font-normal"),
        disabled: cn(d.disabled, "[&>button]:opacity-40 [&>button]:pointer-events-none"),
        range_start: cn(d.range_start, "rounded-l-control bg-bg-subtle"),
        range_middle: cn(d.range_middle, "bg-bg-subtle [&>button]:bg-transparent [&>button]:text-fg-primary"),
        range_end: cn(d.range_end, "rounded-r-control bg-bg-subtle"),
        hidden: cn(d.hidden, "invisible"),
        ...classNames
      }}
      components={{
        Chevron: ({ orientation, ...rest }) =>
          orientation === "left" ? (
            <ChevronLeft aria-hidden className="size-icon-md" {...rest} />
          ) : (
            <ChevronRight aria-hidden className="size-icon-md" {...rest} />
          )
      }}
      {...props}
    />
  );
}
Calendar.displayName = "Calendar";
