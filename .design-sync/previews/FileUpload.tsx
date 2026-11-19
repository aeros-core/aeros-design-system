import * as React from "react";
import { Field, FileUpload } from "@aeros-core/react";

const col: React.CSSProperties = { display: "grid", gap: 16, maxWidth: 560 };

export const EmptyDropzone = () => (
  <div style={col}>
    <FileUpload accept=".pdf" hint="PDF, up to 5 MB" maxSize={5 * 1024 * 1024} />
    <FileUpload multiple accept=".pdf,image/*" maxFiles={5} hint="PDF or images, up to 5 files" />
  </div>
);

// The file list is controlled: fixed names and contents, so sizes never change.
export const WithFiles = () => {
  const [files, setFiles] = React.useState<File[]>(() => [
    new File(["x".repeat(2048)], "signed-quote.pdf", { type: "application/pdf", lastModified: 0 }),
    new File(["x".repeat(734)], "cup-artwork-250ml-final-approved-by-brand-team.png", {
      type: "image/png",
      lastModified: 0,
    }),
  ]);
  return (
    <div style={col}>
      <FileUpload multiple value={files} onFilesChange={setFiles} hint="PDF or images" />
    </div>
  );
};

export const Disabled = () => {
  const [files] = React.useState<File[]>(() => [
    new File(["x"], "locked.pdf", { type: "application/pdf", lastModified: 0 }),
  ]);
  return (
    <div style={col}>
      <FileUpload disabled hint="Uploads are closed for this RFQ" />
      <FileUpload disabled multiple value={files} />
    </div>
  );
};

export const InField = () => (
  <div style={col}>
    <Field label="Attachments" hint="Attach the signed quote and any artwork.">
      <FileUpload multiple />
    </Field>
    <Field label="Signed quote" required error="Attach the signed quote to continue.">
      <FileUpload accept=".pdf" />
    </Field>
  </div>
);
