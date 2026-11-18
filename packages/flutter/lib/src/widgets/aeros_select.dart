import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../foundation/aeros_control_size.dart';
import '../foundation/aeros_field_frame.dart';
import '../foundation/aeros_pressable.dart';
import '../theme/aeros_theme_extension.dart';
import '../tokens/spacing.dart';
import 'aeros_form_field.dart';
import 'aeros_menu.dart';
import 'aeros_popover.dart';

/// One option of an [AerosSelect].
@immutable
class AerosSelectItem<T> {
  const AerosSelectItem({
    required this.value,
    required this.label,
    this.leading,
    this.detail,
    this.enabled = true,
  });

  final T value;
  final String label;

  /// Usually an [Icon]; shown in the list, sized and coloured by the row.
  final Widget? leading;

  /// Muted text at the end of the row — why an option is unavailable, say.
  final String? detail;
  final bool enabled;
}

/// Picks one option from a list.
///
/// The trigger is a field ([AerosFieldFrame] at [size]) showing the chosen
/// option's label or the [placeholder]; it opens a list of the options on an
/// overlay surface, the chosen one checked. Enter, Space or an arrow key open
/// it from the keyboard; arrows move, Enter chooses, Escape closes.
///
/// ```dart
/// AerosSelect<String>(
///   label: 'Material',
///   placeholder: 'Select…',
///   value: material,
///   items: const [
///     AerosSelectItem(value: 'kraft', label: 'Kraft'),
///     AerosSelectItem(value: 'white', label: 'White board'),
///   ],
///   onChanged: (value) => setState(() => material = value),
/// )
/// ```
class AerosSelect<T> extends StatefulWidget {
  const AerosSelect({
    super.key,
    required this.items,
    required this.value,
    required this.onChanged,
    this.placeholder,
    this.label,
    this.helper,
    this.error,
    this.enabled = true,
    this.required = false,
    this.size = AerosControlSize.md,
    this.semanticLabel,
  });

  final List<AerosSelectItem<T>> items;

  /// The chosen option's value; null (or a value no item has) shows the
  /// [placeholder].
  final T? value;

  /// Null disables the select.
  final ValueChanged<T>? onChanged;
  final String? placeholder;
  final String? label;

  /// Help text under the field. Hidden while there is an [error].
  final String? helper;

  /// Turns the border and the focus ring to the danger colour and shows this
  /// message under the field.
  final String? error;
  final bool enabled;

  /// Adds the required mark to the [label].
  final bool required;
  final AerosControlSize size;

  /// Announced with the value when there is no [label].
  final String? semanticLabel;

  /// Opens the list of [items] anchored to [context]'s render box — for a
  /// trigger that is not an [AerosSelect] (a unit picker inside another
  /// field). Completes with the chosen value, or null when dismissed.
  static Future<T?> showOptions<T>(
    BuildContext context, {
    required List<AerosSelectItem<T>> items,
    required T? value,
    Rect? anchorRect,
    bool matchAnchorWidth = true,
    AerosPopoverAlign align = AerosPopoverAlign.start,
    String? semanticLabel,
  }) async {
    final entries = <AerosMenuEntry>[
      for (final item in items)
        AerosMenuRadioItem<T>(
          label: item.label,
          value: item.value,
          groupValue: value,
          leading: item.leading,
          detail: item.detail,
          enabled: item.enabled,
          onChanged: (_) {},
        ),
    ];
    final selected = items.indexWhere((item) => item.value == value);
    final chosen = await AerosPopover.show<AerosMenuEntry>(
      context,
      anchorRect: anchorRect,
      align: align,
      matchAnchorWidth: matchAnchorWidth,
      padding: EdgeInsets.zero,
      constraints: matchAnchorWidth ? null : const BoxConstraints(maxWidth: AerosMenu.maxWidth),
      semanticLabel: semanticLabel,
      builder: (context) => AerosMenuList(
        entries: entries,
        selection: true,
        initialHighlight: selected < 0 ? null : selected,
        onChosen: (entry) => Navigator.of(context).pop(entry),
      ),
    );
    return chosen is AerosMenuRadioItem<T> ? chosen.value : null;
  }

  @override
  State<AerosSelect<T>> createState() => _AerosSelectState<T>();
}

class _AerosSelectState<T> extends State<AerosSelect<T>> {
  final GlobalKey _frameKey = GlobalKey(debugLabel: 'AerosSelect frame');
  bool _open = false;

  bool get _enabled => widget.enabled && widget.onChanged != null;

  AerosSelectItem<T>? get _selected {
    final value = widget.value;
    if (value == null) return null;
    for (final item in widget.items) {
      if (item.value == value) return item;
    }
    return null;
  }

  Future<void> _show() async {
    if (!_enabled || _open) return;
    setState(() => _open = true);
    // Anchored to the frame, so the list lines up with the field and not with
    // the label above it.
    final chosen = await AerosSelect.showOptions<T>(
      _frameKey.currentContext!,
      items: widget.items,
      value: widget.value,
      semanticLabel: widget.semanticLabel ?? widget.label,
    );
    if (!mounted) return;
    setState(() => _open = false);
    if (chosen != null && chosen != widget.value) widget.onChanged?.call(chosen);
  }

  @override
  Widget build(BuildContext context) {
    final a = context.aerosColors;
    final size = widget.size;
    final selected = _selected;
    final hasError = widget.error != null && widget.error!.isNotEmpty;

    final field = CallbackShortcuts(
      bindings: <ShortcutActivator, VoidCallback>{
        const SingleActivator(LogicalKeyboardKey.arrowDown): _show,
        const SingleActivator(LogicalKeyboardKey.arrowUp): _show,
      },
      child: AerosPressable(
        onPressed: _enabled ? _show : null,
        // A field is its own full-size target and keeps the size it was given.
        expandHitTarget: false,
        semanticLabel: widget.semanticLabel ?? widget.label,
        builder: (context, state) => AerosFieldFrame(
          key: _frameKey,
          size: size,
          focused: state.focused || _open,
          hasError: hasError,
          enabled: _enabled,
          child: Row(
            children: [
              Expanded(
                child: Text(
                  selected?.label ?? widget.placeholder ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: size.valueStyle(color: selected == null ? a.fgMuted : a.fgPrimary),
                ),
              ),
              SizedBox(width: size.gap),
              Icon(Icons.keyboard_arrow_down, size: size.iconSize, color: a.fgMuted),
            ],
          ),
        ),
      ),
    );

    if (widget.label == null && widget.helper == null && !hasError) return field;
    return AerosFormField(
      label: widget.label,
      required: widget.required,
      helperText: widget.helper,
      errorText: widget.error,
      labelGap: AerosSpacing.s1_5,
      child: field,
    );
  }
}
