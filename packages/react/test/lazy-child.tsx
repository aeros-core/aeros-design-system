import type * as React from "react";

/**
 * What a child element looks like when a Server Component passes it to a client
 * component and React Flight puts it in a later row of the payload: not an
 * element but a lazy reference ({ $$typeof: react.lazy, _payload: thenable }).
 * The thenable here is already fulfilled, as it is once the row has arrived.
 */
export function lazyChild(element: React.ReactElement): React.ReactElement {
  const payload = Object.assign(Promise.resolve(element), { status: "fulfilled", value: element });
  return {
    $$typeof: Symbol.for("react.lazy"),
    _payload: payload,
    _init: (p: { value: React.ReactElement }) => p.value
  } as unknown as React.ReactElement;
}
