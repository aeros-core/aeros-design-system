"use client";

import * as React from "react";
import {
  Button,
  Input,
  Field,
  Textarea,
  Checkbox,
  RadioGroup,
  RadioGroupItem,
  Switch,
  Badge,
  Tag,
  Card,
  CardHeader,
  CardTitle,
  CardSubtitle,
  CardBody,
  CardFooter,
  StatCard,
  Alert,
  Progress,
  Avatar,
  AvatarStack,
  Tabs,
  TabsList,
  TabsTrigger,
  TabsContent,
  TabCount,
  Breadcrumb,
  DropdownMenu,
  DropdownMenuTrigger,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuSeparator,
  DropdownMenuLabel,
  Dialog,
  DialogTrigger,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogDescription,
  DialogBody,
  DialogFooter,
  DialogClose,
  Tooltip,
  TooltipProvider,
  TooltipTrigger,
  TooltipContent,
  Table,
  Thead,
  Tbody,
  Tr,
  Th,
  Td,
  TdStrong,
  TdMono,
  TdMuted,
  EmptyState,
  TopNav,
  TopNavBrand,
  TopNavLinks,
  TopNavLink,
  TopNavRight,
  Sidebar,
  SidebarBrand,
  SidebarSection,
  SidebarItem,
  DotMatrix,
} from "@aeros/react";
import {
  Inbox,
  Search,
  Plus,
  ChevronDown,
  Settings,
  LogOut,
  Info as InfoIcon,
} from "lucide-react";

// ────────────────────────────────────────────────────────────────
// Section wrapper
// ────────────────────────────────────────────────────────────────
function Section({
  id,
  eyebrow,
  title,
  description,
  children,
}: {
  id: string;
  eyebrow: string;
  title: string;
  description?: string;
  children: React.ReactNode;
}) {
  return (
    <section id={id} className="mb-16 scroll-mt-8">
      <div className="mb-8">
        <div className="mb-2 text-[10px] font-mono font-bold uppercase tracking-[0.1em] text-fg-muted">
          {eyebrow}
        </div>
        <h2 className="mb-2 text-[26px] font-extrabold tracking-[-0.03em] text-fg-primary leading-[1.1]">
          {title}
        </h2>
        {description && (
          <p className="max-w-2xl text-sm text-fg-muted leading-relaxed">
            {description}
          </p>
        )}
      </div>
      {children}
    </section>
  );
}

function Row({
  label,
  children,
  className,
}: {
  label: string;
  children: React.ReactNode;
  className?: string;
}) {
  return (
    <div className="mb-6">
      <div className="mb-2 text-[11px] font-mono uppercase tracking-wider text-fg-muted">
        {label}
      </div>
      <div className={"flex flex-wrap items-center gap-3 " + (className ?? "")}>
        {children}
      </div>
    </div>
  );
}

// ────────────────────────────────────────────────────────────────
// Foundations: colour swatches + type scale
// ────────────────────────────────────────────────────────────────
const SEMANTIC_COLORS: Array<{ token: string; cssVar: string; hex: string }> = [
  { token: "bg-canvas",       cssVar: "--color-bg-canvas",     hex: "#FFFFFF" },
  { token: "bg-subtle",       cssVar: "--color-bg-subtle",     hex: "#F5F5F5" },
  { token: "bg-inverse",      cssVar: "--color-bg-inverse",    hex: "#0A0A0A" },
  { token: "fg-primary",      cssVar: "--color-fg-primary",    hex: "#0A0A0A" },
  { token: "fg-secondary",    cssVar: "--color-fg-secondary",  hex: "#404040" },
  { token: "fg-muted",        cssVar: "--color-fg-muted",      hex: "#6B6B6B" },
  { token: "border-default",  cssVar: "--color-border-default",hex: "#E5E5E5" },
  { token: "border-strong",   cssVar: "--color-border-strong", hex: "#C2C2C2" },
  { token: "accent",          cssVar: "--color-accent",        hex: "#0A0A0A" },
  { token: "accent-muted",    cssVar: "--color-accent-muted",  hex: "#F5F5F5" },
];

