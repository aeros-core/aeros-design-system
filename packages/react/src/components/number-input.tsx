"use client";
import * as React from "react";
import { ChevronDown, ChevronUp } from "lucide-react";
import { cn } from "../lib/cn";
import { fieldBase, fieldSize, fieldState, type FieldSize, type FieldState } from "../internal/recipes";
import { useFieldControl } from "./input";

// A numeric field: a text input with spinbutton semantics and two stepper
// buttons. Text (not type="number") so there are no native spinners, no
// scroll-wheel changes, and the field can hold a half-typed value like "-".

export interface NumberInputProps
  extends Omit<
    React.InputHTMLAttributes<HTMLInputElement>,
    "value" | "defaultValue" | "onChange" | "min" | "max" | "step" | "size" | "prefix" | "type" | "role" | "name"
  > {
  value?: number | null;
  defaultValue?: number | null;
  /** Called as the user types a valid number, steps, or clears (null). */
  onValueChange?: (value: number | null) => void;
  min?: number;
  max?: number;
  /** Arrow keys and stepper buttons move by this; Shift and PageUp/PageDown by ten times it. */
  step?: number;
  /** Decimal places. The value is rounded to it on blur and shown padded to it. */
  precision?: number;
  /** Short unit before the number, e.g. ₹. */
  prefix?: React.ReactNode;
  /** Short unit after the number, e.g. kg. */
  suffix?: React.ReactNode;
  size?: FieldSize;
  state?: FieldState;
  /** Renders a hidden input holding the numeric value. */
  name?: string;
  /** Class for the wrapper; `className` goes to the input itself. */
  containerClassName?: string;
}

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

function decimalsOf(n: number) {
  const text = String(n);
  const exponent = text.indexOf("e-");
  if (exponent >= 0) return Number(text.slice(exponent + 2));
  const dot = text.indexOf(".");
  return dot < 0 ? 0 : text.length - dot - 1;
}

const roundTo = (n: number, places: number) => Number(n.toFixed(Math.min(Math.max(places, 0), 20)));

/** Where the unit sits, per size: the field's own inline padding. */
const prefixInset: Record<FieldSize, string> = { sm: "pl-2.5", md: "pl-3", lg: "pl-3.5" };

const stepper =
  "flex min-h-0 flex-1 items-center justify-center text-fg-muted transition-colors duration-quick " +
  "hover:bg-state-hover hover:text-fg-primary active:bg-state-pressed " +
  "disabled:pointer-events-none disabled:opacity-disabled [&_svg]:size-icon-xs";

