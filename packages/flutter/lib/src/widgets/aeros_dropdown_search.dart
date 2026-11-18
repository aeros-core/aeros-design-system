import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../foundation/aeros_control_size.dart';
import '../foundation/aeros_field_frame.dart';
import '../foundation/aeros_pressable.dart';
import '../theme/aeros_theme_extension.dart';
import '../tokens/aeros_theme_tokens.g.dart';
import '../tokens/spacing.dart';
import '../tokens/typography.dart';
import 'aeros_dialog.dart';
import 'aeros_form_field.dart';
import 'aeros_menu.dart';
import 'aeros_popover.dart';
import 'aeros_search_field.dart';
import 'aeros_sheet.dart';

enum AerosDropdownMode { dialog, sheet, menu }

typedef AerosDropdownItemAsString<T> = String Function(T item);
typedef AerosDropdownOnFind<T> = Future<List<T>> Function(String query);
typedef AerosDropdownItemBuilder<T> = Widget Function(
  BuildContext context,
  T item,
  bool isSelected,
);

/// Searchable dropdown with dialog / bottom-sheet / inline-menu modes.
///
/// The trigger is a field ([AerosFieldFrame]). The options open in an
/// [AerosDialog], a bottom [AerosSheet] or an anchored menu surface, by
/// [mode]; each holds an optional search box and a list of [AerosMenuRow]s
/// with the chosen one checked. Arrow keys move the highlight and Enter
/// chooses, while the search box keeps the focus.
///
/// Pass either a static [items] list or an async [onFind].
class AerosDropdownSearch<T> extends StatefulWidget {
  const AerosDropdownSearch({
    super.key,
    this.items,
    this.selectedItem,
    this.onChanged,
    this.onFind,
    required this.itemAsString,
    this.label,
    this.hint,
    this.popupTitle,
    this.mode = AerosDropdownMode.dialog,
    this.showSearchBox = true,
    this.showClearButton = false,
    this.enabled = true,
    this.required = false,
    this.maxHeight,
    this.dialogMaxWidth,
    this.itemBuilder,
    this.emptyText = 'No results',
    this.searchHint = 'Search',
  }) : assert(items != null || onFind != null,
            'Provide either items or onFind');

  final List<T>? items;
  final T? selectedItem;
  final ValueChanged<T?>? onChanged;
  final AerosDropdownOnFind<T>? onFind;
  final AerosDropdownItemAsString<T> itemAsString;

  final String? label;
  final String? hint;
  final String? popupTitle;

  final AerosDropdownMode mode;
  final bool showSearchBox;
  final bool showClearButton;
  final bool enabled;
  final bool required;

  final double? maxHeight;
  final double? dialogMaxWidth;

  final AerosDropdownItemBuilder<T>? itemBuilder;
  final String emptyText;
  final String searchHint;

  @override
  State<AerosDropdownSearch<T>> createState() => _AerosDropdownSearchState<T>();
}

class _AerosDropdownSearchState<T> extends State<AerosDropdownSearch<T>> {
  final GlobalKey _frameKey = GlobalKey(debugLabel: 'AerosDropdownSearch frame');
  T? _selected;

  static const AerosControlSize _size = AerosControlSize.md;

  @override
  void initState() {
    super.initState();
    _selected = widget.selectedItem;
  }

