"use client";

import * as React from "react";
import Link from "next/link";
import { Button, type ButtonProps } from "@aeros-core/react";

/**
 * A Button that is a link. Internal hrefs use the Next router.
 *
 * It exists as a client component on purpose: `<Button asChild>` composed in a
 * Server Component renders nothing when it also has an icon — the child
 * element reaches Radix Slot as a lazy reference, which Slot does not accept.
 * Composing it here, on the client, hands Slot a real element.
 */
export function LinkButton({
  href,
  children,
  ...props
}: Omit<ButtonProps, "asChild" | "children"> & { href: string; children: React.ReactNode }) {
  return (
    <Button asChild {...props}>
      {href.startsWith("/") ? <Link href={href}>{children}</Link> : <a href={href}>{children}</a>}
    </Button>
  );
}
