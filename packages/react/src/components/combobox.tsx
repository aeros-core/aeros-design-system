"use client";
import * as React from "react";
import { Check, ChevronDown, X } from "lucide-react";
import { cn } from "../lib/cn";
import { fieldBase, fieldSize, fieldState, type FieldSize, type FieldState } from "../internal/recipes";
import { Command, CommandEmpty, CommandGroup, CommandInput, CommandItem, CommandList } from "./command";
import { useFieldControl } from "./input";
import { Popover, PopoverContent, PopoverTrigger } from "./popover";
import { Spinner } from "./spinner";
import { Tag } from "./tag";

// A select with search: a field-styled trigger that opens a cmdk list in a
// Popover. `Combobox` holds one value, `MultiCombobox` a list shown as tags.
//
// The trigger is a real <button role="combobox"> so a <Field> label can target
// it. Buttons cannot nest, so the clear button and the removable tags sit in a
// sibling layer stacked over the trigger (same grid cell, same padding).

export interface ComboboxOption {
  value: string;
  label: string;
  /** Second line under the label; also searched. */
  description?: string;
  disabled?: boolean;
  /** Options sharing a group render under that heading, in first-seen order. */
  group?: string;
}

type TriggerProps = Omit<
  React.ButtonHTMLAttributes<HTMLButtonElement>,
  "value" | "defaultValue" | "onChange" | "name" | "children" | "role" | "type"
>;

interface ComboboxSharedProps extends TriggerProps {
  options: ComboboxOption[];
  placeholder?: string;
  searchPlaceholder?: string;
  emptyText?: React.ReactNode;
  size?: FieldSize;
  state?: FieldState;
  /** Shows a spinner row in the list (async options). */
  loading?: boolean;
  loadingText?: string;
  /** Called with the search text as the user types, and with "" when the list closes. */
  onSearchChange?: (search: string) => void;
  /** Set false when the caller filters `options` itself (async search). */
  shouldFilter?: boolean;
  /** Custom match: return true to keep the option. Default: case-insensitive substring of label + description. */
  filter?: (option: ComboboxOption, search: string) => boolean;
  /** Renders hidden input(s) so the value posts with a form. */
  name?: string;
  open?: boolean;
  defaultOpen?: boolean;
  onOpenChange?: (open: boolean) => void;
  /** Accessible name of the popup. */
  popupLabel?: string;
  /** Class for the wrapper around the trigger; `className` goes to the trigger itself. */
  containerClassName?: string;
}

export interface ComboboxProps extends ComboboxSharedProps {
  value?: string | null;
  defaultValue?: string | null;
  onValueChange?: (value: string | null) => void;
  /** Shows a clear button while a value is selected. */
  clearable?: boolean;
}

