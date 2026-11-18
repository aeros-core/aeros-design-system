import 'package:aeros_design_system/aeros_design_system.dart';
import 'package:flutter/material.dart';

import '../widgets/gallery_page.dart';

class FoundationsPage extends StatelessWidget {
  const FoundationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const GalleryPage(
      title: 'Tokens & primitives',
      summary: 'Everything a widget is made of. Read these through the theme, never as literals.',
      children: [
        Section(
          'Alias colours',
          note: 'context.aerosColors — the colours widgets use. They change with the theme.',
          child: _AliasSwatches(),
        ),
        Section(
          'Status colours',
          note: 'context.aerosSemantic — the only colour in the system, reserved for state.',
          child: _StatusSwatches(),
        ),
        Section('Ink ramp', note: 'AerosColors.ink* — the one neutral ramp behind the aliases.', child: _InkRamp()),
        Section('Type scale', note: 'AerosTypography — Inter for UI, IBM Plex Mono for data.', child: _TypeScale()),
        Section(
          'Elevation',
          note: 'AerosSurface levels. Resting surfaces are flat; only floating layers take a shadow.',
          child: _Elevation(),
        ),
        Section('Radii', note: 'AerosShapeTokens — a radius per role, not per size.', child: _Radii()),
        Section('Spacing', note: 'AerosSpacing — a 4-based scale.', child: _Spacing()),
        Section(
          'Control sizes',
          note: 'AerosControlSize — one ladder for buttons and fields, by density.',
          child: _ControlSizes(),
        ),
        Section(
          'Interaction primitives',
          note: 'AerosPressable reports the state; AerosStateFill and AerosFocusRing draw it. '
              'AerosFieldFrame is the field look for a composite input.',
          child: _Primitives(),
        ),
      ],
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch(this.name, this.color);

  final String name;
  final Color color;

  static String hex(Color c) => '#${c.toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';

  @override
  Widget build(BuildContext context) {
    final a = context.aerosColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // The sample sits on a hairline surface so a colour close to the
        // page still has an edge.
        AerosSurface(
          color: color,
          borderColor: a.borderStrong,
          child: const SizedBox(height: AerosSpacing.s12, width: double.infinity),
        ),
        const SizedBox(height: AerosSpacing.s1_5),
        Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: AerosTypography.labelSm(color: a.fgPrimary)),
        Text(hex(color), style: AerosTypography.monoXs(color: a.fgMuted)),
      ],
    );
  }
}

class _SwatchGrid extends StatelessWidget {
  const _SwatchGrid(this.swatches);

  final Map<String, Color> swatches;

  @override
  Widget build(BuildContext context) => AerosResponsiveGrid.auto(
        tileMinWidth: 132,
        children: [for (final entry in swatches.entries) _Swatch(entry.key, entry.value)],
      );
}

class _AliasSwatches extends StatelessWidget {
  const _AliasSwatches();

  @override
  Widget build(BuildContext context) {
    final a = context.aerosColors;
    return _SwatchGrid({
      'bgCanvas': a.bgCanvas,
      'bgSurface': a.bgSurface,
      'bgElevated': a.bgElevated,
      'bgSubtle': a.bgSubtle,
      'bgInset': a.bgInset,
      'bgInverse': a.bgInverse,
      'fgPrimary': a.fgPrimary,
      'fgSecondary': a.fgSecondary,
      'fgMuted': a.fgMuted,
      'fgDisabled': a.fgDisabled,
      'fgInverse': a.fgInverse,
      'borderSubtle': a.borderSubtle,
      'borderDefault': a.borderDefault,
      'borderStrong': a.borderStrong,
      'brandPrimary': a.brandPrimary,
      'brandPrimaryHover': a.brandPrimaryHover,
      'brandPrimaryMuted': a.brandPrimaryMuted,
      'focusRing': a.focusRing,
    });
  }
}

class _StatusSwatches extends StatelessWidget {
  const _StatusSwatches();

  @override
  Widget build(BuildContext context) {
    final s = context.aerosSemantic;
    return _SwatchGrid({
      'success': s.success,
      'successBg': s.successBg,
      'successText': s.successText,
      'successBorder': s.successBorder,
      'warning': s.warning,
      'warningBg': s.warningBg,
      'warningText': s.warningText,
      'warningBorder': s.warningBorder,
      'danger': s.danger,
      'dangerBg': s.dangerBg,
      'dangerText': s.dangerText,
      'dangerBorder': s.dangerBorder,
      'info': s.info,
      'infoBg': s.infoBg,
      'infoText': s.infoText,
      'infoBorder': s.infoBorder,
    });
  }
}

class _InkRamp extends StatelessWidget {
  const _InkRamp();