  @override
  void didUpdateWidget(covariant AerosDropdownSearch<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedItem != widget.selectedItem) {
      _selected = widget.selectedItem;
    }
  }

  Future<void> _open() async {
    if (!widget.enabled) return;
    final picked = await switch (widget.mode) {
      AerosDropdownMode.dialog => _openDialog(),
      AerosDropdownMode.sheet => _openSheet(),
      AerosDropdownMode.menu => _openMenu(),
    };
    if (!mounted) return;
    if (picked != null && picked != _selected) {
      setState(() => _selected = picked);
      widget.onChanged?.call(picked);
    }
  }

  Widget _body(BuildContext context, {required bool inMenu}) {
    Widget body = _PopupBody<T>(
      showSearchBox: widget.showSearchBox,
      searchHint: widget.searchHint,
      emptyText: widget.emptyText,
      items: widget.items,
      onFind: widget.onFind,
      itemAsString: widget.itemAsString,
      itemBuilder: widget.itemBuilder,
      selected: _selected,
      inMenu: inMenu,
      onPicked: (item) => Navigator.of(context).pop(item),
    );
    final maxHeight = widget.maxHeight;
    if (maxHeight != null) {
      body = ConstrainedBox(constraints: BoxConstraints(maxHeight: maxHeight), child: body);
    }
    return body;
  }

  Future<T?> _openDialog() {
    return AerosDialog.show<T>(
      context,
      builder: (context) => AerosDialog(
        title: widget.popupTitle ?? widget.label,
        maxWidth: widget.dialogMaxWidth,
        scrollable: false,
        content: _body(context, inMenu: false),
      ),
    );
  }

  Future<T?> _openSheet() {
    return AerosSheet.show<T>(
      context,
      builder: (context) => AerosSheet(
        title: widget.popupTitle ?? widget.label,
        scrollable: false,
        content: _body(context, inMenu: false),
      ),
    );
  }

  Future<T?> _openMenu() {
    final anchor = _frameKey.currentContext!;
    final rect = AerosPopover.anchorRectOf(anchor);
    return AerosPopover.show<T>(
      anchor,
      anchorRect: rect,
      padding: EdgeInsets.zero,
      // Exactly as wide as the field; no taller than the small drawer is wide
      // (there is no menu-height token yet).
      constraints: BoxConstraints(
        minWidth: rect.width,
        maxWidth: rect.width,
        maxHeight: widget.maxHeight ?? AerosMetricTokens.layoutDrawerSm,
      ),
      semanticLabel: widget.popupTitle ?? widget.label,
      builder: (context) => _PopupBody<T>(
        showSearchBox: widget.showSearchBox,
        searchHint: widget.searchHint,
        emptyText: widget.emptyText,
        items: widget.items,
        onFind: widget.onFind,
        itemAsString: widget.itemAsString,
        itemBuilder: widget.itemBuilder,
        selected: _selected,
        inMenu: true,
        onPicked: (item) => Navigator.of(context).pop(item),
      ),
    );
  }

  void _clear() {
    if (_selected == null) return;
    setState(() => _selected = null);
    widget.onChanged?.call(null);
  }

  @override
  Widget build(BuildContext context) {
    final a = context.aerosColors;
    final selectedText = _selected != null ? widget.itemAsString(_selected as T) : null;
    final showClear = widget.showClearButton && _selected != null && widget.enabled;
    final height = _size.resolveHeight(context);
    // The clear button is as wide as the field is tall, like the search
    // field's, and sits just before the chevron.
    final chevronSlot = _size.padH + _size.iconSize;

    final field = Stack(
      children: [
        CallbackShortcuts(
          bindings: <ShortcutActivator, VoidCallback>{
            const SingleActivator(LogicalKeyboardKey.arrowDown): _open,
            const SingleActivator(LogicalKeyboardKey.arrowUp): _open,
          },
          child: AerosPressable(
            onPressed: widget.enabled ? _open : null,
            expandHitTarget: false,
            semanticLabel: widget.label,
            builder: (context, state) => AerosFieldFrame(
              key: _frameKey,
              size: _size,
              focused: state.focused,
              enabled: widget.enabled,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      selectedText ?? widget.hint ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: _size.valueStyle(color: selectedText != null ? a.fgPrimary : a.fgMuted),
                    ),
                  ),
                  SizedBox(width: showClear ? height : _size.gap),
                  Icon(Icons.keyboard_arrow_down, size: _size.iconSize, color: a.fgMuted),
                ],
              ),
            ),
          ),
        ),
        if (showClear)
          PositionedDirectional(
            end: chevronSlot,
            top: 0,
            bottom: 0,
            child: AerosPressable(
              onPressed: _clear,
              semanticLabel: 'Clear',
              excludeSemantics: true,
              // Inside the field: the field's own height is the target.
              expandHitTarget: false,
              builder: (context, state) => SizedBox(
                width: height,
                child: Center(
                  child: Icon(
                    Icons.close,
                    size: _size.iconSize,
                    color: state.hovered || state.pressed || state.focused ? a.fgPrimary : a.fgMuted,
                  ),
                ),
              ),
            ),
          ),
      ],
    );

    if (widget.label == null) return field;
    return AerosFormField(
      label: widget.label,
      required: widget.required,
      labelGap: AerosSpacing.s1_5,
      child: field,
    );
  }
}

/// The search box and the list of options, shared by the three presentations.
class _PopupBody<T> extends StatefulWidget {
  const _PopupBody({
    required this.showSearchBox,
    required this.searchHint,
    required this.emptyText,
    required this.items,
    required this.onFind,
    required this.itemAsString,
    required this.itemBuilder,
    required this.selected,
    required this.inMenu,
    required this.onPicked,
  });

  final bool showSearchBox;
  final String searchHint;
  final String emptyText;
  final List<T>? items;
  final AerosDropdownOnFind<T>? onFind;
  final AerosDropdownItemAsString<T> itemAsString;
  final AerosDropdownItemBuilder<T>? itemBuilder;
  final T? selected;

  /// On the menu surface (tight padding) rather than in a dialog or a sheet.
  final bool inMenu;
  final ValueChanged<T> onPicked;

  @override
  State<_PopupBody<T>> createState() => _PopupBodyState<T>();
}

class _PopupBodyState<T> extends State<_PopupBody<T>> {
  late List<T> _filtered;
  bool _loading = false;
  Timer? _debounce;
  int? _highlight;
  final TextEditingController _query = TextEditingController();
  final Map<int, GlobalKey> _keys = <int, GlobalKey>{};

