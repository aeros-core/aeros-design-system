"use client";

import * as React from "react";
import {
  Alert,
  Button,
  Card,
  CardFooter,
  Checkbox,
  Combobox,
  DatePicker,
  Field,
  FieldGroup,
  FileUpload,
  Input,
  NumberInput,
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
  Textarea,
  type ComboboxOption,
} from "@aeros-core/react";

const VENDORS: ComboboxOption[] = [
  { value: "trimurti", label: "Trimurti Packaging", description: "Pune", group: "Packaging" },
  { value: "pacific", label: "Pacific Pack Co.", description: "Chennai", group: "Packaging" },
  { value: "sahyadri", label: "Sahyadri Cartons", description: "Nashik", group: "Packaging" },
  { value: "shakti", label: "Shakti Bearings", description: "Rajkot", group: "Engineering" },
  { value: "apex", label: "Apex Polymers", description: "Vadodara", group: "Engineering" },
];

const MIN_QUANTITY = 50;

/** Indian digit grouping without a locale lookup, so server and client agree. */
function rupees(n: number): string {
  const [whole = "0", fraction] = n.toFixed(2).split(".");
  const grouped =
    whole.length <= 3 ? whole : `${whole.slice(0, -3).replace(/\B(?=(\d{2})+(?!\d))/g, ",")},${whole.slice(-3)}`;
  return `${grouped}.${fraction}`;
}

type Errors = Partial<Record<"reference" | "vendor" | "quantity" | "date", string>>;

function FormSection({
  title,
  description,
  children,
}: {
  title: string;
  description: string;
  children: React.ReactNode;
}) {
  return (
    <div className="grid gap-x-8 gap-y-4 border-b border-border-default p-4 md:grid-cols-[14rem_minmax(0,1fr)] md:p-6">
      <div>
        <h3 className="text-h4 text-fg-primary">{title}</h3>
        <p className="mt-1 text-body-sm text-fg-secondary">{description}</p>
      </div>
      <div className="min-w-0 max-w-xl">{children}</div>
    </div>
  );
}

