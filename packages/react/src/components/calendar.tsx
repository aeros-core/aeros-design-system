"use client";
import * as React from "react";
import { DayPicker, getDefaultClassNames, type Labels } from "react-day-picker";
import { ChevronLeft, ChevronRight } from "lucide-react";
import { cn } from "../lib/cn";

export type CalendarProps = React.ComponentProps<typeof DayPicker>;

/**
 * Accessible name of a day button: "26, Sunday, July 2026" (plus ", today" /
 * ", selected"). It starts with the number the button shows, so the visible
 * label is part of the name (WCAG 2.5.3 Label in Name — speech-input users say
 * what they see) while screen-reader users still hear the full date.
 * react-day-picker's default, "Sunday, July 26th, 2026", does not contain "26"
 * as a word. Override with the `labels` prop.
 */
const labelDayButton: NonNullable<Labels["labelDayButton"]> = (date, modifiers, _options, dateLib) => {
  const format = (pattern: string) =>
    dateLib ? dateLib.format(date, pattern) : new Intl.DateTimeFormat("en-US", INTL[pattern]).format(date);
  let label = `${format("d")}, ${format("EEEE")}, ${format("LLLL yyyy")}`;
  if (modifiers.today) label += ", today";
  if (modifiers.selected) label += ", selected";
  return label;
};
// Only used if react-day-picker ever calls the label without its date library.
const INTL: Record<string, Intl.DateTimeFormatOptions> = {
  d: { day: "numeric" },
  EEEE: { weekday: "long" },
  "LLLL yyyy": { month: "long", year: "numeric" }
};

/**
 * Date grid (react-day-picker v9, fully token-styled — no stylesheet import
 * needed). Compose inside a `<Popover>` for a date picker; see the docs page.
 */
export function Calendar({ className, classNames, labels, showOutsideDays = true, ...props }: CalendarProps) {
  const d = getDefaultClassNames();
  return (
    <DayPicker
      showOutsideDays={showOutsideDays}
      labels={{ labelDayButton, ...labels }}
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
