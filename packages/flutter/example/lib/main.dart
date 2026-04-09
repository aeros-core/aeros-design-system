import 'package:flutter/material.dart';
import 'package:aeros_design_system/aeros_design_system.dart';

void main() => runApp(const ExampleApp());

class ExampleApp extends StatefulWidget {
  const ExampleApp({super.key});
  @override
  State<ExampleApp> createState() => _ExampleAppState();
}

class _ExampleAppState extends State<ExampleApp> {
  ThemeMode _mode = ThemeMode.light;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aeros DS',
      debugShowCheckedModeBanner: false,
      themeMode: _mode,
      theme: AerosTheme.light(),
      darkTheme: AerosTheme.dark(),
      home: Gallery(onToggleTheme: () {
        setState(() => _mode = _mode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light);
      }),
    );
  }
}

class Gallery extends StatefulWidget {
  const Gallery({super.key, required this.onToggleTheme});
  final VoidCallback onToggleTheme;

  @override
  State<Gallery> createState() => _GalleryState();
}

class _GalleryState extends State<Gallery> {
  int _tab = 0;
  bool _check = true;
  bool _switch = true;
  String _radio = 'a';
  double _progress = 0.64;

  @override
  Widget build(BuildContext context) {
    final a = context.aerosColors;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aeros UI Kit'),
        actions: [
          IconButton(icon: const Icon(Icons.brightness_6_outlined), onPressed: widget.onToggleTheme),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero
            Text('Run everything.', style: Theme.of(context).textTheme.displayMedium),
            const SizedBox(height: 8),
            Text(
              'Complete component library for the Aeros platform.',
              style: AerosTypography.bodyMd(color: a.fgMuted),
            ),
            const SizedBox(height: 32),

            _section('Buttons'),
            Wrap(spacing: 10, runSpacing: 10, children: [
              AerosButton.primary(label: 'Primary', onPressed: () {}),
              AerosButton.secondary(label: 'Secondary', onPressed: () {}),
              AerosButton.ghost(label: 'Ghost', onPressed: () {}),
              AerosButton.danger(label: 'Danger', onPressed: () {}),
              const AerosButton(label: 'Loading', onPressed: null, loading: true),
            ]),
            const SizedBox(height: 32),

            _section('Badges & tags'),
            Wrap(spacing: 8, runSpacing: 8, children: const [
              AerosBadge(label: 'Active', tone: AerosBadgeTone.green),
              AerosBadge(label: 'Pending', tone: AerosBadgeTone.amber),
              AerosBadge(label: 'Failed', tone: AerosBadgeTone.red),
              AerosBadge(label: 'New', tone: AerosBadgeTone.blue),
              AerosTag(label: 'RFQ-0042', tone: AerosTagTone.blue),
              AerosTag(label: 'v1.0', tone: AerosTagTone.grey),
            ]),
            const SizedBox(height: 32),

            _section('Stat cards'),
            Row(children: const [
              Expanded(child: AerosStatCard(label: 'Output', value: '4,820', delta: '+8%', deltaDirection: AerosDelta.up)),
              SizedBox(width: 12),
              Expanded(child: AerosStatCard(label: 'RFQ value', value: '₹1,24,000', mono: true, delta: '-2%', deltaDirection: AerosDelta.down)),
              SizedBox(width: 12),
              Expanded(child: AerosStatCard(label: 'Attendance', value: '96%', delta: 'Steady', deltaDirection: AerosDelta.flat)),
            ]),
            const SizedBox(height: 32),

            _section('Card'),
            AerosCard(
              title: "Today's production",
              subtitle: 'Line 3 · updated 3 min ago',
              trailing: const AerosBadge(label: 'Live', tone: AerosBadgeTone.green),
              footer: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('8% above yesterday', style: AerosTypography.caption(color: a.fgMuted)),
                  AerosButton(label: 'View', onPressed: () {}, size: AerosButtonSize.sm, variant: AerosButtonVariant.secondary),
                ],
              ),
              child: AerosProgress(label: 'Output', value: _progress),
            ),
            const SizedBox(height: 32),

