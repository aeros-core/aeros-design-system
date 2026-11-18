"use client";
import * as React from "react";
import { File as FileIcon, Upload, X } from "lucide-react";
import { cn } from "../lib/cn";
import { colorTransition } from "../internal/recipes";
import { Button } from "./button";
import { useFieldControl, type FieldControlProps } from "./input";

export type FileRejectionReason = "type" | "size" | "count";

export interface FileRejection {
  file: File;
  reason: FileRejectionReason;
}

export interface FileUploadProps
  extends Omit<React.HTMLAttributes<HTMLDivElement>, "onChange" | "defaultValue" | "aria-invalid" | "aria-required">,
    FieldControlProps {
  /** Same syntax as the native attribute: ".pdf,image/*,text/csv". */
  accept?: string;
  /** Keep several files. Without it a new file replaces the current one. */
  multiple?: boolean;
  /** Largest accepted file, in bytes. */
  maxSize?: number;
  /** Most files kept at once (with `multiple`). */
  maxFiles?: number;
  disabled?: boolean;
  /** Controlled file list. Leave unset to let the component keep its own. */
  value?: File[];
  /** Called with the full list whenever a file is added or removed. */
  onFilesChange?: (files: File[]) => void;
  /** Called with the files that were turned away, and why. */
  onReject?: (rejections: FileRejection[]) => void;
  /** Constraints in words, shown in the dropzone: "PDF or PNG, up to 5 MB". */
  hint?: React.ReactNode;
  /** Text of the browse button. */
  browseLabel?: string;
}

/** 1536 → "1.5 KB". */
function formatFileSize(bytes: number): string {
  if (bytes < 1024) return `${bytes} B`;
  const units = ["KB", "MB", "GB", "TB"];
  let n = bytes / 1024;
  let u = 0;
  while (n >= 1024 && u < units.length - 1) {
    n /= 1024;
    u++;
  }
  return `${n >= 100 ? Math.round(n) : Number(n.toFixed(1))} ${units[u]}`;
}

function matchesAccept(file: File, accept: string | undefined): boolean {
  const rules = (accept ?? "")
    .split(",")
    .map((r) => r.trim().toLowerCase())
    .filter(Boolean);
  if (rules.length === 0) return true;
  const name = file.name.toLowerCase();
  const type = file.type.toLowerCase();
  return rules.some((rule) =>
    rule.startsWith(".") ? name.endsWith(rule) : rule.endsWith("/*") ? type.startsWith(rule.slice(0, -1)) : type === rule
  );
}

function rejectionMessage({ file, reason }: FileRejection, maxSize?: number, limit?: number): string {
  if (reason === "type") return `${file.name}: this file type is not accepted.`;
  if (reason === "size") {
    return `${file.name}: larger than ${maxSize != null ? formatFileSize(maxSize) : "the size limit"}.`;
  }
  return `${file.name}: not added — the limit is ${limit} ${limit === 1 ? "file" : "files"}.`;
}

/**
 * A dropzone and file list. It only collects `File` objects — uploading them is
 * the caller's job. Works inside `<Field>`: the browse button takes the field's
 * id, so the label names it and the hint or error describes it.
 */
