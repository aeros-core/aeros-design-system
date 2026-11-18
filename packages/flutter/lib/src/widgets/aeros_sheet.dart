import 'package:flutter/gestures.dart' show kMinFlingVelocity;
import 'package:flutter/material.dart';

import '../foundation/aeros_surface.dart';
import '../theme/aeros_theme_extension.dart';
import '../tokens/aeros_theme_tokens.g.dart';
import '../tokens/density.dart';
import '../tokens/motion.dart';
import '../tokens/spacing.dart';
import 'aeros_modal_parts.dart';

/// The edge a sheet slides in from.
enum AerosSheetSide {
  /// A bottom sheet — the touch default. Full width, as tall as its content.
  bottom,

  /// A side sheet on the right edge. Full height.
  right,

  /// A side sheet on the left edge. Full height.
  left,
}

/// How wide a side sheet may get — the `layout.drawer*` tokens. A bottom
/// sheet is always the width of the screen.
enum AerosSheetSize {
  sm(AerosMetricTokens.layoutDrawerSm),
  md(AerosMetricTokens.layoutDrawerMd),
  lg(AerosMetricTokens.layoutDrawerLg);

  const AerosSheetSize(this.maxWidth);

  /// 360 / 480 / 640.
  final double maxWidth;
}

/// A modal sheet: the same surface and the same header / body / footer as
/// [AerosDialog], attached to an edge of the screen.
///
/// ```dart
/// AerosSheet.show<void>(
///   context,
///   side: AerosSheetSide.right,
///   builder: (context) => AerosSheet(
///     title: 'Order #1042',
///     content: const OrderDetails(),
///     actions: [AerosButton(label: 'Done', onPressed: () => Navigator.of(context).pop())],
///   ),
/// );
/// ```
///
/// A bottom sheet has a drag handle: drag it (or the header) down to dismiss.
/// Escape and a tap on the scrim close any sheet; focus stays inside until it
/// does.
class AerosSheet extends StatefulWidget {
  const AerosSheet({
    super.key,
    this.title,
    this.description,
    this.content,
    this.actions = const <Widget>[],
    this.side,
    this.size,
    this.showClose = true,
    this.showDragHandle = true,
    this.scrollable = true,
    this.contentPadding,
    this.semanticLabel,
  });

  final String? title;
  final String? description;

  /// The body. It scrolls when it is taller than the sheet can be.
  final Widget? content;

  /// The footer, right-aligned.
  final List<Widget> actions;

  /// Defaults to the side given to [AerosSheet.show] (bottom outside one).
  final AerosSheetSide? side;

  /// Defaults to the size given to [AerosSheet.show] (md outside one).
  final AerosSheetSize? size;
  final bool showClose;

  /// The grab handle at the top of a bottom sheet.
  final bool showDragHandle;

  /// False hands [content] the remaining height to lay out (and scroll) itself.
  final bool scrollable;
  final EdgeInsetsGeometry? contentPadding;

  /// What a screen reader announces when the sheet opens. Defaults to [title].
  final String? semanticLabel;

  /// Shows the sheet [builder] returns, sliding in from [side], and completes
  /// with the value it was popped with (null when dismissed).
  static Future<T?> show<T>(
    BuildContext context, {
    required WidgetBuilder builder,
    AerosSheetSide side = AerosSheetSide.bottom,
    AerosSheetSize size = AerosSheetSize.md,
    bool barrierDismissible = true,
    bool useRootNavigator = true,
    RouteSettings? routeSettings,
  }) {
    final navigator = Navigator.of(context, rootNavigator: useRootNavigator);
    final themes = InheritedTheme.capture(from: context, to: navigator.context);
    final density = context.getInheritedWidgetOfExactType<AerosDensityScope>()?.density;
    final begin = switch (side) {
      AerosSheetSide.bottom => const Offset(0, 1),
      AerosSheetSide.right => const Offset(1, 0),
      AerosSheetSide.left => const Offset(-1, 0),
    };
    return navigator.push<T>(
      RawDialogRoute<T>(
        settings: routeSettings,
        barrierDismissible: barrierDismissible,
        barrierColor: context.aerosColors.scrim,
        barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
        transitionDuration: AerosMotion.resolve(context, AerosMotion.slow),
        pageBuilder: (context, _, __) {
          final Widget page = _AerosSheetScope(side: side, size: size, child: Builder(builder: builder));
          return themes.wrap(density == null ? page : AerosDensityScope(density: density, child: page));
        },
        transitionBuilder: (context, animation, _, child) => SlideTransition(
          position: Tween<Offset>(begin: begin, end: Offset.zero).animate(
            CurvedAnimation(parent: animation, curve: AerosMotion.decelerate, reverseCurve: AerosMotion.standard),
          ),
          child: child,
        ),
      ),
    );
  }

