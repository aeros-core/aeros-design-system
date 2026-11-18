import 'package:flutter/material.dart';

import '../foundation/aeros_surface.dart';
import '../theme/aeros_theme_extension.dart';
import '../tokens/aeros_theme_tokens.g.dart';
import '../tokens/density.dart';
import '../tokens/motion.dart';
import '../tokens/spacing.dart';
import 'aeros_modal_parts.dart';

/// How wide a dialog may get — the `layout.dialog*` tokens.
enum AerosDialogSize {
  sm(AerosMetricTokens.layoutDialogSm),
  md(AerosMetricTokens.layoutDialogMd),
  lg(AerosMetricTokens.layoutDialogLg),
  xl(AerosMetricTokens.layoutDialogXl);

  const AerosDialogSize(this.maxWidth);

  /// 400 / 520 / 720 / 960.
  final double maxWidth;
}

/// A modal dialog: `bgElevated`, the modal elevation, [AerosShapeTokens.modal]
/// corners, over a scrim.
///
/// A header ([title], [description], a close button), a body that scrolls
/// when it is too tall, and a footer of [actions] separated by a hairline.
///
/// ```dart
/// final saved = await AerosDialog.show<bool>(
///   context,
///   builder: (context) => AerosDialog(
///     title: 'Edit address',
///     content: const AddressForm(),
///     actions: [
///       AerosButton.secondary(label: 'Cancel', onPressed: () => Navigator.of(context).pop(false)),
///       AerosButton(label: 'Save', onPressed: () => Navigator.of(context).pop(true)),
///     ],
///   ),
/// );
/// ```
///
/// Shown with [AerosDialog.show], it fades in with a slight scale (instantly
/// when the platform asks for reduced motion), keeps keyboard focus inside
/// until it closes, closes on Escape or a tap on the scrim, and is announced
/// by its title.
class AerosDialog extends StatelessWidget {
  const AerosDialog({
    super.key,
    this.title,
    this.description,
    this.content,
    this.actions = const <Widget>[],
    this.size = AerosDialogSize.md,
    this.maxWidth,
    this.showClose = true,
    this.scrollable = true,
    this.contentPadding,
    this.semanticLabel,
  });

  final String? title;

  /// A line under the title, in `fgSecondary`.
  final String? description;

  /// The body. It scrolls when it is taller than the dialog can be.
  final Widget? content;

  /// The footer, right-aligned — usually [AerosButton]s, the primary one last.
  final List<Widget> actions;
  final AerosDialogSize size;

  /// Overrides the width [size] gives.
  final double? maxWidth;

  /// Shows the close button in the header's corner.
  final bool showClose;

  /// False hands [content] the remaining height to lay out (and scroll)
  /// itself, with no padding — for a body that holds its own list.
  final bool scrollable;

  /// Around [content]. Defaults to the dialog's inset when [scrollable].
  final EdgeInsetsGeometry? contentPadding;

  /// What a screen reader announces when the dialog opens. Defaults to [title].
  final String? semanticLabel;

  /// How far the dialog is scaled down when it starts to appear.
  static const double _enterScale = 0.98;

  /// Shows the dialog [builder] returns over a scrim and completes with the
  /// value it was popped with (`Navigator.of(context).pop(value)`), or null
  /// when it was dismissed.
  ///
  /// With [barrierDismissible] false, neither a tap on the scrim nor Escape
  /// closes it.
  static Future<T?> show<T>(
    BuildContext context, {
    required WidgetBuilder builder,
    bool barrierDismissible = true,
    bool useRootNavigator = true,
    RouteSettings? routeSettings,
  }) {
    final navigator = Navigator.of(context, rootNavigator: useRootNavigator);
    final themes = InheritedTheme.capture(from: context, to: navigator.context);
    final density = context.getInheritedWidgetOfExactType<AerosDensityScope>()?.density;
    return navigator.push<T>(
      RawDialogRoute<T>(
        settings: routeSettings,
        barrierDismissible: barrierDismissible,
        barrierColor: context.aerosColors.scrim,
        barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
        transitionDuration: AerosMotion.resolve(context, AerosMotion.base),
        pageBuilder: (context, _, __) {
          final page = Builder(builder: builder);
          return themes.wrap(density == null ? page : AerosDensityScope(density: density, child: page));
        },
        transitionBuilder: (context, animation, _, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: AerosMotion.enter,
            reverseCurve: AerosMotion.standard,
          );
          return FadeTransition(
            opacity: curved,
            child: ScaleTransition(scale: Tween<double>(begin: _enterScale, end: 1).animate(curved), child: child),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final label = semanticLabel ?? title;
    return Padding(
      // Clear of the status bar, the home indicator and the keyboard, with
      // the scrim showing on every side.
      padding: media.padding +
          media.viewInsets +
          const EdgeInsets.symmetric(horizontal: AerosSpacing.s4, vertical: AerosSpacing.s8),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth ?? size.maxWidth),
          child: Semantics(
            scopesRoute: true,
            namesRoute: label != null,
            label: label,
            explicitChildNodes: true,
            child: AerosSurface(
              level: AerosSurfaceLevel.modal,
              clipBehavior: Clip.antiAlias,
              child: Material(
                type: MaterialType.transparency,
                child: AerosModalLayout(
                  title: title,
                  description: description,
                  content: content,
                  actions: actions,
                  showClose: showClose,
                  scrollable: scrollable,
                  contentPadding: contentPadding,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
