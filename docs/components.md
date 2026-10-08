# Components

Each component ships in both `@aeros-core/react` and `aeros_design_system` (Flutter) with matching API intent. Where Flutter uses Material behaviors (ripple, focus), we style them to match the web component.

## Inventory

| Component | React | Flutter | Notes |
|---|---|---|---|
| Button | `Button` | `AerosButton` | 5 variants × 5 sizes, `loading`, leading/trailing icons |
| Input | `Input` + `Field` | `AerosTextField` | Prefix/suffix, error/success states |
| Textarea | `Textarea` | — | Use `AerosTextField` with `maxLines` in Flutter |
| Select | `Select*` (Radix) | `AerosDropdownSearch` | Scrolls long lists; `state`/`size` props on web |
| Checkbox | `Checkbox` | `AerosCheckbox` | Indeterminate supported |
| Radio | `RadioGroup` | `AerosRadio` | |
| Switch | `Switch` | `AerosSwitch` | |
| Badge | `Badge` | `AerosBadge` | 6 tones, optional dot |
| Count badge | — | `AerosCountBadge` | Unread / pending count; `99+` cap, `N+` floor, muted grey |
| Filter chip | — | `AerosFilterChip` | One filter in a chip row: count, leading icon, dropdown caret, clear ✕, warning tone |
| Tag | `Tag` | `AerosTag` | Info / neutral / inverse |
| Card | `Card*` | `AerosCard` | Header/Body/Footer composition |
| StatCard | `StatCard` | `AerosStatCard` | Label + value + delta |
| Alert | `Alert` | `AerosAlert` | Info / success / warning / danger |
| Progress | `Progress` | `AerosProgress` | 4 color variants |
| Avatar | `Avatar`, `AvatarStack` | `AerosAvatar` | 5 sizes, 5 variants |
| Tabs | `Tabs*` | `AerosTabs` | Underline + pill variants |
| Breadcrumb | `Breadcrumb` | `AerosBreadcrumb` | |
| Dropdown Menu | `DropdownMenu*` (Radix) | — | Use Flutter `PopupMenuButton` with theme |
| Dialog | `Dialog*` (Radix) | `AerosConfirmDialog` | `showClose`, scrollable body |
| Tooltip | `Tooltip*` (Radix) | `AerosTooltip` | Themed; message exposed to AT |
| Table | `Table` + helpers | `AerosDataTable` | Sortable `Th` (aria-sort), `selected` rows, loading/empty rows |
| Empty state | `EmptyState` | `AerosEmptyState` | |
| TopNav | `TopNav*` | `AerosTopnav` | `asChild`, `aria-current` on web |
| Sidebar | `Sidebar*` | `AerosSidenav` | 32px rows, 16px icons, 13px labels; sentence-case group labels; `count` pill; Flutter `density: touch` = 48px rows; Flutter `AerosSidenavHeader` (workspace + switcher) / `AerosSidenavFooter` (signed-in person + one action) are the 56px top and bottom blocks. `asChild`, `aria-current` on web. Web chrome is dark in both themes; Flutter uses `bgSurface` |
| Attribute selector | — | `AerosAttributeSelector` | Picks the right input from `(datatype, optionSource)` — see [configurable-mto.md](./configurable-mto.md) |
| Enum dropdown | — | `AerosEnumDropdown` | Single-select dropdown over `AerosAttributeOption[]` |
| Enum chips | — | `AerosEnumChips` | Single-select chip group with optional unit suffix and colour swatches |
| Range slider | — | `AerosRangeSlider` | MEASUREMENT + RANGE attribute |
| Measurement input | — | `AerosMeasurementInput` | Number field + unit dropdown |
| File upload | — | `AerosFileUploadButton` | Empty-state and attached-file states; consumer manages the actual upload |
| Variant picker | — | `AerosVariantPicker` | Chip or swatch style; in-stock badge from `stockQty` |
| Price breakdown | — | `AerosPriceBreakdown` | Collapsible breakdown of `BreakdownStep[]` with discountable / non-discountable subtotal split |
| Routing-signal badge | — | `AerosRoutingSignalBadge` | Pill for `requires_rfq`, `requires_credit_check`, …; severity-driven colour |
| Constraint error alert | — | `AerosConstraintErrorAlert` | Locale-aware constraint violations from v1 literal or v2 JSONLogic constraints |
| Wordmark | `aeros-logo` (CSS class) | `AerosWordmark` | Brand mark: Nunito Sans wdth-125, weight 800 |
| Label | `Label` | — | Standalone control label (Radix) |
| Separator | `Separator` | Material `Divider` | |
| Spinner | `Spinner` | Material `CircularProgressIndicator` | `role="status"` + sr-only label |
| Skeleton | `Skeleton` | — | `aria-hidden`; respects reduced motion |
| Toast | `Toast*` + `Toaster` / `toast()` | `AerosSnackbar.show` | Imperative queue on web; tones on both |
| Alert dialog | `AlertDialog*` (Radix) | `AerosConfirmDialog(barrierDismissible: false)` | Must-answer confirmations |
| Popover | `Popover*` (Radix) | — | |
| Accordion | `Accordion*` (Radix) | Material `ExpansionTile` | Token motion, reduced-motion safe |
| Drawer / Sheet | `Drawer*` | Material `showModalBottomSheet` | right / left / bottom |
| Pagination | `Pagination` | `AerosPagination` | `aria-current="page"`, ellipsis model |
| Command / Combobox | `Command*` (cmdk) | `AerosDropdownSearch` | Compose in `Popover` for select-with-search |
| Calendar / DatePicker | `Calendar` (react-day-picker) | — | Compose in `Popover`; token-styled |
| Search field | recipe: `Input prefix={<Search/>}` | `AerosSearchField` | Escape clears; labeled clear button |
| Tag field | — | `AerosTagField` | |
| Stepper / Pagination shells | — | `AerosStepper`, `AerosScaffold`, `AerosPageHeader` | |

