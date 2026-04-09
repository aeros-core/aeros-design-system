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
