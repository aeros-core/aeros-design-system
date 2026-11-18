import 'package:flutter/material.dart';
import '../tokens/aeros_theme_tokens.g.dart';
import '../tokens/colors.dart';
import '../tokens/spacing.dart';
import '../tokens/typography.dart';
import 'aeros_theme_extension.dart';

/// Aeros Material theme factories. Use these to seed `MaterialApp`.
///
/// Everything here is read from tokens, so a raw Material widget dropped into
/// an Aeros app (a `Checkbox`, a `PopupMenuButton`, a `ListTile`) picks up the
/// same hairlines, radii and colour-only states as the Aeros widgets: no
/// ripple, no surface tint, no Material elevation.
class AerosTheme {
  AerosTheme._();

  static ThemeData light() => _build(
        brightness: Brightness.light,
        extension: AerosThemeExtension.light,
      );

  static ThemeData dark() => _build(
        brightness: Brightness.dark,
        extension: AerosThemeExtension.dark,
      );

  static const BorderRadius _itemRadius = BorderRadius.all(Radius.circular(AerosShapeTokens.item));
  static const BorderRadius _controlRadius = BorderRadius.all(Radius.circular(AerosShapeTokens.control));
  static const BorderRadius _surfaceRadius = BorderRadius.all(Radius.circular(AerosShapeTokens.surface));
  static const BorderRadius _modalRadius = BorderRadius.all(Radius.circular(AerosShapeTokens.modal));

  static ThemeData _build({
    required Brightness brightness,
    required AerosThemeExtension extension,
  }) {
    final aliases = extension.aliases;
    final semantic = extension.semantic;

    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: aliases.brandPrimary,
      onPrimary: aliases.fgInverse,
      primaryContainer: aliases.brandPrimaryMuted,
      onPrimaryContainer: aliases.fgPrimary,
      secondary: aliases.fgSecondary,
      onSecondary: aliases.fgInverse,
      secondaryContainer: aliases.bgSubtle,
      onSecondaryContainer: aliases.fgPrimary,
      tertiary: aliases.fgMuted,
      onTertiary: aliases.fgInverse,
      tertiaryContainer: aliases.bgSubtle,
      onTertiaryContainer: aliases.fgPrimary,
      error: semantic.danger,
      // fgInverse is white on the light danger red and near-black on the
      // lighter dark-mode red — readable on both.
      onError: aliases.fgInverse,
      errorContainer: semantic.dangerBg,
      onErrorContainer: semantic.dangerText,
      surface: aliases.bgSurface,
      onSurface: aliases.fgPrimary,
      surfaceContainerLowest: aliases.bgSurface,
      surfaceContainerLow: aliases.bgCanvas,
      surfaceContainer: aliases.bgSubtle,
      surfaceContainerHigh: aliases.bgSubtle,
      surfaceContainerHighest: aliases.bgSubtle,
      onSurfaceVariant: aliases.fgSecondary,
      outline: aliases.borderStrong,
      outlineVariant: aliases.borderDefault,
      inverseSurface: aliases.bgInverse,
      onInverseSurface: aliases.fgInverse,
      inversePrimary: aliases.fgInverse,
      scrim: aliases.scrim,
      shadow: AerosColors.ink950,
      surfaceTint: Colors.transparent,
    );

    final textTheme = AerosTypography.textTheme(
      fg: aliases.fgPrimary,
      fgMuted: aliases.fgMuted,
    );

    // Colour-only states: the translucent state aliases, never ink.
    final stateOverlay = WidgetStateProperty.resolveWith<Color?>((states) {
      if (states.contains(WidgetState.pressed)) return aliases.statePressed;
      if (states.contains(WidgetState.hovered)) return aliases.stateHover;
      return Colors.transparent;
    });

    OutlineInputBorder inputBorder(Color color) => OutlineInputBorder(
          borderRadius: _controlRadius,
          borderSide: BorderSide(color: color, width: AerosMetricTokens.borderHairline),
        );