## Button

```tsx
// React
<Button variant="primary">Create RFQ</Button>
<Button variant="secondary" size="sm" leadingIcon={<Plus />}>Add line</Button>
<Button variant="ghost">Cancel</Button>
<Button variant="danger">Delete</Button>
<Button variant="primary" loading>Saving…</Button>
<Button asChild><Link href="/rfqs">All RFQs</Link></Button>
```

```dart
// Flutter
AerosButton.primary(label: 'Create RFQ', onPressed: () {})
AerosButton.secondary(label: 'Add line', onPressed: () {}, size: AerosButtonSize.sm, leading: Icon(Icons.add, size: 14))
AerosButton.ghost(label: 'Cancel', onPressed: () {})
AerosButton.danger(label: 'Delete', onPressed: () {})
const AerosButton(label: 'Saving…', onPressed: null, loading: true)
```

Variants: `primary | secondary | ghost | danger | link`
Sizes: `xs | sm | md | lg | xl`

## Input / Text field

```tsx
<Field label="Email" required hint="We'll never share your address">
  <Input type="email" placeholder="you@example.com" />
</Field>

<Field label="Search"><Input prefix={<Search className="h-4 w-4" />} placeholder="Search RFQs…" /></Field>
```

```dart
AerosTextField(label: 'Email', hint: 'you@example.com', required: true, helperText: "We'll never share your address")
```

## Card

```tsx
<Card>
  <CardHeader>
    <div>
      <CardTitle>Today's production</CardTitle>
      <CardSubtitle>Line 3 · updated 3 min ago</CardSubtitle>
    </div>
    <Badge variant="success" dot>Live</Badge>
  </CardHeader>
  <CardBody>…</CardBody>
  <CardFooter>
    <span className="text-xs text-fg-muted">8% above yesterday</span>
    <Button variant="secondary" size="sm">View</Button>
  </CardFooter>
</Card>
```

```dart
AerosCard(
  title: "Today's production",
  subtitle: 'Line 3 · updated 3 min ago',
  trailing: const AerosBadge(label: 'Live', tone: AerosBadgeTone.success),
  footer: Row(/* … */),
  child: AerosProgress(label: 'Output', value: 0.64),
)
```

## StatCard

```tsx
<StatCard label="RFQ value" value="₹1,24,000" mono delta={{ value: "+8%", direction: "up" }} />
```

```dart
const AerosStatCard(label: 'RFQ value', value: '₹1,24,000', mono: true, delta: '+8%', deltaDirection: AerosDelta.up)
```

## Badge

