"use client";
import * as React from "react";
import * as RT from "@radix-ui/react-toast";
import { X } from "lucide-react";
import { cva, type VariantProps } from "class-variance-authority";
import { cn } from "../lib/cn";

export const ToastProvider: typeof RT.Provider = RT.Provider;

export const ToastViewport = React.forwardRef<
  React.ElementRef<typeof RT.Viewport>,
  React.ComponentPropsWithoutRef<typeof RT.Viewport>
>(({ className, ...props }, ref) => (
  <RT.Viewport
    ref={ref}
    className={cn(
      "fixed bottom-0 right-0 z-(--aeros-z-toast) flex max-h-screen w-full flex-col gap-2 p-5 sm:max-w-[380px]",
      className
    )}
    {...props}
  />
));
ToastViewport.displayName = "ToastViewport";

const toastVariants = cva(
  "group pointer-events-auto relative flex w-full items-start gap-3 overflow-hidden rounded-lg border p-4 pr-9 shadow-lg " +
  "data-[state=open]:animate-in data-[state=open]:slide-in-from-bottom-2 data-[state=open]:fade-in-0 " +
  "data-[state=closed]:animate-out data-[state=closed]:fade-out-0 data-[state=closed]:slide-out-to-right-2 " +
  "data-[state=open]:duration-(--aeros-duration-base) data-[state=open]:ease-(--aeros-ease-entrance) motion-reduce:animate-none",
  {
    variants: {
      variant: {
        neutral: "bg-bg-elevated border-border-default text-fg-primary",
        success: "bg-success-bg border-success-border text-success-text",
        warning: "bg-warning-bg border-warning-border text-warning-text",
        danger:  "bg-danger-bg border-danger-border text-danger-text"
      }
    },
    defaultVariants: { variant: "neutral" }
  }
);

export const Toast = React.forwardRef<
  React.ElementRef<typeof RT.Root>,
  React.ComponentPropsWithoutRef<typeof RT.Root> & VariantProps<typeof toastVariants>
>(({ className, variant, ...props }, ref) => (
  <RT.Root ref={ref} className={cn(toastVariants({ variant }), className)} {...props} />
));
Toast.displayName = "Toast";

export const ToastTitle = React.forwardRef<
  React.ElementRef<typeof RT.Title>,
  React.ComponentPropsWithoutRef<typeof RT.Title>
>(({ className, ...props }, ref) => (
  <RT.Title ref={ref} className={cn("text-[13px] font-bold", className)} {...props} />
));
ToastTitle.displayName = "ToastTitle";

export const ToastDescription = React.forwardRef<
  React.ElementRef<typeof RT.Description>,
  React.ComponentPropsWithoutRef<typeof RT.Description>
>(({ className, ...props }, ref) => (
  <RT.Description ref={ref} className={cn("text-xs leading-relaxed opacity-90", className)} {...props} />
));
ToastDescription.displayName = "ToastDescription";

export const ToastAction = React.forwardRef<
  React.ElementRef<typeof RT.Action>,
  React.ComponentPropsWithoutRef<typeof RT.Action>
>(({ className, ...props }, ref) => (
  <RT.Action
    ref={ref}
    className={cn(
      "ml-auto inline-flex h-7 shrink-0 items-center rounded-md border border-current/25 px-2.5 text-[12px] font-semibold",
      "transition-colors duration-(--aeros-duration-fast) hover:bg-bg-subtle/60",
      "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-focus-ring",
      className
    )}
    {...props}
  />
));
ToastAction.displayName = "ToastAction";

export const ToastClose = React.forwardRef<
  React.ElementRef<typeof RT.Close>,
  React.ComponentPropsWithoutRef<typeof RT.Close>
>(({ className, ...props }, ref) => (
  <RT.Close
    ref={ref}
    className={cn(
      "absolute right-2 top-2 rounded-md p-1 opacity-70 transition-opacity hover:opacity-100",
      "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-focus-ring",
      className
    )}
    {...props}
  >
    <X className="h-3.5 w-3.5" />
    <span className="sr-only">Dismiss</span>
  </RT.Close>
));
ToastClose.displayName = "ToastClose";

// ── Imperative API ────────────────────────────────────────
// Mount <Toaster /> once at the app root, then call toast(...) anywhere.

export interface ToastOptions {
  title?: React.ReactNode;
  description?: React.ReactNode;
  variant?: VariantProps<typeof toastVariants>["variant"];
  /** Auto-dismiss delay in ms (default 5000). */
  duration?: number;
  action?: { label: string; onClick: () => void; altText: string };
}

interface QueuedToast extends ToastOptions {
  id: number;
  open: boolean;
}

let toastCount = 0;
let queue: QueuedToast[] = [];
const listeners = new Set<(toasts: QueuedToast[]) => void>();

function emit() {
  for (const l of listeners) l([...queue]);
}

/** Show a toast. Returns a dismiss function. */
export function toast(options: ToastOptions): () => void {
  const id = ++toastCount;
  queue = [...queue.slice(-4), { ...options, id, open: true }];
  emit();
  const dismiss = () => {
    queue = queue.map((t) => (t.id === id ? { ...t, open: false } : t));
    emit();
  };
  return dismiss;
}

export function useToastQueue(): [QueuedToast[], (id: number, open: boolean) => void] {
  const [toasts, setToasts] = React.useState<QueuedToast[]>(() => [...queue]);
  React.useEffect(() => {
    listeners.add(setToasts);
    return () => {
      listeners.delete(setToasts);
    };
  }, []);
  const setOpen = React.useCallback((id: number, open: boolean) => {
    queue = open ? queue : queue.filter((t) => t.id !== id);
    emit();
  }, []);
  return [toasts, setOpen];
}

/** Renders the queue from `toast(...)`. Mount once, near the app root. */
export function Toaster(props: React.ComponentPropsWithoutRef<typeof RT.Provider>) {
  const [toasts, setOpen] = useToastQueue();
  return (
    <ToastProvider {...props}>
      {toasts.map((t) => (
        <Toast
          key={t.id}
          variant={t.variant}
          duration={t.duration}
          open={t.open}
          onOpenChange={(open) => setOpen(t.id, open)}
        >
          <div className="flex-1 min-w-0">
            {t.title && <ToastTitle>{t.title}</ToastTitle>}
            {t.description && <ToastDescription>{t.description}</ToastDescription>}
          </div>
          {t.action && (
            <ToastAction altText={t.action.altText} onClick={t.action.onClick}>
              {t.action.label}
            </ToastAction>
          )}
          <ToastClose />
        </Toast>
      ))}
      <ToastViewport />
    </ToastProvider>
  );
}