  @override
  State<AerosSheet> createState() => _AerosSheetState();
}

class _AerosSheetScope extends InheritedWidget {
  const _AerosSheetScope({required this.side, required this.size, required super.child});

  final AerosSheetSide side;
  final AerosSheetSize size;

  @override
  bool updateShouldNotify(_AerosSheetScope oldWidget) => oldWidget.side != side || oldWidget.size != size;
}

class _AerosSheetState extends State<AerosSheet> {
  /// How far a bottom sheet has been dragged down.
  double _drag = 0;

  void _onDragUpdate(DragUpdateDetails details) {
    setState(() => _drag = (_drag + details.delta.dy).clamp(0.0, double.infinity));
  }

  void _onDragEnd(DragEndDetails details) {
    final threshold = AerosDensity.of(context).sizes.header;
    final flung = (details.primaryVelocity ?? 0) > kMinFlingVelocity;
    if (_drag > threshold || (flung && _drag > 0)) {
      Navigator.of(context).maybePop();
    } else {
      setState(() => _drag = 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final a = context.aerosColors;
    final scope = context.dependOnInheritedWidgetOfExactType<_AerosSheetScope>();
    final side = widget.side ?? scope?.side ?? AerosSheetSide.bottom;
    final size = widget.size ?? scope?.size ?? AerosSheetSize.md;
    final media = MediaQuery.of(context);
    final bottom = side == AerosSheetSide.bottom;
    final label = widget.semanticLabel ?? widget.title;
    const corner = Radius.circular(AerosShapeTokens.modal);

    Widget? handle;
    if (bottom && widget.showDragHandle) {
      handle = ExcludeSemantics(
        child: Padding(
          padding: const EdgeInsets.only(top: AerosSpacing.s2),
          child: Center(
            child: Container(
              width: AerosSpacing.s8,
              height: AerosSpacing.s1,
              decoration: BoxDecoration(
                color: a.borderStrong,
                borderRadius: const BorderRadius.all(Radius.circular(AerosShapeTokens.pill)),
              ),
            ),
          ),
        ),
      );
    }

    Widget layout = AerosModalLayout(
      title: widget.title,
      description: widget.description,
      content: widget.content,
      actions: widget.actions,
      showClose: widget.showClose,
      scrollable: widget.scrollable,
      contentPadding: widget.contentPadding,
      top: handle,
      fill: !bottom,
    );
    if (handle != null) {
      // Dragging anywhere the content does not scroll moves the sheet.
      layout = GestureDetector(
        behavior: HitTestBehavior.translucent,
        excludeFromSemantics: true,
        onVerticalDragUpdate: _onDragUpdate,
        onVerticalDragEnd: _onDragEnd,
        child: layout,
      );
    }

    final surface = Semantics(
      scopesRoute: true,
      namesRoute: label != null,
      label: label,
      explicitChildNodes: true,
      child: AerosSurface(
        level: AerosSurfaceLevel.modal,
        radius: bottom ? const BorderRadius.vertical(top: corner) : BorderRadius.zero,
        clipBehavior: Clip.antiAlias,
        child: Material(
          type: MaterialType.transparency,
          child: Padding(
            // The surface runs to the screen edge; its content stays clear of
            // the system bars and the keyboard.
            padding: EdgeInsets.only(
              top: bottom ? 0 : media.padding.top,
              bottom: media.padding.bottom + media.viewInsets.bottom,
            ),
            child: layout,
          ),
        ),
      ),
    );

    if (bottom) {
      return Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          // Never taller than the screen less a header's height, so the page
          // behind stays visible above it.
          padding: EdgeInsets.only(top: media.padding.top + AerosDensity.of(context).sizes.header),
          child: Transform.translate(
            offset: Offset(0, _drag),
            child: SizedBox(width: double.infinity, child: surface),
          ),
        ),
      );
    }
    return Align(
      alignment: side == AerosSheetSide.right ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: size.maxWidth),
        child: SizedBox(width: double.infinity, height: double.infinity, child: surface),
      ),
    );
  }
}
