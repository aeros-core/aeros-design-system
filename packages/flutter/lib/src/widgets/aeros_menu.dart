import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import '../foundation/aeros_control_size.dart';
import '../foundation/aeros_state_layer.dart';
import '../theme/aeros_theme_extension.dart';
import '../tokens/aeros_theme_tokens.g.dart';
import '../tokens/spacing.dart';
import '../tokens/typography.dart';
import 'aeros_popover.dart';

/// Opens and closes an [AerosMenu] from its trigger.
typedef AerosMenuController = AerosPopoverController;

/// One entry of an [AerosMenu]: an [AerosMenuItem], an
/// [AerosMenuCheckboxItem], an [AerosMenuRadioItem], an [AerosMenuSeparator]
/// or an [AerosMenuLabel].
@immutable
sealed class AerosMenuEntry {
  const AerosMenuEntry();
}

/// A row that runs an action.
class AerosMenuItem<T> extends AerosMenuEntry {
  const AerosMenuItem({
    required this.label,
    this.onSelected,
    this.value,
    this.leading,
    this.shortcut,
    this.enabled = true,
    this.destructive = false,
  });

  final String label;

  /// Called after the menu has closed.
  final VoidCallback? onSelected;

  /// What [AerosMenu.show] completes with when this row is chosen.
  final T? value;

  /// Usually an [Icon]; it is sized and coloured by the row.
  final Widget? leading;

  /// A keyboard hint shown at the end of the row, e.g. `⌘K`. Not a binding.
  final String? shortcut;
  final bool enabled;

  /// Draws the row in the danger colours — delete, remove, revoke.
  final bool destructive;
}

/// A row that turns an option on or off. It shows a check when [checked].
class AerosMenuCheckboxItem extends AerosMenuEntry {
  const AerosMenuCheckboxItem({
    required this.label,
    required this.checked,
    required this.onChanged,
    this.enabled = true,
  });

  final String label;
  final bool checked;

  /// Called with the new value after the menu has closed. Null disables the row.
  final ValueChanged<bool>? onChanged;
  final bool enabled;

  bool get _interactive => enabled && onChanged != null;
}

/// A row that picks one option of a group. It shows a dot when [value] is the
/// [groupValue].
class AerosMenuRadioItem<T> extends AerosMenuEntry {
  const AerosMenuRadioItem({
    required this.label,
    required this.value,
    required this.groupValue,
    required this.onChanged,
    this.leading,
    this.detail,
    this.enabled = true,
  });

  final String label;
  final T value;
  final T? groupValue;

  /// Usually an [Icon]; it is sized and coloured by the row.
  final Widget? leading;

  /// Muted text at the end of the row.
  final String? detail;

  /// Called with [value] after the menu has closed. Null disables the row.
  final ValueChanged<T>? onChanged;
  final bool enabled;

  // Read here, where the callback's type is known: through a list of entries
  // the item is an `AerosMenuRadioItem<dynamic>`.
  bool get _interactive => enabled && onChanged != null;
  bool get _checked => value == groupValue;
  void _select() => onChanged?.call(value);
}

/// A hairline between groups of rows.
class AerosMenuSeparator extends AerosMenuEntry {
  const AerosMenuSeparator();
}

/// A caption above a group of rows.
class AerosMenuLabel extends AerosMenuEntry {
  const AerosMenuLabel(this.text);

  final String text;
}

/// What a menu row shows in front of (or after) its label.
enum AerosMenuRowMark {
  none,

  /// A leading slot holding a check when the row is checked.
  checkbox,

  /// A leading slot holding a dot when the row is checked.
  radio,

  /// A trailing slot holding a check when the row is checked — the chosen
  /// option of a select.
  selection,
}

/// The one row for every list of choices: menus, selects, the search dropdown.
///
/// [AerosControlSize.sm] high for the density, [AerosShapeTokens.item]
/// corners, `bodySm` text. The row does not track the pointer itself: its
/// list owns one highlight for mouse and keyboard and passes [highlighted],
/// which draws the hover state layer (or the danger tint, when
/// [destructive]).
class AerosMenuRow extends StatelessWidget {
  const AerosMenuRow({
    super.key,
    this.label,
    this.child,
    this.leading,
    this.detail,
    this.mark = AerosMenuRowMark.none,
    this.checked = false,
    this.highlighted = false,
    this.enabled = true,
    this.destructive = false,
    this.onTap,
    this.onHighlight,
    this.semanticsRole = SemanticsRole.none,
  }) : assert(label != null || child != null, 'Give the row a label or a child');

