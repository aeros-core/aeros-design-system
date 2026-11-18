"use client";
import * as React from "react";
import type { Matcher } from "react-day-picker";
import { Calendar as CalendarIcon, X } from "lucide-react";
import { cn } from "../lib/cn";
import { fieldBase, fieldSize, fieldState, menuItem, type FieldSize, type FieldState } from "../internal/recipes";
import { Calendar } from "./calendar";
import { useFieldControl } from "./input";
import { Popover, PopoverContent, PopoverTrigger } from "./popover";

// A field-styled trigger that opens the DS Calendar in a Popover.
// `DatePicker` holds one day, `DateRangePicker` a from–to pair.

const parts = new Intl.DateTimeFormat("en-GB", { day: "2-digit", month: "short", year: "numeric" });

/**
 * `20 Aug 2026`. Fixed locale so server and client agree; the month is cut to
 * three letters because newer ICU data spells en-GB September "Sept".
 */
export function formatDisplayDate(date: Date): string {
  const get = (type: Intl.DateTimeFormatPartTypes) =>
    parts.formatToParts(date).find((part) => part.type === type)?.value ?? "";
  return `${get("day")} ${get("month").slice(0, 3)} ${get("year")}`;
}

/** Local calendar day as `yyyy-MM-dd` (not `toISOString`, which shifts to UTC). */
export function toISODate(date: Date): string {
  const pad = (n: number, width = 2) => String(n).padStart(width, "0");
  return `${pad(date.getFullYear(), 4)}-${pad(date.getMonth() + 1)}-${pad(date.getDate())}`;
}

const sameDay = (a?: Date, b?: Date) =>
  Boolean(a && b) &&
  a!.getFullYear() === b!.getFullYear() &&
  a!.getMonth() === b!.getMonth() &&
  a!.getDate() === b!.getDate();

function useControlled<T>(controlled: T | undefined, initial: T, onChange?: (next: T) => void) {
  const [inner, setInner] = React.useState(initial);
  const isControlled = controlled !== undefined;
  const set = React.useCallback(
    (next: T) => {
      if (!isControlled) setInner(next);
      onChange?.(next);
    },
    [isControlled, onChange]
  );
  return [isControlled ? controlled : inner, set] as const;
}

/** Small ghost button that lives inside a field (clear). */
const fieldAction =
  "pointer-events-auto inline-flex size-5 shrink-0 items-center justify-center rounded-item text-fg-muted " +
  "transition-colors duration-quick hover:bg-state-hover hover:text-fg-primary [&_svg]:size-icon-sm";

type TriggerProps = Omit<
  React.ButtonHTMLAttributes<HTMLButtonElement>,
  "value" | "defaultValue" | "onChange" | "name" | "children" | "type"
>;

interface DateFieldSharedProps extends TriggerProps {
  /** Days before this are disabled, and earlier months cannot be reached. */
  min?: Date;
  /** Days after this are disabled, and later months cannot be reached. */
  max?: Date;
  /** Extra react-day-picker matcher(s) for days that cannot be picked. */
  disabledDates?: Matcher | Matcher[];
  placeholder?: string;
  formatDate?: (date: Date) => string;
  /** Shows a clear button while a value is set. */
  clearable?: boolean;
  size?: FieldSize;
  state?: FieldState;
  open?: boolean;
  defaultOpen?: boolean;
  onOpenChange?: (open: boolean) => void;
  /** Month shown when the calendar opens with no value. */
  defaultMonth?: Date;
  /** Overrides "today" (tests, fixtures). */
  today?: Date;
  /** Accessible name of the calendar popup. */
  dialogLabel?: string;
  /** Class for the wrapper around the trigger; `className` goes to the trigger itself. */
  containerClassName?: string;
}

function disabledMatchers(min?: Date, max?: Date, extra?: Matcher | Matcher[]): Matcher[] {
  return [
    ...(min ? [{ before: min }] : []),
    ...(max ? [{ after: max }] : []),
    ...(extra === undefined ? [] : Array.isArray(extra) ? extra : [extra])
  ];
}

interface FrameProps extends TriggerProps {
  forwardedRef: React.ForwardedRef<HTMLButtonElement>;
  /** Formatted value; undefined shows the placeholder. */
  text?: string;
  placeholder?: string;
  onClear?: () => void;
  size?: FieldSize;
  state?: FieldState;
  open: boolean;
  onOpenChange: (open: boolean) => void;
  dialogLabel: string;
  containerClassName?: string;
  /** Hidden inputs. */
  inputs?: React.ReactNode;
  children: React.ReactNode;
}

