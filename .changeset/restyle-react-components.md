---
"@aeros-core/react": major
---

**3.0 — every component except the app shell is restyled on shared recipes.** Resting surfaces are a hairline with no shadow; only floating layers have elevation; nothing lifts or scales on hover; one focus ring everywhere.

Breaking changes to act on:

- **Button:** `size="icon-sm|icon-md|icon-lg"` → `size="sm|md|lg" iconOnly`. `variant="danger"` is now solid; use `variant="danger-subtle"` for the old tinted look. Heights are 24 / 28 / 32 / 36 / 40 (were 28 / 32 / 36 / 40 / 48). `asChild` now works with `leadingIcon` / `trailingIcon`.
- **Field:** no longer has a bottom margin — wrap fields in the new `FieldGroup`, or space them yourself. Inputs, textareas and select triggers are 28 / 32 / 36 high.
- **Tabs:** `TabsContent` no longer has a top margin.
- **Dialog:** default width is 520 (was 420); pass `size="sm"` for 400. New `size` prop on `DialogContent`, `AlertDialogContent` and `DrawerContent`. Modal footers have no fill.
- **Card / StatCard:** no shadow. `interactive` cards change border and fill on hover instead of lifting.
- **Toast:** tones colour the title; the surface is always the neutral elevated one.
- **Avatar:** sizes are 20 / 24 / 32 / 40 / 56. **Checkbox / Radio:** 16px. **Switch:** 20×36.
- **Focus:** components no longer draw a ring; the global `:focus-visible` outline does. Remove any `ring-offset-*` overrides you added to match the old ring.

New: `DropdownMenuCheckboxItem`, `DropdownMenuRadioGroup` / `RadioItem`, `DropdownMenuSub` / `SubTrigger` / `SubContent`, `DropdownMenuShortcut`, `TooltipContent arrow`, `FieldGroup`, styled `DrawerTitle` / `DrawerDescription`.

Fixed: `Button asChild` threw; toast success / warning text failed contrast in light mode; `StatCard` did not announce the delta direction; `CommandInput` had no focus indicator.