    // Raw Material buttons carry no density, so they take the unscoped
    // (touch) medium control height — the same as an unscoped AerosButton.
    final buttonMinimumSize = Size(0, AerosSizeTokens.touch.controlMd);
    const buttonPadding = EdgeInsets.symmetric(horizontal: AerosSpacing.s3);
    const buttonShape = RoundedRectangleBorder(borderRadius: _controlRadius);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: aliases.bgCanvas,
      canvasColor: aliases.bgSurface,
      dividerColor: aliases.borderDefault,
      disabledColor: aliases.fgDisabled,
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      // No ripple anywhere: state is a colour change.
      splashFactory: NoSplash.splashFactory,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      // Raw Material widgets (and Aeros widgets not yet on AerosPressable) keep
      // a hover tint — the same state overlay the foundation layer uses.
      hoverColor: aliases.stateHover,
      visualDensity: VisualDensity.standard,
      appBarTheme: AppBarTheme(
        backgroundColor: aliases.bgCanvas,
        foregroundColor: aliases.fgPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        iconTheme: IconThemeData(color: aliases.fgPrimary, size: AerosSizeTokens.iconLg),
        titleTextStyle: AerosTypography.h4(color: aliases.fgPrimary),
      ),
      cardTheme: CardThemeData(
        color: aliases.bgSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: _surfaceRadius,
          side: BorderSide(color: aliases.borderDefault, width: AerosMetricTokens.borderHairline),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: aliases.borderDefault,
        thickness: AerosMetricTokens.borderHairline,
        space: AerosMetricTokens.borderHairline,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: aliases.bgSurface,
        hoverColor: Colors.transparent,
        contentPadding: const EdgeInsets.symmetric(horizontal: AerosSpacing.s3, vertical: AerosSpacing.s2_5),
        hintStyle: AerosTypography.bodyMd(color: aliases.fgMuted),
        labelStyle: AerosTypography.labelSm(color: aliases.fgSecondary),
        helperStyle: AerosTypography.caption(color: aliases.fgMuted),
        errorStyle: AerosTypography.caption(color: semantic.dangerText),
        // The border is 1px in every state — focus is the ring's job (Aeros
        // fields) or, for a raw TextField, the darker border colour.
        border: inputBorder(aliases.borderStrong),
        enabledBorder: inputBorder(aliases.borderStrong),
        focusedBorder: inputBorder(aliases.borderFocus),
        disabledBorder: inputBorder(aliases.borderDefault),
        errorBorder: inputBorder(semantic.danger),
        focusedErrorBorder: inputBorder(semantic.danger),
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: aliases.fgPrimary,
        selectionColor: aliases.borderStrong,
        selectionHandleColor: aliases.fgPrimary,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          foregroundColor: aliases.fgInverse,
          disabledBackgroundColor: aliases.bgSubtle,
          disabledForegroundColor: aliases.fgDisabled,
          elevation: 0,
          padding: buttonPadding,
          minimumSize: buttonMinimumSize,
          textStyle: AerosTypography.labelMd(),
          shape: buttonShape,
        ).copyWith(
          // The state overlays are ink on a light surface — invisible on the
          // solid brand fill — so hover / pressed swap the fill instead.
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) return aliases.bgSubtle;
            if (states.contains(WidgetState.pressed) || states.contains(WidgetState.hovered)) {
              return aliases.brandPrimaryHover;
            }
            return aliases.brandPrimary;
          }),
          overlayColor: const WidgetStatePropertyAll(Colors.transparent),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: aliases.fgPrimary,
          backgroundColor: aliases.bgSurface,
          disabledForegroundColor: aliases.fgDisabled,
          side: BorderSide(color: aliases.borderStrong, width: AerosMetricTokens.borderHairline),
          padding: buttonPadding,
          minimumSize: buttonMinimumSize,
          textStyle: AerosTypography.labelMd(),
          shape: buttonShape,
        ).copyWith(overlayColor: stateOverlay),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: aliases.fgPrimary,
          disabledForegroundColor: aliases.fgDisabled,
          textStyle: AerosTypography.labelMd(),
          padding: buttonPadding,
          minimumSize: buttonMinimumSize,
          shape: buttonShape,
        ).copyWith(overlayColor: stateOverlay),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: aliases.fgSecondary,
          disabledForegroundColor: aliases.fgDisabled,
          iconSize: AerosSizeTokens.iconLg,
          shape: buttonShape,
        ).copyWith(overlayColor: stateOverlay),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return states.contains(WidgetState.disabled) ? aliases.fgDisabled : aliases.brandPrimary;
          }
          return aliases.bgSurface;
        }),
        checkColor: WidgetStatePropertyAll(aliases.fgInverse),
        side: BorderSide(color: aliases.borderStrong, width: AerosMetricTokens.borderHairline),
        shape: const RoundedRectangleBorder(borderRadius: _itemRadius),
        overlayColor: stateOverlay,
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) return aliases.fgDisabled;
          return states.contains(WidgetState.selected) ? aliases.brandPrimary : aliases.borderStrong;
        }),
        overlayColor: stateOverlay,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected) ? aliases.fgInverse : aliases.fgMuted,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected) ? aliases.brandPrimary : aliases.bgSubtle,
        ),
        trackOutlineColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected) ? aliases.brandPrimary : aliases.borderStrong,
        ),
        trackOutlineWidth: const WidgetStatePropertyAll(AerosMetricTokens.borderHairline),
        overlayColor: stateOverlay,
      ),
      // Floating layers: an elevated fill and a hairline edge. Material
      // elevation is off — the Aeros shadow lives in AerosSurface.
      popupMenuTheme: PopupMenuThemeData(
        color: aliases.bgElevated,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: _surfaceRadius,
          side: BorderSide(color: aliases.borderDefault, width: AerosMetricTokens.borderHairline),
        ),
        textStyle: AerosTypography.bodyMd(color: aliases.fgPrimary),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => AerosTypography.bodyMd(
            color: states.contains(WidgetState.disabled) ? aliases.fgDisabled : aliases.fgPrimary,
          ),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: aliases.bgElevated,
        modalBackgroundColor: aliases.bgElevated,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        elevation: 0,
        modalElevation: 0,
        modalBarrierColor: aliases.scrim,
        dragHandleColor: aliases.borderStrong,
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(AerosShapeTokens.modal)),
          side: BorderSide(color: aliases.borderDefault, width: AerosMetricTokens.borderHairline),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: aliases.bgElevated,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        elevation: 0,
        barrierColor: aliases.scrim,
        shape: RoundedRectangleBorder(
          borderRadius: _modalRadius,
          side: BorderSide(color: aliases.borderDefault, width: AerosMetricTokens.borderHairline),
        ),
        titleTextStyle: AerosTypography.titleLg(color: aliases.fgPrimary),
        contentTextStyle: AerosTypography.bodyMd(color: aliases.fgSecondary),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: aliases.bgInverse,
        contentTextStyle: AerosTypography.bodySm(color: aliases.fgInverse),
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        shape: const RoundedRectangleBorder(borderRadius: _controlRadius),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: aliases.bgInverse,
          borderRadius: _itemRadius,
        ),
        textStyle: AerosTypography.caption(color: aliases.fgInverse),
        padding: const EdgeInsets.symmetric(horizontal: AerosSpacing.s2, vertical: AerosSpacing.s1),
      ),
      scrollbarTheme: ScrollbarThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          final active = states.contains(WidgetState.hovered) || states.contains(WidgetState.dragged);
          return active ? aliases.fgMuted : aliases.borderStrong;
        }),
        trackColor: const WidgetStatePropertyAll(Colors.transparent),
        trackBorderColor: const WidgetStatePropertyAll(Colors.transparent),
        thickness: const WidgetStatePropertyAll(AerosSpacing.s1_5),
        radius: const Radius.circular(AerosShapeTokens.pill),
        crossAxisMargin: AerosSpacing.s0_5,
        mainAxisMargin: AerosSpacing.s0_5,
      ),
      listTileTheme: ListTileThemeData(
        iconColor: aliases.fgSecondary,
        textColor: aliases.fgPrimary,
        titleTextStyle: AerosTypography.bodyMd(color: aliases.fgPrimary),
        subtitleTextStyle: AerosTypography.bodySm(color: aliases.fgMuted),
        leadingAndTrailingTextStyle: AerosTypography.caption(color: aliases.fgMuted),
        selectedColor: aliases.fgPrimary,
        selectedTileColor: aliases.stateSelected,
        contentPadding: const EdgeInsets.symmetric(horizontal: AerosSpacing.s3),
        horizontalTitleGap: AerosSpacing.s3,
        minVerticalPadding: AerosSpacing.s2,
        shape: const RoundedRectangleBorder(borderRadius: _controlRadius),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: aliases.brandPrimary,
        linearTrackColor: aliases.bgSubtle,
        circularTrackColor: Colors.transparent,
        linearMinHeight: AerosSpacing.s1,
      ),
      extensions: [extension],
    );
  }
}