function DateFieldFrame({
  forwardedRef,
  text,
  placeholder,
  onClear,
  size = "md",
  state,
  open,
  onOpenChange,
  dialogLabel,
  containerClassName,
  inputs,
  children,
  className,
  disabled,
  "aria-label": ariaLabel,
  ...props
}: FrameProps) {
  const { fieldProps, state: resolvedState } = useFieldControl(props, state);
  const triggerRef = React.useRef<HTMLButtonElement | null>(null);
  const valueId = React.useId();
  const hasValue = text !== undefined;
  const showClear = Boolean(onClear && hasValue && !disabled);
  const labelledBy = props["aria-labelledby"];

  const setRef = React.useCallback(
    (node: HTMLButtonElement | null) => {
      triggerRef.current = node;
      if (typeof forwardedRef === "function") forwardedRef(node);
      else if (forwardedRef) forwardedRef.current = node;
    },
    [forwardedRef]
  );

  // A <label for> names a button and hides its content from the accessible
  // name, which would drop the visible text (the chosen date, or the
  // placeholder). Name it "<label> <text>" instead by pointing aria-labelledby
  // at the label(s) and the value text. The label
  // belongs to the caller (usually <Field>), so it is found through the DOM.
  React.useEffect(() => {
    const trigger = triggerRef.current;
    if (!trigger || ariaLabel || labelledBy) return;
    const labels = Array.from(trigger.labels ?? []);
    if (labels.length === 0) {
      trigger.removeAttribute("aria-labelledby");
      return;
    }
    const ids = labels.map((label, index) => {
      if (!label.id) label.id = `${valueId}-label-${index}`;
      return label.id;
    });
    trigger.setAttribute("aria-labelledby", [...ids, valueId].join(" "));
  });

  return (
    <div className={cn("grid w-full", containerClassName)}>
      <Popover open={open} onOpenChange={onOpenChange}>
        <PopoverTrigger asChild>
          <button
            ref={setRef}
            type="button"
            disabled={disabled}
            data-placeholder={hasValue ? undefined : ""}
            // The visible text (the date, or the placeholder) is always part of the name.
            aria-label={ariaLabel ? `${ariaLabel}, ${text ?? placeholder}` : undefined}
            className={cn(
              fieldBase,
              "col-start-1 row-start-1 flex items-center gap-2 text-left",
              fieldSize[size],
              fieldState[resolvedState],
              className
            )}
            {...props}
            // A plain button does not support aria-invalid / aria-required; the
            // error is announced through aria-describedby and shown by the border.
            id={fieldProps.id}
            aria-describedby={fieldProps["aria-describedby"]}
            data-invalid={resolvedState === "error" || undefined}
          >
            <CalendarIcon aria-hidden className="size-icon-md shrink-0 text-fg-muted" />
            <span id={valueId} className="min-w-0 flex-1 truncate">
              {text ?? placeholder}
            </span>
            {showClear && <span aria-hidden className="size-5 shrink-0" />}
          </button>
        </PopoverTrigger>
        <PopoverContent align="start" aria-label={dialogLabel} className="w-auto max-w-[calc(100vw-1rem)] p-0">
          {children}
        </PopoverContent>
      </Popover>
      {showClear && (
        // Buttons cannot nest, so the clear button is stacked over the trigger in the same cell.
        <div
          className={cn(
            "pointer-events-none col-start-1 row-start-1 flex items-center justify-end border border-transparent",
            fieldSize[size]
          )}
        >
          <button
            type="button"
            aria-label="Clear date"
            className={fieldAction}
            onClick={() => {
              onClear?.();
              triggerRef.current?.focus();
            }}
          >
            <X aria-hidden />
          </button>
        </div>
      )}
      {inputs}
    </div>
  );
}

// ── Single ────────────────────────────────────────────────

export interface DatePickerProps extends DateFieldSharedProps {
  value?: Date | null;
  defaultValue?: Date | null;
  onValueChange?: (date: Date | null) => void;
  /** Renders a hidden input holding the value as `yyyy-MM-dd`. */
  name?: string;
}

export const DatePicker = React.forwardRef<HTMLButtonElement, DatePickerProps>(
  (
    {
      value: valueProp,
      defaultValue = null,
      onValueChange,
      min,
      max,
      disabledDates,
      placeholder = "Pick a date",
      formatDate = formatDisplayDate,
      clearable,
      open: openProp,
      defaultOpen = false,
      onOpenChange,
      defaultMonth,
      today,
      dialogLabel = "Choose date",
      name,
      ...props
    },
    ref
  ) => {
    const [value, setValue] = useControlled<Date | null>(valueProp, defaultValue, onValueChange);
    const [open, setOpen] = useControlled(openProp, defaultOpen, onOpenChange);

    return (
      <DateFieldFrame
        {...props}
        forwardedRef={ref}
        text={value ? formatDate(value) : undefined}
        placeholder={placeholder}
        onClear={clearable ? () => setValue(null) : undefined}
        open={open}
        onOpenChange={setOpen}
        dialogLabel={dialogLabel}
        inputs={
          name && <input type="hidden" name={name} value={value ? toISODate(value) : ""} disabled={props.disabled} />
        }
      >
        <Calendar
          mode="single"
          // Moving focus into the grid is the point of opening a date popup.
          // eslint-disable-next-line jsx-a11y/no-autofocus
          autoFocus
          selected={value ?? undefined}
          onSelect={(day) => {
            // Clicking the selected day again un-selects it; only a clearable picker accepts that.
            if (day) setValue(day);
            else if (clearable) setValue(null);
            setOpen(false);
          }}
          defaultMonth={value ?? defaultMonth}
          today={today}
          startMonth={min}
          endMonth={max}
          disabled={disabledMatchers(min, max, disabledDates)}
        />
      </DateFieldFrame>
    );
  }
);
DatePicker.displayName = "DatePicker";