            _section('Alerts'),
            Column(children: const [
              AerosAlert(tone: AerosAlertTone.blue, title: 'Heads up', body: 'New RFQ available for review.'),
              SizedBox(height: 8),
              AerosAlert(tone: AerosAlertTone.green, title: 'Approved', body: 'Order passed QC checks.'),
              SizedBox(height: 8),
              AerosAlert(tone: AerosAlertTone.amber, title: 'Delayed', body: 'Shipment running 2 hours behind.'),
              SizedBox(height: 8),
              AerosAlert(tone: AerosAlertTone.red, title: 'Failed', body: 'Line 4 halted — check sensor 2.'),
            ]),
            const SizedBox(height: 32),

            _section('Form'),
            AerosCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AerosTextField(label: 'Buyer name', hint: 'Pacific Pack Co.', required: true),
                  const SizedBox(height: 16),
                  const AerosTextField(label: 'Email', hint: 'priya@pacificpack.co'),
                  const SizedBox(height: 16),
                  Row(children: [
                    AerosCheckbox(value: _check, onChanged: (v) => setState(() => _check = v ?? false)),
                    const SizedBox(width: 8),
                    Text('I agree to the Terms', style: AerosTypography.bodySm(color: a.fgSecondary)),
                  ]),
                  const SizedBox(height: 8),
                  Row(children: [
                    AerosRadio<String>(value: 'a', groupValue: _radio, onChanged: (v) => setState(() => _radio = v!)),
                    const SizedBox(width: 8),
                    Text('Option A', style: AerosTypography.bodySm(color: a.fgSecondary)),
                    const SizedBox(width: 16),
                    AerosRadio<String>(value: 'b', groupValue: _radio, onChanged: (v) => setState(() => _radio = v!)),
                    const SizedBox(width: 8),
                    Text('Option B', style: AerosTypography.bodySm(color: a.fgSecondary)),
                  ]),
                  const SizedBox(height: 8),
                  Row(children: [
                    AerosSwitch(value: _switch, onChanged: (v) => setState(() => _switch = v)),
                    const SizedBox(width: 12),
                    Text('Enable notifications', style: AerosTypography.bodySm(color: a.fgSecondary)),
                  ]),
                ],
              ),
            ),
            const SizedBox(height: 32),

            _section('Tabs'),
            AerosTabs(
              tabs: const ['Overview', 'Production', 'Orders', 'Team'],
              selectedIndex: _tab,
              onChanged: (i) => setState(() => _tab = i),
            ),
            const SizedBox(height: 12),
            AerosTabs(
              tabs: const ['Day', 'Week', 'Month'],
              selectedIndex: _tab.clamp(0, 2),
              onChanged: (i) => setState(() => _tab = i),
              variant: AerosTabVariant.pill,
            ),
            const SizedBox(height: 32),

            _section('Breadcrumb'),
            AerosBreadcrumb(items: [
              AerosBreadcrumbItem('Operations', onTap: () {}),
              AerosBreadcrumbItem('RFQs', onTap: () {}),
              const AerosBreadcrumbItem('RFQ-0042'),
            ]),
            const SizedBox(height: 32),

            _section('Avatars'),
            Row(children: const [
              AerosAvatar(initials: 'PS'),
              SizedBox(width: 12),
              AerosAvatar(initials: 'RK', tone: AerosAvatarTone.green),
              SizedBox(width: 12),
              AerosAvatar(initials: 'MN', tone: AerosAvatarTone.amber, size: AerosAvatarSize.lg),
              SizedBox(width: 12),
              AerosAvatar(initials: 'AA', tone: AerosAvatarTone.dark, size: AerosAvatarSize.xl),
            ]),
            const SizedBox(height: 32),

            _section('Empty state'),
            const AerosEmptyState(
              icon: Icons.inbox_outlined,
              title: 'No RFQs yet',
              description: 'When buyers submit requests, they\'ll show up here. Invite your team to get started.',
            ),
            const SizedBox(height: 64),
          ],
        ),
      ),
    );
  }

  Widget _section(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        label.toUpperCase(),
        style: AerosTypography.overline(color: AerosColors.slate400),
      ),
    );
  }
}
