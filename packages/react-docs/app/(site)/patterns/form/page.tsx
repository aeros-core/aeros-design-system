import type { Metadata } from "next";
import { CodeBlock } from "../../../_site/code-block";
import { Code, Demo, PageIntro, Section } from "../../../_site/prose";
import { OrderForm } from "./order-form";

export const metadata: Metadata = { title: "Form" };

const COMPOSITION = `<form onSubmit={submit} noValidate>
  <Card>
    <FormSection title="Vendor" description="Who the order is placed with.">
      <FieldGroup>
        <Field label="Vendor" required error={errors.vendor}>
          <Combobox options={vendors} value={vendor} onValueChange={setVendor} clearable />
        </Field>
        <Field label="Payment terms">
          <Select value={terms} onValueChange={setTerms}>…</Select>
        </Field>
      </FieldGroup>
    </FormSection>

    <FormSection title="Line item">
      <FieldGroup className="sm:grid-cols-2">
        <Field label="Quantity" required error={errors.quantity} hint="Sold in cartons of 50.">
          <NumberInput value={quantity} onValueChange={setQuantity} min={0} step={50} suffix="pcs" />
        </Field>
        <Field label="Delivery date" required error={errors.date}>
          <DatePicker value={date} onValueChange={setDate} clearable />
        </Field>
      </FieldGroup>
    </FormSection>

    <CardFooter>
      <span className="text-caption text-fg-muted">* Required</span>
      <div className="flex gap-2">
        <Button type="button" variant="ghost">Cancel</Button>
        <Button type="submit">Create order</Button>
      </div>
    </CardFooter>
  </Card>
</form>`;

export default function FormPatternPage() {
  return (
    <>
      <PageIntro section="Patterns">
        A create form on one surface: sections with a title on the left and fields on the right, a hairline between
        them, and a submit bar at the bottom. Every control is the same height and sits on the same field recipe, so
        a form with eight kinds of input still reads as one thing.
      </PageIntro>

      <Section
        title="Live"
        description="Submit it empty to see validation: the message replaces the hint, the border and the focus ring turn to the danger colour, and focus moves to the first invalid field."
      >
        <Demo>
          <OrderForm />
        </Demo>
      </Section>

      <Section
        title="Composition"
        description={
          <>
            <Code>Field</Code> gives each control its label, hint and error and wires the ids and ARIA attributes.{" "}
            <Code>FieldGroup</Code> stacks fields with the standard gap — <Code>Field</Code> has no margin of its own.
          </>
        }
      >
        <CodeBlock title="order-form.tsx" code={COMPOSITION} />
      </Section>

      <Section title="Rules of thumb">
        <ul className="grid max-w-prose list-disc gap-2 pl-5 text-body-md text-fg-secondary">
          <li>One primary button, at the end of the submit bar. Cancel is a ghost; a secondary save sits between.</li>
          <li>Validate on submit, then on change for fields already in error. Say what to do, not what went wrong.</li>
          <li>Use a Select for a handful of fixed options and a Combobox once the list needs searching.</li>
          <li>Numbers with a unit take a NumberInput with a suffix; computed totals are shown in mono, not in a field.</li>
        </ul>
      </Section>
    </>
  );
}
