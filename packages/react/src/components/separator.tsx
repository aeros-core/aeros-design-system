"use client";
import * as React from "react";
import * as RS from "@radix-ui/react-separator";
import { cn } from "../lib/cn";

export const Separator = React.forwardRef<
  React.ElementRef<typeof RS.Root>,
  React.ComponentPropsWithoutRef<typeof RS.Root>
>(({ className, orientation = "horizontal", decorative = true, ...props }, ref) => (
  <RS.Root
    ref={ref}
    orientation={orientation}
    decorative={decorative}
    className={cn(
      "shrink-0 bg-border-default",
      orientation === "horizontal" ? "h-px w-full" : "h-full w-px",
      className
    )}
    {...props}
  />
));
Separator.displayName = "Separator";