| Tone | React prop | Flutter |
|---|---|---|
| Success | `variant="success"` | `AerosBadgeTone.success` |
| Warning | `variant="warning"` | `AerosBadgeTone.warning` |
| Danger  | `variant="danger"` | `AerosBadgeTone.danger` |
| Info    | `variant="info"` | `AerosBadgeTone.info` |
| Neutral | `variant="neutral"` | `AerosBadgeTone.neutral` |
| Inverse | `variant="inverse"` | `AerosBadgeTone.inverse` |

```tsx
<Badge variant="success" dot>Active</Badge>
```

## Density

`AerosDensity` sizes a surface by the pointer that will use it. **`pointer` on desktop web, `touch` on phones and tablets.** Wrap the surface in an `AerosDensityScope`; widgets and screens read it with `AerosDensity.of(context)`. With no scope it resolves to `touch`, so nothing changes until a screen opts in.

| Metric | `pointer` | `touch` |
|---|---|---|
| `controlHeight` (chips, inline filters) | 28 | 32 (44 tap target) |
| `headerHeight` (app bars, pane headers) | 48 | 56 |
| `rowPadding` (list rows) | 12 × 10 | 16 × 10 |
| `listAvatar` / `inlineAvatar` | 40 / 26 | 48 / 30 |
| `iconButton` / `iconSize` | 32 / 18 | 44 / 22 |
| `badgeHeight` | 18 | 20 |
| `titleStyle` | 14 / 1.3 w600 | 16 / 1.25 w600 |
| `bodyStyle` | 14 / 1.4 | 14 / 1.45 |
| `secondaryStyle` | 13 / 1.35 | 13 / 1.35 |
| `metaStyle` | 12 / 1.25 | 12 / 1.3 |
| `labelStyle` | 12 w600 | 13 w600 |
| `microStyle` | 11 / 1.2 | 11 / 1.2 |

`touch` keeps the phone's type sizes; it only tightens line heights. The ramp's styles take a `weight:` and move Inter's `wght` axis with it — never re-weight an Aeros style with `copyWith(fontWeight:)`, which does not change the glyphs (use `withWeight`).

The reference for `pointer` is WhatsApp Desktop and Apple Mail: two-line list rows, timestamps inside the message, one filter row, one slim status strip. Information density is a feature (principle 1).

## Count badge

```dart
AerosCountBadge(count: row.unread, muted: row.muted, semanticsLabel: '${row.unread} unread')
```

A filled pill, never narrower than tall. `floor: true` renders `6+` when the number is a lower bound.

## Filter chip

```dart
AerosFilterChip(label: 'Mine', count: 6, countIsFloor: true, selected: lens == Lens.mine, onTap: …)
AerosFilterChip(label: 'Needs attention', leadingIcon: Icons.flag_rounded, tone: AerosFilterChipTone.warning, …)
AerosFilterChip(label: stage == null ? 'Stage' : 'Stage: ${stage.name}', dropdown: true, selected: stage != null, onTap: openMenu, onClear: clear)
```

Lay chips out in one horizontally scrolling row. A dropdown chip that is set shows a ✕ that clears it without reopening the menu.

## Alert

```tsx
<Alert variant="warning" title="Delayed">Shipment running 2 hours behind.</Alert>
```

## Tabs

Two variants — `underline` (page-level navigation) and `pill` (dense, inline filters).

```tsx
<Tabs defaultValue="overview" variant="underline">
  <TabsList>
    <TabsTrigger value="overview">Overview <TabCount>12</TabCount></TabsTrigger>
    <TabsTrigger value="orders">Orders</TabsTrigger>
  </TabsList>
  <TabsContent value="overview">…</TabsContent>
</Tabs>
```

## Dialog

```tsx
<Dialog>
  <DialogTrigger asChild><Button>Invite</Button></DialogTrigger>
  <DialogContent>
    <DialogHeader>
      <DialogTitle>Invite a teammate</DialogTitle>
      <DialogDescription>They'll get access to this workspace.</DialogDescription>
    </DialogHeader>
    <DialogBody><Field label="Email"><Input /></Field></DialogBody>
    <DialogFooter>
      <DialogClose asChild><Button variant="secondary">Cancel</Button></DialogClose>
      <Button>Send invite</Button>
    </DialogFooter>
  </DialogContent>
</Dialog>
```

## Empty state

