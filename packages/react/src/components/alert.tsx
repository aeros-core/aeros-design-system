import * as React from "react";
import { cva, type VariantProps } from "class-variance-authority";
import { Info, CheckCircle2, AlertTriangle, XCircle } from "lucide-react";
import { cn } from "../lib/cn";

// Body copy uses the `-text` shade (WCAG 4.5:1 on the tinted bg); only the
// icon may use the brighter base color (3:1 non-text minimum).
const alertVariants = cva(
  "flex gap-3 rounded-lg border px-4 py-3.5",
  {
    variants: {
      variant: {
        info:    "bg-info-bg border-info-border text-info-text [&_.aeros-alert-icon]:text-info",
        success: "bg-success-bg border-success-border text-success-text [&_.aeros-alert-icon]:text-success",
        warning: "bg-warning-bg border-warning-border text-warning-text [&_.aeros-alert-icon]:text-warning",
        danger:  "bg-danger-bg border-danger-border text-danger-text [&_.aeros-alert-icon]:text-danger"
      }
    },
    defaultVariants: { variant: "info" }
  }
);

const iconMap = {
  info:    Info,
  success: CheckCircle2,
  warning: AlertTriangle,
  danger:  XCircle
};

export interface AlertProps
  extends Omit<React.HTMLAttributes<HTMLDivElement>, "title">,
    VariantProps<typeof alertVariants> {
  title?: React.ReactNode;
  icon?: React.ReactNode;
}

export const Alert = React.forwardRef<HTMLDivElement, AlertProps>(
  ({ className, variant = "info", title, icon, role, children, ...props }, ref) => {
    const Icon = iconMap[variant!];
    return (
      <div
        ref={ref}
        // Only danger interrupts assistive tech; everything else is a polite
        // status region. Pass role explicitly to override (e.g. role={undefined}
        // for purely static content).
        role={role !== undefined ? role : variant === "danger" ? "alert" : "status"}
        className={cn(alertVariants({ variant }), className)}
        {...props}
      >
        <div className="aeros-alert-icon shrink-0 mt-0.5">
          {icon ?? <Icon className="h-[18px] w-[18px]" />}
        </div>
        <div className="flex-1 min-w-0">
          {title && <div className="text-[13px] font-bold mb-0.5">{title}</div>}
          <div className="text-xs leading-relaxed">{children}</div>
        </div>
      </div>
    );
  }
);
Alert.displayName = "Alert";

export { alertVariants };
