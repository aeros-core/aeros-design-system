import 'dart:io';

import 'package:aeros_design_system/aeros_design_system.dart';
import 'package:aeros_design_system/src/tokens/aeros_theme_tokens.g.dart' show AerosTypeScale;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

double? _wght(TextStyle style) {
  final axes = [
    for (final v in style.fontVariations ?? const <FontVariation>[])
      if (v.axis == 'wght') v.value,
  ];
  expect(axes.length, lessThanOrEqualTo(1), reason: 'the wght axis must be pinned once, not stacked');
  return axes.isEmpty ? null : axes.single;
}

double _opsz(TextStyle style) => style.fontVariations!.singleWhere((v) => v.axis == 'opsz').value;

/// The advance width of [text] laid out on one line in [style].
double _advance(String text, TextStyle style) {
  final painter = TextPainter(
    text: TextSpan(text: text, style: style),
    textDirection: TextDirection.ltr,
  )..layout();
  addTearDown(painter.dispose);
  return painter.width;
}

Future<void> _load(String family, List<String> assets) async {
  final loader = FontLoader(family);
  for (final asset in assets) {
    final bytes = await File(asset).readAsBytes();
    loader.addFont(Future.value(ByteData.view(bytes.buffer)));
  }
  await loader.load();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    // The real faces, registered the way a consuming app sees them.
    await _load('packages/aeros_design_system/Inter', ['assets/fonts/InterVariable.ttf']);
    await _load('packages/aeros_design_system/IBM Plex Mono', [
      'assets/fonts/IBMPlexMono-Regular.ttf',
      'assets/fonts/IBMPlexMono-Medium.ttf',
    ]);
  });

  group('AerosTypography', () {
    test('roles are the generated scale, with only the colour added', () {
      expect(AerosTypography.bodyMd(), AerosTypeScale.bodyMd);
      expect(AerosTypography.h1(), AerosTypeScale.h1);
      expect(AerosTypography.overline(), AerosTypeScale.overline);
      const red = Color(0xFFFF0000);
      expect(AerosTypography.bodyMd(color: red), AerosTypeScale.bodyMd.copyWith(color: red));
      expect(AerosTypography.bodyMd().color, isNull, reason: 'bare roles inherit the ambient colour');
    });

    test('body text carries the brand weight, wght 450', () {
      expect(_wght(AerosTypography.bodyLg()), 450);
      expect(_wght(AerosTypography.bodyMd()), 450);
      expect(_wght(AerosTypography.bodySm()), 450);
      expect(AerosTypography.bodyMd().fontFamily, 'packages/aeros_design_system/Inter');
    });

    test('weight: and withWeight move the wght axis and keep the optical size', () {
      final viaParam = AerosTypography.bodyMd(weight: FontWeight.w600);
      final viaExtension = AerosTypography.bodyMd().withWeight(FontWeight.w600);
      expect(viaParam, viaExtension);
      expect(viaParam.fontWeight, FontWeight.w600);
      expect(_wght(viaParam), 600);
      expect(_opsz(viaParam), _opsz(AerosTypography.bodyMd()));

      final display = AerosTypography.h1(weight: FontWeight.w500);
      expect(_wght(display), 500);
      expect(_opsz(display), 32);

      // Everything but the weight is untouched.
      expect(viaParam.copyWith(fontWeight: FontWeight.w400, fontVariations: AerosTypeScale.bodyMd.fontVariations),
          AerosTypeScale.bodyMd);
    });

    test('a heavier weight really renders wider glyphs in Inter', () {
      const sample = 'Minimum order quantity 12,500 units';
      final regular = _advance(sample, AerosTypography.bodyMd());
      final viaParam = _advance(sample, AerosTypography.bodyMd(weight: FontWeight.w600));
      final viaExtension = _advance(sample, AerosTypography.bodyMd().withWeight(FontWeight.w600));
      final bold = _advance(sample, AerosTypography.bodyMd(weight: FontWeight.w800));

      // Guard: the placeholder test font is 14px-per-glyph square; real Inter is not.
      expect(regular, isNot(sample.length * 14.0), reason: 'Inter did not load');
      expect(viaParam, greaterThan(regular));
      expect(viaExtension, viaParam);
      expect(bold, greaterThan(viaParam));

      // The trap this replaces: fontWeight alone leaves the pinned axis, and the glyphs, alone.
      final noop = _advance(sample, AerosTypography.bodyMd().copyWith(fontWeight: FontWeight.w600));
      expect(noop, regular);
    });

    test('mono roles resolve the bundled IBM Plex Mono', () {
      for (final style in [
        AerosTypography.monoLg(),
        AerosTypography.monoMd(),
        AerosTypography.monoSm(),
        AerosTypography.monoXs(),
      ]) {
        expect(style.fontFamily, 'packages/aeros_design_system/IBM Plex Mono');
      }
      expect(AerosTypography.monoMd().fontSize, AerosTypeScale.monoMd.fontSize);
      expect(AerosTypography.monoMd().fontWeight, AerosTypeScale.monoMd.fontWeight);
      expect(AerosTypography.monoSm(weight: FontWeight.w500).fontWeight, FontWeight.w500);
    });

    test('the bundled mono face loads and is monospaced', () {
      final style = AerosTypography.monoMd();
      final narrow = _advance('iiiiiiiiii', style);
      final wide = _advance('MMMMMMMMMM', style);
      expect(narrow, wide);
      // IBM Plex Mono advances 0.6em; the placeholder test font advances 1em.
      expect(narrow, closeTo(10 * 14 * 0.6, 0.01));
    });

    test('the pubspec declares both mono faces and no google_fonts', () {
      final pubspec = File('pubspec.yaml').readAsStringSync();
      expect(pubspec, contains('family: IBM Plex Mono'));
      expect(pubspec, contains('assets/fonts/IBMPlexMono-Regular.ttf'));
      expect(pubspec, contains('assets/fonts/IBMPlexMono-Medium.ttf'));
      expect(pubspec, isNot(contains('google_fonts')));
    });

    test('textTheme maps onto the scale', () {
      const fg = Color(0xFF111111);
      const muted = Color(0xFF777777);
      final theme = AerosTypography.textTheme(fg: fg, fgMuted: muted);
      expect(theme.bodyMedium, AerosTypeScale.bodyMd.copyWith(color: fg));
      expect(theme.labelSmall, AerosTypeScale.overline.copyWith(color: muted));
    });
  });
}
