# Components

The inventory of both libraries: every export of `@aeros-core/react` and every public symbol of `aeros_design_system`, side by side. It is written from the two barrel files, [`packages/react/src/index.ts`](../packages/react/src/index.ts) and [`packages/flutter/lib/aeros_design_system.dart`](../packages/flutter/lib/aeros_design_system.dart). When you add or remove an export, update this page in the same change.

For live examples of every React component, run the showcase in `packages/react-docs`. For the Flutter widgets, run `packages/flutter/example`.

## How components are built

**Components compose recipes; they do not restate styles.** Each library has one layer where a family's look is defined, and every component in the family is assembled from it. A change to the look is made once, in that layer.

### React: shared recipes

[`packages/react/src/internal/recipes.ts`](../packages/react/src/internal/recipes.ts) holds the recipes. It is not exported from the package.

| Recipe | Defines | Composed by |
|---|---|---|
| `colorTransition`, `disabledControl` | Colour-only state changes; the disabled treatment | `Button`, `Toggle`, `Checkbox`, `RadioGroupItem`, `Switch`, the sidebar and header rows, and others |
| `controlSize`, `controlSquare` | Height, padding, gap, label type and icon size for the `xs`–`xl` ladder | `Button`, `Toggle` and its group forms |
| `fieldBase`, `fieldSize`, `fieldState` | The look of every text-entry control and its `sm` / `md` / `lg` sizes and `default` / `error` / `success` states | `Input`, `Textarea`, `SelectTrigger`, `Combobox`, `DatePicker`, `NumberInput` |
| `floatingPanel`, `menuPanel`, `overlayMotion` | A floating surface: `bg-bg-elevated`, `shadow-overlay`, no border, enter and exit motion | `DropdownMenuContent`, `SelectContent`, `PopoverContent` |
| `menuItem`, `menuItemState`, `menuItemDanger`, `menuLabel`, `menuSeparator`, `menuShortcut` | One row spec for every list of choices | `DropdownMenu*`, `Select*`, `Command*`, `Combobox` |
| `scrim`, `modalPanel`, `dialogMotion`, `dialogSize`, `dialogPosition`, `modalHeader`, `modalTitle`, `modalDescription`, `modalBody`, `modalFooter`, `modalClose` | The scrim and the header / body / footer of a modal surface | `Dialog*`, `AlertDialog*`, `Drawer*`, the mobile `Sidebar` sheet |

Rules for contributors:

- Use a recipe when one exists. If two components need the same string of classes, move it into `recipes.ts`.
- Use token classes only: alias colours, `text-<role>`, `rounded-<shape>`, `shadow-<elevation>`, `h-control-<size>`, `duration-<name>`, `z-<layer>`. `pnpm check:hardcoded` fails on anything else.
- Do not draw a focus ring. The global `:focus-visible` outline is the ring; a component may only move it with `focus-ring-field` or `focus-ring-inset`.
- A floating layer takes an elevation and no border class.
- Merge classes with `cn()`. It is configured from the tokens, so `text-body-sm text-fg-muted` keeps both and `rounded-md rounded-control` resolves to the latter.

### Flutter: the foundation layer

[`packages/flutter/lib/src/foundation/`](../packages/flutter/lib/src/foundation) holds six primitives. All are exported, so an app can build its own controls on them.

| Primitive | Defines |
|---|---|
| `AerosPressable` | The one interaction primitive: hover, press, keyboard focus, Enter / Space activation, semantics, and a tappable box at least the density's minimum target. Reports an `AerosInteraction` to its builder. No ripple. |
| `AerosStateLayer`, `AerosStateFill` | The hover / pressed / selected overlays composited over a base colour, and a hairline box that animates between them |
| `AerosFocusRing` | The focus ring, painted outside the child so focus never shifts layout. `AerosFocusRingPlacement`: `outside`, `field`, `inset`. `AerosFocusRingTone.danger` for invalid controls |
| `AerosSurface` | A surface at an `AerosSurfaceLevel`: `flat`, `raised`, `overlay`, `modal`. The only place a `BoxShadow` is attached |
| `AerosControlSize`, `AerosControlSizeScope` | The size ladder shared by buttons and fields, resolved for the ambient density |
| `AerosFieldFrame` | The field look, for a composite input that should match `AerosTextField` |

Rules for contributors:

