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
      "fixed bottom-0 right-0 z-toast flex max-h-screen w-full flex-col gap-2 p-4 sm:max-w-sm",
      className
    )}
    {...props}
  />
));
ToastViewport.displayName = "ToastViewport";

// Every toast is the same elevated surface; the tone only colours the title,
// so status text never sits on a tinted fill.
const toastVariants = cva(
  "group pointer-events-auto relative flex w-full items-start gap-3 overflow-hidden rounded-surface bg-bg-elevated p-3 pr-9 text-fg-primary shadow-overlay " +
    "data-[state=open]:animate-in data-[state=open]:slide-in-from-bottom-2 data-[state=open]:fade-in-0 " +
    "data-[state=closed]:animate-out data-[state=closed]:fade-out-0 data-[state=closed]:slide-out-to-right-2 " +
    "data-[state=open]:duration-base data-[state=open]:ease-enter data-[state=closed]:duration-fast data-[state=closed]:ease-exit " +
    "motion-reduce:animate-none",
  {
    variants: {
      variant: {
        neutral: "",
        success: "[&_[data-toast-title]]:text-success-text",
        warning: "[&_[data-toast-title]]:text-warning-text",
        danger: "[&_[data-toast-title]]:text-danger-text"
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
  <RT.Title ref={ref} data-toast-title="" className={cn("text-label-sm", className)} {...props} />
));
ToastTitle.displayName = "ToastTitle";

export const ToastDescription = React.forwardRef<
  React.ElementRef<typeof RT.Description>,
  React.ComponentPropsWithoutRef<typeof RT.Description>
>(({ className, ...props }, ref) => (
  <RT.Description ref={ref} className={cn("text-caption text-fg-secondary", className)} {...props} />
));
ToastDescription.displayName = "ToastDescription";

export const ToastAction = React.forwardRef<
  React.ElementRef<typeof RT.Action>,
  React.ComponentPropsWithoutRef<typeof RT.Action>
>(({ className, ...props }, ref) => (
  <RT.Action
    ref={ref}
    className={cn(
      "ml-auto inline-flex h-control-xs shrink-0 items-center rounded-control border border-border-strong px-2 text-label-xs",
      "transition-colors duration-quick hover:bg-state-hover",
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
      "absolute right-2 top-2 inline-flex size-control-xs items-center justify-center rounded-control text-fg-muted",
      "transition-colors duration-quick hover:bg-state-hover hover:text-fg-primary [&_svg]:size-icon-sm",
      className
    )}
    {...props}
  >
    <X />
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
