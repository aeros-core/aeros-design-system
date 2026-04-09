import * as React from "react";
import { cn } from "../lib/cn";

export function TopNav({ className, children, ...props }: React.HTMLAttributes<HTMLElement>) {
  return (
    <header
      className={cn(
        "h-14 flex items-center gap-2.5 px-5 rounded-lg bg-slate-900 text-white",
        className
      )}
      {...props}
    >
      {children}
    </header>
  );
}

export function TopNavBrand({
  mark,
  name,
  className
}: {
  mark?: React.ReactNode;
  name: React.ReactNode;
  className?: string;
}) {
  return (
    <div className={cn("flex items-center gap-2.5", className)}>
      <div className="flex h-[30px] w-[30px] items-center justify-center rounded-lg bg-royal-600 text-[13px] font-extrabold tracking-[-0.01em] text-white">
        {mark}
      </div>
      <div className="text-[15px] font-extrabold tracking-[-0.02em]">{name}</div>
    </div>
  );
}

export function TopNavLinks({ className, children }: { className?: string; children: React.ReactNode }) {
  return <nav className={cn("flex flex-1 gap-0.5 ml-1.5", className)}>{children}</nav>;
}

export function TopNavLink({
  active,
  className,
  ...props
}: React.AnchorHTMLAttributes<HTMLAnchorElement> & { active?: boolean }) {
  return (
    <a
      className={cn(
        "text-[13px] font-medium px-2.5 py-1 rounded-md transition-colors",
        active ? "bg-white/10 text-white font-semibold" : "text-white/40 hover:text-white/70",
        className
      )}
      {...props}
    />
  );
}

export function TopNavRight({ className, children }: { className?: string; children: React.ReactNode }) {
  return <div className={cn("flex items-center gap-2", className)}>{children}</div>;
}