```tsx
<EmptyState
  icon={<Inbox className="h-5 w-5" />}
  title="No RFQs yet"
  description="When buyers submit requests, they'll show up here."
  action={<Button>Invite team</Button>}
/>
```

## Wordmark

The Aeros brand mark — Nunito Sans **wdth-125, weight 800** — matches the
web's `aeros-logo` CSS class (`font-stretch: 125%`). Use it whenever the
literal "Aeros" string is rendered as branding (auth screens, splash,
walkthrough, web shell). Never `Text('Aeros')` with a default font.

```dart
// Default — 24px, fgPrimary from the active theme.
const AerosWordmark()

// Hero / splash.
const AerosWordmark(size: 40)

// Inverse on a brand-coloured surface.
AerosWordmark(size: 32, color: Colors.white)
```

## Configurable-MTO components (Flutter)

These ten components support the [configurable-MTO](./configurable-mto.md) listing
mode shipped in the backend in April 2026. They are Flutter-only for v1 — both
consumers (`aeros-mobile-marketplace-app` and `aeros-admin`) are Flutter. React
parity will follow when the storefront frontend lands.

### AerosAttributeSelector

Routes to the right leaf input based on `(datatype, optionSource)`:

```dart
AerosAttributeSelector(
  spec: AerosAttributeSpec(
    key: 'cup_size',
    label: 'Cup size',
    datatype: AerosAttributeDatatype.enumValue,
    optionSource: AerosAttributeOptionSource.enumOptions,
    required: true,
    options: [
      AerosAttributeOption(id: '200ml', label: '200ml'),
      AerosAttributeOption(id: '350ml', label: '350ml'),
      AerosAttributeOption(id: '500ml', label: '500ml'),
    ],
  ),
  value: AerosAttributeValue(enumValueId: '350ml'),
  onChanged: (v) => /* persist v.enumValueId into your form state */,
)
```

See [configurable-mto.md](./configurable-mto.md) for the full datatype × option-source
matrix, leaf-input APIs, token tables, and integration recipes.

### AerosVariantPicker

Single-select picker over a list of `AerosVariantOption`. Out-of-stock and
low-stock badges render automatically from `stockQty`:

```dart
AerosVariantPicker(
  label: 'Colour',
  selectedVariantId: state.variantId,
  onChanged: (id) => state.setVariant(id),
  style: AerosVariantPickerStyle.swatch, // or .chip
  variants: [
    AerosVariantOption(id: 'red', label: 'Crimson', swatchColor: 0xFFDC2626, stockQty: 1200),
    AerosVariantOption(id: 'chr', label: 'Charcoal', swatchColor: 0xFF404040, stockQty: 7),
    AerosVariantOption(id: 'grn', label: 'Forest',  swatchColor: 0xFF15803D, stockQty: 0),
  ],
)
```

### AerosPriceBreakdown

Collapsible card driven by the backend pricing-engine output. Renders the
`discountable` / `non-discountable` subtotal split with `AerosPriceTone` colour
tokens:

```dart
AerosPriceBreakdown(
  data: AerosPriceBreakdownData(
    currencySymbol: '₹',
    discountableSubtotal: 6500,
    nonDiscountableSubtotal: 500,
    total: 7000,
    steps: [
      AerosBreakdownStep(name: 'Base price · 350ml', amount: 4.5, perUnit: true),
      AerosBreakdownStep(name: 'GSM 250',            amount: 0.6, perUnit: true),
      AerosBreakdownStep(name: 'Plate setup',        amount: 500, discountable: false),
    ],
  ),
)
```

### AerosRoutingSignalBadge

```dart
AerosRoutingSignalBadge(
  signal: AerosRoutingSignal(
    kind: 'requires_rfq',
    label: 'Send as RFQ',
    severity: AerosRoutingSeverity.warn,
  ),
  onTap: () => showSheet(...),
)
```

### AerosConstraintErrorAlert

Locale-aware. The backend stores the message as a JSONB locale map; pass it
directly:

```dart
AerosConstraintErrorAlert(
  messageByLocale: {
    'en': 'Custom Pantone print requires GSM ≥ 250.',
    'hi': 'कस्टम पैंटोन प्रिंट के लिए जीएसएम ≥ 250 चाहिए।',
  },
  locale: appLocale,
)
```