  @override
  void initState() {
    super.initState();
    _filtered = widget.items ?? const [];
    final selected = widget.selected;
    if (selected != null) {
      final index = _filtered.indexOf(selected);
      if (index >= 0) {
        _highlight = index;
        WidgetsBinding.instance.addPostFrameCallback((_) => _reveal(centre: true));
      }
    }
    if (widget.onFind != null) {
      _runFind('');
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _query.dispose();
    super.dispose();
  }

  void _onQueryChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), () {
      if (widget.onFind != null) {
        _runFind(value);
      } else {
        _localFilter(value);
      }
    });
  }

  void _localFilter(String value) {
    final all = widget.items ?? const [];
    if (value.isEmpty) {
      setState(() {
        _filtered = all;
        _highlight = null;
      });
      return;
    }
    final lower = value.toLowerCase();
    setState(() {
      _filtered = all.where((it) => widget.itemAsString(it).toLowerCase().contains(lower)).toList();
      _highlight = _filtered.isEmpty ? null : 0;
    });
  }

  Future<void> _runFind(String value) async {
    setState(() => _loading = true);
    try {
      final results = await widget.onFind!.call(value);
      if (!mounted) return;
      setState(() {
        _filtered = results;
        _highlight = null;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  void _move(int step) {
    final count = _filtered.length;
    if (count == 0 || _loading) return;
    final from = _highlight ?? (step > 0 ? -1 : count);
    setState(() => _highlight = (from + step) % count);
    WidgetsBinding.instance.addPostFrameCallback((_) => _reveal());
  }

  void _reveal({bool centre = false}) {
    final target = _keys[_highlight]?.currentContext;
    if (target == null) return;
    if (centre) {
      Scrollable.ensureVisible(target, alignment: 0.5);
      return;
    }
    Scrollable.ensureVisible(target, alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtEnd);
    Scrollable.ensureVisible(target, alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtStart);
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is KeyUpEvent) return KeyEventResult.ignored;
    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.arrowDown) {
      _move(1);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowUp) {
      _move(-1);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.enter || key == LogicalKeyboardKey.numpadEnter) {
      final index = _highlight;
      if (index != null && index < _filtered.length && !_loading) widget.onPicked(_filtered[index]);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  Widget _message(Widget child) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: AerosSpacing.s3, vertical: AerosSpacing.s10),
        child: Center(child: child),
      );

  @override
  Widget build(BuildContext context) {
    final a = context.aerosColors;
    // In a dialog or a sheet the rows' text lines up with the title.
    final side = widget.inMenu ? AerosMenu.panelPadding : AerosSpacing.s5 - AerosSpacing.s2;
    final bottom = widget.inMenu ? AerosMenu.panelPadding : AerosSpacing.s3;

    Widget list;
    if (_loading) {
      list = _message(
        SizedBox.square(
          dimension: AerosSizeTokens.iconLg,
          child: CircularProgressIndicator(strokeWidth: AerosMetricTokens.borderThick, color: a.fgMuted),
        ),
      );
    } else if (_filtered.isEmpty) {
      list = _message(Text(widget.emptyText, style: AerosTypography.bodySm(color: a.fgMuted)));
    } else {
      final builder = widget.itemBuilder;
      list = SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: side),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < _filtered.length; i++)
              AerosMenuRow(
                key: _keys.putIfAbsent(i, GlobalKey.new),
                label: builder == null ? widget.itemAsString(_filtered[i]) : null,
                mark: builder == null ? AerosMenuRowMark.selection : AerosMenuRowMark.none,
                checked: _filtered[i] == widget.selected,
                highlighted: i == _highlight,
                onTap: () => widget.onPicked(_filtered[i]),
                onHighlight: () {
                  if (_highlight != i) setState(() => _highlight = i);
                },
                child: builder?.call(context, _filtered[i], _filtered[i] == widget.selected),
              ),
          ],
        ),
      );
      if (builder == null) {
        // Rows are all one height: cut the viewport at a whole row.
        list = AerosWholeRows(rowHeight: AerosMenuRow.heightOf(context), child: list);
      }
      // Outside the scroll view, so the padding stays at both ends of a
      // scrolled list (as in AerosMenu).
      list = Padding(
        padding: EdgeInsets.only(top: AerosMenu.panelPadding, bottom: bottom),
        child: list,
      );
    }

    return Focus(
      autofocus: !widget.showSearchBox,
      onKeyEvent: _onKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.showSearchBox)
            Padding(
              padding: widget.inMenu
                  ? const EdgeInsets.all(AerosSpacing.s2)
                  : const EdgeInsets.fromLTRB(AerosSpacing.s5, AerosSpacing.s0, AerosSpacing.s5, AerosSpacing.s2),
              child: AerosSearchField(
                controller: _query,
                autofocus: true,
                hint: widget.searchHint,
                onChanged: _onQueryChanged,
                size: widget.inMenu ? AerosControlSize.sm : AerosControlSize.md,
              ),
            ),
          if (widget.showSearchBox && widget.inMenu)
            Container(height: AerosMetricTokens.borderHairline, color: a.borderDefault),
          Flexible(child: list),
        ],
      ),
    );
  }
}
