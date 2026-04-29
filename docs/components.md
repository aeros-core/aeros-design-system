# Components

Each component ships in both `@aeros/react` and `aeros_design_system` (Flutter) with matching API intent. Where Flutter uses Material behaviors (ripple, focus), we style them to match the web component.

## Inventory

| Component | React | Flutter | Notes |
|---|---|---|---|
| Button | `Button` | `AerosButton` | 6 variants × 5 sizes, `loading`, leading/trailing icons |
| Input | `Input` + `Field` | `AerosTextField` | Prefix/suffix, error/success states |
| Textarea | `Textarea` | — | Use `AerosTextField` with `maxLines` in Flutter |
| Select | `Select*` (Radix) | — | Use Flutter's `DropdownMenu` with theme |
| Checkbox | `Checkbox` | `AerosCheckbox` | Indeterminate supported |
| Radio | `RadioGroup` | `AerosRadio` | |
| Switch | `Switch` | `AerosSwitch` | |
| Badge | `Badge` | `AerosBadge` | 6 tones, optional dot |
| Tag | `Tag` | `AerosTag` | Blue / grey / slate |
| Card | `Card*` | `AerosCard` | Header/Body/Footer composition |
| StatCard | `StatCard` | `AerosStatCard` | Label + value + delta |
| Alert | `Alert` | `AerosAlert` | Blue / green / amber / red |
| Progress | `Progress` | `AerosProgress` | 4 color variants |
| Avatar | `Avatar`, `AvatarStack` | `AerosAvatar` | 5 sizes, 4 tones |
| Tabs | `Tabs*` | `AerosTabs` | Underline + pill variants |
| Breadcrumb | `Breadcrumb` | `AerosBreadcrumb` | |
| Dropdown Menu | `DropdownMenu*` (Radix) | — | Use Flutter `PopupMenuButton` |
| Dialog | `Dialog*` (Radix) | — | Use `showDialog` with theme |
| Tooltip | `Tooltip*` (Radix) | — | Use Flutter `Tooltip` with theme |
| Table | `Table` + helpers | — | Plain Flutter `DataTable` |
| Empty state | `EmptyState` | `AerosEmptyState` | |
| TopNav | `TopNav*` | — | |
| Sidebar | `Sidebar*` | — | |
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

Variants: `primary | secondary | ghost | danger | dark | link`
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
    <Badge variant="green" dot>Live</Badge>
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
  trailing: const AerosBadge(label: 'Live', tone: AerosBadgeTone.green),
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
| Success | `variant="green"` | `AerosBadgeTone.green` |
| Warning | `variant="amber"` | `AerosBadgeTone.amber` |
| Danger  | `variant="red"`   | `AerosBadgeTone.red`   |
| Info    | `variant="blue"`  | `AerosBadgeTone.blue`  |
| Neutral | `variant="grey"`  | `AerosBadgeTone.grey`  |
| Dark    | `variant="dark"`  | `AerosBadgeTone.dark`  |

```tsx
<Badge variant="green" dot>Active</Badge>
```

## Alert

```tsx
<Alert variant="amber" title="Delayed">Shipment running 2 hours behind.</Alert>
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
    AerosVariantOption(id: 'blu', label: 'Royal',   swatchColor: 0xFF2347D9, stockQty: 7),
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
