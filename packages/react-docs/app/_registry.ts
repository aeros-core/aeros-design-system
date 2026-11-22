import { FIXTURE_SLUGS, type FixtureSlug } from "./preview/_fixtures/slugs";

/**
 * The component catalogue of the showcase site: one entry per component page
 * (`/components/<slug>`), each naming the preview fixtures it shows.
 *
 * Plain data on purpose — no React, no CSS — so the Playwright specs in `e2e/`
 * can import it from Node.
 *
 * The guard at the bottom of this file ties it to the fixture list in both
 * directions, so a new component cannot be forgotten:
 *   - a fixture slug that no entry shows (and that is not listed in
 *     NON_COMPONENT_FIXTURES) is a type error → `next build` fails;
 *   - an entry naming a fixture that does not exist is a type error;
 *   - a fixture shown by two entries throws while the build prerenders.
 */

export const FAMILIES = [
  "Actions",
  "Forms",
  "Data display",
  "Feedback",
  "Navigation",
  "Overlays",
  "Layout",
] as const;
export type Family = (typeof FAMILIES)[number];

export interface ComponentDoc {
  title: string;
  family: Family;
  /** One paragraph: what it is and when to reach for it. */
  description: string;
  /** The named exports to import from `@aeros-core/react`. */
  imports: readonly string[];
  /** A short usage snippet (TSX). */
  usage: string;
  /** The preview fixtures shown on the page, in order. The first is the primary one. */
  fixtures: readonly [FixtureSlug, ...FixtureSlug[]];
}

/** Fixtures that are not a component page: the foundations pages cover them. */
export const NON_COMPONENT_FIXTURES = ["foundations-type", "foundations-surfaces"] as const;

export interface FixtureFrameSpec {
  /** Frame height in pixels. */
  height: number;
  /**
   * False for a forced-open overlay: the frame is `inert`, so the overlay's
   * focus trap cannot pull focus (and the scroll position) out of the page.
   * The page links to the fixture for anyone who wants to operate it.
   */
  interactive: boolean;
}

/**
 * Fixtures shown in an isolated frame instead of inline. These render a
 * forced-open overlay (inline it would trap focus and block the whole page),
 * or are full-height chrome sized by the viewport.
 */
export const FRAMED_FIXTURES: Partial<Record<FixtureSlug, FixtureFrameSpec>> = {
  "select-open": { height: 320, interactive: false },
  "combobox-open": { height: 400, interactive: false },
  // Framed although it is not an overlay: a DatePicker inside a Field
  // intermittently points aria-labelledby at an id that is not in the DOM after
  // hydration (a component defect, reproducible on /preview/date-picker). In a
  // frame it stays the fixture suite's finding instead of a flaky site page.
  "date-picker": { height: 860, interactive: true },
  "date-picker-open": { height: 520, interactive: false },
  "dropdown-menu": { height: 460, interactive: false },
  dialog: { height: 480, interactive: false },
  "alert-dialog": { height: 400, interactive: false },
  "drawer-right": { height: 480, interactive: false },
  "drawer-left": { height: 480, interactive: false },
  "drawer-bottom": { height: 480, interactive: false },
  popover: { height: 300, interactive: false },
  tooltip: { height: 200, interactive: false },
  toast: { height: 480, interactive: true },
  sidebar: { height: 620, interactive: true },
  "sidebar-rail": { height: 620, interactive: true },
  "app-shell": { height: 620, interactive: true },
  "app-header": { height: 420, interactive: true },
  "page-header": { height: 760, interactive: true },
};

const define = <const T extends Record<string, ComponentDoc>>(components: T): T => components;

