"use client";

import * as React from "react";
import { Field, FileUpload } from "@aeros-core/react";
import { Group } from "./kit";

export default function FileUploadFixture() {
  // Fixed names and contents, so sizes render the same on every run.
  const [files, setFiles] = React.useState<File[]>(() => [
    new File(["x".repeat(2048)], "signed-quote.pdf", { type: "application/pdf", lastModified: 0 }),
    new File(["x".repeat(734)], "cup-artwork-250ml-final-approved-by-brand-team.png", { type: "image/png", lastModified: 0 })
  ]);
  const [disabledFiles] = React.useState<File[]>(() => [
    new File(["x"], "locked.pdf", { type: "application/pdf", lastModified: 0 })
  ]);

  return (
    <>
      <Group label="Empty — single file" className="max-w-xl flex-col items-stretch">
        <FileUpload accept=".pdf" hint="PDF, up to 5 MB" maxSize={5 * 1024 * 1024} />
      </Group>
      <Group label="Empty — multiple" className="max-w-xl flex-col items-stretch">
        <FileUpload multiple accept=".pdf,image/*" maxFiles={5} hint="PDF or images, up to 5 files" />
      </Group>
      <Group label="With two files" className="max-w-xl flex-col items-stretch">
        <FileUpload multiple value={files} onFilesChange={setFiles} hint="PDF or images" />
      </Group>
      <Group label="Disabled (empty / with a file)" className="max-w-xl flex-col items-stretch">
        <FileUpload disabled hint="Uploads are closed for this RFQ" />
        <FileUpload disabled multiple value={disabledFiles} />
      </Group>
      <Group label="Inside a Field" className="max-w-xl flex-col items-stretch gap-4">
        <Field label="Attachments" hint="Attach the signed quote and any artwork.">
          <FileUpload multiple />
        </Field>
        <Field label="Signed quote" required error="Attach the signed quote to continue.">
          <FileUpload accept=".pdf" />
        </Field>
      </Group>
    </>
  );
}
