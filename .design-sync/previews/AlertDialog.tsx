import * as React from "react";
import {
  AlertDialog,
  AlertDialogAction,
  AlertDialogCancel,
  AlertDialogContent,
  AlertDialogDescription,
  AlertDialogFooter,
  AlertDialogHeader,
  AlertDialogTitle,
  AlertDialogTrigger,
  Button,
} from "@aeros-core/react";

// defaultOpen renders the confirmation in its open state for a static card.
export const DeleteConfirmation = () => (
  <AlertDialog defaultOpen>
    <AlertDialogTrigger asChild>
      <Button variant="danger">Delete industry</Button>
    </AlertDialogTrigger>
    <AlertDialogContent>
      <AlertDialogHeader>
        <AlertDialogTitle>Delete industry?</AlertDialogTitle>
        <AlertDialogDescription>
          Items in Construction will be reclassified as Other. This cannot be undone.
        </AlertDialogDescription>
      </AlertDialogHeader>
      <AlertDialogFooter>
        <AlertDialogCancel asChild>
          <Button variant="secondary">Cancel</Button>
        </AlertDialogCancel>
        <AlertDialogAction asChild>
          <Button variant="danger">Delete</Button>
        </AlertDialogAction>
      </AlertDialogFooter>
    </AlertDialogContent>
  </AlertDialog>
);