export const COMPONENTS = define({
  // ── Actions ─────────────────────────────────────────────
  button: {
    title: "Button",
    family: "Actions",
    description:
      "The standard action. Primary is solid ink and there is one per view; secondary is a hairline on the surface; ghost has no chrome until hovered. Danger is the only place a status colour fills a control. State changes are colour only — nothing lifts or scales.",
    imports: ["Button"],
    usage: `<Button>Create order</Button>
<Button variant="secondary" leadingIcon={<Download />}>Export</Button>
<Button variant="ghost" size="sm" iconOnly aria-label="Search"><Search /></Button>
<Button variant="danger" loading>Deleting…</Button>
<Button asChild trailingIcon={<ArrowRight />}><Link href="/orders">All orders</Link></Button>`,
    fixtures: ["button"],
  },
  toggle: {
    title: "Toggle",
    family: "Actions",
    description:
      "A button that stays pressed: pin, bold, show archived. Toggle is a single on/off control; ToggleGroup holds several, single or multiple, optionally joined into one bar.",
    imports: ["Toggle", "ToggleGroup", "ToggleGroupItem"],
    usage: `<Toggle variant="outline" defaultPressed>Pinned</Toggle>

<ToggleGroup type="multiple" joined aria-label="Text style">
  <ToggleGroupItem value="bold" iconOnly aria-label="Bold"><Bold /></ToggleGroupItem>
  <ToggleGroupItem value="italic" iconOnly aria-label="Italic"><Italic /></ToggleGroupItem>
</ToggleGroup>`,
    fixtures: ["toggle"],
  },
  "segmented-control": {
    title: "Segmented control",
    family: "Actions",
    description:
      "One choice out of a few, always with a value — a view switch or a date range. It is announced as a radio group and arrow keys move the selection. For more than five options, or options that need a sentence, use a Select.",
    imports: ["SegmentedControl", "SegmentedControlItem"],
    usage: `<SegmentedControl value={range} onValueChange={setRange} aria-label="Range">
  <SegmentedControlItem value="day">Day</SegmentedControlItem>
  <SegmentedControlItem value="week">Week</SegmentedControlItem>
  <SegmentedControlItem value="month">Month</SegmentedControlItem>
</SegmentedControl>`,
    fixtures: ["segmented-control"],
  },

  // ── Forms ───────────────────────────────────────────────
  input: {
    title: "Input",
    family: "Forms",
    description:
      "A single-line text field. Wrap it in Field for a label, hint and error — Field generates the ids and wires aria-describedby, aria-invalid and aria-required for you. FieldGroup stacks fields with the standard gap.",
    imports: ["Field", "FieldGroup", "Input"],
    usage: `<FieldGroup>
  <Field label="Email" required hint="We'll send the invoice here.">
    <Input type="email" placeholder="priya@example.com" />
  </Field>
  <Field label="Reference" error="This reference is already in use.">
    <Input defaultValue="PO-1042" />
  </Field>
</FieldGroup>

<Input aria-label="Search" prefix={<Search />} placeholder="Search orders" />`,
    fixtures: ["input"],
  },
  textarea: {
    title: "Textarea",
    family: "Forms",
    description:
      "A multi-line text field on the same field recipe as Input: hairline border, the focus ring on the border, error and success carried by the border colour.",
    imports: ["Field", "Textarea"],
    usage: `<Field label="Notes" hint="Visible to your team only.">
  <Textarea rows={3} placeholder="Add context for your team…" />
</Field>`,
    fixtures: ["textarea"],
  },
  select: {
    title: "Select",
    family: "Forms",
    description:
      "Pick one option from a short, known list. The trigger is a field; the list is a floating menu on the shared row spec. For long or searchable lists use Combobox.",
    imports: ["Select", "SelectContent", "SelectItem", "SelectTrigger", "SelectValue"],
    usage: `<Field label="Payment terms">
  <Select value={terms} onValueChange={setTerms}>
    <SelectTrigger>
      <SelectValue placeholder="Choose terms" />
    </SelectTrigger>
    <SelectContent>
      <SelectItem value="net-15">Net 15</SelectItem>
      <SelectItem value="net-30">Net 30</SelectItem>
    </SelectContent>
  </Select>
</Field>`,
    fixtures: ["select", "select-open"],
  },
  combobox: {
    title: "Combobox",
    family: "Forms",
    description:
      "A select with search: groups, descriptions, a clear button and async options. Combobox holds one value; MultiCombobox holds a list shown as tags.",
    imports: ["Combobox", "MultiCombobox", "type ComboboxOption"],
    usage: `const vendors: ComboboxOption[] = [
  { value: "trimurti", label: "Trimurti Packaging", group: "Packaging" },
  { value: "shakti", label: "Shakti Bearings", group: "Engineering" },
];

<Field label="Vendor" required>
  <Combobox options={vendors} value={vendor} onValueChange={setVendor} clearable
    placeholder="Choose a vendor" searchPlaceholder="Search vendors…" />
</Field>`,
    fixtures: ["combobox", "combobox-open"],
  },
  checkbox: {
    title: "Checkbox",
    family: "Forms",
    description:
      "An independent yes/no choice, or several from a list. Supports the indeterminate state for a parent of a partly-selected group.",
    imports: ["Checkbox"],
    usage: `<label className="inline-flex items-center gap-2 text-body-sm">
  <Checkbox checked={agreed} onCheckedChange={(value) => setAgreed(value === true)} />
  Email me order updates
</label>`,
    fixtures: ["checkbox"],
  },
  radio: {
    title: "Radio group",
    family: "Forms",
    description:
      "One choice from a short list where every option should stay visible. Give the group an accessible name.",
    imports: ["RadioGroup", "RadioGroupItem"],
    usage: `<RadioGroup value={mode} onValueChange={setMode} aria-label="Shipping mode">
  <label className="inline-flex items-center gap-2 text-body-sm">
    <RadioGroupItem value="road" /> Road freight
  </label>
  <label className="inline-flex items-center gap-2 text-body-sm">
    <RadioGroupItem value="air" /> Air freight
  </label>
</RadioGroup>`,
    fixtures: ["radio"],
  },
  switch: {
    title: "Switch",
    family: "Forms",
    description:
      "A setting that takes effect immediately — no save button. If the change needs confirming with the rest of a form, use a Checkbox instead.",
    imports: ["Switch"],
    usage: `<label className="inline-flex items-center gap-3 text-body-sm">
  <Switch checked={enabled} onCheckedChange={setEnabled} />
  Email me when an order ships
</label>`,
    fixtures: ["switch"],
  },
  label: {
    title: "Label",
    family: "Forms",
    description:
      "A standalone control label. Field renders its own label, so reach for this only when a control sits outside a Field — a checkbox row, a custom layout.",
    imports: ["Label"],
    usage: `<Label htmlFor="po-ref">PO reference</Label>
<Input id="po-ref" />`,
    fixtures: ["label"],
  },
  "number-input": {
    title: "Number input",
    family: "Forms",
    description:
      "A numeric field with keyboard stepping, clamping to min and max, fixed precision and a unit prefix or suffix. The value is a number or null, never a string.",
    imports: ["Field", "NumberInput"],
    usage: `<Field label="Quantity" hint="Sold in cartons of 50.">
  <NumberInput value={qty} onValueChange={setQty} min={50} step={50} suffix="pcs" />
</Field>

<NumberInput aria-label="Unit price" prefix="₹" precision={2} defaultValue={48} />`,
    fixtures: ["number-input"],
  },
  "date-picker": {
    title: "Date picker",
    family: "Forms",
    description:
      "A field-styled trigger over the Calendar. DatePicker holds one day; DateRangePicker holds a from–to range and can offer presets. Both take min, max and disabled dates, and post with a form when given a name.",
    imports: ["DatePicker", "DateRangePicker"],
    usage: `<Field label="Delivery date" required>
  <DatePicker value={date} onValueChange={setDate} min={new Date()} clearable />
</Field>

<DateRangePicker
  aria-label="Reporting period"
  value={range}
  onValueChange={setRange}
  presets={[{ label: "This week", range: { from: monday, to: sunday } }]}
/>`,
    fixtures: ["date-picker", "date-picker-open"],
  },
  calendar: {
    title: "Calendar",
    family: "Forms",
    description:
      "The month grid behind the date pickers (react-day-picker, styled from tokens). Use it directly when the calendar should stay on the page rather than open from a field.",
    imports: ["Calendar"],
    usage: `<Calendar mode="single" selected={date} onSelect={setDate} />

<Calendar mode="range" selected={range} onSelect={setRange} numberOfMonths={2} />`,
    fixtures: ["calendar"],
  },
  "file-upload": {
    title: "File upload",
    family: "Forms",
    description:
      "A drop zone with a browse button and a list of the chosen files. It validates type, size and count and reports rejections; sending the files anywhere is the caller's job.",
    imports: ["Field", "FileUpload"],
    usage: `<Field label="Attachments" hint="PDF or images, up to 5 files.">
  <FileUpload
    multiple
    accept=".pdf,image/*"
    maxFiles={5}
    maxSize={5 * 1024 * 1024}
    value={files}
    onFilesChange={setFiles}
    onReject={(rejections) => console.warn(rejections)}
    // Optional: localise the built-in strings (a partial object).
    labels={{ browse: (multiple) => (multiple ? "Dateien wählen" : "Datei wählen") }}
  />
</Field>`,
    fixtures: ["file-upload"],
  },

  // ── Data display ────────────────────────────────────────
  badge: {
    title: "Badge",
    family: "Data display",
    description:
      "The status of a record: approved, pending, rejected. Status colour appears here and nowhere decorative — the dot and the tint both carry the tone, the text states it.",
    imports: ["Badge"],
    usage: `<Badge variant="success" dot>Dispatched</Badge>
<Badge variant="warning" dot>Pending</Badge>
<Badge variant="danger" dot>Rejected</Badge>
<Badge>Draft</Badge>`,
    fixtures: ["badge"],
  },
  "count-badge": {
    title: "Count badge",
    family: "Data display",
    description:
      "A number next to a label — unread, pending, selected. Caps at 99+ by default and hides itself at zero unless told otherwise.",
    imports: ["CountBadge"],
    usage: `<span className="inline-flex items-center gap-2 text-body-sm">
  Inbox <CountBadge count={3} aria-label="3 unread" />
</span>
<CountBadge count={1250} max={999} tone="muted" />`,
    fixtures: ["count-badge"],
  },
  tag: {
    title: "Tag",
    family: "Data display",
    description:
      "A neutral label for metadata: a version, a category, a keyword. It carries no status — use Badge when the colour should mean something.",
    imports: ["Tag"],
    usage: `<Tag>v3.0.0</Tag>
<Tag variant="info">beta</Tag>
<Tag variant="inverse">internal</Tag>`,
    fixtures: ["tag"],
  },
  avatar: {
    title: "Avatar",
    family: "Data display",
    description:
      "A person or organisation: an image with an initials fallback. AvatarStack overlaps a few and counts the rest.",
    imports: ["Avatar", "AvatarStack"],
    usage: `<Avatar src={user.photo} alt={user.name} fallback="PS" />
<Avatar size="sm" variant="inverse" fallback="PS" />`,
    fixtures: ["avatar"],
  },
  card: {
    title: "Card",
    family: "Data display",
    description:
      "A resting surface: white on the canvas with a hairline and no shadow. Compose it from a header, body and footer. An interactive card changes border and fill on hover — it does not lift. On its own `interactive` is styling for a card that holds its own link or button; with `onClick` the card becomes a keyboard-operable button (give it no other control inside), and with `asChild` it renders as your element, such as a link.",
    imports: ["Card", "CardBody", "CardFooter", "CardHeader", "CardSubtitle", "CardTitle"],
    usage: `<Card>
  <CardHeader>
    <div>
      <CardTitle>Today's production</CardTitle>
      <CardSubtitle>Line 3 · updated 3 min ago</CardSubtitle>
    </div>
    <Badge variant="success" dot>Live</Badge>
  </CardHeader>
  <CardBody>…</CardBody>
  <CardFooter>
    <span className="text-caption text-fg-muted">Updated automatically</span>
    <Button variant="secondary" size="sm">View</Button>
  </CardFooter>
</Card>

// The whole card as a link, or as a button
<Card asChild interactive><Link href="/orders/1042">…</Link></Card>
<Card interactive onClick={openOrder} aria-label="Open order 1042">…</Card>`,
    fixtures: ["card"],
  },
  "stat-card": {
    title: "Stat card",
    family: "Data display",
    description:
      "One number an operator watches: a label, the value and an optional change against the previous period. The direction of the change is announced, not only coloured.",
    imports: ["StatCard"],
    usage: `<StatCard label="Output" value="4,820" delta={{ value: "+8%", direction: "up" }} />
<StatCard label="RFQ value" value="₹1,24,000" mono />`,
    fixtures: ["stat-card"],
  },
  table: {
    title: "Table",
    family: "Data display",
    description:
      "The presentational table parts: hairline rows, sortable headers with aria-sort, selected rows, loading and empty rows, and cell helpers for strong, muted and monospaced values. For sorting, selection and pagination as behaviour, use DataTable.",
    imports: ["Table", "Tbody", "Td", "TdMono", "TdMuted", "TdStrong", "Th", "Thead", "Tr"],
    usage: `<Table>
  <Thead>
    <Tr>
      <Th>RFQ</Th>
      <Th sortable sortDirection="asc" onSort={toggleSort}>Buyer</Th>
      <Th>Status</Th>
    </Tr>
  </Thead>
  <Tbody>
    <Tr>
      <Td><TdMono>RFQ-0042</TdMono></Td>
      <Td><TdStrong>Pacific Pack Co.</TdStrong></Td>
      <Td><Badge variant="success" dot>Approved</Badge></Td>
    </Tr>
  </Tbody>
</Table>`,
    fixtures: ["table"],
  },
  "data-table": {
    title: "Data table",
    family: "Data display",
    description:
      "A data grid for admin screens, built on TanStack Table and the Table parts: sorting, row selection with a selection bar, three densities, a sticky header, loading and empty states, and client or server pagination. Keep the columns array stable — module scope or useMemo.",
    imports: ["DataTable", "type DataTableColumn"],
    usage: `const columns: DataTableColumn<Order>[] = [
  { accessorKey: "id", header: "Order", meta: { mono: true, width: "7rem" } },
  { accessorKey: "vendor", header: "Vendor" },
  { accessorKey: "value", header: "Value (₹)", meta: { align: "end", mono: true } },
];

<DataTable
  aria-label="Orders"
  columns={columns}
  data={orders}
  getRowId={(order) => order.id}
  selectable
  selectionActions={(rows) => <Button size="sm">Export {rows.length}</Button>}
  pageSize={20}
  // Optional: localise the built-in strings (a partial object; keep it stable).
  labels={{ selected: (n) => \`\${n} ausgewählt\`, clearSelection: "Auswahl aufheben" }}
/>`,
    fixtures: ["data-table"],
  },
  kbd: {
    title: "Kbd",
    family: "Data display",
    description:
      "A keyboard key. KbdGroup sets a combination; use it in menus, tooltips and inline help.",
    imports: ["Kbd", "KbdGroup"],
    usage: `<KbdGroup>
  <Kbd>⌘</Kbd>
  <Kbd>K</Kbd>
</KbdGroup>`,
    fixtures: ["kbd"],
  },
  "dot-matrix": {
    title: "Dot matrix",
    family: "Data display",
    description:
      "The animated dot grid used as a brand motif on empty and loading surfaces. It is decoration: it stops under reduced motion and should never carry information.",
    imports: ["DotMatrix"],
    usage: `<DotMatrix variant="ripple" />
<DotMatrix size={200} rings={4} variant="pulse" speed={1600} />`,
    fixtures: ["dot-matrix"],
  },

  // ── Feedback ────────────────────────────────────────────
  alert: {
    title: "Alert",
    family: "Feedback",
    description:
      "A message in the flow of the page: a hairline, a tint and an icon in the status colour. Danger alerts are announced immediately (role=alert); the others politely (role=status).",
    imports: ["Alert"],
    usage: `<Alert variant="warning" title="Delayed">
  Shipment running 2 hours behind schedule.
</Alert>`,
    fixtures: ["alert"],
  },
  toast: {
    title: "Toast",
    family: "Feedback",
    description:
      "A brief confirmation that floats above the page and leaves on its own. Mount one Toaster at the root and call toast() from anywhere. The tone colours the title; the surface stays the neutral elevated one.",
    imports: ["Toaster", "toast"],
    usage: `// once, in the root layout
<Toaster />

// anywhere
toast({
  title: "Saved",
  description: "Catalog updated.",
  variant: "success",
  action: { label: "Undo", altText: "Undo the catalog update", onClick: undo },
});`,
    fixtures: ["toast"],
  },
  progress: {
    title: "Progress",
    family: "Feedback",
    description:
      "How far a measurable task has got. Give it an accessible name; use a status variant only when the value itself is good or bad.",
    imports: ["Progress"],
    usage: `<Progress value={64} aria-label="Line 3 output" />
<Progress value={22} variant="danger" aria-label="Stock remaining" />`,
    fixtures: ["progress"],
  },
  spinner: {
    title: "Spinner",
    family: "Feedback",
    description:
      "Work of unknown length is under way. It is a status region with a visually hidden label — name what is loading.",
    imports: ["Spinner"],
    usage: `<Spinner />
<Spinner size="sm" label="Loading orders" />`,
    fixtures: ["spinner"],
  },
  skeleton: {
    title: "Skeleton",
    family: "Feedback",
    description:
      "A placeholder in the shape of content that is about to arrive. Hidden from assistive tech and still under reduced motion.",
    imports: ["Skeleton"],
    usage: `<Skeleton className="h-4 w-3/4" />
<Skeleton className="size-avatar-lg rounded-pill" />`,
    fixtures: ["skeleton"],
  },
  "empty-state": {
    title: "Empty state",
    family: "Feedback",
    description:
      "What a list says when it has nothing to show: a plain title, one sentence on why, and the action that fills it.",
    imports: ["EmptyState"],
    usage: `<EmptyState
  icon={<Inbox />}
  title="No RFQs yet"
  description="When buyers submit requests, they'll show up here."
  action={<Button size="sm">Invite team</Button>}
/>`,
    fixtures: ["empty-state"],
  },

  // ── Navigation ──────────────────────────────────────────
  tabs: {
    title: "Tabs",
    family: "Navigation",
    description:
      "Views of the same subject. Underline tabs sit on a hairline under a page header; pill tabs are a compact switch on a recessed track. Every trigger needs its panel.",
    imports: ["TabCount", "Tabs", "TabsContent", "TabsList", "TabsTrigger"],
    usage: `<Tabs defaultValue="overview">
  <TabsList>
    <TabsTrigger value="overview">Overview</TabsTrigger>
    <TabsTrigger value="orders">Orders <TabCount>4</TabCount></TabsTrigger>
  </TabsList>
  <TabsContent value="overview" className="pt-4">…</TabsContent>
  <TabsContent value="orders" className="pt-4">…</TabsContent>
</Tabs>`,
    fixtures: ["tabs"],
  },
  breadcrumb: {
    title: "Breadcrumb",
    family: "Navigation",
    description:
      "Where a page sits in the hierarchy. The last item is the current page and is not a link.",
    imports: ["Breadcrumb"],
    usage: `<Breadcrumb
  items={[
    { label: "Operations", href: "/operations" },
    { label: "RFQs", href: "/operations/rfqs" },
    { label: "RFQ-0042" },
  ]}
/>`,
    fixtures: ["breadcrumb"],
  },
  pagination: {
    title: "Pagination",
    family: "Navigation",
    description:
      "Page through a long list. The first and last pages are always visible, gaps collapse into an ellipsis, and the current page is marked aria-current.",
    imports: ["Pagination"],
    usage: `<Pagination page={page} count={pageCount} onPageChange={setPage} />`,
    fixtures: ["pagination"],
  },
  stepper: {
    title: "Stepper",
    family: "Navigation",
    description:
      "Progress through a fixed sequence: checkout, onboarding. Horizontal or vertical; completed steps can be made clickable.",
    imports: ["Stepper"],
    usage: `<Stepper
  aria-label="Seller onboarding"
  current={1}
  steps={[
    { label: "Company details", description: "Legal name and GSTIN" },
    { label: "Bank account", description: "For payouts" },
    { label: "Go live" },
  ]}
/>`,
    fixtures: ["stepper"],
  },
  "filter-chip": {
    title: "Filter chip",
    family: "Navigation",
    description:
      "One filter in a filter bar. It shows the applied value or a count, can open a menu, and gets a separate clear button once applied. The warning tone is for a filter that surfaces a problem, such as late orders.",
    imports: ["FilterChip"],
    usage: `<FilterChip label="Late" tone="warning" active={late} onClick={() => setLate(!late)} />

<Popover>
  <PopoverTrigger asChild>
    <FilterChip label="Vendor" value={vendor} dropdown active={vendor != null} onClear={clearVendor} />
  </PopoverTrigger>
  <PopoverContent align="start">…</PopoverContent>
</Popover>`,
    fixtures: ["filter-chip"],
  },
  command: {
    title: "Command",
    family: "Navigation",
    description:
      "A searchable list of commands or destinations (cmdk) on the shared menu row spec. Render it in a Dialog for a command palette; Combobox already composes it in a Popover.",
    imports: ["Command", "CommandEmpty", "CommandGroup", "CommandInput", "CommandItem", "CommandList"],
    usage: `<Command label="Command menu">
  <CommandInput placeholder="Search…" />
  <CommandList>
    <CommandEmpty>Nothing found.</CommandEmpty>
    <CommandGroup heading="Go to">
      <CommandItem onSelect={() => router.push("/orders")}>Orders</CommandItem>
      <CommandItem onSelect={() => router.push("/shipments")}>Shipments</CommandItem>
    </CommandGroup>
  </CommandList>
</Command>`,
    fixtures: ["command"],
  },

  // ── Overlays ────────────────────────────────────────────
  dialog: {
    title: "Dialog",
    family: "Overlays",
    description:
      "A modal task that interrupts the page: a short form, a detail view. The panel is the elevated surface with the modal shadow over a scrim; a long body scrolls and the footer stays put. Sizes run from sm to xl and full.",
    imports: [
      "Dialog",
      "DialogBody",
      "DialogClose",
      "DialogContent",
      "DialogDescription",
      "DialogFooter",
      "DialogHeader",
      "DialogTitle",
      "DialogTrigger",
    ],
    usage: `<Dialog>
  <DialogTrigger asChild>
    <Button>Invite teammate</Button>
  </DialogTrigger>
  <DialogContent size="sm">
    <DialogHeader>
      <DialogTitle>Invite a teammate</DialogTitle>
      <DialogDescription>They'll get access to this workspace.</DialogDescription>
    </DialogHeader>
    <DialogBody>…</DialogBody>
    <DialogFooter>
      <DialogClose asChild><Button variant="secondary">Cancel</Button></DialogClose>
      <Button>Send invite</Button>
    </DialogFooter>
  </DialogContent>
</Dialog>`,
    fixtures: ["dialog"],
  },
  "alert-dialog": {
    title: "Alert dialog",
    family: "Overlays",
    description:
      "A confirmation that must be answered — it does not close on an outside click. Use it before anything destructive or irreversible, and say what will happen in the description.",
    imports: [
      "AlertDialog",
      "AlertDialogAction",
      "AlertDialogCancel",
      "AlertDialogContent",
      "AlertDialogDescription",
      "AlertDialogFooter",
      "AlertDialogHeader",
      "AlertDialogTitle",
      "AlertDialogTrigger",
    ],
    usage: `<AlertDialog>
  <AlertDialogTrigger asChild>
    <Button variant="danger">Delete workspace</Button>
  </AlertDialogTrigger>
  <AlertDialogContent>
    <AlertDialogHeader>
      <AlertDialogTitle>Delete workspace?</AlertDialogTitle>
      <AlertDialogDescription>This cannot be undone.</AlertDialogDescription>
    </AlertDialogHeader>
    <AlertDialogFooter>
      <AlertDialogCancel asChild><Button variant="secondary">Cancel</Button></AlertDialogCancel>
      <AlertDialogAction asChild><Button variant="danger">Delete</Button></AlertDialogAction>
    </AlertDialogFooter>
  </AlertDialogContent>
</AlertDialog>`,
    fixtures: ["alert-dialog"],
  },
  drawer: {
    title: "Drawer",
    family: "Overlays",
    description:
      "A modal panel that slides from an edge: record details from the right, navigation from the left, actions from the bottom on touch. It shares the scrim, header, body and footer with Dialog.",
    imports: [
      "Drawer",
      "DrawerBody",
      "DrawerClose",
      "DrawerContent",
      "DrawerDescription",
      "DrawerFooter",
      "DrawerHeader",
      "DrawerTitle",
      "DrawerTrigger",
    ],
    usage: `<Drawer>
  <DrawerTrigger asChild>
    <Button variant="secondary">Order details</Button>
  </DrawerTrigger>
  <DrawerContent side="right" size="md">
    <DrawerHeader>
      <DrawerTitle>Order #1042</DrawerTitle>
      <DrawerDescription>Trimurti Packaging · dispatch Friday</DrawerDescription>
    </DrawerHeader>
    <DrawerBody>…</DrawerBody>
    <DrawerFooter>
      <DrawerClose asChild><Button variant="secondary">Close</Button></DrawerClose>
      <Button>Accept order</Button>
    </DrawerFooter>
  </DrawerContent>
</Drawer>`,
    fixtures: ["drawer-right", "drawer-left", "drawer-bottom"],
  },
  popover: {
    title: "Popover",
    family: "Overlays",
    description:
      "A floating panel anchored to its trigger, for content richer than a menu: a filter form, a short explanation. Floating layers are the elevated surface plus the overlay shadow, which carries its own edge — no border.",
    imports: ["Popover", "PopoverClose", "PopoverContent", "PopoverTrigger"],
    usage: `<Popover>
  <PopoverTrigger asChild>
    <Button variant="secondary">Dispatch window</Button>
  </PopoverTrigger>
  <PopoverContent align="start">
    Orders cleared by QC before 2 pm ship the same day.
  </PopoverContent>
</Popover>`,
    fixtures: ["popover"],
  },
  tooltip: {
    title: "Tooltip",
    family: "Overlays",
    description:
      "The name of a control that has no visible label, shown on hover and keyboard focus. Never put anything in a tooltip that the user needs in order to proceed.",
    imports: ["Tooltip", "TooltipContent", "TooltipProvider", "TooltipTrigger"],
    usage: `<TooltipProvider>
  <Tooltip>
    <TooltipTrigger asChild>
      <Button variant="ghost" iconOnly aria-label="Refresh"><RefreshCw /></Button>
    </TooltipTrigger>
    <TooltipContent>Refresh</TooltipContent>
  </Tooltip>
</TooltipProvider>`,
    fixtures: ["tooltip"],
  },
  "dropdown-menu": {
    title: "Dropdown menu",
    family: "Overlays",
    description:
      "A list of actions on a button: items with icons and shortcuts, checkbox and radio items, one level of submenu, and a destructive item set apart at the end.",
    imports: [
      "DropdownMenu",
      "DropdownMenuContent",
      "DropdownMenuItem",
      "DropdownMenuLabel",
      "DropdownMenuSeparator",
      "DropdownMenuShortcut",
      "DropdownMenuTrigger",
    ],
    usage: `<DropdownMenu>
  <DropdownMenuTrigger asChild>
    <Button variant="secondary" trailingIcon={<ChevronDown />}>Actions</Button>
  </DropdownMenuTrigger>
  <DropdownMenuContent align="start">
    <DropdownMenuLabel>Order</DropdownMenuLabel>
    <DropdownMenuItem onSelect={duplicate}>
      <Copy /> Duplicate <DropdownMenuShortcut>⌘D</DropdownMenuShortcut>
    </DropdownMenuItem>
    <DropdownMenuSeparator />
    <DropdownMenuItem destructive onSelect={cancel}>Cancel order</DropdownMenuItem>
  </DropdownMenuContent>
</DropdownMenu>`,
    fixtures: ["dropdown-menu"],
  },

  // ── Layout ──────────────────────────────────────────────
  "app-shell": {
    title: "App shell",
    family: "Layout",
    description:
      "The page frame: a sidebar beside a column of header, content and footer. The parts are plain layout elements, follow the theme, and can render in server components. This site is built from it.",
    imports: ["AppContent", "AppFooter", "AppHeader", "AppMain", "AppShell", "SidebarProvider"],
    usage: `<SidebarProvider storageKey="app.sidebar">
  <AppShell>
    <Sidebar>…</Sidebar>
    <AppMain>
      <AppHeader>…</AppHeader>
      <AppContent contained>{children}</AppContent>
      <AppFooter>…</AppFooter>
    </AppMain>
  </AppShell>
</SidebarProvider>`,
    fixtures: ["app-shell"],
  },
  "app-header": {
    title: "App header",
    family: "Layout",
    description:
      "The top bar: full width, a hairline below, level with the sidebar header. Beside a sidebar it holds the sidebar trigger, the page title and trailing actions; in an app without a sidebar it holds the brand and the primary links.",
    imports: ["AppHeader", "AppHeaderActions", "AppHeaderBrand", "AppHeaderLink", "AppHeaderNav", "AppHeaderTitle"],
    usage: `<AppHeader>
  <SidebarTrigger />
  <AppHeaderTitle>Orders</AppHeaderTitle>
  <AppHeaderActions>
    <Button size="sm" variant="secondary">Export</Button>
    <Button size="sm">New order</Button>
  </AppHeaderActions>
</AppHeader>`,
    fixtures: ["app-header"],
  },
  sidebar: {
    title: "Sidebar",
    family: "Layout",
    description:
      "The app navigation, in three presentations from one tree: a sheet at touch density below md, an icon rail that floats open between md and lg, and a full column from lg that the user can collapse to the rail. Icons never move; labels fade. In the rail a group opens its pages in a menu. SidebarProvider owns the state and remembers it.",
    imports: [
      "Sidebar",
      "SidebarBrand",
      "SidebarContent",
      "SidebarFooter",
      "SidebarGroup",
      "SidebarHeader",
      "SidebarItem",
      "SidebarMenuButton",
      "SidebarSection",
      "SidebarSubItem",
      "SidebarTrigger",
    ],
    usage: `<Sidebar label="Main">
  <SidebarHeader>
    <SidebarBrand mark="A" name="Aeros" sub="Marketplace" />
  </SidebarHeader>
  <SidebarContent>
    <SidebarSection label="Workspace">
      <SidebarItem href="/" active icon={<Home />}>Dashboard</SidebarItem>
      <SidebarItem href="/inbox" icon={<Inbox />} count={3} countTone="solid">Inbox</SidebarItem>
      <SidebarItem asChild icon={<Box />} count={128}><Link href="/orders">Orders</Link></SidebarItem>
      <SidebarGroup label="Catalog" icon={<Tags />}>
        <SidebarSubItem href="/products">Products</SidebarSubItem>
        <SidebarSubItem href="/categories">Categories</SidebarSubItem>
      </SidebarGroup>
    </SidebarSection>
  </SidebarContent>
</Sidebar>`,
    fixtures: ["sidebar", "sidebar-rail"],
  },
  "page-header": {
    title: "Page header",
    family: "Layout",
    description:
      "The top of a page's content: title, description, a back control, a breadcrumb above, actions on the title row and tabs below. The actions wrap under the title when the row runs out of width.",
    imports: ["PageHeader"],
    usage: `<PageHeader
  title="PO-1042"
  description="Raised 14 Aug 2026 by Priya Sharma."
  breadcrumb={<Breadcrumb items={crumbs} />}
  back={{ href: "/orders", label: "Back to orders" }}
  actions={<Button leadingIcon={<Plus />}>New order</Button>}
/>`,
    fixtures: ["page-header"],
  },
  accordion: {
    title: "Accordion",
    family: "Layout",
    description:
      "A stack of sections that open in place — FAQs, grouped settings. Single or multiple open at once; the open and close motion uses the token timing and stops under reduced motion.",
    imports: ["Accordion", "AccordionContent", "AccordionItem", "AccordionTrigger"],
    usage: `<Accordion type="single" collapsible defaultValue="shipping">
  <AccordionItem value="shipping">
    <AccordionTrigger>Shipping policy</AccordionTrigger>
    <AccordionContent>Orders dispatch within 48 hours of QC clearance.</AccordionContent>
  </AccordionItem>
  <AccordionItem value="returns">
    <AccordionTrigger>Returns</AccordionTrigger>
    <AccordionContent>Defects are replaced free within 30 days.</AccordionContent>
  </AccordionItem>
</Accordion>`,
    fixtures: ["accordion"],
  },
  collapsible: {
    title: "Collapsible",
    family: "Layout",
    description:
      "One region that shows and hides. It is unstyled on purpose: bring your own trigger and frame.",
    imports: ["Collapsible", "CollapsibleContent", "CollapsibleTrigger"],
    usage: `<Collapsible>
  <CollapsibleTrigger asChild>
    <Button variant="ghost" size="sm">Shipping details</Button>
  </CollapsibleTrigger>
  <CollapsibleContent>Dispatched from Pune in 3 cartons.</CollapsibleContent>
</Collapsible>`,
    fixtures: ["collapsible"],
  },
  "scroll-area": {
    title: "Scroll area",
    family: "Layout",
    description:
      "A scroll container with thin, token-coloured scrollbars that look the same on every platform. Give it an accessible name so keyboard users can reach it.",
    imports: ["ScrollArea"],
    usage: `<ScrollArea aria-label="Recent orders" className="h-48 rounded-surface border border-border-default">
  <ul className="grid gap-2 p-3 text-body-sm">…</ul>
</ScrollArea>`,
    fixtures: ["scroll-area"],
  },
  separator: {
    title: "Separator",
    family: "Layout",
    description:
      "A hairline between groups, horizontal or vertical. Decorative by default; pass decorative={false} when it marks a real boundary for assistive tech.",
    imports: ["Separator"],
    usage: `<Separator className="my-4" />
<Separator orientation="vertical" />`,
    fixtures: ["separator"],
  },
});

