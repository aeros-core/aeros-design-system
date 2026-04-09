# aeros_design_system

Flutter implementation of the Aeros Design System — tokens, theme, and widgets.

## Install

Until this is published, add it as a path dependency:

```yaml
dependencies:
  aeros_design_system:
    path: ../aeros-design-system/packages/flutter
```

## Use the theme

```dart
import 'package:flutter/material.dart';
import 'package:aeros_design_system/aeros_design_system.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AerosTheme.light(),
      darkTheme: AerosTheme.dark(),
      themeMode: ThemeMode.system,
      home: const Scaffold(/* ... */),
    );
  }
}
```

## Use widgets

```dart
AerosButton.primary(label: 'Create RFQ', onPressed: () {})

AerosCard(
  title: "Today's production",
  subtitle: 'Line 3',
  child: AerosProgress(label: 'Output', value: 0.64),
)

AerosBadge(label: 'Active', tone: AerosBadgeTone.green)

AerosStatCard(
  label: 'RFQ value',
  value: '₹1,24,000',
  mono: true,
  delta: '+8%',
  deltaDirection: AerosDelta.up,
)
```

## Access tokens directly

Via `AerosColors`, `AerosTypography`, `AerosSpacing`, `AerosRadii`, `AerosShadows`, `AerosMotion`:

```dart
Container(
  padding: const EdgeInsets.all(AerosSpacing.s4),
  decoration: BoxDecoration(
    color: AerosColors.royal50,
    borderRadius: AerosRadii.brLg,
  ),
  child: Text('Label', style: AerosTypography.bodyMd()),
)
```

Or theme-aware via `BuildContext`:

```dart
final colors = context.aerosColors;
Container(color: colors.bgSurface, ...)
```

## Run the example

```bash
cd example
flutter pub get
flutter run
```

The example gallery shows every widget in both light and dark themes.

## Widget inventory

Button, TextField, Card, StatCard, Badge, Tag, Alert, Progress, Avatar, Tabs (underline + pill), Checkbox, Radio, Switch, EmptyState, Breadcrumb.

Not yet shipped (use Material/Cupertino counterparts): Tooltip (use `Tooltip`), Dialog (use `showDialog` — the theme styles it), Dropdown/Menu, Table.
