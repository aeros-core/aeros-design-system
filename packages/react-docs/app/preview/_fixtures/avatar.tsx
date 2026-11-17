"use client";

import { Avatar, AvatarStack } from "@aeros-core/react";
import { Group } from "./kit";

// Inline SVG so the image path is exercised without any network request.
const AVATAR_SRC =
  "data:image/svg+xml;utf8," +
  encodeURIComponent(
    '<svg xmlns="http://www.w3.org/2000/svg" width="64" height="64">' +
      '<rect width="64" height="64" fill="#57554F"/>' +
      '<circle cx="32" cy="24" r="12" fill="#E7E6E2"/>' +
      '<rect x="10" y="42" width="44" height="30" rx="15" fill="#E7E6E2"/>' +
      "</svg>"
  );

export default function AvatarFixture() {
  return (
    <>
      <Group label="Sizes">
        <Avatar size="xs" fallback="PS" />
        <Avatar size="sm" fallback="PS" />
        <Avatar size="md" fallback="PS" />
        <Avatar size="lg" fallback="PS" />
        <Avatar size="xl" fallback="PS" />
      </Group>
      <Group label="Tones">
        <Avatar variant="neutral" fallback="NE" />
        <Avatar variant="inverse" fallback="IN" />
        <Avatar variant="info" fallback="IF" />
        <Avatar variant="success" fallback="SU" />
        <Avatar variant="warning" fallback="WA" />
      </Group>
      <Group label="Image (inline data URI)">
        <Avatar size="sm" src={AVATAR_SRC} alt="Priya Sharma" fallback="PS" />
        <Avatar size="md" src={AVATAR_SRC} alt="Priya Sharma" fallback="PS" />
        <Avatar size="lg" src={AVATAR_SRC} alt="Priya Sharma" fallback="PS" />
      </Group>
      <Group label="Stack">
        <AvatarStack>
          <Avatar size="sm" fallback="PS" />
          <Avatar size="sm" variant="inverse" fallback="RK" />
          <Avatar size="sm" variant="success" fallback="MN" />
          <Avatar size="sm" variant="warning" fallback="AA" />
        </AvatarStack>
        <AvatarStack>
          <Avatar fallback="PS" />
          <Avatar variant="info" fallback="RK" />
          <Avatar variant="inverse" fallback="+3" />
        </AvatarStack>
      </Group>
      <Group label="Stack on bg-surface (ring colour)">
        <div className="rounded-lg border border-border-default bg-bg-surface p-4">
          <AvatarStack>
            <Avatar size="sm" fallback="PS" />
            <Avatar size="sm" variant="inverse" fallback="RK" />
            <Avatar size="sm" variant="success" fallback="MN" />
          </AvatarStack>
        </div>
      </Group>
    </>
  );
}
