import * as React from "react";
import { cn } from "../lib/cn";

export function Sidebar({ className, children, ...props }: React.HTMLAttributes<HTMLElement>) {
  return (
    <aside
      className={cn(
        "w-[228px] shrink-0 h-screen sticky top-0 overflow-y-auto bg-slate-900 text-white [scrollbar-width:none] [&::-webkit-scrollbar]:hidden",
        className
      )}
      {...props}
    >
      {children}
    </aside>
  );
}

export function SidebarBrand({
  mark,
  name,
  sub,
  className
}: {
  mark?: React.ReactNode;
  name: React.ReactNode;
  sub?: React.ReactNode;
  className?: string;
}) {
  return (
    <div className={cn("flex items-center gap-2.5 px-5 py-5 border-b border-white/5", className)}>
      <div className="flex h-9 w-9 items-center justify-center rounded-lg bg-royal-600 text-base font-extrabold text-white">
        {mark}
      </div>
      <div className="min-w-0">
        <div className="text-base font-extrabold tracking-[-0.02em] text-white leading-tight">{name}</div>
        {sub && <div className="mt-px font-mono text-[10px] text-slate-400 truncate">{sub}</div>}
      </div>
    </div>
  );
}

export function SidebarSection({
  label,
  className,
  children
}: {
  label?: React.ReactNode;
  className?: string;
  children: React.ReactNode;
}) {
  return (
    <div className={cn("px-3 pt-[18px] pb-1", className)}>
      {label && (
        <div className="mb-2 px-3 text-[10px] font-bold uppercase tracking-[0.08em] text-slate-400">
          {label}
        </div>
      )}
      {children}
    </div>
  );
}

export function SidebarItem({
  active,
  icon,
  className,
  children,
  ...props
}: React.AnchorHTMLAttributes<HTMLAnchorElement> & { active?: boolean; icon?: React.ReactNode }) {
  return (
    <a
      className={cn(
        "flex items-center gap-2.5 rounded-md px-3 py-2 text-[13px] font-medium transition-colors",
        active
          ? "bg-royal-600/30 text-white"
          : "text-white/50 hover:bg-white/5 hover:text-white/80",
        className
      )}
      {...props}
    >
      {icon ?? <span className={cn("h-1.5 w-1.5 rounded-full", active ? "bg-royal-400" : "bg-white/20")} />}
      {children}
    </a>
  );
}