// ── Range ─────────────────────────────────────────────────

export interface DateRangeValue {
  from?: Date;
  to?: Date;
}

export interface DateRangePreset {
  label: string;
  range: { from: Date; to: Date };
}

export interface DateRangePickerProps extends DateFieldSharedProps {
  value?: DateRangeValue | null;
  defaultValue?: DateRangeValue | null;
  /** Called with a complete range (both ends), or null when cleared. */
  onValueChange?: (range: DateRangeValue | null) => void;
  /** Months shown side by side from the `sm` breakpoint up (stacked below it). */
  numberOfMonths?: number;
  /** Shortcuts listed beside the calendar. */
  presets?: DateRangePreset[];
  /** Renders hidden inputs `<name>_from` and `<name>_to` holding `yyyy-MM-dd`. */
  name?: string;
}

export const DateRangePicker = React.forwardRef<HTMLButtonElement, DateRangePickerProps>(
  (
    {
      value: valueProp,
      defaultValue = null,
      onValueChange,
      min,
      max,
      disabledDates,
      placeholder = "Pick a date range",
      formatDate = formatDisplayDate,
      clearable,
      open: openProp,
      defaultOpen = false,
      onOpenChange,
      defaultMonth,
      today,
      dialogLabel = "Choose date range",
      numberOfMonths = 2,
      presets,
      name,
      ...props
    },
    ref
  ) => {
    const [value, setValue] = useControlled<DateRangeValue | null>(valueProp, defaultValue, onValueChange);
    const [open, setOpenState] = useControlled(openProp, defaultOpen, onOpenChange);
    // The range being picked. It reaches `value` only once both ends are set;
    // closing half-way discards it.
    const [draft, setDraft] = React.useState<DateRangeValue | null>(value);

    const setOpen = (next: boolean) => {
      if (next) setDraft(value);
      setOpenState(next);
    };
    const commit = (range: DateRangeValue) => {
      setDraft(range);
      setValue(range);
      setOpenState(false);
    };

    const text = value?.from
      ? `${formatDate(value.from)} – ${value.to ? formatDate(value.to) : ""}`.trimEnd()
      : undefined;

    return (
      <DateFieldFrame
        {...props}
        forwardedRef={ref}
        text={text}
        placeholder={placeholder}
        onClear={
          clearable
            ? () => {
                setDraft(null);
                setValue(null);
              }
            : undefined
        }
        open={open}
        onOpenChange={setOpen}
        dialogLabel={dialogLabel}
        inputs={
          name && (
            <>
              <input
                type="hidden"
                name={`${name}_from`}
                value={value?.from ? toISODate(value.from) : ""}
                disabled={props.disabled}
              />
              <input
                type="hidden"
                name={`${name}_to`}
                value={value?.to ? toISODate(value.to) : ""}
                disabled={props.disabled}
              />
            </>
          )
        }
      >
        <div className="flex flex-col sm:flex-row">
          {presets && presets.length > 0 && (
            <div
              role="group"
              aria-label="Presets"
              className="flex shrink-0 flex-col gap-px border-b border-border-default p-1 sm:w-40 sm:border-b-0 sm:border-r"
            >
              {presets.map((preset) => {
                const active = sameDay(value?.from, preset.range.from) && sameDay(value?.to, preset.range.to);
                return (
                  <button
                    key={preset.label}
                    type="button"
                    aria-pressed={active}
                    className={cn(menuItem, "w-full text-left hover:bg-state-hover aria-pressed:bg-state-selected")}
                    onClick={() => commit({ from: preset.range.from, to: preset.range.to })}
                  >
                    {preset.label}
                  </button>
                );
              })}
            </div>
          )}
          <Calendar
            mode="range"
            // Moving focus into the grid is the point of opening a date popup.
            // eslint-disable-next-line jsx-a11y/no-autofocus
            autoFocus
            numberOfMonths={numberOfMonths}
            selected={draft?.from ? { from: draft.from, to: draft.to } : undefined}
            // react-day-picker completes a range on the first click (from = to)
            // and then nudges the nearer end. Here the first click starts a
            // range, the second finishes it, and a third starts over.
            onSelect={(_range, day) => {
              if (!draft?.from || draft.to) {
                setDraft({ from: day });
                return;
              }
              commit(day < draft.from ? { from: day, to: draft.from } : { from: draft.from, to: day });
            }}
            defaultMonth={value?.from ?? defaultMonth}
            today={today}
            startMonth={min}
            endMonth={max}
            disabled={disabledMatchers(min, max, disabledDates)}
          />
        </div>
      </DateFieldFrame>
    );
  }
);
DateRangePicker.displayName = "DateRangePicker";