export type ComponentSlug = keyof typeof COMPONENTS;
export const COMPONENT_SLUGS = Object.keys(COMPONENTS) as ComponentSlug[];

/** Typed lookup (the literal object's value type is a union of narrow shapes). */
export function getComponent(slug: ComponentSlug): ComponentDoc {
  return COMPONENTS[slug];
}

export function isComponentSlug(slug: string): slug is ComponentSlug {
  return Object.prototype.hasOwnProperty.call(COMPONENTS, slug);
}

export function componentsByFamily(): Array<{ family: Family; slugs: ComponentSlug[] }> {
  return FAMILIES.map((family) => ({
    family,
    slugs: COMPONENT_SLUGS.filter((slug) => COMPONENTS[slug].family === family),
  }));
}

// ── The guard ─────────────────────────────────────────────

type ShownFixture = (typeof COMPONENTS)[ComponentSlug]["fixtures"][number];
type AccountedFixture = ShownFixture | (typeof NON_COMPONENT_FIXTURES)[number];
type UnaccountedFixture = Exclude<FixtureSlug, AccountedFixture>;

/**
 * Compile-time: every fixture slug is shown by a component page or listed in
 * NON_COMPONENT_FIXTURES. When a fixture is added without a registry entry this
 * line stops compiling and names the missing slug(s).
 */