const STATUS_COLORS: Array<{ token: string; hex: string; cls: string }> = [
  { token: "success",      hex: "#16A34A", cls: "bg-success" },
  { token: "success-bg",   hex: "#DCFCE7", cls: "bg-success-bg" },
  { token: "warning",      hex: "#D97706", cls: "bg-warning" },
  { token: "warning-bg",   hex: "#FEF3C7", cls: "bg-warning-bg" },
  { token: "danger",       hex: "#DC2626", cls: "bg-danger" },
  { token: "danger-bg",    hex: "#FEE2E2", cls: "bg-danger-bg" },
  { token: "info",         hex: "#404040", cls: "bg-info" },
  { token: "info-bg",      hex: "#F5F5F5", cls: "bg-info-bg" },
];

const RAMPS: Array<{ name: string; shades: Array<{ k: string; hex: string }> }> = [
  {
    name: "ink",
    shades: [
      { k: "50", hex: "#F5F5F5" },
      { k: "100", hex: "#E5E5E5" },
      { k: "200", hex: "#C2C2C2" },
      { k: "400", hex: "#737373" },
      { k: "600", hex: "#404040" },
      { k: "800", hex: "#1A1A1A" },
      { k: "900", hex: "#0A0A0A" },
    ],
  },
];

function Swatch({
  hex,
  token,
  bgStyle,
  bgClass,
  withBorder = false,
}: {
  hex: string;
  token: string;
  bgStyle?: React.CSSProperties;
  bgClass?: string;
  withBorder?: boolean;
}) {
  return (
    <div className="flex flex-col gap-1.5">
      <div
        className={
          "h-16 w-full rounded-lg " +
          (bgClass ?? "") +
          (withBorder ? " border border-border-default" : "")
        }
        style={bgStyle}
      />
      <div className="font-mono text-[11px] text-fg-primary leading-tight">{token}</div>
      <div className="font-mono text-[10px] uppercase text-fg-muted">{hex}</div>
    </div>
  );
}

const TYPE_SCALE: Array<{ cls: string; label: string; sample: string }> = [
  { cls: "t-display-xl", label: "display-xl · 56 / 800", sample: "Run everything." },
  { cls: "t-display-lg", label: "display-lg · 42 / 800", sample: "Run everything." },
  { cls: "t-display-md", label: "display-md · 32 / 800", sample: "Built for operators." },
  { cls: "t-h1",         label: "h1 · 28 / 800",          sample: "Today's production" },
  { cls: "t-h2",         label: "h2 · 22 / 800",          sample: "Pending approvals" },
  { cls: "t-h3",         label: "h3 · 20 / 700",          sample: "Live shipments" },
  { cls: "t-h4",         label: "h4 · 16 / 700",          sample: "RFQ-0042 · Pacific Pack Co." },
  { cls: "t-body-lg",    label: "body-lg · 16 / 500",     sample: "Designed for the operator who can't pause for slow software." },
  { cls: "t-body-md",    label: "body-md · 14 / 500",     sample: "Designed for the operator who can't pause for slow software." },
  { cls: "t-body-sm",    label: "body-sm · 13 / 500",     sample: "Updated 3 minutes ago by Priya Sharma." },
  { cls: "t-caption",    label: "caption · 12 / 500",     sample: "Auto-refreshed at 14:02 IST" },
  { cls: "t-overline",   label: "overline · 11 / 600 · UPPERCASE", sample: "Section label" },
  { cls: "t-mono-md",    label: "mono-md · 14 / 500",     sample: "RFQ-0042  ·  ₹1,24,000" },
  { cls: "t-mono-sm",    label: "mono-sm · 12 / 400",     sample: "0xA94F-LINE-3-SENSOR-02" },
];

