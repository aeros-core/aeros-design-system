import * as React from "react";

// Helpers for `asChild`. Not exported from the package.
//
// Why this exists: when a Server Component writes
//   <Button asChild leadingIcon={<Plus />}><Link href="/orders">Orders</Link></Button>
// the child can reach the (client) Button not as an element but as a lazy
// reference to a later row of the RSC payload ({ $$typeof: react.lazy,
// _payload: <thenable> }). Radix Slot unwraps that only when it is Slot's
// *direct* child; anything that inspects the child first (`isValidElement`,
// `Slottable`) sees "not an element" and renders nothing, without an error.
// So every asChild component resolves its child here first, then hands Slot a
// real element.

const REACT_LAZY_TYPE = Symbol.for("react.lazy");

// `React.use` is read indirectly so bundlers do not flag the missing export on React 18.
const use = (React as unknown as Record<string, unknown>)[" use ".trim()] as
  | (<T>(usable: PromiseLike<T>) => T)
  | undefined;

interface LazyNode {
  $$typeof: symbol;
  _payload: PromiseLike<React.ReactNode>;
}

function isLazyNode(node: unknown): node is LazyNode {
  if (typeof node !== "object" || node === null) return false;
  const lazy = node as Partial<LazyNode>;
  return (
    lazy.$$typeof === REACT_LAZY_TYPE &&
    typeof lazy._payload === "object" &&
    lazy._payload !== null &&
    "then" in lazy._payload
  );
}

/**
 * The node a lazy RSC reference stands for; any other node is returned as is.
 * Suspends (like `React.use`) while the reference is still loading, so it may
 * only be called during render.
 */
export function resolveLazyNode(node: React.ReactNode): React.ReactNode {
  let resolved: unknown = node;
  while (isLazyNode(resolved) && typeof use === "function") resolved = use(resolved._payload);
  return resolved as React.ReactNode;
}

type ChildElement = React.ReactElement<{ children?: React.ReactNode }>;

/**
 * The single element an `asChild` component should render as, or null when the
 * caller did not pass exactly one element.
 */
export function resolveSlotChild(children: React.ReactNode): ChildElement | null {
  const child = resolveLazyNode(children);
  return React.isValidElement(child) ? (child as ChildElement) : null;
}

/**
 * The `asChild` child with its content replaced by `render(ownContent)` — how a
 * component places icons, a label wrapper or a count inside the caller's element.
 * Pass the result to Radix `Slot`, which merges props, handlers and refs.
 */
export function slotChildWith(
  children: React.ReactNode,
  render: (content: React.ReactNode) => React.ReactNode
): ChildElement | null {
  const child = resolveSlotChild(children);
  return child ? React.cloneElement(child, undefined, render(child.props.children)) : null;
}