- Build interaction on `AerosPressable`. Do not use `InkWell`, or Material's `showDialog`, `showMenu`, `showModalBottomSheet`, `DropdownButton` or `DataTable` inside `lib`.
- Attach a shadow only through `AerosSurface`. Use `AerosShapeTokens` for radii, never a literal.
- Read colours from the theme: `context.aerosColors`, `context.aerosSemantic`, `context.aerosElevation`.
- Read sizes from the density: `AerosDensity.of(context).sizes`.
- Set a weight with `AerosTypography.role(weight: …)` or `withWeight`, not `copyWith(fontWeight:)`.

## Inventory

React names are exports of `@aeros-core/react`. Flutter names are exports of `package:aeros_design_system/aeros_design_system.dart`. "Web only" and "Flutter only" mean the other library has no counterpart.

### Actions

| Component | React | Flutter | Notes |
|---|---|---|---|
| Button | `Button`, `buttonVariants` | `AerosButton`, `AerosButtonVariant` | Variants `primary`, `secondary`, `ghost`, `danger`, `danger-subtle` / `dangerSubtle`, `link`. Sizes `xs`–`xl` from the control ladder. Icon-only: `iconOnly` on the web, `AerosButton.icon` in Flutter. `asChild` is web only. |
| Toggle | `Toggle`, `ToggleGroup`, `ToggleGroupItem`, `toggleVariants` | — | Web only. A pressed / not-pressed button and a group of them. |
| Segmented control | `SegmentedControl`, `SegmentedControlItem` | — | Web only as a component. In Flutter use `AerosTabs` with `AerosTabVariant.pill` for the same look. |

### Forms

| Component | React | Flutter | Notes |
|---|---|---|---|
| Field wrapper | `Field`, `FieldGroup`, `useFieldControl` | `AerosFormField` | `Field` wires label, hint and error to its control and has no margin; `FieldGroup` stacks fields. `AerosFormField` is the label / helper / error wrapper for field-like widgets. `AerosTextField` draws its own label. |
| Text input | `Input` | `AerosTextField` | Prefix and suffix, `error` / `success` state. Web sizes `sm` / `md` / `lg`; Flutter takes any `AerosControlSize`. |
| Textarea | `Textarea` | — | Web only as a component. In Flutter use `AerosTextField` with `maxLines`. |
| Search field | — | `AerosSearchField` | Flutter only. On the web use `Input` with a search icon as `prefix`. |
| Tag field | — | `AerosTagField` | Flutter only. |
| Number input | `NumberInput` | — | Web only. Keyboard stepping, clamping, precision, unit prefix / suffix. `AerosMeasurementInput` is the closest Flutter widget (a number with a unit). |
| Select | `Select`, `SelectTrigger`, `SelectValue`, `SelectContent`, `SelectItem`, `SelectGroup`, `SelectLabel`, `SelectSeparator`, `SelectScrollUpButton`, `SelectScrollDownButton` | `AerosSelect`, `AerosSelectItem` | A field-styled trigger that opens a list. Radix parts on the web; one widget with `items` in Flutter. |
| Select with search | `Combobox`, `MultiCombobox` | `AerosDropdownSearch`, `AerosDropdownMode`, `AerosDropdownItemAsString`, `AerosDropdownOnFind`, `AerosDropdownItemBuilder` | Groups, descriptions, clear and async options on the web. `AerosDropdownSearch` opens as a menu, a dialog or a sheet (`AerosDropdownMode`). Multi-select is web only. |
| Checkbox | `Checkbox` | `AerosCheckbox` | 16px box, indeterminate / mixed supported. Flutter: `compact` shrinks the hit area to the glyph. |
| Radio | `RadioGroup`, `RadioGroupItem` | `AerosRadio` | 16px. The web has a group component; in Flutter each `AerosRadio` takes `value` and `groupValue`. |
| Switch | `Switch` | `AerosSwitch` | Web 36×20, Flutter 32×18. Monochrome on both; no Cupertino switch in Flutter. |
| Label | `Label` | — | Web only. A standalone control label; `Field` renders its own. |
| Date picker | `DatePicker`, `DateRangePicker`, `Calendar`, `formatDisplayDate`, `toISODate` | — | Web only. Field-styled triggers over `Calendar` (react-day-picker), with min / max, presets and form posting. |
| File upload | `FileUpload` | `AerosFileUploadButton` | `FileUpload` is a drop zone that validates and lists files. `AerosFileUploadButton` shows an empty or attached state and leaves picking and uploading to the app. |
| Repeating rows | — | `AerosRepeatingRows` | Flutter only. An add / remove list of row editors. |