// ────────────────────────────────────────────────────────────────
// Page
// ────────────────────────────────────────────────────────────────
const NAV: Array<{ section: string; items: Array<{ href: string; label: React.ReactNode }> }> = [
  {
    section: "Foundations",
    items: [
      { href: "#colors", label: "Colors" },
      { href: "#typography", label: "Typography" },
    ],
  },
  {
    section: "Components",
    items: [
      { href: "#buttons", label: "Buttons" },
      { href: "#inputs", label: "Inputs" },
      { href: "#controls", label: "Controls" },
      { href: "#badges", label: <>Badges &amp; tags</> },
      { href: "#cards", label: "Cards" },
      { href: "#stats", label: "Stat cards" },
      { href: "#alerts", label: "Alerts" },
      { href: "#progress", label: "Progress" },
      { href: "#avatars", label: "Avatars" },
      { href: "#tabs", label: "Tabs" },
      { href: "#breadcrumb", label: "Breadcrumb" },
      { href: "#menu", label: "Dropdown menu" },
      { href: "#dialog", label: "Dialog" },
      { href: "#tooltip", label: "Tooltip" },
      { href: "#table", label: "Table" },
      { href: "#empty", label: "Empty state" },
      { href: "#dot-matrix", label: "Dot matrix" },
      { href: "#nav", label: "TopNav" },
    ],
  },
];

function useActiveSection(defaultId: string): string {
  const [active, setActive] = React.useState(defaultId);

  React.useEffect(() => {
    const ids = NAV.flatMap((g) => g.items.map((i) => i.href.slice(1)));

    const fromHash = () => {
      const h = window.location.hash.slice(1);
      if (h && ids.includes(h)) setActive(h);
    };
    fromHash();
    window.addEventListener("hashchange", fromHash);

    const observer = new IntersectionObserver(
      (entries) => {
        const visible = entries
          .filter((e) => e.isIntersecting)
          .sort((a, b) => a.boundingClientRect.top - b.boundingClientRect.top)[0];
        if (visible) setActive(visible.target.id);
      },
      { rootMargin: "-40% 0px -55% 0px", threshold: 0 }
    );
    ids.forEach((id) => {
      const el = document.getElementById(id);
      if (el) observer.observe(el);
    });

    return () => {
      window.removeEventListener("hashchange", fromHash);
      observer.disconnect();
    };
  }, []);

  return active;
}

