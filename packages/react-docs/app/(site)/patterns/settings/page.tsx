import type { Metadata } from "next";
import { CodeBlock } from "../../../_site/code-block";
import { Code, Demo, PageIntro, Section } from "../../../_site/prose";
import { SettingsScreen } from "./settings-screen";

export const metadata: Metadata = { title: "Settings" };

const COMPOSITION = `<Tabs defaultValue="general">
  <PageHeader
    title="Workspace settings"
    description="Trimurti Packaging · Pune"
    tabs={
      <TabsList>
        <TabsTrigger value="general">General</TabsTrigger>
        <TabsTrigger value="notifications">Notifications</TabsTrigger>
      </TabsList>
    }
  />

  <TabsContent value="notifications" className="pt-6">
    <Card>
      <div className="flex items-start justify-between gap-4 px-4 py-3">
        <div>
          <Label htmlFor="notify-orders">Order updates</Label>
          <p id="notify-orders-hint" className="text-caption text-fg-muted">When an order ships.</p>
        </div>
        <Switch id="notify-orders" aria-describedby="notify-orders-hint" checked={on} onCheckedChange={setOn} />
      </div>
    </Card>
  </TabsContent>
</Tabs>

<AlertDialog>
  <AlertDialogTrigger asChild>
    <Button variant="danger-subtle">Delete workspace</Button>
  </AlertDialogTrigger>
  <AlertDialogContent>
    <AlertDialogHeader>
      <AlertDialogTitle>Delete this workspace?</AlertDialogTitle>
      <AlertDialogDescription>Its orders and vendors are removed. This cannot be undone.</AlertDialogDescription>
    </AlertDialogHeader>
    <AlertDialogFooter>
      <AlertDialogCancel asChild><Button variant="secondary">Cancel</Button></AlertDialogCancel>
      <AlertDialogAction asChild><Button variant="danger" onClick={remove}>Delete workspace</Button></AlertDialogAction>
    </AlertDialogFooter>
  </AlertDialogContent>
</AlertDialog>`;

export default function SettingsPatternPage() {
  return (
    <>
      <PageIntro section="Patterns">
        Settings are grouped under tabs, each group on its own surface. A preference that takes effect at once is a
        switch; anything that needs a deliberate save is a form with a button. Destructive actions live apart, in a
        danger zone, behind a confirmation that must be answered.
      </PageIntro>

      <Section
        title="Live"
        description="Switch tabs, flip the switches, and try the delete button — the confirmation does not close on an outside click."
      >
        <Demo>
          <SettingsScreen />
        </Demo>
      </Section>

      <Section
        title="Composition"
        description={
          <>
            The tab list sits in the page header&apos;s <Code>tabs</Code> slot, so <Code>Tabs</Code> wraps the header
            and the panels. Each switch is named by a <Code>Label</Code> and described by its hint.
          </>
        }
      >
        <CodeBlock title="settings-screen.tsx" code={COMPOSITION} />
      </Section>

      <Section title="Rules of thumb">
        <ul className="grid max-w-prose list-disc gap-2 pl-5 text-body-md text-fg-secondary">
          <li>A switch applies immediately. If the change waits for a save button, use a checkbox.</li>
          <li>The danger zone is the only place the danger colour appears at rest, and it stays quiet: the subtle variant on the page, the solid one inside the confirmation.</li>
          <li>The confirmation names the thing being destroyed and the consequence, and its action repeats the verb.</li>
        </ul>
      </Section>
    </>
  );
}