### Data display

| Component | React | Flutter | Notes |
|---|---|---|---|
| Badge | `Badge`, `badgeVariants` | `AerosBadge`, `AerosBadgeTone` | A pill with a tinted fill and a tone border; optional dot. Web 20px high; Flutter 18 at pointer and 20 at touch. |
| Count badge | `CountBadge` | `AerosCountBadge` | Unread / pending count. |
| Tag | `Tag`, `tagVariants` | `AerosTag`, `AerosTagTone` | Like a badge with 4px corners. Flutter tags can be removable. |
| Filter chip | `FilterChip` | `AerosFilterChip`, `AerosFilterChipTone` | One filter in a chip row: count, caret, clear. |
| Avatar | `Avatar`, `AvatarStack`, `avatarVariants` | `AerosAvatar`, `AerosAvatarSize`, `AerosAvatarTone` | Sizes 20 / 24 / 32 / 40 / 56. `AvatarStack` is web only. |
| Card | `Card`, `CardHeader`, `CardTitle`, `CardSubtitle`, `CardBody`, `CardFooter` | `AerosCard`, `AerosCardVariant` | Flat: fill and hairline, no shadow. Composed parts on the web; `title` / `child` / `footer` arguments in Flutter. `AerosCardVariant.raised` is deprecated and renders flat. |
| Stat card | `StatCard` | `AerosStatCard`, `AerosDelta` | Label, value, delta. The delta direction is announced in words on both. |
| Intent card | — | `AerosIntentCard` | Flutter only. A tappable card with an icon tile, title and description. |
| Table | `Table`, `Thead`, `Tbody`, `Tr`, `Th`, `Td`, `TdStrong`, `TdMono`, `TdMuted`, `TableLoadingRow`, `TableEmptyRow` | — | Web only as parts. The presentational table: sortable `Th`, `selected` rows, loading and empty rows. |
| Data table | `DataTable`, `createDataTableColumnHelper` | `AerosDataTable`, `AerosDataColumn`, `AerosDataSort` | Sorting, row selection, sticky header, loading and empty states on both. Density setting, pagination and a selection bar are web only (`@tanstack/react-table`). The Flutter table takes a `footer` widget for pagination. |
| Empty state | `EmptyState` | `AerosEmptyState` | Icon, title, description, action. Dashed outline in Flutter. |
| Keyboard key | `Kbd`, `KbdGroup` | — | Web only. |
| Wordmark | — | `AerosWordmark` | The Aeros wordmark. On the web it is the `aeros-logo` CSS class, not a component. Do not restyle it. |
| Dot matrix | `DotMatrix` | — | Web only. An animated dot-grid indicator. |
| Thinking orb | — | `AerosThinkingOrb` | Flutter only. An animated working indicator. |

### Feedback

| Component | React | Flutter | Notes |
|---|---|---|---|
| Alert | `Alert`, `alertVariants` | `AerosAlert`, `AerosAlertTone` | Tint and hairline; `info` / `success` / `warning` / `danger`. |
| Toast / snackbar | `toast`, `Toaster`, `useToastQueue`, `Toast`, `ToastProvider`, `ToastViewport`, `ToastTitle`, `ToastDescription`, `ToastAction`, `ToastClose` | `AerosSnackbar`, `AerosSnackbarTone` | An elevated surface; the tone colours the title. Web: call `toast()` and mount `<Toaster />` once. Flutter: `AerosSnackbar.show`. |
| Progress | `Progress` | `AerosProgress` | A 4px pill track; indeterminate supported in Flutter. |
| Stepper | `Stepper` | `AerosStepper` | Steps of a flow with their state. |
| Spinner | `Spinner` | — | Web only. In Flutter use `CircularProgressIndicator`; the theme styles it. |
| Skeleton | `Skeleton` | — | Web only. |
| Tooltip | `Tooltip`, `TooltipTrigger`, `TooltipContent`, `TooltipProvider` | `AerosTooltip` | Inverse surface, caption text. `arrow` on `TooltipContent` is web only. |

### Overlays