  @override
  Widget build(BuildContext context) => const _SwatchGrid({
        'ink0': AerosColors.ink0,
        'ink50': AerosColors.ink50,
        'ink100': AerosColors.ink100,
        'ink200': AerosColors.ink200,
        'ink300': AerosColors.ink300,
        'ink400': AerosColors.ink400,
        'ink500': AerosColors.ink500,
        'ink600': AerosColors.ink600,
        'ink700': AerosColors.ink700,
        'ink800': AerosColors.ink800,
        'ink850': AerosColors.ink850,
        'ink900': AerosColors.ink900,
        'ink950': AerosColors.ink950,
      });
}

class _TypeScale extends StatelessWidget {
  const _TypeScale();

  @override
  Widget build(BuildContext context) {
    final a = context.aerosColors;
    final roles = <String, TextStyle>{
      'displayMd': AerosTypography.displayMd(),
      'h1': AerosTypography.h1(),
      'h2': AerosTypography.h2(),
      'h3': AerosTypography.h3(),
      'h4': AerosTypography.h4(),
      'bodyLg': AerosTypography.bodyLg(),
      'bodyMd': AerosTypography.bodyMd(),
      'bodySm': AerosTypography.bodySm(),
      'labelMd': AerosTypography.labelMd(),
      'labelSm': AerosTypography.labelSm(),
      'labelXs': AerosTypography.labelXs(),
      'caption': AerosTypography.caption(),
      'overline': AerosTypography.overline(),
      'monoLg': AerosTypography.monoLg(),
      'monoMd': AerosTypography.monoMd(),
      'monoSm': AerosTypography.monoSm(),
    };
    return AerosCard(
      padding: const EdgeInsets.symmetric(horizontal: AerosSpacing.s4, vertical: AerosSpacing.s2),
      child: Column(
        children: [
          for (final role in roles.entries)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AerosSpacing.s2),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: AerosSpacing.s24,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(role.key, style: AerosTypography.labelSm(color: a.fgPrimary)),
                        Text(
                          '${role.value.fontSize!.round()} · w${role.value.fontWeight!.value}',
                          style: AerosTypography.monoXs(color: a.fgMuted),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Text(
                      role.key.startsWith('mono') ? '₹ 48,200.00  #4821' : 'Run everything.',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: role.value.copyWith(color: a.fgPrimary),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _Elevation extends StatelessWidget {
  const _Elevation();

  @override
  Widget build(BuildContext context) {
    final a = context.aerosColors;
    return AerosResponsiveGrid.auto(
      tileMinWidth: 180,
      mainAxisSpacing: AerosSpacing.s6,
      crossAxisSpacing: AerosSpacing.s6,
      children: [
        for (final level in AerosSurfaceLevel.values)
          AerosSurface(
            level: level,
            padding: const EdgeInsets.all(AerosSpacing.s4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(level.name, style: AerosTypography.labelMd(color: a.fgPrimary)),
                const SizedBox(height: AerosSpacing.s1),
                Text(
                  switch (level) {
                    AerosSurfaceLevel.flat => 'Cards, panels, tables',
                    AerosSurfaceLevel.raised => 'The active segment',
                    AerosSurfaceLevel.overlay => 'Menus, popovers, toasts',
                    AerosSurfaceLevel.modal => 'Dialogs, sheets',
                  },
                  style: AerosTypography.caption(color: a.fgMuted),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _Radii extends StatelessWidget {
  const _Radii();

  static const _roles = <String, double>{
    'item · 4': AerosShapeTokens.item,
    'control · 6': AerosShapeTokens.control,
    'surface · 8': AerosShapeTokens.surface,
    'modal · 12': AerosShapeTokens.modal,
    'pill': AerosShapeTokens.pill,
  };

  @override
  Widget build(BuildContext context) => Examples(
        spacing: AerosSpacing.s5,
        children: [
          for (final role in _roles.entries)
            Captioned(
              role.key,
              child: AerosSurface(
                radius: BorderRadius.all(Radius.circular(role.value)),
                borderColor: context.aerosColors.borderStrong,
                child: const SizedBox(width: AerosSpacing.s20, height: AerosSpacing.s12),
              ),
            ),
        ],
      );
}

class _Spacing extends StatelessWidget {
  const _Spacing();

  static const _steps = <String, double>{
    's1': AerosSpacing.s1,
    's2': AerosSpacing.s2,
    's3': AerosSpacing.s3,
    's4': AerosSpacing.s4,
    's5': AerosSpacing.s5,
    's6': AerosSpacing.s6,
    's8': AerosSpacing.s8,
    's10': AerosSpacing.s10,
    's12': AerosSpacing.s12,
    's16': AerosSpacing.s16,
  };

  @override
  Widget build(BuildContext context) {
    final a = context.aerosColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final step in _steps.entries)
          Padding(
            padding: const EdgeInsets.only(bottom: AerosSpacing.s1_5),
            child: Row(
              children: [
                SizedBox(
                  width: AerosSpacing.s16,
                  child: Text('${step.key} · ${step.value.round()}', style: AerosTypography.monoSm(color: a.fgMuted)),
                ),
                AerosSurface(
                  color: a.brandPrimary,
                  borderColor: a.brandPrimary,
                  radius: AerosRadii.brXs,
                  child: SizedBox(width: step.value, height: AerosSpacing.s3),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _ControlSizes extends StatelessWidget {
  const _ControlSizes();

  @override
  Widget build(BuildContext context) {
    final a = context.aerosColors;
    return AerosResponsiveGrid.auto(
      tileMinWidth: 320,
      children: [
        // Each card pins a density with its own scope, whatever the top bar says.
        for (final density in AerosDensity.values)
          AerosDensityScope(
            density: density,
            child: AerosCard(
              title: density.isPointer ? 'Pointer' : 'Touch',
              subtitle: density.isPointer ? 'Mouse and trackpad' : 'Fingers',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final size in AerosControlSize.values)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AerosSpacing.s2),
                      child: Row(
                        children: [
                          SizedBox(
                            width: AerosSpacing.s16,
                            child: Text(
                              '${size.name} · ${size.heightFor(density).round()}',
                              style: AerosTypography.monoSm(color: a.fgMuted),
                            ),
                          ),
                          AerosButton.secondary(label: 'Button', size: size, onPressed: () {}),
                          const SizedBox(width: AerosSpacing.s2),
                          Expanded(child: AerosTextField(hint: 'Field', size: size)),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _Primitives extends StatefulWidget {
  const _Primitives();

  @override
  State<_Primitives> createState() => _PrimitivesState();
}

class _PrimitivesState extends State<_Primitives> {
  int _presses = 0;
  int _quantity = 2;

  @override
  Widget build(BuildContext context) {
    final a = context.aerosColors;
    return Examples(
      spacing: AerosSpacing.s6,
      children: [
        Captioned(
          'A control of your own · pressed $_presses×',
          // AerosPressable gives the state; the builder draws it.
          child: AerosPressable(
            onPressed: () => setState(() => _presses++),
            semanticLabel: 'Custom control',
            builder: (context, state) => AerosFocusRing(
              focused: state.focused,
              child: AerosStateFill(
                color: AerosStateLayer.resolve(a, a.bgSurface, hovered: state.hovered, pressed: state.pressed),
                borderColor: a.borderStrong,
                padding: const EdgeInsets.symmetric(horizontal: AerosSpacing.s3, vertical: AerosSpacing.s2),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.bolt, size: AerosSizeTokens.iconMd, color: a.fgPrimary),
                    const SizedBox(width: AerosSpacing.s2),
                    Text(
                      state.pressed
                          ? 'Pressed'
                          : state.hovered
                              ? 'Hovered'
                              : 'Hover, press or Tab to me',
                      style: AerosTypography.labelSm(color: a.fgPrimary),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Captioned(
          'AerosHoverable — a row that tints under the pointer',
          child: AerosHoverable(
            builder: (context, hovered) => AerosStateFill(
              color: AerosStateLayer.resolve(a, a.bgSurface, hovered: hovered),
              borderColor: a.borderDefault,
              padding: const EdgeInsets.symmetric(horizontal: AerosSpacing.s3, vertical: AerosSpacing.s2),
              child: Text('Not a control: hover only', style: AerosTypography.bodySm(color: a.fgSecondary)),
            ),
          ),
        ),
        Captioned(
          'AerosFieldFrame — a stepper that matches the fields',
          child: SizedBox(
            width: AerosSpacing.s32,
            child: AerosFieldFrame(
              padding: const EdgeInsets.symmetric(horizontal: AerosSpacing.s1),
              // The scope makes both icon buttons small without saying so twice.
              child: AerosControlSizeScope(
                size: AerosControlSize.xs,
                child: Row(
                  children: [
                    AerosButton.icon(
                      icon: const Icon(Icons.remove),
                      semanticLabel: 'Fewer',
                      onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null,
                    ),
                    Expanded(
                      child: Text(
                        '$_quantity',
                        textAlign: TextAlign.center,
                        style: AerosTypography.monoMd(color: a.fgPrimary),
                      ),
                    ),
                    AerosButton.icon(
                      icon: const Icon(Icons.add),
                      semanticLabel: 'More',
                      onPressed: () => setState(() => _quantity++),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