export interface MultiComboboxProps extends ComboboxSharedProps {
  value?: string[];
  defaultValue?: string[];
  onValueChange?: (values: string[]) => void;
  /** Tags shown before the rest collapse into "+N". */
  maxTags?: number;
  clearable?: boolean;
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

function useMergedRef<T>(...refs: (React.Ref<T> | undefined)[]) {
  return React.useCallback((node: T | null) => {
    for (const ref of refs) {
      if (typeof ref === "function") ref(node);
      else if (ref) (ref as React.MutableRefObject<T | null>).current = node;
    }
  }, refs);
}

const defaultFilter = (option: ComboboxOption, search: string) =>
  `${option.label} ${option.description ?? ""}`.toLowerCase().includes(search.trim().toLowerCase());

/** Small ghost button that lives inside a field (clear, remove). */
const fieldAction =
  "pointer-events-auto inline-flex size-5 shrink-0 items-center justify-center rounded-item text-fg-muted " +
  "transition-colors duration-quick hover:bg-state-hover hover:text-fg-primary [&_svg]:size-icon-sm";

function groupOptions(options: ComboboxOption[]) {
  const groups: { heading?: string; options: ComboboxOption[] }[] = [];
  const byHeading = new Map<string | undefined, ComboboxOption[]>();
  for (const option of options) {
    let bucket = byHeading.get(option.group);
    if (!bucket) {
      bucket = [];
      byHeading.set(option.group, bucket);
      groups.push({ heading: option.group, options: bucket });
    }
    bucket.push(option);
  }
  return groups;
}

interface FrameProps extends Omit<ComboboxSharedProps, "placeholder" | "name"> {
  forwardedRef: React.ForwardedRef<HTMLButtonElement>;
  hasValue: boolean;
  /** What the trigger shows (and exposes as its text). */
  display: React.ReactNode;
  /** Interactive pieces laid over the trigger; receives a function that returns focus to it. */
  overlay?: (focusTrigger: () => void) => React.ReactNode;
  /** Keep room in the trigger for an overlaid clear button. */
  reserveAction?: boolean;
  isSelected: (value: string) => boolean;
  onPick: (option: ComboboxOption) => void;
  /** Row highlighted when the list opens. */
  highlight?: string;
  multiple?: boolean;
  children?: React.ReactNode;
}

function ComboboxFrame({
  forwardedRef,
  hasValue,
  display,
  overlay,
  reserveAction,
  isSelected,
  onPick,
  highlight,
  multiple,
  children,
  options,
  searchPlaceholder = "Search…",
  emptyText = "No results.",
  size = "md",
  state,
  loading,
  loadingText = "Loading…",
  onSearchChange,
  shouldFilter = true,
  filter = defaultFilter,
  open: openProp,
  defaultOpen = false,
  onOpenChange,
  popupLabel = "Options",
  containerClassName,
  className,
  disabled,
  onKeyDown,
  ...props
}: FrameProps) {
  const { fieldProps, state: resolvedState } = useFieldControl(props, state);
  const [open, setOpen] = useControlled(openProp, defaultOpen, onOpenChange);
  const [search, setSearchState] = React.useState("");
  const triggerRef = React.useRef<HTMLButtonElement | null>(null);
  const ref = useMergedRef(forwardedRef, triggerRef);
  const popupId = React.useId();

  const setSearch = (next: string) => {
    setSearchState(next);
    onSearchChange?.(next);
  };

  const handleOpenChange = (next: boolean) => {
    setOpen(next);
    if (!next && search !== "") setSearch("");
  };

  const byValue = React.useMemo(() => new Map(options.map((o) => [o.value, o])), [options]);
  const groups = React.useMemo(() => groupOptions(options), [options]);
  const overlayNode = overlay?.(() => triggerRef.current?.focus());

  return (
    <div className={cn("grid w-full", containerClassName)}>
      <Popover open={open} onOpenChange={handleOpenChange}>
        <PopoverTrigger asChild>
          <button
            ref={ref}
            type="button"
            role="combobox"
            aria-expanded={open}
            aria-controls={popupId}
            disabled={disabled}
            data-placeholder={hasValue ? undefined : ""}
            className={cn(
              fieldBase,
              "col-start-1 row-start-1 flex items-center gap-2 text-left",
              fieldSize[size],
              fieldState[resolvedState],
              className
            )}
            onKeyDown={(event) => {
              onKeyDown?.(event);
              if (event.defaultPrevented) return;
              if (event.key === "ArrowDown" || event.key === "ArrowUp") {
                event.preventDefault();
                handleOpenChange(true);
              }
            }}
            {...props}
            {...fieldProps}
          >
            <span className="min-w-0 flex-1 truncate">{display}</span>
            {reserveAction && <span aria-hidden className="size-5 shrink-0" />}
            <ChevronDown aria-hidden className="size-icon-md shrink-0 text-fg-muted" />
          </button>
        </PopoverTrigger>
        <PopoverContent
          id={popupId}
          align="start"
          aria-label={popupLabel}
          className="w-(--radix-popover-trigger-width) min-w-48 overflow-hidden p-0"
        >
          <Command
            label={searchPlaceholder}
            shouldFilter={shouldFilter}
            defaultValue={highlight}
            // cmdk scores by the item's value; ours is an id, so match on the option instead.
            filter={(value, term) => {
              const option = byValue.get(value);
              return option && filter(option, term) ? 1 : 0;
            }}
          >
            <CommandInput placeholder={searchPlaceholder} value={search} onValueChange={setSearch} />
            <CommandList aria-multiselectable={multiple || undefined}>
              {!loading && <CommandEmpty>{emptyText}</CommandEmpty>}
              {groups.map((group, index) => {
                const items = group.options.map((option) => {
                  const selected = isSelected(option.value);
                  return (
                    <CommandItem
                      key={option.value}
                      value={option.value}
                      disabled={option.disabled}
                      aria-checked={selected}
                      onSelect={() => onPick(option)}
                      className="pr-8"
                    >
                      <span className="flex min-w-0 flex-col py-1">
                        <span className="truncate">{option.label}</span>
                        {option.description && (
                          <span className="truncate text-caption text-fg-muted">{option.description}</span>
                        )}
                      </span>
                      {/* The check trails the label, as in Select. */}
                      {selected && (
                        <span className="absolute right-2 flex size-icon-md items-center justify-center">
                          <Check aria-hidden className="text-fg-primary" />
                        </span>
                      )}
                    </CommandItem>
                  );
                });
                return group.heading ? (
                  <CommandGroup key={`group-${group.heading}`} heading={group.heading}>
                    {items}
                  </CommandGroup>
                ) : (
                  <React.Fragment key={`ungrouped-${index}`}>{items}</React.Fragment>
                );
              })}
              {loading && (
                <div className="flex min-h-control-sm items-center gap-2 px-2 text-body-sm text-fg-muted">
                  <Spinner size="sm" label={loadingText} />
                  <span aria-hidden>{loadingText}</span>
                </div>
              )}
            </CommandList>
          </Command>
        </PopoverContent>
      </Popover>
      {overlayNode && (
        <div
          role="group"
          aria-disabled={disabled || undefined}
          className={cn(
            "pointer-events-none col-start-1 row-start-1 flex min-w-0 items-center gap-2 border border-transparent",
            fieldSize[size],
            disabled && "opacity-disabled"
          )}
        >
          {overlayNode}
          {/* Stands in for the trigger's chevron so the two layers line up. */}
          <span aria-hidden className="size-icon-md shrink-0" />
        </div>
      )}
      {children}
    </div>
  );
}

// ── Single ────────────────────────────────────────────────

export const Combobox = React.forwardRef<HTMLButtonElement, ComboboxProps>(
  ({ value: valueProp, defaultValue = null, onValueChange, clearable, placeholder, name, ...props }, ref) => {
    const [value, setValue] = useControlled<string | null>(valueProp, defaultValue, onValueChange);
    // Remembers the label of a picked option that later leaves `options` (async search).
    const [picked, setPicked] = React.useState<ComboboxOption | null>(null);
    const [open, setOpen] = useControlled(props.open, props.defaultOpen ?? false, props.onOpenChange);

    const selected =
      value == null
        ? undefined
        : (props.options.find((o) => o.value === value) ?? (picked?.value === value ? picked : undefined));
    const hasValue = value != null;
    const showClear = Boolean(clearable && hasValue && !props.disabled);

    return (
      <ComboboxFrame
        {...props}
        forwardedRef={ref}
        open={open}
        onOpenChange={setOpen}
        hasValue={hasValue}
        display={hasValue ? (selected?.label ?? value) : placeholder}
        reserveAction={showClear}
        highlight={value ?? undefined}
        isSelected={(v) => v === value}
        onPick={(option) => {
          setPicked(option);
          if (option.value !== value) setValue(option.value);
          setOpen(false);
        }}
        overlay={
          showClear
            ? (focusTrigger) => (
                <>
                  <span className="flex-1" />
                  <button
                    type="button"
                    aria-label="Clear selection"
                    className={fieldAction}
                    onClick={() => {
                      setValue(null);
                      focusTrigger();
                    }}
                  >
                    <X aria-hidden />
                  </button>
                </>
              )
            : undefined
        }
      >
        {name && <input type="hidden" name={name} value={value ?? ""} disabled={props.disabled} />}
      </ComboboxFrame>
    );
  }
);
Combobox.displayName = "Combobox";

// ── Multiple ──────────────────────────────────────────────

const NO_VALUES: string[] = [];

export const MultiCombobox = React.forwardRef<HTMLButtonElement, MultiComboboxProps>(
  (
    { value: valueProp, defaultValue = NO_VALUES, onValueChange, maxTags = 2, clearable, placeholder, name, ...props },
    ref
  ) => {
    const [values, setValues] = useControlled<string[]>(valueProp, defaultValue, onValueChange);
    const [picked, setPicked] = React.useState<Record<string, ComboboxOption>>({});

    const labelOf = (v: string) => props.options.find((o) => o.value === v)?.label ?? picked[v]?.label ?? v;
    const hasValue = values.length > 0;
    const shown = values.slice(0, Math.max(0, maxTags));
    const hidden = values.length - shown.length;
    const showClear = Boolean(clearable && hasValue && !props.disabled);

    return (
      <ComboboxFrame
        {...props}
        forwardedRef={ref}
        multiple
        hasValue={hasValue}
        // The visible tags are in the overlay; the trigger carries the same selection as text.
        display={hasValue ? <span className="sr-only">{values.map(labelOf).join(", ")}</span> : placeholder}
        isSelected={(v) => values.includes(v)}
        onPick={(option) => {
          setPicked((prev) => ({ ...prev, [option.value]: option }));
          setValues(
            values.includes(option.value) ? values.filter((v) => v !== option.value) : [...values, option.value]
          );
        }}
        overlay={
          hasValue
            ? (focusTrigger) => (
                <>
                  <span className="flex min-w-0 flex-1 items-center gap-1 overflow-hidden">
                    {shown.map((v) => {
                      const label = labelOf(v);
                      return (
                        <Tag key={v} className="min-w-0 max-w-40 shrink gap-0.5 pr-0.5">
                          <span className="truncate">{label}</span>
                          <button
                            type="button"
                            aria-label={`Remove ${label}`}
                            disabled={props.disabled}
                            className={cn(fieldAction, "size-4 [&_svg]:size-icon-xs")}
                            onClick={() => {
                              setValues(values.filter((x) => x !== v));
                              focusTrigger();
                            }}
                          >
                            <X aria-hidden />
                          </button>
                        </Tag>
                      );
                    })}
                    {hidden > 0 && (
                      <Tag aria-hidden className="shrink-0">
                        +{hidden}
                      </Tag>
                    )}
                  </span>
                  {showClear && (
                    <button
                      type="button"
                      aria-label="Clear selection"
                      className={fieldAction}
                      onClick={() => {
                        setValues([]);
                        focusTrigger();
                      }}
                    >
                      <X aria-hidden />
                    </button>
                  )}
                </>
              )
            : undefined
        }
      >
        {name && values.map((v) => <input key={v} type="hidden" name={name} value={v} disabled={props.disabled} />)}
      </ComboboxFrame>
    );
  }
);
MultiCombobox.displayName = "MultiCombobox";