| Component | React | Flutter | Notes |
|---|---|---|---|
| Dialog | `Dialog`, `DialogTrigger`, `DialogContent`, `DialogHeader`, `DialogTitle`, `DialogDescription`, `DialogBody`, `DialogFooter`, `DialogClose`, `DialogOverlay`, `DialogPortal` | `AerosDialog`, `AerosDialogSize` | Sizes `sm` 400, `md` 520 (default), `lg` 720, `xl` 960; the web adds `full`. Web: composed Radix parts. Flutter: `AerosDialog.show`. |
| Confirmation | `AlertDialog`, `AlertDialogTrigger`, `AlertDialogContent`, `AlertDialogHeader`, `AlertDialogTitle`, `AlertDialogDescription`, `AlertDialogFooter`, `AlertDialogAction`, `AlertDialogCancel`, `AlertDialogOverlay`, `AlertDialogPortal` | `AerosConfirmDialog` | A dialog that must be answered; `sm` (400) by default on both. |
| Drawer / sheet | `Drawer`, `DrawerTrigger`, `DrawerContent`, `DrawerHeader`, `DrawerTitle`, `DrawerDescription`, `DrawerBody`, `DrawerFooter`, `DrawerClose`, `DrawerOverlay`, `DrawerPortal` | `AerosSheet`, `AerosSheetSide`, `AerosSheetSize` | Sides `right`, `left`, `bottom`; side widths `sm` 360, `md` 480, `lg` 640. The Flutter bottom sheet has a drag handle. |
| Popover | `Popover`, `PopoverTrigger`, `PopoverContent`, `PopoverAnchor`, `PopoverClose` | `AerosPopover`, `AerosPopoverController`, `AerosPopoverSide`, `AerosPopoverAlign` | An anchored floating surface with any content. |
| Menu | `DropdownMenu`, `DropdownMenuTrigger`, `DropdownMenuContent`, `DropdownMenuItem`, `DropdownMenuCheckboxItem`, `DropdownMenuRadioGroup`, `DropdownMenuRadioItem`, `DropdownMenuLabel`, `DropdownMenuSeparator`, `DropdownMenuShortcut`, `DropdownMenuGroup`, `DropdownMenuPortal`, `DropdownMenuSub`, `DropdownMenuSubTrigger`, `DropdownMenuSubContent` | `AerosMenu`, `AerosMenuItem`, `AerosMenuCheckboxItem`, `AerosMenuRadioItem`, `AerosMenuSeparator`, `AerosMenuLabel`, `AerosMenuEntry`, `AerosMenuRow`, `AerosMenuRowMark`, `AerosMenuList`, `AerosWholeRows`, `AerosMenuController` | Items, checkbox and radio items, labels, separators, shortcuts. Submenus are web only. `AerosMenuRow`, `AerosMenuList` and `AerosWholeRows` are the row and list on their own, for custom menus. |
| Command list | `Command`, `CommandInput`, `CommandList`, `CommandEmpty`, `CommandGroup`, `CommandItem`, `CommandSeparator` | — | Web only (cmdk). A filterable list; `Combobox` is built on it. |

### Navigation

| Component | React | Flutter | Notes |
|---|---|---|---|
| Tabs | `Tabs`, `TabsList`, `TabsTrigger`, `TabsContent`, `TabCount` | `AerosTabs`, `AerosTabVariant` | Underline and pill variants. `TabsContent` has no margin. |
| Breadcrumb | `Breadcrumb` | `AerosBreadcrumb`, `AerosBreadcrumbItem` | On the web an item is the `BreadcrumbItem` type. |
| Pagination | `Pagination` | `AerosPagination`, `AerosPaginationVariant` | — |
| Accordion | `Accordion`, `AccordionItem`, `AccordionTrigger`, `AccordionContent` | — | Web only. |
| Collapsible | `Collapsible`, `CollapsibleTrigger`, `CollapsibleContent` | — | Web only. |

### App shell and layout