export const FileUpload = React.forwardRef<HTMLDivElement, FileUploadProps>(
  (
    {
      accept,
      multiple = false,
      maxSize,
      maxFiles,
      disabled = false,
      value,
      onFilesChange,
      onReject,
      hint,
      browseLabel,
      className,
      id,
      "aria-describedby": ariaDescribedby,
      "aria-invalid": ariaInvalid,
      "aria-required": ariaRequired,
      "aria-label": ariaLabel,
      "aria-labelledby": ariaLabelledby,
      ...props
    },
    ref
  ) => {
    const { fieldProps, state } = useFieldControl({
      id,
      "aria-describedby": ariaDescribedby,
      "aria-invalid": ariaInvalid,
      "aria-required": ariaRequired
    });
    const hintId = React.useId();
    const inputRef = React.useRef<HTMLInputElement>(null);
    const [inner, setInner] = React.useState<File[]>([]);
    const [rejections, setRejections] = React.useState<FileRejection[]>([]);
    const [dragging, setDragging] = React.useState(false);
    // dragenter/dragleave also fire for children; count them to know when the pointer truly left.
    const dragDepth = React.useRef(0);

    const files = value ?? inner;
    const limit = multiple ? maxFiles : 1;
    const invalid = state === "error" || fieldProps["aria-invalid"] === true || fieldProps["aria-invalid"] === "true";

    const commit = (next: File[]) => {
      if (value === undefined) setInner(next);
      onFilesChange?.(next);
    };

    const add = (incoming: File[]) => {
      if (disabled || incoming.length === 0) return;
      const rejected: FileRejection[] = [];
      const passed: File[] = [];
      for (const file of incoming) {
        if (!matchesAccept(file, accept)) rejected.push({ file, reason: "type" });
        else if (maxSize != null && file.size > maxSize) rejected.push({ file, reason: "size" });
        else passed.push(file);
      }
      // A single-file control replaces its file; a multiple one fills the remaining room.
      const room = !multiple ? 1 : maxFiles != null ? Math.max(maxFiles - files.length, 0) : Infinity;
      const accepted = passed.slice(0, room);
      for (const file of passed.slice(room)) rejected.push({ file, reason: "count" });

      setRejections(rejected);
      if (rejected.length > 0) onReject?.(rejected);
      if (accepted.length > 0) commit(multiple ? [...files, ...accepted] : accepted);
    };

    const remove = (index: number) => {
      setRejections([]);
      commit(files.filter((_, i) => i !== index));
    };

    const describedBy = [fieldProps["aria-describedby"], hint != null ? hintId : undefined].filter(Boolean).join(" ") || undefined;

    return (
      <div ref={ref} className={cn("grid min-w-0 gap-2", className)} {...props}>
        <div
          // A named-less group, so the disabled state is real to assistive tech
          // (and its dimmed text is correctly exempt from contrast checks).
          role="group"
          aria-disabled={disabled || undefined}
          data-dragging={dragging || undefined}
          data-disabled={disabled || undefined}
          data-invalid={invalid || undefined}
          className={cn(
            `flex flex-col items-center gap-2 rounded-surface border border-dashed px-4 py-6 text-center ${colorTransition}`,
            invalid ? "border-danger" : "border-border-strong",
            dragging ? "border-fg-primary bg-state-hover" : "bg-bg-surface",
            disabled && "opacity-disabled"
          )}
          onDragEnter={(event) => {
            if (disabled) return;
            event.preventDefault();
            dragDepth.current += 1;
            setDragging(true);
          }}
          onDragOver={(event) => {
            // Without this the browser refuses the drop and opens the file instead.
            if (!disabled) event.preventDefault();
          }}
          onDragLeave={() => {
            dragDepth.current = Math.max(dragDepth.current - 1, 0);
            if (dragDepth.current === 0) setDragging(false);
          }}
          onDrop={(event) => {
            event.preventDefault();
            dragDepth.current = 0;
            setDragging(false);
            add(Array.from(event.dataTransfer?.files ?? []));
          }}
        >
          <Upload aria-hidden className="size-icon-lg text-fg-muted" />
          <p className="text-body-sm text-fg-secondary">
            {multiple ? "Drag files here, or" : "Drag a file here, or"}
          </p>
          <Button
            type="button"
            variant="secondary"
            size="sm"
            disabled={disabled}
            id={fieldProps.id}
            aria-label={ariaLabel}
            aria-labelledby={ariaLabelledby}
            aria-describedby={describedBy}
            onClick={() => inputRef.current?.click()}
          >
            {browseLabel ?? (multiple ? "Choose files" : "Choose file")}
          </Button>
          {hint != null && (
            <p id={hintId} className="text-caption text-fg-muted">
              {hint}
            </p>
          )}
          {/* The native picker, driven by the button above; kept out of the tab order and the a11y tree. */}
          <input
            ref={inputRef}
            type="file"
            className="sr-only"
            tabIndex={-1}
            aria-hidden
            accept={accept}
            multiple={multiple}
            disabled={disabled}
            onChange={(event) => {
              add(Array.from(event.target.files ?? []));
              // Reset so choosing the same file again still fires a change.
              event.target.value = "";
            }}
          />
        </div>

        {files.length > 0 && (
          <ul aria-label="Selected files" className="grid gap-1.5">
            {files.map((file, i) => (
              <li
                key={`${file.name}-${file.size}-${file.lastModified}-${i}`}
                className="flex h-control-lg min-w-0 items-center gap-2 rounded-control border border-border-default bg-bg-surface pl-2.5 pr-1.5"
              >
                <FileIcon aria-hidden className="size-icon-md shrink-0 text-fg-muted" />
                <span className="min-w-0 flex-1 truncate text-body-sm text-fg-primary">{file.name}</span>
                <span className="shrink-0 text-caption text-fg-muted tabular-nums">{formatFileSize(file.size)}</span>
                <Button
                  type="button"
                  variant="ghost"
                  size="xs"
                  iconOnly
                  disabled={disabled}
                  aria-label={`Remove ${file.name}`}
                  onClick={() => remove(i)}
                >
                  <X aria-hidden />
                </Button>
              </li>
            ))}
          </ul>
        )}

        {/* Always mounted and in the accessibility tree, so text arriving in it is announced.
            While empty it cancels the parent's row gap instead of being hidden. */}
        <div role="alert" className="grid gap-0.5 empty:-mt-2">
          {rejections.map((rejection, i) => (
            <p key={i} className="text-caption text-danger-text">
              {rejectionMessage(rejection, maxSize, limit)}
            </p>
          ))}
        </div>
      </div>
    );
  }
);
FileUpload.displayName = "FileUpload";