export const NumberInput = React.forwardRef<HTMLInputElement, NumberInputProps>(
  (
    {
      value: valueProp,
      defaultValue = null,
      onValueChange,
      min,
      max,
      step = 1,
      precision,
      prefix,
      suffix,
      size = "md",
      state,
      name,
      className,
      containerClassName,
      disabled,
      readOnly,
      onKeyDown,
      onBlur,
      style,
      ...props
    },
    ref
  ) => {
    const { fieldProps, state: resolvedState } = useFieldControl(props, state);
    const [value, setValue] = useControlled<number | null>(valueProp, defaultValue, onValueChange);
    // What the user is typing; null means "show the formatted value".
    const [draft, setDraft] = React.useState<string | null>(null);
    const inputRef = React.useRef<HTMLInputElement | null>(null);
    const prefixRef = React.useRef<HTMLSpanElement | null>(null);
    const suffixRef = React.useRef<HTMLSpanElement | null>(null);
    const [unitWidth, setUnitWidth] = React.useState({ prefix: 0, suffix: 0 });

    const setRef = React.useCallback(
      (node: HTMLInputElement | null) => {
        inputRef.current = node;
        if (typeof ref === "function") ref(node);
        else if (ref) ref.current = node;
      },
      [ref]
    );

    // Units can be any width ("₹", "INR", "pcs"), so the input's padding is
    // measured rather than guessed. Until measured, the classes below apply.
    React.useEffect(() => {
      const next = { prefix: prefixRef.current?.offsetWidth ?? 0, suffix: suffixRef.current?.offsetWidth ?? 0 };
      setUnitWidth((prev) => (prev.prefix === next.prefix && prev.suffix === next.suffix ? prev : next));
    }, [prefix, suffix, size]);

    const clamp = (n: number) => Math.min(max ?? Infinity, Math.max(min ?? -Infinity, n));
    const normalise = (n: number) => clamp(precision === undefined ? n : roundTo(n, precision));
    const format = (n: number | null) => (n === null ? "" : precision === undefined ? String(n) : n.toFixed(precision));
    const commit = (next: number | null) => {
      if (next !== value) setValue(next);
    };

    const allowNegative = min === undefined || min < 0;
    const allowDecimal = precision !== 0;
    const accepts = (text: string) =>
      new RegExp(`^${allowNegative ? "-?" : ""}\\d*${allowDecimal ? "(\\.\\d*)?" : ""}$`).test(text);
    const parse = (text: string) => (/\d/.test(text) && Number.isFinite(Number(text)) ? Number(text) : null);

    const locked = Boolean(disabled || readOnly);
    const atMin = min !== undefined && value !== null && value <= min;
    const atMax = max !== undefined && value !== null && value >= max;

    const stepBy = (direction: 1 | -1, multiplier = 1) => {
      if (locked) return;
      const base = value ?? 0;
      const places = precision ?? Math.max(decimalsOf(step), decimalsOf(base));
      commit(clamp(roundTo(base + direction * step * multiplier, places)));
      setDraft(null);
    };

    const text = draft ?? format(value);
    const unitText = [prefix, value === null ? null : format(value), suffix].filter(
      (part): part is string => typeof part === "string" && part !== ""
    );

    return (
      <div
        // A group, so the disabled state reaches the unit prefix/suffix too.
        role="group"
        aria-disabled={disabled || undefined}
        className={cn("relative w-full", containerClassName)}
      >
        {prefix != null && (
          <span
            ref={prefixRef}
            aria-hidden
            className={cn(
              "pointer-events-none absolute inset-y-0 left-0 flex items-center text-body-sm text-fg-muted [&_svg]:size-icon-md",
              prefixInset[size],
              disabled && "opacity-disabled"
            )}
          >
            {prefix}
          </span>
        )}
        <input
          ref={setRef}
          type="text"
          role="spinbutton"
          inputMode="decimal"
          autoComplete="off"
          aria-valuenow={value ?? undefined}
          aria-valuemin={min}
          aria-valuemax={max}
          // Only worth announcing when a unit adds something the bare number lacks.
          aria-valuetext={value !== null && unitText.length > 1 ? unitText.join(" ") : undefined}
          disabled={disabled}
          readOnly={readOnly}
          value={text}
          className={cn(
            fieldBase,
            fieldSize[size],
            fieldState[resolvedState],
            "pr-8 tabular-nums",
            prefix != null && "pl-8",
            suffix != null && "pr-14",
            className
          )}
          style={{
            ...(unitWidth.prefix ? { paddingLeft: unitWidth.prefix + 6 } : null),
            ...(unitWidth.suffix ? { paddingRight: unitWidth.suffix + 30 } : null),
            ...style
          }}
          onChange={(event) => {
            const next = event.target.value;
            // Anything that is not on the way to a number is dropped; the field keeps what it had.
            if (!accepts(next)) return;
            setDraft(next);
            if (next === "") commit(null);
            else {
              const parsed = parse(next);
              if (parsed !== null) commit(parsed);
            }
          }}
          onBlur={(event) => {
            onBlur?.(event);
            // A draft that never became a number ("-", ".") falls back to the last valid value.
            const settled = draft === null || draft === "" ? value : (parse(draft) ?? value);
            if (draft === "") commit(null);
            else if (settled !== null) commit(normalise(settled));
            setDraft(null);
          }}
          onKeyDown={(event) => {
            onKeyDown?.(event);
            if (event.defaultPrevented || locked) return;
            const big = event.shiftKey ? 10 : 1;
            if (event.key === "ArrowUp") stepBy(1, big);
            else if (event.key === "ArrowDown") stepBy(-1, big);
            else if (event.key === "PageUp") stepBy(1, 10);
            else if (event.key === "PageDown") stepBy(-1, 10);
            else if (event.key === "Home" && min !== undefined) {
              commit(min);
              setDraft(null);
            } else if (event.key === "End" && max !== undefined) {
              commit(max);
              setDraft(null);
            } else return;
            event.preventDefault();
          }}
          {...props}
          {...fieldProps}
        />
        {suffix != null && (
          <span
            ref={suffixRef}
            aria-hidden
            className={cn(
              "pointer-events-none absolute inset-y-0 right-6 flex items-center pr-2 text-body-sm text-fg-muted [&_svg]:size-icon-md",
              disabled && "opacity-disabled"
            )}
          >
            {suffix}
          </span>
        )}
        {/* Mouse-only shortcuts: the keyboard steps with the arrow keys, so these stay out of the tab order. */}
        <div
          className="absolute inset-y-px right-px flex w-6 flex-col overflow-hidden rounded-r-control border-l border-border-default"
        >
          <button
            type="button"
            tabIndex={-1}
            aria-label="Increase"
            disabled={locked || atMax}
            className={stepper}
            // Keep focus (and the caret) in the input.
            onMouseDown={(event) => event.preventDefault()}
            onClick={() => {
              stepBy(1);
              inputRef.current?.focus();
            }}
          >
            <ChevronUp aria-hidden />
          </button>
          <button
            type="button"
            tabIndex={-1}
            aria-label="Decrease"
            disabled={locked || atMin}
            className={cn(stepper, "border-t border-border-default")}
            onMouseDown={(event) => event.preventDefault()}
            onClick={() => {
              stepBy(-1);
              inputRef.current?.focus();
            }}
          >
            <ChevronDown aria-hidden />
          </button>
        </div>
        {name && <input type="hidden" name={name} value={value ?? ""} disabled={disabled} />}
      </div>
    );
  }
);
NumberInput.displayName = "NumberInput";