export default function Playground() {
  const [checked, setChecked] = React.useState<boolean>(true);
  const [switched, setSwitched] = React.useState(true);
  const active = useActiveSection("colors");

  return (
    <div className="flex min-h-screen">
      {/* ── SIDEBAR ─────────────────────────────────────── */}
      <Sidebar>
        <SidebarBrand mark="A" name="Aeros" sub="React docs" />
        {NAV.map((group) => (
          <SidebarSection key={group.section} label={group.section}>
            {group.items.map((item) => (
              <SidebarItem
                key={item.href}
                href={item.href}
                active={active === item.href.slice(1)}
              >
                {item.label}
              </SidebarItem>
            ))}
          </SidebarSection>
        ))}
      </Sidebar>

      {/* ── MAIN ───────────────────────────────────────── */}
      <main className="flex-1 px-10 py-14 max-w-[960px]">
        {/* HERO */}
        <div className="mb-16">
          <div className="inline-flex items-center gap-1.5 rounded-full border border-border-default bg-bg-subtle px-3 py-1 mb-5">
            <span className="h-1.5 w-1.5 rounded-full bg-ink-900 animate-pulse" />
            <span className="text-[11px] font-mono font-medium uppercase tracking-wider text-fg-secondary">
              Aeros DS · React playground
            </span>
          </div>
          <h1 className="text-[42px] font-extrabold tracking-[-0.04em] text-fg-primary leading-[1.0]">
            Run everything.
          </h1>
          <p className="mt-4 max-w-xl text-base text-fg-muted leading-relaxed">
            Every <code className="font-mono text-sm text-fg-primary">@aeros/react</code> component
            rendered with live props. Edit{" "}
            <code className="font-mono text-sm text-fg-primary">packages/react-docs/app/page.tsx</code>{" "}
            to extend this gallery.
          </p>
        </div>

        {/* COLORS */}
        <Section
          id="colors"
          eyebrow="01 — Foundations"
          title="Colors"
          description="Semantic aliases first; raw ramps only when you need a specific shade. Aliases switch automatically with [data-theme]."
        >
          <Row label="Semantic — surface, text, border">
            <div className="grid w-full grid-cols-2 gap-4 md:grid-cols-5">
              {SEMANTIC_COLORS.map((c) => (
                <Swatch
                  key={c.token}
                  hex={c.hex}
                  token={c.token}
                  bgStyle={{ backgroundColor: `var(${c.cssVar})` }}
                  withBorder={c.hex.toUpperCase() === "#FFFFFF" || c.hex.toUpperCase() === "#F5F5F5"}
                />
              ))}
            </div>
          </Row>
          <Row label="Status">
            <div className="grid w-full grid-cols-2 gap-4 md:grid-cols-4">
              {STATUS_COLORS.map((c) => (
                <Swatch key={c.token} hex={c.hex} token={c.token} bgClass={c.cls} />
              ))}
            </div>
          </Row>
          <Row label="Ramps">
            <div className="w-full space-y-5">
              {RAMPS.map((ramp) => (
                <div key={ramp.name}>
                  <div className="mb-2 font-mono text-[11px] uppercase tracking-wider text-fg-muted">
                    {ramp.name}
                  </div>
                  <div className="grid grid-cols-7 gap-2">
                    {ramp.shades.map((s) => (
                      <div key={s.k} className="flex flex-col gap-1">
                        <div
                          className="h-12 w-full rounded-md border border-border-default"
                          style={{ backgroundColor: s.hex }}
                        />
                        <div className="font-mono text-[10px] text-fg-primary">
                          {ramp.name}-{s.k}
                        </div>
                        <div className="font-mono text-[10px] uppercase text-fg-muted">{s.hex}</div>
                      </div>
                    ))}
                  </div>
                </div>
              ))}
            </div>
          </Row>
        </Section>

        {/* TYPOGRAPHY */}
        <Section
          id="typography"
          eyebrow="02 — Foundations"
          title="Typography"
          description="Plus Jakarta Sans for UI. IBM Plex Mono for data. Nunito Sans (wdth 125) is reserved for the wordmark."
        >
          <div className="space-y-5">
            {TYPE_SCALE.map((t) => (
              <div key={t.cls} className="flex items-baseline gap-6 border-b border-border-default pb-4">
                <div className="w-44 shrink-0 font-mono text-[11px] text-fg-muted">{t.label}</div>
                <div className={t.cls + " text-fg-primary"}>{t.sample}</div>
              </div>
            ))}
            <div className="flex items-baseline gap-6 pt-2">
              <div className="w-44 shrink-0 font-mono text-[11px] text-fg-muted">aeros-logo</div>
              <div className="aeros-logo text-[44px] text-fg-primary">Aeros</div>
            </div>
          </div>
        </Section>

        {/* BUTTONS */}
        <Section id="buttons" eyebrow="03 — Components" title="Buttons" description="Six variants. Five sizes. Loading, icons, asChild polymorphism.">
          <Row label="Variants">
            <Button variant="primary">Primary</Button>
            <Button variant="secondary">Secondary</Button>
            <Button variant="ghost">Ghost</Button>
            <Button variant="danger">Danger</Button>
            <Button variant="dark">Dark</Button>
            <Button variant="link">Link</Button>
          </Row>
          <Row label="Sizes">
            <Button size="xs">xs</Button>
            <Button size="sm">sm</Button>
            <Button size="md">md</Button>
            <Button size="lg">lg</Button>
            <Button size="xl">xl</Button>
          </Row>
          <Row label="With icons & loading">
            <Button leadingIcon={<Plus className="h-4 w-4" />}>Create RFQ</Button>
            <Button variant="secondary" trailingIcon={<ChevronDown className="h-4 w-4" />}>
              Filter
            </Button>
            <Button loading>Saving…</Button>
            <Button disabled>Disabled</Button>
          </Row>
        </Section>

        {/* INPUTS */}
        <Section id="inputs" eyebrow="04 — Components" title="Inputs" description="Text inputs with prefix/suffix slots, states, and the Field wrapper.">
          <div className="grid max-w-xl gap-4">
            <Field label="Email" hint="We'll never share your address.">
              <Input type="email" placeholder="priya@example.com" />
            </Field>
            <Field label="Full name" required>
              <Input placeholder="Priya Sharma" />
            </Field>
            <Field label="Search orders">
              <Input prefix={<Search className="h-4 w-4" />} placeholder="Search by RFQ / SKU" />
            </Field>
            <Field label="With error" error="This field is required.">
              <Input state="error" placeholder="RFQ-0042" />
            </Field>
            <Field label="Notes">
              <Textarea placeholder="Add context for your team…" rows={3} />
            </Field>
          </div>
        </Section>

        {/* CONTROLS */}
        <Section id="controls" eyebrow="05 — Components" title="Checkbox · Radio · Switch">
          <Row label="Checkboxes">
            <label className="inline-flex items-center gap-2 text-sm text-fg-secondary">
              <Checkbox checked={checked} onCheckedChange={(v) => setChecked(v === true)} />
              I agree to the terms
            </label>
            <label className="inline-flex items-center gap-2 text-sm text-fg-secondary">
              <Checkbox checked="indeterminate" />
              Partial selection
            </label>
            <label className="inline-flex items-center gap-2 text-sm text-fg-muted">
              <Checkbox disabled />
              Disabled
            </label>
          </Row>
          <Row label="Radio group">
            <RadioGroup defaultValue="monthly" className="flex gap-5">
              <label className="inline-flex items-center gap-2 text-sm text-fg-secondary">
                <RadioGroupItem value="monthly" id="monthly" /> Monthly
              </label>
              <label className="inline-flex items-center gap-2 text-sm text-fg-secondary">
                <RadioGroupItem value="annual" id="annual" /> Annual
              </label>
              <label className="inline-flex items-center gap-2 text-sm text-fg-muted">
                <RadioGroupItem value="never" id="never" disabled /> Never
              </label>
            </RadioGroup>
          </Row>
          <Row label="Switch">
            <label className="inline-flex items-center gap-3 text-sm text-fg-secondary">
              <Switch checked={switched} onCheckedChange={setSwitched} />
              Notifications
            </label>
            <label className="inline-flex items-center gap-3 text-sm text-fg-muted">
              <Switch disabled /> Disabled
            </label>
          </Row>
        </Section>

        {/* BADGES */}
        <Section id="badges" eyebrow="06 — Components" title="Badges &amp; tags">
          <Row label="Badges">
            <Badge variant="green" dot>
              Active
            </Badge>
            <Badge variant="amber" dot>
              Pending
            </Badge>
            <Badge variant="red" dot>
              Failed
            </Badge>
            <Badge variant="blue" dot>
              Info
            </Badge>
            <Badge variant="grey" dot>
              Neutral
            </Badge>
            <Badge variant="dark" dot>
              Dark
            </Badge>
          </Row>
          <Row label="Tags">
            <Tag variant="grey">v1.0.0</Tag>
            <Tag variant="blue">beta</Tag>
            <Tag variant="dark">internal</Tag>
          </Row>
        </Section>

        {/* CARDS */}
        <Section id="cards" eyebrow="07 — Components" title="Cards">
          <div className="grid gap-5 md:grid-cols-2">
            <Card>
              <CardHeader>
                <div>
                  <CardTitle>Today's production</CardTitle>
                  <CardSubtitle>Line 3 · updated 3 min ago</CardSubtitle>
                </div>
                <Badge variant="green" dot>
                  Live
                </Badge>
              </CardHeader>
              <CardBody>
                <Progress value={64} />
                <p className="mt-3 text-xs text-fg-muted font-mono">
                  4,820 units · 8% above yesterday
                </p>
              </CardBody>
              <CardFooter>
                <span className="text-xs text-fg-muted">Updated automatically</span>
                <Button variant="secondary" size="sm">
                  View
                </Button>
              </CardFooter>
            </Card>

            <Card>
              <CardHeader>
                <CardTitle>Pending approvals</CardTitle>
              </CardHeader>
              <CardBody>
                <div className="space-y-2 text-sm text-fg-secondary">
                  <div className="flex justify-between">
                    <span>RFQ-0042</span>
                    <span className="font-mono text-fg-primary">₹1,24,000</span>
                  </div>
                  <div className="flex justify-between">
                    <span>RFQ-0043</span>
                    <span className="font-mono text-fg-primary">₹68,500</span>
                  </div>
                  <div className="flex justify-between">
                    <span>RFQ-0044</span>
                    <span className="font-mono text-fg-primary">₹2,10,000</span>
                  </div>
                </div>
              </CardBody>
            </Card>
          </div>
        </Section>

        {/* STAT CARDS */}
        <Section id="stats" eyebrow="08 — Components" title="Stat cards">
          <div className="grid gap-4 md:grid-cols-3">
            <StatCard
              label="Output"
              value="4,820"
              delta={{ value: "+8%", direction: "up" }}
            />
            <StatCard
              label="RFQ value"
              value="₹1,24,000"
              mono
              delta={{ value: "-2%", direction: "down" }}
            />
            <StatCard
              label="Attendance"
              value="96%"
              delta={{ value: "Steady", direction: "flat" }}
            />
          </div>
        </Section>

        {/* ALERTS */}
        <Section id="alerts" eyebrow="09 — Components" title="Alerts">
          <div className="grid max-w-xl gap-2">
            <Alert variant="blue" title="Heads up">
              A new RFQ is available for review.
            </Alert>
            <Alert variant="green" title="Approved">
              Order passed QC. Ready for dispatch.
            </Alert>
            <Alert variant="amber" title="Delayed">
              Shipment running 2 hours behind schedule.
            </Alert>
            <Alert variant="red" title="Failed">
              Line 4 halted — check sensor 2.
            </Alert>
          </div>
        </Section>

        {/* PROGRESS */}
        <Section id="progress" eyebrow="10 — Components" title="Progress">
          <div className="max-w-md space-y-4">
            <div>
              <div className="mb-1.5 flex justify-between text-xs">
                <span className="text-fg-secondary font-medium">Line 1</span>
                <span className="text-fg-muted font-mono">64%</span>
              </div>
              <Progress value={64} />
            </div>
            <div>
              <div className="mb-1.5 flex justify-between text-xs">
                <span className="text-fg-secondary font-medium">Line 2 · warning</span>
                <span className="text-fg-muted font-mono">42%</span>
              </div>
              <Progress value={42} color="warning" />
            </div>
            <div>
              <div className="mb-1.5 flex justify-between text-xs">
                <span className="text-fg-secondary font-medium">Line 3 · danger</span>
                <span className="text-fg-muted font-mono">22%</span>
              </div>
              <Progress value={22} color="danger" />
            </div>
          </div>
        </Section>

        {/* AVATARS */}
        <Section id="avatars" eyebrow="11 — Components" title="Avatars">
          <Row label="Sizes">
            <Avatar size="xs" fallback="PS" />
            <Avatar size="sm" fallback="PS" />
            <Avatar size="md" fallback="PS" />
            <Avatar size="lg" fallback="PS" />
            <Avatar size="xl" fallback="PS" />
          </Row>
          <Row label="Tones">
            <Avatar tone="ink" fallback="IK" />
            <Avatar tone="dark" fallback="DK" />
            <Avatar tone="green" fallback="GR" />
            <Avatar tone="amber" fallback="AM" />
          </Row>
          <Row label="Stack">
            <AvatarStack>
              <Avatar size="sm" fallback="PS" />
              <Avatar size="sm" tone="dark" fallback="RK" />
              <Avatar size="sm" tone="green" fallback="MN" />
              <Avatar size="sm" tone="amber" fallback="AA" />
            </AvatarStack>
          </Row>
        </Section>

        {/* TABS */}
        <Section id="tabs" eyebrow="12 — Components" title="Tabs">
          <div className="mb-6">
            <Tabs defaultValue="overview" variant="underline">
              <TabsList>
                <TabsTrigger value="overview">
                  Overview <TabCount>12</TabCount>
                </TabsTrigger>
                <TabsTrigger value="orders">Orders</TabsTrigger>
                <TabsTrigger value="team">Team</TabsTrigger>
              </TabsList>
              <TabsContent value="overview">
                <p className="text-sm text-fg-muted">Overview panel.</p>
              </TabsContent>
              <TabsContent value="orders">
                <p className="text-sm text-fg-muted">Orders panel.</p>
              </TabsContent>
              <TabsContent value="team">
                <p className="text-sm text-fg-muted">Team panel.</p>
              </TabsContent>
            </Tabs>
          </div>
          <div>
            <Tabs defaultValue="day" variant="pill">
              <TabsList>
                <TabsTrigger value="day">Day</TabsTrigger>
                <TabsTrigger value="week">Week</TabsTrigger>
                <TabsTrigger value="month">Month</TabsTrigger>
              </TabsList>
            </Tabs>
          </div>
        </Section>

        {/* BREADCRUMB */}
        <Section id="breadcrumb" eyebrow="13 — Components" title="Breadcrumb">
          <Breadcrumb
            items={[
              { label: "Operations", href: "#" },
              { label: "RFQs", href: "#" },
              { label: "RFQ-0042" },
            ]}
          />
        </Section>

        {/* DROPDOWN MENU */}
        <Section id="menu" eyebrow="14 — Components" title="Dropdown menu">
          <DropdownMenu>
            <DropdownMenuTrigger asChild>
              <Button variant="secondary" trailingIcon={<ChevronDown className="h-4 w-4" />}>
                Actions
              </Button>
            </DropdownMenuTrigger>
            <DropdownMenuContent>
              <DropdownMenuLabel>Workspace</DropdownMenuLabel>
              <DropdownMenuItem>
                <Settings className="h-4 w-4" /> Settings
              </DropdownMenuItem>
              <DropdownMenuItem>
                <Plus className="h-4 w-4" /> New RFQ
              </DropdownMenuItem>
              <DropdownMenuSeparator />
              <DropdownMenuItem destructive>
                <LogOut className="h-4 w-4" /> Sign out
              </DropdownMenuItem>
            </DropdownMenuContent>
          </DropdownMenu>
        </Section>

        {/* DIALOG */}
        <Section id="dialog" eyebrow="15 — Components" title="Dialog">
          <Dialog>
            <DialogTrigger asChild>
              <Button>Invite teammate</Button>
            </DialogTrigger>
            <DialogContent>
              <DialogHeader>
                <DialogTitle>Invite a teammate</DialogTitle>
                <DialogDescription>
                  They'll get access to this workspace.
                </DialogDescription>
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
        </Section>

        {/* TOOLTIP */}
        <Section id="tooltip" eyebrow="16 — Components" title="Tooltip">
          <TooltipProvider>
            <Tooltip>
              <TooltipTrigger asChild>
                <Button variant="secondary">
                  <InfoIcon className="h-4 w-4" />
                  Hover me
                </Button>
              </TooltipTrigger>
              <TooltipContent>This is a tooltip.</TooltipContent>
            </Tooltip>
          </TooltipProvider>
        </Section>

        {/* TABLE */}
        <Section id="table" eyebrow="17 — Components" title="Table">
          <Table>
            <Thead>
              <Tr>
                <Th>RFQ</Th>
                <Th>Buyer</Th>
                <Th>Value</Th>
                <Th>Status</Th>
              </Tr>
            </Thead>
            <Tbody>
              <Tr>
                <Td>
                  <TdMono>RFQ-0042</TdMono>
                </Td>
                <Td>
                  <TdStrong>Pacific Pack Co.</TdStrong>
                </Td>
                <Td>
                  <TdMono>₹1,24,000</TdMono>
                </Td>
                <Td>
                  <Badge variant="green" dot>
                    Approved
                  </Badge>
                </Td>
              </Tr>
              <Tr>
                <Td>
                  <TdMono>RFQ-0043</TdMono>
                </Td>
                <Td>
                  <TdStrong>Coastal Foods</TdStrong>
                </Td>
                <Td>
                  <TdMono>₹68,500</TdMono>
                </Td>
                <Td>
                  <Badge variant="amber" dot>
                    Pending
                  </Badge>
                </Td>
              </Tr>
              <Tr>
                <Td>
                  <TdMono>RFQ-0044</TdMono>
                </Td>
                <Td>
                  <TdStrong>Meridian Logistics</TdStrong>
                </Td>
                <Td>
                  <TdMono>₹2,10,000</TdMono>
                </Td>
                <Td>
                  <Badge variant="red" dot>
                    Rejected
                  </Badge>
                </Td>
              </Tr>
            </Tbody>
          </Table>
        </Section>

        {/* EMPTY STATE */}
        <Section id="empty" eyebrow="18 — Components" title="Empty state">
          <EmptyState
            icon={<Inbox className="h-5 w-5" />}
            title="No RFQs yet"
            description="When buyers submit requests, they'll show up here. Invite your team to get started."
            action={<Button size="sm">Invite team</Button>}
          />
        </Section>

        {/* DOT MATRIX */}
        <Section
          id="dot-matrix"
          eyebrow="19 — Motion / Brand"
          title="Dot matrix"
          description="Hexagonal halftone matrix. Radial ripple by default; pulse variant fires all rings in phase."
        >
          <div className="flex flex-wrap gap-6">
            <div className="rounded-3xl overflow-hidden shadow-lg">
              <DotMatrix size={480} rings={5} variant="ripple" />
            </div>
            <div className="rounded-3xl overflow-hidden shadow-lg">
              <DotMatrix size={240} rings={4} variant="pulse" speed={1600} />
            </div>
          </div>
        </Section>

        {/* TOP NAV */}
        <Section id="nav" eyebrow="20 — Components" title="TopNav">
          <TopNav>
            <TopNavBrand mark="A" name="Aeros" />
            <TopNavLinks>
              <TopNavLink active>Dashboard</TopNavLink>
              <TopNavLink>Marketplace</TopNavLink>
              <TopNavLink>Operations</TopNavLink>
              <TopNavLink>AI</TopNavLink>
            </TopNavLinks>
            <TopNavRight>
              <Avatar size="sm" tone="dark" fallback="PS" />
            </TopNavRight>
          </TopNav>
        </Section>

        <div className="mt-24 pt-8 border-t border-border-default">
          <p className="text-xs text-fg-muted font-mono">
            @aeros/react · Made for operators.
          </p>
        </div>
      </main>
    </div>
  );
}
