import 'package:flutter/material.dart';
import '../theme/aeros_theme_extension.dart';
import '../tokens/colors.dart';
import '../tokens/radii.dart';
import '../tokens/spacing.dart';
import 'aeros_button.dart';
import 'aeros_form_field.dart';

/// Generic add/remove repeater for arrays of form rows.
///
/// Caller owns the model list and passes an [itemBuilder] that renders one
/// row's editor; the widget wraps each row in a card with a trailing remove
/// affordance and renders a single Add button below the list.
///
/// Typical use: heterogeneous box-group editor on the connected-carrier
/// shipment booking form, where each row needs its own count + L/W/H +
/// weight controllers. The caller manages the controllers (e.g. via a
/// `List<RowControllers>` in state) and supplies an [onAdd] / [onRemove]
/// pair that mutates that list.
///
/// The widget delegates count enforcement: pass [minItems] (defaults to 1)
/// to keep at least one row visible — the trailing remove button on the
/// last row is hidden when `items.length <= minItems`. Pass [maxItems] to
/// hide the Add button when the list is at capacity.
class AerosRepeatingRows<T> extends StatelessWidget {
  const AerosRepeatingRows({
    super.key,
    required this.items,
    required this.itemBuilder,
    required this.onAdd,
    required this.addLabel,
    this.onRemove,
    this.minItems = 1,
    this.maxItems = 20,
    this.label,
    this.helperText,
    this.errorText,
    this.required = false,
    this.rowGap = AerosSpacing.s3,
  });

  /// The current list of row models. Length drives how many rows render.
  final List<T> items;

  /// Builds the editor for one row. Receives the row's index, the model,
  /// and a `onRemove` callback that should be wired to a button inside the
  /// row when [onRemove] (top-level) is null. When the top-level [onRemove]
  /// is supplied, the widget owns the trash icon and you don't need to
  /// render one inside [itemBuilder].
  final Widget Function(BuildContext context, int index, T item) itemBuilder;

  /// Add a new row. Caller mutates [items] and calls setState (or its
  /// equivalent) to rebuild.
  final VoidCallback onAdd;

  /// Remove the row at the given index. Defaults to a no-op when null —
  /// pass null only if you don't want a remove affordance at all (rare).
  final void Function(int index)? onRemove;

  /// Add-button label, e.g. "Add another box group".
  final String addLabel;

  /// Hide the trash button on the last remaining row when `items.length <=
  /// minItems`. Defaults to 1 — by convention an empty repeater is invalid.
  final int minItems;

  /// Hide the Add button when `items.length >= maxItems`.
  final int maxItems;

  /// Optional label rendered above the list via [AerosFormField].
  final String? label;

  /// Helper text rendered below the list (suppressed when [errorText] is set).
  final String? helperText;

  /// Error text rendered below the list. When set, suppresses [helperText]
  /// and outlines the list in danger color.
  final String? errorText;

  /// Renders a `*` next to the label when true.
  final bool required;

  /// Vertical gap between rows. Defaults to [AerosSpacing.s3] (12).
  final double rowGap;

  bool get _canRemove => (onRemove != null) && items.length > minItems;
  bool get _canAdd => items.length < maxItems;

  @override
  Widget build(BuildContext context) {
    final a = context.aerosColors;

    final list = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < items.length; i++) ...[
          if (i > 0) SizedBox(height: rowGap),
          _RepeaterRow(
            child: itemBuilder(context, i, items[i]),
            onRemove: _canRemove ? () => onRemove!(i) : null,
            color: a.bgSurface,
            border: a.borderDefault,
          ),
        ],
        if (_canAdd) ...[
          SizedBox(height: rowGap),
          Align(
            alignment: Alignment.centerLeft,
            child: AerosButton.ghost(
              label: addLabel,
              onPressed: onAdd,
              size: AerosButtonSize.sm,
            ),
          ),
        ],
      ],
    );

    if (label == null && helperText == null && errorText == null && !required) {
      return list;
    }
    return AerosFormField(
      label: label,
      helperText: helperText,
      errorText: errorText,
      required: required,
      child: list,
    );
  }
}

class _RepeaterRow extends StatelessWidget {
  const _RepeaterRow({
    required this.child,
    required this.onRemove,
    required this.color,
    required this.border,
  });

  final Widget child;
  final VoidCallback? onRemove;
  final Color color;
  final Color border;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: AerosRadii.brLg,
        border: Border.all(color: border),
      ),
      padding: const EdgeInsets.fromLTRB(
        AerosSpacing.s4,
        AerosSpacing.s3,
        AerosSpacing.s2,
        AerosSpacing.s3,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: child),
          if (onRemove != null) ...[
            const SizedBox(width: AerosSpacing.s2),
            IconButton(
              tooltip: 'Remove',
              splashRadius: 18,
              onPressed: onRemove,
              icon: const Icon(
                Icons.close,
                size: 18,
                color: AerosColors.dangerText,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