  /// The row's text. Ignored when [child] is given.
  final String? label;

  /// Custom row content in place of [label].
  final Widget? child;
  final Widget? leading;

  /// Muted text at the end of the row — a shortcut, a reason.
  final String? detail;
  final AerosMenuRowMark mark;
  final bool checked;
  final bool highlighted;
  final bool enabled;
  final bool destructive;
  final VoidCallback? onTap;

  /// The pointer moved onto the row.
  final VoidCallback? onHighlight;

  /// `menuItem`, `menuItemCheckbox` or `menuItemRadio` inside a menu.
  final SemanticsRole semanticsRole;

  static const AerosControlSize _size = AerosControlSize.sm;
  static const double _markSlot = AerosSizeTokens.iconMd;
  static const double _dot = AerosSpacing.s1_5;

  /// The height of a row holding one line of text, for [context]'s density.
  static double heightOf(BuildContext context) => _size.resolveHeight(context);

  @override
  Widget build(BuildContext context) {
    final a = context.aerosColors;
    final s = context.aerosSemantic;
    final fg = destructive ? s.dangerText : a.fgPrimary;
    final iconColor = destructive ? s.dangerText : a.fgMuted;
    final fill = !highlighted || !enabled
        ? Colors.transparent
        : destructive
            ? s.dangerBg
            : a.stateHover;

    Widget markGlyph() => switch (mark) {
          AerosMenuRowMark.radio => Container(
              width: _dot,
              height: _dot,
              decoration: BoxDecoration(color: fg, shape: BoxShape.circle),
            ),
          _ => Icon(Icons.check_rounded, size: _markSlot, color: fg),
        };
    final markSlot = SizedBox.square(
      dimension: _markSlot,
      child: checked ? Center(child: markGlyph()) : null,
    );

    final content = Row(
      children: [
        if (mark == AerosMenuRowMark.checkbox || mark == AerosMenuRowMark.radio) ...[
          markSlot,
          const SizedBox(width: AerosSpacing.s2),
        ],
        if (leading != null) ...[
          IconTheme.merge(data: IconThemeData(color: iconColor, size: AerosSizeTokens.iconMd), child: leading!),
          const SizedBox(width: AerosSpacing.s2),
        ],
        Expanded(
          child: child ??
              Text(
                label!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AerosTypography.bodySm(color: fg),
              ),
        ),
        if (detail != null) ...[
          const SizedBox(width: AerosSpacing.s4),
          Text(detail!, maxLines: 1, style: AerosTypography.caption(color: a.fgMuted)),
        ],
        if (mark == AerosMenuRowMark.selection) ...[
          const SizedBox(width: AerosSpacing.s2),
          markSlot,
        ],
      ],
    );

    final checkable = mark == AerosMenuRowMark.checkbox || mark == AerosMenuRowMark.radio;
    return MergeSemantics(
      child: Semantics(
        role: semanticsRole,
        button: true,
        enabled: enabled,
        checked: checkable ? checked : null,
        selected: mark == AerosMenuRowMark.selection ? checked : null,
        inMutuallyExclusiveGroup: mark == AerosMenuRowMark.radio ? true : null,
        onTap: enabled ? onTap : null,
        child: MouseRegion(
          cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
          onEnter: enabled ? (_) => onHighlight?.call() : null,
          onHover: enabled ? (_) => onHighlight?.call() : null,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            excludeFromSemantics: true,
            onTap: enabled ? onTap : null,
            child: Opacity(
              opacity: enabled ? 1 : AerosMetricTokens.opacityDisabled,
              child: AnimatedContainer(
                duration: AerosStateLayer.duration(context),
                curve: AerosStateLayer.curve,
                constraints: BoxConstraints(minHeight: heightOf(context)),
                padding: const EdgeInsets.symmetric(horizontal: AerosSpacing.s2),
                decoration: BoxDecoration(
                  color: fill,
                  borderRadius: const BorderRadius.all(Radius.circular(AerosShapeTokens.item)),
                ),
                child: content,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// An anchored popup menu: rows on an elevated overlay surface.
///
/// ```dart
/// AerosMenu(
///   items: [
///     AerosMenuItem(label: 'Rename', onSelected: rename),
///     const AerosMenuSeparator(),
///     AerosMenuItem(label: 'Delete', destructive: true, onSelected: delete),
///   ],
///   trigger: (context, menu) => AerosButton.icon(
///     icon: const Icon(Icons.more_horiz),
///     semanticLabel: 'More',
///     onPressed: menu.toggle,
///   ),
/// )
/// ```
///
/// Arrow keys (and Home / End) move the highlight, skipping disabled rows;
/// Enter or Space choose; Escape or a tap outside close the menu, and focus
/// returns to the trigger. With no trigger to wrap — a context menu, say —
/// use [AerosMenu.show].
class AerosMenu extends StatelessWidget {
  const AerosMenu({
    super.key,
    required this.items,
    required this.trigger,
    this.controller,
    this.side = AerosPopoverSide.below,
    this.align = AerosPopoverAlign.start,
    this.matchAnchorWidth = false,
    this.semanticLabel,
    this.onOpenChanged,
  });

  final List<AerosMenuEntry> items;

  /// Builds the widget the menu is anchored to. Call `controller.toggle` from it.
  final Widget Function(BuildContext context, AerosMenuController controller) trigger;
  final AerosMenuController? controller;
  final AerosPopoverSide side;
  final AerosPopoverAlign align;
  final bool matchAnchorWidth;

  /// Announced when the menu opens.
  final String? semanticLabel;
  final ValueChanged<bool>? onOpenChanged;

  /// The narrowest a menu gets. No width token yet: twice `space.24` (192).
  static const double minWidth = AerosSpacing.s24 * 2;

  /// The widest a menu gets. No width token yet: the small drawer (360).
  static const double maxWidth = AerosMetricTokens.layoutDrawerSm;

  /// Inside the surface, around the rows.
  static const double panelPadding = AerosSpacing.s1;

  static BoxConstraints _constraints(bool matchAnchorWidth) =>
      matchAnchorWidth ? const BoxConstraints() : const BoxConstraints(minWidth: minWidth, maxWidth: maxWidth);

  /// Opens a menu anchored to [context]'s render box (or to [anchorRect], in
  /// the navigator's coordinates). Completes with the chosen
  /// [AerosMenuItem.value], or null when the menu was dismissed.
  static Future<T?> show<T>(
    BuildContext context, {
    required List<AerosMenuEntry> items,
    Rect? anchorRect,
    AerosPopoverSide side = AerosPopoverSide.below,
    AerosPopoverAlign align = AerosPopoverAlign.start,
    bool matchAnchorWidth = false,
    String? semanticLabel,
    bool useRootNavigator = false,
  }) async {
    final chosen = await AerosPopover.show<AerosMenuEntry>(
      context,
      anchorRect: anchorRect,
      side: side,
      align: align,
      matchAnchorWidth: matchAnchorWidth,
      padding: EdgeInsets.zero,
      constraints: _constraints(matchAnchorWidth),
      semanticLabel: semanticLabel,
      useRootNavigator: useRootNavigator,
      builder: (context) => AerosMenuList(
        entries: items,
        onChosen: (entry) => Navigator.of(context).pop(entry),
      ),
    );
    return _run<T>(chosen);
  }

  /// Runs the chosen entry's callback — after the menu has closed, so a
  /// callback that opens a dialog or navigates starts from a settled stack.
  static T? _run<T>(AerosMenuEntry? chosen) {
    switch (chosen) {
      case AerosMenuItem():
        chosen.onSelected?.call();
        final value = chosen.value;
        return value is T ? value : null;
      case AerosMenuCheckboxItem():
        chosen.onChanged?.call(!chosen.checked);
      case AerosMenuRadioItem():
        chosen._select();
      case AerosMenuSeparator() || AerosMenuLabel() || null:
        break;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return AerosPopover(
      controller: controller,
      side: side,
      align: align,
      matchAnchorWidth: matchAnchorWidth,
      padding: EdgeInsets.zero,
      constraints: _constraints(matchAnchorWidth),
      semanticLabel: semanticLabel,
      onOpenChanged: onOpenChanged,
      trigger: trigger,
      content: (context) => AerosMenuList(
        entries: items,
        onChosen: (entry) {
          Navigator.of(context).pop();
          _run<Object?>(entry);
        },
      ),
    );
  }
}

/// The rows of a menu, with the one highlight that the mouse and the keyboard
/// share. It is what [AerosMenu] puts on its surface; use it directly to put
/// menu rows on a surface of your own.
class AerosMenuList extends StatefulWidget {
  const AerosMenuList({
    super.key,
    required this.entries,
    required this.onChosen,
    this.initialHighlight,
    this.selection = false,
    this.autofocus = true,
  });

  final List<AerosMenuEntry> entries;

  /// A row was chosen with a tap, Enter or Space.
  final ValueChanged<AerosMenuEntry> onChosen;

  /// The index (into [entries]) highlighted and scrolled to at first.
  final int? initialHighlight;

  /// The rows are the options of a select: checked [AerosMenuRadioItem]s show
  /// a trailing check, and the viewport is cut at a whole row.
  final bool selection;
  final bool autofocus;

  @override
  State<AerosMenuList> createState() => _AerosMenuListState();
}

class _AerosMenuListState extends State<AerosMenuList> {
  final FocusNode _focus = FocusNode(debugLabel: 'AerosMenuList');
  final Map<int, GlobalKey> _keys = <int, GlobalKey>{};
  int? _highlight;

  @override
  void initState() {
    super.initState();
    _highlight = widget.initialHighlight;
    if (_highlight != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _reveal(jump: true));
    }
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  bool _interactive(int index) {
    final entry = widget.entries[index];
    return switch (entry) {
      AerosMenuItem() => entry.enabled,
      AerosMenuCheckboxItem() => entry._interactive,
      AerosMenuRadioItem() => entry._interactive,
      AerosMenuSeparator() || AerosMenuLabel() => false,
    };
  }

  void _setHighlight(int? index) {
    if (index == _highlight) return;
    setState(() => _highlight = index);
  }

  /// Moves the highlight by [step] rows, skipping what cannot be chosen and
  /// wrapping at the ends. [from] is the index to start counting from.
  void _move(int step, {int? from}) {
    final count = widget.entries.length;
    if (count == 0) return;
    var index = from ?? _highlight ?? (step > 0 ? -1 : count);
    for (var i = 0; i < count; i++) {
      index = (index + step) % count;
      if (index < 0) index += count;
      if (_interactive(index)) {
        _setHighlight(index);
        WidgetsBinding.instance.addPostFrameCallback((_) => _reveal());
        return;
      }
    }
  }

  void _reveal({bool jump = false}) {
    final context = _keys[_highlight]?.currentContext;
    if (context == null) return;
    Scrollable.ensureVisible(
      context,
      alignment: jump ? 0.5 : 0,
      alignmentPolicy: jump ? ScrollPositionAlignmentPolicy.explicit : ScrollPositionAlignmentPolicy.keepVisibleAtEnd,
    );
    if (!jump) {
      Scrollable.ensureVisible(context, alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtStart);
    }
  }

  void _choose(int index) {
    if (_interactive(index)) widget.onChosen(widget.entries[index]);
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is KeyUpEvent) return KeyEventResult.ignored;
    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.arrowDown) {
      _move(1);
    } else if (key == LogicalKeyboardKey.arrowUp) {
      _move(-1);
    } else if (key == LogicalKeyboardKey.home) {
      _move(1, from: -1);
    } else if (key == LogicalKeyboardKey.end) {
      _move(-1, from: widget.entries.length);
    } else if (key == LogicalKeyboardKey.enter ||
        key == LogicalKeyboardKey.numpadEnter ||
        key == LogicalKeyboardKey.space) {
      final index = _highlight;
      if (index != null && event is KeyDownEvent) _choose(index);
    } else if (key == LogicalKeyboardKey.tab) {
      // Focus stays in the menu until it closes.
    } else {
      return KeyEventResult.ignored;
    }
    return KeyEventResult.handled;
  }

  Widget _entry(BuildContext context, int index) {
    final a = context.aerosColors;
    final entry = widget.entries[index];
    final highlighted = index == _highlight;
    final key = _keys.putIfAbsent(index, GlobalKey.new);
    void onTap() => _choose(index);
    void onHighlight() => _setHighlight(index);

    switch (entry) {
      case AerosMenuItem():
        return AerosMenuRow(
          key: key,
          label: entry.label,
          leading: entry.leading,
          detail: entry.shortcut,
          enabled: entry.enabled,
          destructive: entry.destructive,
          highlighted: highlighted,
          onTap: onTap,
          onHighlight: onHighlight,
          semanticsRole: SemanticsRole.menuItem,
        );
      case AerosMenuCheckboxItem():
        return AerosMenuRow(
          key: key,
          label: entry.label,
          mark: AerosMenuRowMark.checkbox,
          checked: entry.checked,
          enabled: _interactive(index),
          highlighted: highlighted,
          onTap: onTap,
          onHighlight: onHighlight,
          semanticsRole: SemanticsRole.menuItemCheckbox,
        );
      case AerosMenuRadioItem():
        return AerosMenuRow(
          key: key,
          label: entry.label,
          leading: entry.leading,
          detail: entry.detail,
          mark: widget.selection ? AerosMenuRowMark.selection : AerosMenuRowMark.radio,
          checked: entry._checked,
          enabled: _interactive(index),
          highlighted: highlighted,
          onTap: onTap,
          onHighlight: onHighlight,
          semanticsRole: widget.selection ? SemanticsRole.none : SemanticsRole.menuItemRadio,
        );
      case AerosMenuSeparator():
        return Container(
          height: AerosMetricTokens.borderHairline,
          margin: const EdgeInsets.symmetric(vertical: AerosSpacing.s1),
          color: a.borderDefault,
        );
      case AerosMenuLabel():
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: AerosSpacing.s2, vertical: AerosSpacing.s1_5),
          child: Text(entry.text, style: AerosTypography.caption(color: a.fgMuted)),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final uniform = widget.entries.every((e) => e is! AerosMenuSeparator && e is! AerosMenuLabel);
    final rows = <Widget>[
      for (var i = 0; i < widget.entries.length; i++)
        // The separator runs edge to edge; everything else sits inside the padding.
        widget.entries[i] is AerosMenuSeparator
            ? _entry(context, i)
            : Padding(
                padding: const EdgeInsets.symmetric(horizontal: AerosMenu.panelPadding),
                child: _entry(context, i),
              ),
    ];

    Widget list = SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: AerosMenu.panelPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: rows,
      ),
    );
    if (uniform) {
      list = AerosWholeRows(
        rowHeight: AerosMenuRow.heightOf(context),
        leadingPadding: AerosMenu.panelPadding,
        child: list,
      );
    }

    return Semantics(
      role: widget.selection || widget.entries.isEmpty ? SemanticsRole.none : SemanticsRole.menu,
      container: true,
      explicitChildNodes: true,
      child: Focus(
        focusNode: _focus,
        autofocus: widget.autofocus,
        onKeyEvent: _onKey,
        child: MouseRegion(
          onExit: (_) => _setHighlight(null),
          child: IntrinsicWidth(child: list),
        ),
      ),
    );
  }
}

/// Cuts a scrolling list of equal rows at a whole row, so the last visible
/// row is never sliced through its text.
///
/// When the child (a scroll view) is taller than the space it is given, its
/// height becomes [leadingPadding] plus as many [rowHeight]s as fit.
class AerosWholeRows extends SingleChildRenderObjectWidget {
  const AerosWholeRows({super.key, required this.rowHeight, this.leadingPadding = 0, required super.child});

  final double rowHeight;
  final double leadingPadding;

  @override
  RenderObject createRenderObject(BuildContext context) => _RenderWholeRows(rowHeight, leadingPadding);

  @override
  void updateRenderObject(BuildContext context, covariant RenderObject renderObject) {
    (renderObject as _RenderWholeRows)
      ..rowHeight = rowHeight
      ..leadingPadding = leadingPadding;
  }
}

class _RenderWholeRows extends RenderProxyBox {
  _RenderWholeRows(this._rowHeight, this._leadingPadding);

  double _rowHeight;
  set rowHeight(double value) {
    if (value == _rowHeight) return;
    _rowHeight = value;
    markNeedsLayout();
  }

  double _leadingPadding;
  set leadingPadding(double value) {
    if (value == _leadingPadding) return;
    _leadingPadding = value;
    markNeedsLayout();
  }

  BoxConstraints _snap(BoxConstraints constraints, double wanted) {
    if (!constraints.hasBoundedHeight || wanted <= constraints.maxHeight || _rowHeight <= 0) return constraints;
    final rows = math.max(1, ((constraints.maxHeight - _leadingPadding) / _rowHeight).floor());
    final height = math.min(constraints.maxHeight, _leadingPadding + rows * _rowHeight);
    return constraints.copyWith(minHeight: math.min(constraints.minHeight, height), maxHeight: height);
  }

  double _wanted(BoxConstraints constraints) {
    final width = constraints.hasBoundedWidth ? constraints.maxWidth : double.infinity;
    return child?.getMaxIntrinsicHeight(width) ?? 0;
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) =>
      child?.getDryLayout(_snap(constraints, _wanted(constraints))) ?? constraints.smallest;

  @override
  void performLayout() {
    final c = child;
    if (c == null) {
      size = constraints.smallest;
      return;
    }
    c.layout(_snap(constraints, _wanted(constraints)), parentUsesSize: true);
    size = c.size;
  }
}