| Component | React | Flutter | Notes |
|---|---|---|---|
| Shell | `AppShell`, `AppMain`, `AppContent`, `AppFooter` | `AerosScaffold`, `AerosScaffoldState` | The page frame. `AerosScaffold` takes `topnav`, `sidenav` and `body`, and moves the sidenav into a drawer below the `md` breakpoint. |
| Header | `AppHeader`, `AppHeaderBrand`, `AppHeaderTitle`, `AppHeaderNav`, `AppHeaderLink`, `AppHeaderActions` | `AerosTopnav` | One header high: 48 at pointer, 56 at touch. Composed parts on the web; `title`, `leading`, `actions` in Flutter. |
| Sidebar | `Sidebar`, `SidebarProvider`, `useSidebar`, `SidebarHeader`, `SidebarContent`, `SidebarFooter`, `SidebarBrand`, `SidebarMenuButton`, `SidebarSection`, `SidebarItem`, `SidebarGroup`, `SidebarSubItem`, `SidebarTrigger` | `AerosSidenav`, `AerosNavItem`, `AerosSidenavHeader`, `AerosSidenavFooter`, `AerosSidenavMark`, `AerosSidenavDensity`, `AerosSidenavExpanded`, `AerosSidenavScope`, `AerosSidebarController`, `kAerosSidenavBlockHeight` | One design on both platforms (`docs/sidebar/spec.md`): 240 wide, 56 as an icon rail; a sheet or drawer below `md`, a rail that floats open between `md` and `lg`, expanded from `lg`; icons 28px from the edge in every state; groups nest and open as a menu in the rail; Cmd/Ctrl+B toggles. Web: `SidebarProvider` owns the state and remembers it under `storageKey` (localStorage and a cookie). Flutter: `AerosScaffold` presents the sidenav, and an `AerosSidebarController` owns and remembers the choice through storage the app plugs in. Flutter: pass `collapsed` and handle `onExpandRequested`. `kAerosSidenavBlockHeight` is deprecated. |
| Page header | `PageHeader` | `AerosPageHeader` | Title, description, back link and actions above page content. |
| Scroll area | `ScrollArea` | — | Web only. The Flutter theme styles the platform scrollbar. |
| Separator | `Separator` | — | Web only. In Flutter use `Divider`; the theme styles it. |
| Responsive helpers | — | `AerosResponsiveValue`, `AerosResponsiveGrid`, `AerosTwoColumn`, `AerosBreakpoint`, `AerosBreakpoints`, `AerosViewportScope` | Flutter only. On the web use Tailwind's breakpoint variants. |
| Hover helper | — | `AerosHoverable` | Flutter only. Hover tracking for custom rows; a real button when given `onTap`. |

### Made-to-order configuration

| Component | React | Flutter | Notes |
|---|---|---|---|
| Attribute selector | — | `AerosAttributeSelector`, `AerosAttributeInputVariant` | Flutter only. Picks the input for an attribute. See [configurable-mto.md](./configurable-mto.md). |
| Inputs | — | `AerosEnumDropdown`, `AerosEnumChips`, `AerosRangeSlider`, `AerosNumericRangeBand`, `AerosMeasurementInput` | Flutter only. |
| Variant picker | — | `AerosVariantPicker`, `AerosVariantPickerStyle` | Flutter only. Chips or swatches with stock badges. |
| Price breakdown | — | `AerosPriceBreakdown`, `AerosAmountFormat`, `AerosDigitGrouping`, `AerosAmountFormatter` | Flutter only. Amounts are grouped (Indian grouping for ₹ / INR); pass `formatAmount` to change it. |
| Routing and constraints | — | `AerosRoutingSignalBadge`, `AerosConstraintErrorAlert` | Flutter only. |
| Data models | — | `AerosAttributeSpec`, `AerosAttributeValue`, `AerosAttributeOption`, `AerosAttributeDatatype`, `AerosAttributeOptionSource`, `AerosMeasurementUnit`, `AerosNumericRange`, `AerosFileRef`, `AerosVariantOption`, `AerosBreakdownStep`, `AerosPriceBreakdownData`, `AerosRoutingSignal`, `AerosRoutingSeverity` | Flutter only. Plain value classes the host app fills from API responses. |
| State palettes | — | `AerosSeverity`, `AerosSeverityPalette`, `AerosSelectionState`, `AerosSelectionPalette`, `AerosPriceTone`, `AerosPricePalette` | Flutter only. Resolve with `.of(context, …)`. |

### Foundation, theme and tokens

