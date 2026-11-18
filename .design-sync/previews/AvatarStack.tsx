import * as React from "react";
import { AvatarStack, Avatar } from "@aeros-core/react";

export const Team = () => (
  <AvatarStack>
    <Avatar size="sm" fallback="PS" />
    <Avatar size="sm" variant="inverse" fallback="RK" />
    <Avatar size="sm" variant="success" fallback="MN" />
    <Avatar size="sm" variant="warning" fallback="AA" />
  </AvatarStack>
);

export const ReviewersLg = () => (
  <AvatarStack>
    <Avatar size="md" fallback="SG" />
    <Avatar size="md" variant="info" fallback="DV" />
    <Avatar size="md" variant="success" fallback="PN" />
  </AvatarStack>
);
