import * as React from "react";
import { Input, Field } from "@aeros-core/react";
import { Search } from "lucide-react";

export const Fields = () => (
  <div style={{ display: "grid", gap: 16, maxWidth: 420 }}>
    <Field label="Email" hint="We'll never share your address.">
      <Input type="email" placeholder="priya@example.com" />
    </Field>
    <Field label="Full name" required>
      <Input placeholder="Priya Sharma" />
    </Field>
    <Field label="Search orders">
      <Input prefix={<Search size={16} />} placeholder="Search by RFQ / SKU" />
    </Field>
    <Field label="With error" error="This field is required.">
      <Input state="error" placeholder="RFQ-0042" />
    </Field>
  </div>
);