| Component | React | Flutter | Notes |
|---|---|---|---|
| Class merging | `cn` | — | Web only. `clsx` plus `tailwind-merge`, configured from the tokens. |
| Interaction | — | `AerosPressable`, `AerosInteraction`, `AerosPressableBuilder`, `AerosStateLayer`, `AerosStateFill` | Flutter only. The web equivalent is the internal recipes, which are not exported. |
| Focus ring | — | `AerosFocusRing`, `AerosFocusRingPlacement`, `AerosFocusRingTone` | Flutter only. On the web the ring is the global `:focus-visible` outline. |
| Surface | — | `AerosSurface`, `AerosSurfaceLevel` | Flutter only. On the web use `shadow-raised` / `shadow-overlay` / `shadow-modal`. |
| Control size | — | `AerosControlSize`, `AerosControlSizeScope`, `AerosButtonSize`, `AerosFieldSize` | Flutter only. `AerosButtonSize` and `AerosFieldSize` are deprecated aliases of `AerosControlSize`. |
| Field frame | — | `AerosFieldFrame` | Flutter only. |
| Theme | — | `AerosTheme`, `AerosThemeExtension`, `AerosThemeContext` | Flutter only. `AerosTheme.light()` / `.dark()`; `AerosThemeContext` adds `context.aeros`, `context.aerosColors`, `context.aerosSemantic`, `context.aerosElevation`. On the web the theme is `data-theme`. |
| Density | — | `AerosDensity`, `AerosDensityScope` | Flutter only. On the web density is `data-density`. |
| Colour tokens | — | `AerosColors`, `AerosAliasColors`, `AerosSemanticColors` | Flutter only. On the web these are CSS variables and Tailwind classes. |
| Type tokens | — | `AerosTypography`, `AerosTextStyleWeight` | Flutter only. `AerosTextStyleWeight` adds `withWeight` to `TextStyle`. |
| Other tokens | — | `AerosSpacing`, `AerosRadii`, `AerosMotion`, `AerosElevation`, `AerosSizeTokens`, `AerosShapeTokens`, `AerosMetricTokens` | Flutter only. See [tokens.md](./tokens.md). |

## Exported types

Type-only exports of `@aeros-core/react`, by source file. Every component's props are also available through `React.ComponentProps<typeof Component>`.

| File | Types |
|---|---|
| `button.tsx` | `ButtonProps` |
| `input.tsx` | `FieldControlSize`, `FieldControlProps`, `InputProps`, `FieldProps` |
| `textarea.tsx` | `TextareaProps` |
| `badge.tsx` | `BadgeProps` |
| `tag.tsx` | `TagProps` |
| `card.tsx` | `CardProps` |
| `stat-card.tsx` | `StatCardProps` |
| `alert.tsx` | `AlertProps` |
| `progress.tsx` | `ProgressProps` |
| `avatar.tsx` | `AvatarProps` |
| `tabs.tsx` | `TabsProps`, `TabCountProps` |
| `breadcrumb.tsx` | `BreadcrumbItem`, `BreadcrumbProps` |
| `table.tsx` | `TableProps`, `TrProps`, `ThProps`, `TableStateRowProps`, `TableLoadingRowProps` |
| `empty-state.tsx` | `EmptyStateProps` |
| `app-shell.tsx` | `AppHeaderBrandProps`, `AppHeaderLinkProps` |
| `sidebar.tsx` | `SidebarProviderProps`, `SidebarProps`, `SidebarBrandProps`, `SidebarMenuButtonProps`, `SidebarSectionProps`, `SidebarItemProps`, `SidebarGroupProps`, `SidebarSubItemProps` |
| `dot-matrix.tsx` | `DotMatrixProps` |
| `spinner.tsx` | `SpinnerProps` |
| `toast.tsx` | `ToastOptions` |
| `pagination.tsx` | `PaginationProps` |
| `calendar.tsx` | `CalendarProps` |
| `data-table.tsx` | `DataTableColumnMeta`, `DataTableFeatures`, `DataTableColumn`, `DataTableInstance`, `DataTableSortingState`, `DataTableRowSelectionState`, `DataTablePaginationState`, `DataTableDensity`, `DataTableProps` |
| `toggle.tsx` | `ToggleVariant`, `ToggleProps`, `ToggleGroupProps`, `ToggleGroupItemProps`, `SegmentedControlProps`, `SegmentedControlItemProps` |
| `collapsible.tsx` | `CollapsibleProps`, `CollapsibleTriggerProps`, `CollapsibleContentProps` |
| `scroll-area.tsx` | `ScrollAreaProps` |
| `count-badge.tsx` | `CountBadgeTone`, `CountBadgeProps` |
| `filter-chip.tsx` | `FilterChipTone`, `FilterChipProps` |
| `page-header.tsx` | `PageHeaderBack`, `PageHeaderProps` |
| `file-upload.tsx` | `FileRejectionReason`, `FileRejection`, `FileUploadProps` |
| `stepper.tsx` | `StepperStep`, `StepState`, `StepperProps` |
| `combobox.tsx` | `ComboboxOption`, `ComboboxProps`, `MultiComboboxProps` |
| `date-picker.tsx` | `DatePickerProps`, `DateRangeValue`, `DateRangePreset`, `DateRangePickerProps` |
| `number-input.tsx` | `NumberInputProps` |