const EVERY_FIXTURE_HAS_A_PAGE: [UnaccountedFixture] extends [never]
  ? true
  : { "fixture slugs with no entry in app/_registry.ts": UnaccountedFixture } = true;
void EVERY_FIXTURE_HAS_A_PAGE;

/** Run-time (module load, so it also fails the build and the specs): no fixture is shown twice or left out. */
(function assertRegistryMatchesFixtures() {
  const seen = new Map<string, string>();
  for (const slug of COMPONENT_SLUGS) {
    for (const fixture of getComponent(slug).fixtures) {
      const owner = seen.get(fixture);
      if (owner) throw new Error(`app/_registry.ts: fixture "${fixture}" is shown by both "${owner}" and "${slug}".`);
      seen.set(fixture, slug);
    }
  }
  for (const fixture of NON_COMPONENT_FIXTURES) {
    if (seen.has(fixture)) throw new Error(`app/_registry.ts: "${fixture}" is both a component fixture and in NON_COMPONENT_FIXTURES.`);
    seen.set(fixture, "(none)");
  }
  const missing = FIXTURE_SLUGS.filter((fixture) => !seen.has(fixture));
  if (missing.length) throw new Error(`app/_registry.ts: no component page shows the fixture(s) ${missing.join(", ")}.`);
  const unknown = [...seen.keys()].filter((fixture) => !(FIXTURE_SLUGS as readonly string[]).includes(fixture));
  if (unknown.length) throw new Error(`app/_registry.ts: unknown fixture slug(s) ${unknown.join(", ")}.`);
})();
