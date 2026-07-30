import * as React from "react";
import { AvatarStack, Avatar } from "@aeros-core/react";

export const Team = () => (
  <AvatarStack>
    <Avatar size="sm" fallback="PS" />
    <Avatar size="sm" tone="dark" fallback="RK" />
    <Avatar size="sm" tone="green" fallback="MN" />
    <Avatar size="sm" tone="amber" fallback="AA" />
  </AvatarStack>
);

export const ReviewersLg = () => (
  <AvatarStack>
    <Avatar size="md" tone="ink" fallback="SG" />
    <Avatar size="md" tone="royal" fallback="DV" />
    <Avatar size="md" tone="green" fallback="PN" />
  </AvatarStack>
);
