import * as React from "react";
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogDescription,
  DialogBody,
  DialogFooter,
  DialogClose,
  Field,
  Input,
  Button,
} from "@aeros-core/react";

// defaultOpen renders the modal in its open state for a static card.
export const InviteDialog = () => (
  <Dialog defaultOpen>
    <DialogContent>
      <DialogHeader>
        <DialogTitle>Invite a teammate</DialogTitle>
        <DialogDescription>They'll get access to this workspace.</DialogDescription>
      </DialogHeader>
      <DialogBody>
        <Field label="Email" required>
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
);