export function OrderForm() {
  const form = React.useRef<HTMLFormElement>(null);
  const [reference, setReference] = React.useState("");
  const [vendor, setVendor] = React.useState<string | null>(null);
  const [terms, setTerms] = React.useState("net-30");
  const [quantity, setQuantity] = React.useState<number | null>(null);
  const [price, setPrice] = React.useState<number | null>(48);
  const [date, setDate] = React.useState<Date | null>(null);
  const [notes, setNotes] = React.useState("");
  const [files, setFiles] = React.useState<File[]>([]);
  const [notify, setNotify] = React.useState(true);
  const [errors, setErrors] = React.useState<Errors>({});
  const [created, setCreated] = React.useState<string | null>(null);

  const validate = (): Errors => {
    const next: Errors = {};
    if (reference.trim() === "") next.reference = "Enter a reference, for example PO-1066.";
    if (vendor == null) next.vendor = "Choose the vendor this order is placed with.";
    if (quantity == null || quantity < MIN_QUANTITY) next.quantity = `Enter a quantity of at least ${MIN_QUANTITY}.`;
    if (date == null) next.date = "Choose a delivery date.";
    return next;
  };

  // Once a field has shown an error, re-check it as the user fixes it.
  const recheck = (field: keyof Errors, ok: boolean) => {
    if (errors[field] && ok) setErrors(({ [field]: _fixed, ...rest }) => rest);
  };

  const submit = (event: React.FormEvent) => {
    event.preventDefault();
    const next = validate();
    setErrors(next);
    if (Object.keys(next).length > 0) {
      setCreated(null);
      // Field marks its control aria-invalid; move focus to the first one.
      requestAnimationFrame(() => form.current?.querySelector<HTMLElement>("[aria-invalid='true']")?.focus());
      return;
    }
    setCreated(reference.trim());
  };

  const reset = () => {
    setReference("");
    setVendor(null);
    setTerms("net-30");
    setQuantity(null);
    setPrice(48);
    setDate(null);
    setNotes("");
    setFiles([]);
    setNotify(true);
    setErrors({});
    setCreated(null);
  };

  const total = (quantity ?? 0) * (price ?? 0);
  const errorCount = Object.keys(errors).length;

  return (
    <form ref={form} onSubmit={submit} noValidate className="grid min-w-0 gap-4">
      {created && (
        <Alert variant="success" title={`${created} created`}>
          This is a demo — nothing was sent.
        </Alert>
      )}
      {errorCount > 0 && (
        <Alert variant="danger" title={errorCount === 1 ? "1 field needs attention" : `${errorCount} fields need attention`}>
          Fix the highlighted fields and submit again.
        </Alert>
      )}

      <Card>
        <div className="border-b border-border-default px-4 py-3 md:px-6">
          <h2 className="text-h3 text-fg-primary">New purchase order</h2>
          <p className="mt-0.5 text-body-sm text-fg-secondary">Raise an order with an approved vendor.</p>
        </div>

        <FormSection title="Order" description="How the order is identified and who supplies it.">
          <FieldGroup>
            <Field label="Reference" required error={errors.reference} hint="Shown on the vendor's copy.">
              <Input
                className="font-mono"
                placeholder="PO-1066"
                value={reference}
                onChange={(event) => {
                  setReference(event.target.value);
                  recheck("reference", event.target.value.trim() !== "");
                }}
              />
            </Field>
            <Field label="Vendor" required error={errors.vendor}>
              <Combobox
                options={VENDORS}
                value={vendor}
                onValueChange={(value) => {
                  setVendor(value);
                  recheck("vendor", value != null);
                }}
                clearable
                placeholder="Choose a vendor"
                searchPlaceholder="Search vendors…"
              />
            </Field>
            <Field label="Payment terms">
              <Select value={terms} onValueChange={setTerms}>
                <SelectTrigger>
                  <SelectValue />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="advance">Advance</SelectItem>
                  <SelectItem value="net-15">Net 15</SelectItem>
                  <SelectItem value="net-30">Net 30</SelectItem>
                  <SelectItem value="net-45">Net 45</SelectItem>
                </SelectContent>
              </Select>
            </Field>
          </FieldGroup>
        </FormSection>

        <FormSection title="Line item" description="What is being bought, how much of it, and when it is needed.">
          <FieldGroup>
            <Field label="Item">
              <Input defaultValue="250 ml double-wall paper cup" />
            </Field>
            {/* items-start: a stretched Field would grow its control to match a taller neighbour. */}
            <div className="grid items-start gap-4 sm:grid-cols-2">
              <Field
                label="Quantity"
                required
                error={errors.quantity}
                hint={`Sold in cartons of ${MIN_QUANTITY}.`}
              >
                <NumberInput
                  value={quantity}
                  onValueChange={(value) => {
                    setQuantity(value);
                    recheck("quantity", value != null && value >= MIN_QUANTITY);
                  }}
                  min={0}
                  step={MIN_QUANTITY}
                  suffix="pcs"
                  placeholder="0"
                />
              </Field>
              <Field label="Unit price">
                <NumberInput value={price} onValueChange={setPrice} min={0} step={0.5} precision={2} prefix="₹" />
              </Field>
            </div>
            <Field label="Delivery date" required error={errors.date} hint="Working days only.">
              {/* aria-label on purpose. Without one the picker names itself after mount by
                  pointing aria-labelledby at the Field label and its own value text, and
                  that id intermittently does not match the hydrated DOM. With a label it
                  is named "Delivery date, <value>" directly. */}
              <DatePicker
                aria-label="Delivery date"
                value={date}
                onValueChange={(value) => {
                  setDate(value);
                  recheck("date", value != null);
                }}
                clearable
              />
            </Field>
            <div className="flex items-baseline justify-between gap-3 rounded-control bg-bg-subtle px-3 py-2">
              <span className="text-label-sm text-fg-secondary">Order total</span>
              <span className="font-mono text-mono-md text-fg-primary">₹{rupees(total)}</span>
            </div>
          </FieldGroup>
        </FormSection>

        <FormSection title="Attachments and notes" description="Anything the vendor needs to fulfil the order.">
          <FieldGroup>
            <Field label="Attachments" hint="Artwork or a signed quote. PDF or images, up to 5 files.">
              <FileUpload multiple accept=".pdf,image/*" maxFiles={5} value={files} onFilesChange={setFiles} />
            </Field>
            <Field label="Notes for the vendor">
              <Textarea
                rows={3}
                placeholder="Delivery instructions, packing requirements…"
                value={notes}
                onChange={(event) => setNotes(event.target.value)}
              />
            </Field>
            <label className="inline-flex items-center gap-2 text-body-sm text-fg-secondary">
              <Checkbox checked={notify} onCheckedChange={(value) => setNotify(value === true)} />
              Email me when the vendor accepts
            </label>
          </FieldGroup>
        </FormSection>

        <CardFooter className="flex-wrap border-t-0 md:px-6">
          <span className="text-caption text-fg-muted">
            <span aria-hidden className="text-danger">*</span> Required
          </span>
          <div className="flex flex-wrap gap-2">
            <Button type="button" variant="ghost" onClick={reset}>
              Cancel
            </Button>
            <Button type="button" variant="secondary">
              Save draft
            </Button>
            <Button type="submit">Create order</Button>
          </div>
        </CardFooter>
      </Card>
    </form>
  );
}
