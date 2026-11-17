"use client";

import {
  Button,
  Dialog,
  DialogBody,
  DialogClose,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
  Field,
  Input,
} from "@aeros-core/react";
import { Group } from "./kit";

export default function DialogFixture() {
  return (
    <Group label="Dialog — open">
      <Dialog open>
        <DialogTrigger asChild>
          <Button>Invite teammate</Button>
        </DialogTrigger>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>Invite a teammate</DialogTitle>
            <DialogDescription>They'll get access to this workspace.</DialogDescription>
          </DialogHeader>
          <DialogBody>
            <Field label="Email" required hint="We'll send a one-time invite link.">
              <Input type="email" placeholder="priya@example.com" />
            </Field>
          </DialogBody>
          <DialogFooter>
            <DialogClose asChild>
              <Button variant="secondary">Cancel</Button>
            </DialogClose>
            <Button>Send invite</Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </Group>
  );
}
