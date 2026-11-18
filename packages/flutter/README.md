# aeros_design_system

The Aeros design system for Flutter: tokens, theme and widgets. No runtime dependencies besides Flutter. Inter, IBM Plex Mono and the wordmark face are bundled.

## Install

The package is not on pub.dev. Pin it by git tag:

```yaml
dependencies:
  aeros_design_system:
    git:
      url: https://github.com/aeros-core/aeros-design-system.git
      path: packages/flutter
      ref: v3.0.0
```

Inside this repository the example app uses a path dependency (`path: ../`).

## Theme

```dart
import 'package:flutter/material.dart';
import 'package:aeros_design_system/aeros_design_system.dart';

void main() => runApp(MaterialApp(
      theme: AerosTheme.light(),
      darkTheme: AerosTheme.dark(),
      themeMode: ThemeMode.system,
      home: const HomeScreen(),
    ));
```

Read theme values from the context:

```dart
final colors = context.aerosColors;      // bgSurface, fgPrimary, borderDefault …
final status = context.aerosSemantic;    // dangerText, successBg …
final elevation = context.aerosElevation; // raised, overlay, modal
```

```dart
Text('Order 1042', style: AerosTypography.h3(color: colors.fgPrimary));
Text('₹1,24,000', style: AerosTypography.monoMd());
Text('Due today', style: AerosTypography.bodySm(weight: FontWeight.w600));
```

Set a weight with `weight:` or `withWeight`. `copyWith(fontWeight:)` does not move Inter's weight axis.

## Density

With no scope, everything is touch density. Wrap desktop and web surfaces in a pointer scope:

```dart
AerosDensityScope(
  density: AerosDensity.pointer,
  child: child,
)
```

Controls are 24 / 28 / 32 / 36 / 40 high at pointer and 32 / 36 / 40 / 44 / 48 at touch. A control's tappable box is at least 24 at pointer and 48 at touch. `AerosDensity.of(context).sizes` gives the size tokens for the ambient density.

## Widgets

```dart
AerosButton.primary(label: 'Create RFQ', onPressed: () {})
// Every variant has a named constructor with the same options as the default one.
AerosButton.secondary(label: 'Export', trailing: const Icon(Icons.expand_more), onPressed: () {})
AerosButton.icon(icon: const Icon(Icons.edit), semanticLabel: 'Edit', onPressed: () {})

AerosCard(
  title: "Today's production",
  subtitle: 'Line 3',
  child: AerosProgress(label: 'Output', value: 0.64),
)

AerosBadge(label: 'Active', tone: AerosBadgeTone.success)

final ok = await AerosConfirmDialog.show(
  context,
  title: 'Delete order?',
  body: 'This cannot be undone.',
  destructive: true,
);
```

The app shell is `AerosScaffold` with an `AerosTopnav` and an `AerosSidenav`. The sidenav is inline from the `md` breakpoint and in a drawer below it; the top bar shows the menu button itself, and anything below the scaffold reaches it with `AerosScaffold.of(context)` (`isSidenavInline`, `isDrawerOpen`, `openDrawer()`, `closeDrawer()`), the widget that builds it with a `GlobalKey<AerosScaffoldState>`:

```dart
final shell = GlobalKey<AerosScaffoldState>();

AerosScaffold(
  key: shell,
  topnav: const AerosTopnav(title: 'Orders'),
  sidenav: AerosSidenav(
    header: const AerosSidenavHeader.custom(child: AerosWordmark(size: 20)),
    items: [
      AerosNavItem(label: 'Orders', icon: Icons.receipt_long_outlined, onTap: () {
        // …navigate, then:
        shell.currentState?.closeDrawer(); // a no-op while the sidenav is inline
      }),
    ],
  ),
  body: const AerosPageHeader(title: 'Orders'), // moves its actions under the title when they do not fit
)
```

Fields share one vocabulary — `label`, `helperText`, `errorText`, `required` — on `AerosTextField`, `AerosSelect`, `AerosDropdownSearch` and the rest.

Use the package's overlays, not Material's: `AerosDialog`, `AerosSheet`, `AerosMenu`, `AerosPopover`, `AerosSelect`, `AerosSnackbar`.

The full inventory is in [docs/components.md](../../docs/components.md). Upgrading from 2.x: [docs/migration.md](../../docs/migration.md#4-flutter). Changes by version: [CHANGELOG.md](./CHANGELOG.md).

## Example

```bash
cd example
flutter pub get
flutter run
```

## Contributing

**Widgets are built on the foundation layer; they do not restate it.** [`lib/src/foundation/`](./lib/src/foundation) holds the primitives every widget uses:

| Primitive | Use it for |
|---|---|
| `AerosPressable` | Every tappable thing: hover, press, keyboard focus, Enter / Space, semantics, minimum hit target |
| `AerosStateLayer`, `AerosStateFill` | Hover, pressed and selected colours |
| `AerosFocusRing` | The focus ring |
| `AerosSurface` | Every surface. The only place a `BoxShadow` is attached |
| `AerosControlSize` | Heights, padding and type for buttons and fields |
| `AerosFieldFrame` | Anything that should look like a text field |

Rules:

- No `InkWell`, and no Material `showDialog`, `showModalBottomSheet`, `showMenu`, `PopupMenuItem`, `DropdownButton` or `DataTable` in `lib`.
- No `BoxShadow` outside `AerosSurface`. No literal radius: use `AerosShapeTokens`.
- No literal colours. Read `context.aerosColors` and `context.aerosSemantic`, so dark mode is correct.
- Sizes come from `AerosDensity.of(context).sizes`.
- Hover and press change colour only. Durations go through `AerosMotion.resolve(context, …)` so reduced motion is honoured.
- Do not edit `lib/src/tokens/*.g.dart`. They are generated from `packages/tokens/src/tokens.json` by `pnpm build:tokens`; CI fails if they are stale. The hand-written token files alias them.
- A new public widget needs: an export in `lib/aeros_design_system.dart`, a test, a golden scene, a row in `docs/components.md`, and a `CHANGELOG.md` entry.

## Test

```bash
dart analyze lib test
flutter test --exclude-tags golden   # behaviour tests
flutter test --tags golden           # golden images
```

### Goldens

`test/golden/` renders each scene four times — light and dark, pointer and touch — with the real bundled fonts and real shadows (`goldenMatrix` in `test/golden/harness.dart`).

- Baselines live in `test/golden/goldens/linux`. Linux is the canonical platform; CI compares against that folder.
- Do not generate baselines on a developer machine. After an intended visual change, the `flutter-goldens` CI job fails and uploads regenerated images as the `flutter-goldens-linux` artifact. Download it with `gh run download <run-id> -n flutter-goldens-linux` and commit the images into `test/golden/goldens/linux`. The steps are in [docs/releasing.md](../../docs/releasing.md#image-baselines).
- A local run on macOS is useful for seeing that a scene renders, not for comparing.
- `GOLDEN_MEASURE=1 flutter test --tags golden` prints the size each scene needs, without comparing or writing images.
- Flutter is pinned in `.github/workflows/ci.yml`. Bump it deliberately and regenerate the baselines in the same pull request.

## Release

Set `version:` in `pubspec.yaml`, date the changelog entry, merge, then tag `v<version>`. See [docs/releasing.md](../../docs/releasing.md#releasing-the-flutter-package).
