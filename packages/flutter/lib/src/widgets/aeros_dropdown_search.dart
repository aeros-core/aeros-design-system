import 'dart:async';

import 'package:flutter/material.dart';
import '../theme/aeros_theme_extension.dart';
import '../tokens/colors.dart';
import '../tokens/radii.dart';
import '../tokens/spacing.dart';
import '../tokens/typography.dart';

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
/// API parity with the legacy `DropdownSearch` widget in aeros-admin, restyled
/// onto Aeros tokens. Pass either a static [items] list or an async [onFind].
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
  T? _selected;

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
    T? picked;
    switch (widget.mode) {
      case AerosDropdownMode.dialog:
        picked = await _openDialog();
        break;
      case AerosDropdownMode.sheet:
        picked = await _openSheet();
        break;
      case AerosDropdownMode.menu:
        picked = await _openMenu();
        break;
    }
    if (picked != null && picked != _selected) {
      setState(() => _selected = picked);
      widget.onChanged?.call(picked);
    }
  }

  Future<T?> _openDialog() {
    return showDialog<T>(
      context: context,
      builder: (ctx) {
        final a = ctx.aerosColors;
        final width =
            widget.dialogMaxWidth ?? MediaQuery.of(ctx).size.width * 0.7;
        final height =
            widget.maxHeight ?? MediaQuery.of(ctx).size.height * 0.6;
        return Dialog(
          backgroundColor: a.bgSurface,
          shape: RoundedRectangleBorder(borderRadius: AerosRadii.brLg),
          child: SizedBox(
            width: width,
            height: height,
            child: _PopupBody<T>(
              title: widget.popupTitle ?? widget.label,
              showSearchBox: widget.showSearchBox,
              searchHint: widget.searchHint,
              emptyText: widget.emptyText,
              items: widget.items,
              onFind: widget.onFind,
              itemAsString: widget.itemAsString,
              itemBuilder: widget.itemBuilder,
              selected: _selected,
            ),
          ),
        );
      },
    );
  }

  Future<T?> _openSheet() {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final a = ctx.aerosColors;
        final height =
            widget.maxHeight ?? MediaQuery.of(ctx).size.height * 0.7;
        return Container(
          height: height,
          decoration: BoxDecoration(
            color: a.bgSurface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(AerosRadii.lg)),
          ),
          child: _PopupBody<T>(
            title: widget.popupTitle ?? widget.label,
            showSearchBox: widget.showSearchBox,
            searchHint: widget.searchHint,
            emptyText: widget.emptyText,
            items: widget.items,
            onFind: widget.onFind,
            itemAsString: widget.itemAsString,
            itemBuilder: widget.itemBuilder,
            selected: _selected,
          ),
        );
      },
    );
  }

  Future<T?> _openMenu() async {
    final renderBox = context.findRenderObject() as RenderBox?;
    final overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox?;
    if (renderBox == null || overlay == null) return null;

    final position = RelativeRect.fromRect(
      Rect.fromPoints(
        renderBox.localToGlobal(renderBox.size.bottomLeft(Offset.zero),
            ancestor: overlay),
        renderBox.localToGlobal(renderBox.size.bottomRight(Offset.zero),
            ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );

    final a = context.aerosColors;
    final menuItems = widget.items ?? const [];
    return showMenu<T>(
      context: context,
      position: position,
      color: a.bgSurface,
      shape: RoundedRectangleBorder(borderRadius: AerosRadii.brMd),
      constraints: BoxConstraints(
        maxHeight: widget.maxHeight ?? 320,
        minWidth: renderBox.size.width,
        maxWidth: renderBox.size.width,
      ),
      items: [
        for (final item in menuItems)
          PopupMenuItem<T>(
            value: item,
            child: Text(
              widget.itemAsString(item),
              style: AerosTypography.bodyMd(color: a.fgPrimary),
            ),
          ),
      ],
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
    final selectedText =
        _selected != null ? widget.itemAsString(_selected as T) : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          RichText(
            text: TextSpan(
              text: widget.label!,
              style: AerosTypography.bodySm(color: a.fgSecondary)
                  .copyWith(fontWeight: FontWeight.w600),
              children: [
                if (widget.required)
                  const TextSpan(
                      text: ' *',
                      style: TextStyle(color: AerosColors.danger)),
              ],
            ),
          ),
          const SizedBox(height: AerosSpacing.s2),
        ],
        InkWell(
          onTap: _open,
          borderRadius: AerosRadii.brMd,
          child: Container(
            padding: const EdgeInsets.symmetric(
                horizontal: AerosSpacing.s3, vertical: AerosSpacing.s3),
            decoration: BoxDecoration(
              borderRadius: AerosRadii.brMd,
              border: Border.all(color: a.borderDefault),
              color: widget.enabled ? a.bgSurface : a.bgSubtle,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    selectedText ?? widget.hint ?? '',
                    style: AerosTypography.bodyMd(
                      color: selectedText != null ? a.fgPrimary : a.fgMuted,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (widget.showClearButton && _selected != null)
                  InkWell(
                    onTap: _clear,
                    borderRadius: AerosRadii.brSm,
                    child: Padding(
                      padding: const EdgeInsets.all(AerosSpacing.s1),
                      child: Icon(Icons.close, size: 16, color: a.fgMuted),
                    ),
                  ),
                Icon(Icons.keyboard_arrow_down, size: 18, color: a.fgMuted),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _PopupBody<T> extends StatefulWidget {
  const _PopupBody({
    required this.title,
    required this.showSearchBox,
    required this.searchHint,
    required this.emptyText,
    required this.items,
    required this.onFind,
    required this.itemAsString,
    required this.itemBuilder,
    required this.selected,
  });

  final String? title;
  final bool showSearchBox;
  final String searchHint;
  final String emptyText;
  final List<T>? items;
  final AerosDropdownOnFind<T>? onFind;
  final AerosDropdownItemAsString<T> itemAsString;
  final AerosDropdownItemBuilder<T>? itemBuilder;
  final T? selected;

  @override
  State<_PopupBody<T>> createState() => _PopupBodyState<T>();
}

class _PopupBodyState<T> extends State<_PopupBody<T>> {
  late List<T> _filtered;
  bool _loading = false;
  Timer? _debounce;
  final TextEditingController _query = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filtered = widget.items ?? const [];
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
      setState(() => _filtered = all);
      return;
    }
    final lower = value.toLowerCase();
    setState(() {
      _filtered = all
          .where((it) => widget.itemAsString(it).toLowerCase().contains(lower))
          .toList();
    });
  }

  Future<void> _runFind(String value) async {
    setState(() => _loading = true);
    try {
      final results = await widget.onFind!.call(value);
      if (!mounted) return;
      setState(() {
        _filtered = results;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final a = context.aerosColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.title != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AerosSpacing.s4, AerosSpacing.s4, AerosSpacing.s4, AerosSpacing.s2),
            child: Text(widget.title!,
                style: AerosTypography.h4(color: a.fgPrimary)),
          ),
        if (widget.showSearchBox)
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AerosSpacing.s4, AerosSpacing.s2, AerosSpacing.s4, AerosSpacing.s3),
            child: TextField(
              controller: _query,
              autofocus: true,
              onChanged: _onQueryChanged,
              style: AerosTypography.bodyMd(color: a.fgPrimary),
              decoration: InputDecoration(
                hintText: widget.searchHint,
                prefixIcon: Icon(Icons.search, size: 18, color: a.fgMuted),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: AerosSpacing.s3, vertical: AerosSpacing.s2),
                border: OutlineInputBorder(
                  borderRadius: AerosRadii.brMd,
                  borderSide: BorderSide(color: a.borderDefault),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: AerosRadii.brMd,
                  borderSide: BorderSide(color: a.borderDefault),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: AerosRadii.brMd,
                  borderSide: BorderSide(color: a.borderFocus),
                ),
              ),
            ),
          ),
        Divider(height: 1, color: a.borderDefault),
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _filtered.isEmpty
                  ? Center(
                      child: Text(widget.emptyText,
                          style: AerosTypography.bodyMd(color: a.fgMuted)),
                    )
                  : ListView.builder(
                      itemCount: _filtered.length,
                      itemBuilder: (ctx, i) {
                        final item = _filtered[i];
                        final isSelected = item == widget.selected;
                        if (widget.itemBuilder != null) {
                          return InkWell(
                            onTap: () => Navigator.of(ctx).pop(item),
                            child: widget.itemBuilder!(ctx, item, isSelected),
                          );
                        }
                        return InkWell(
                          onTap: () => Navigator.of(ctx).pop(item),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: AerosSpacing.s4,
                                vertical: AerosSpacing.s3),
                            color: isSelected
                                ? a.brandPrimaryMuted
                                : Colors.transparent,
                            child: Text(
                              widget.itemAsString(item),
                              style: AerosTypography.bodyMd(color: a.fgPrimary)
                                  .copyWith(
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }
}
