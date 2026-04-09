import * as React from "react";
import { cva, type VariantProps } from "class-variance-authority";
import { Info, CheckCircle2, AlertTriangle, XCircle } from "lucide-react";
import { cn } from "../lib/cn";

const alertVariants = cva(
  "flex gap-3 rounded-lg border px-4 py-3.5",
  {
    variants: {
      variant: {
        blue:  "bg-royal-50 border-royal-100 text-royal-600 [&_.aeros-alert-title]:text-royal-800",
        green: "bg-success-bg border-[#BBF7D0] text-success [&_.aeros-alert-title]:text-success-text",
        amber: "bg-warning-bg border-[#FDE68A] text-warning [&_.aeros-alert-title]:text-warning-text",
        red:   "bg-danger-bg border-[#FECACA] text-danger [&_.aeros-alert-title]:text-danger-text"
      }
    },
    defaultVariants: { variant: "blue" }
  }
);

const iconMap = {
  blue:  Info,
  green: CheckCircle2,
  amber: AlertTriangle,
  red:   XCircle
};

export interface AlertProps
  extends React.HTMLAttributes<HTMLDivElement>,
    VariantProps<typeof alertVariants> {
  title?: React.ReactNode;
  icon?: React.ReactNode;
}

export function Alert({ className, variant = "blue", title, icon, children, ...props }: AlertProps) {
  const Icon = iconMap[variant!];
  return (
    <div role="alert" className={cn(alertVariants({ variant }), className)} {...props}>
      <div className="shrink-0 mt-0.5">
        {icon ?? <Icon className="h-[18px] w-[18px]" />}
      </div>
      <div className="flex-1 min-w-0">
        {title && <div className="aeros-alert-title text-[13px] font-bold mb-0.5">{title}</div>}
        <div className="text-xs leading-relaxed">{children}</div>
      </div>
    </div>
  );
}
