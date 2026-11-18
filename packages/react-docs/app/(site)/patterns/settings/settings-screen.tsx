"use client";

import * as React from "react";
import {
  Alert,
  AlertDialog,
  AlertDialogAction,
  AlertDialogCancel,
  AlertDialogContent,
  AlertDialogDescription,
  AlertDialogFooter,
  AlertDialogHeader,
  AlertDialogTitle,
  AlertDialogTrigger,
  Badge,
  Button,
  Card,
  CardBody,
  CardFooter,
  CardHeader,
  CardSubtitle,
  CardTitle,
  Field,
  FieldGroup,
  Input,
  Label,
  PageHeader,
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
  Switch,
  Tabs,
  TabsContent,
  TabsList,
  TabsTrigger,
} from "@aeros-core/react";

const NOTIFICATIONS = [
  { id: "orders", label: "Order updates", hint: "When an order is accepted, shipped or delivered." },
  { id: "rfqs", label: "New RFQs", hint: "When a buyer sends a request for quotation." },
  { id: "late", label: "Late shipments", hint: "When a shipment passes its promised date." },
  { id: "digest", label: "Weekly summary", hint: "A digest every Monday morning." },
] as const;
type NotificationId = (typeof NOTIFICATIONS)[number]["id"];

export function SettingsScreen() {
  const [name, setName] = React.useState("Trimurti Packaging");
  const [savedName, setSavedName] = React.useState(name);
  const [timezone, setTimezone] = React.useState("asia-kolkata");
  const [savedTimezone, setSavedTimezone] = React.useState(timezone);
  const [enabled, setEnabled] = React.useState<Record<NotificationId, boolean>>({
    orders: true,
    rfqs: true,
    late: true,
    digest: false,
  });
  const [deleted, setDeleted] = React.useState(false);

  const dirty = name !== savedName || timezone !== savedTimezone;
  const nameError = name.trim() === "" ? "Enter a workspace name." : undefined;
  const enabledCount = Object.values(enabled).filter(Boolean).length;

  const save = (event: React.FormEvent) => {
    event.preventDefault();
    if (nameError) return;
    setSavedName(name);
    setSavedTimezone(timezone);
  };

  return (
    <Tabs defaultValue="general" className="min-w-0">
      <PageHeader
        as="h2"
        title="Workspace settings"
        description={`${savedName} · Pune`}
        tabs={
          <TabsList>
            <TabsTrigger value="general">General</TabsTrigger>
            <TabsTrigger value="notifications">Notifications</TabsTrigger>
          </TabsList>
        }
      />

      <TabsContent value="general" className="grid gap-6 pt-6">
        <Card>
          <form onSubmit={save} noValidate>
            <CardHeader>
              <div>
                <CardTitle>Profile</CardTitle>
                <CardSubtitle>Shown on orders and invoices.</CardSubtitle>
              </div>
            </CardHeader>
            <CardBody>
              <FieldGroup className="max-w-xl">
                <Field label="Workspace name" required error={nameError}>
                  <Input value={name} onChange={(event) => setName(event.target.value)} />
                </Field>
                <Field label="Time zone" hint="Used for dispatch cut-offs and reports.">
                  <Select value={timezone} onValueChange={setTimezone}>
                    <SelectTrigger>
                      <SelectValue />
                    </SelectTrigger>
                    <SelectContent>
                      <SelectItem value="asia-kolkata">India (IST, UTC+5:30)</SelectItem>
                      <SelectItem value="asia-dubai">Gulf (GST, UTC+4)</SelectItem>
                      <SelectItem value="asia-singapore">Singapore (SGT, UTC+8)</SelectItem>
                    </SelectContent>
                  </Select>
                </Field>
              </FieldGroup>
            </CardBody>
            <CardFooter>
              <span className="text-caption text-fg-muted" aria-live="polite">
                {dirty ? "Unsaved changes" : "All changes saved"}
              </span>
              <Button type="submit" disabled={!dirty || nameError != null}>
                Save changes
              </Button>
            </CardFooter>
          </form>
        </Card>

        <Card className="border-danger-border">
          <CardHeader className="border-danger-border">
            <div>
              <CardTitle>Danger zone</CardTitle>
              <CardSubtitle>These actions cannot be undone.</CardSubtitle>
            </div>
          </CardHeader>
          <CardBody className="flex flex-wrap items-center justify-between gap-4">
            <div className="min-w-0">
              <div className="text-label-md text-fg-primary">Delete this workspace</div>
              <p className="mt-0.5 max-w-prose text-body-sm text-fg-secondary">
                Removes the workspace with its orders, vendors and documents for every member.
              </p>
            </div>
            <AlertDialog>
              <AlertDialogTrigger asChild>
                <Button variant="danger-subtle" disabled={deleted}>
                  Delete workspace
                </Button>
              </AlertDialogTrigger>
              <AlertDialogContent>
                <AlertDialogHeader>
                  <AlertDialogTitle>Delete {savedName}?</AlertDialogTitle>
                  <AlertDialogDescription>
                    Its orders, vendors and documents are removed for every member. This cannot be undone.
                  </AlertDialogDescription>
                </AlertDialogHeader>
                <AlertDialogFooter>
                  <AlertDialogCancel asChild>
                    <Button variant="secondary">Cancel</Button>
                  </AlertDialogCancel>
                  <AlertDialogAction asChild>
                    <Button variant="danger" onClick={() => setDeleted(true)}>
                      Delete workspace
                    </Button>
                  </AlertDialogAction>
                </AlertDialogFooter>
              </AlertDialogContent>
            </AlertDialog>
          </CardBody>
          {deleted && (
            <div className="border-t border-danger-border p-4">
              <Alert variant="success" title="Workspace deleted">
                This is a demo — nothing was removed.{" "}
                <Button variant="link" onClick={() => setDeleted(false)}>
                  Undo
                </Button>
              </Alert>
            </div>
          )}
        </Card>
      </TabsContent>

      <TabsContent value="notifications" className="pt-6">
        <Card>
          <CardHeader>
            <div>
              <CardTitle>Email notifications</CardTitle>
              <CardSubtitle>Changes apply immediately.</CardSubtitle>
            </div>
            <Badge variant="neutral">
              {enabledCount} of {NOTIFICATIONS.length} on
            </Badge>
          </CardHeader>
          <div>
            {NOTIFICATIONS.map((item) => (
              <div
                key={item.id}
                className="flex items-start justify-between gap-4 border-b border-border-subtle px-4 py-3 last:border-b-0"
              >
                <div className="min-w-0">
                  <Label htmlFor={`notify-${item.id}`}>{item.label}</Label>
                  <p id={`notify-${item.id}-hint`} className="mt-0.5 text-caption text-fg-muted">
                    {item.hint}
                  </p>
                </div>
                <Switch
                  id={`notify-${item.id}`}
                  aria-describedby={`notify-${item.id}-hint`}
                  checked={enabled[item.id]}
                  onCheckedChange={(value) => setEnabled((current) => ({ ...current, [item.id]: value }))}
                />
              </div>
            ))}
          </div>
        </Card>
      </TabsContent>
    </Tabs>
  );
}
