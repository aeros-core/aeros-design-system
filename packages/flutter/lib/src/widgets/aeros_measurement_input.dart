import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../foundation/aeros_control_size.dart';
import '../foundation/aeros_field_frame.dart';
import '../foundation/aeros_pressable.dart';
import '../theme/aeros_theme_extension.dart';
import '../tokens/spacing.dart';
import 'aeros_attribute_models.dart';
import 'aeros_form_field.dart';
import 'aeros_popover.dart';
import 'aeros_select.dart';

/// Number-with-unit input for a MEASUREMENT attribute.
///
/// One field ([AerosFieldFrame]) holding the number and, at its end, the
/// unit: a button that opens the list of units when there is more than one.
/// A disabled input dims as a whole. Use this when the buyer
/// needs free-form numeric entry inside an allowed range. For discrete
/// values, prefer [AerosEnumChips]; for continuous selection along a track,
/// prefer [AerosRangeSlider].
class AerosMeasurementInput extends StatefulWidget {
  const AerosMeasurementInput({
    super.key,
    required this.units,
    required this.numericValue,
    required this.unitCode,
    required this.onChanged,
    this.label,
    this.hint,
    this.helperText,
    this.required = false,
    this.enabled = true,
    this.range,
    this.errorText,
    this.size = AerosControlSize.md,
  });

  final List<AerosMeasurementUnit> units;
  final num? numericValue;
  final String? unitCode;
  final void Function(num? value, String? unitCode) onChanged;

  final String? label;
  final String? hint;
  final String? helperText;
  final bool required;
  final bool enabled;
  final AerosNumericRange? range;
  final String? errorText;

  /// Control size — the same ladder as [AerosTextField].
  final AerosControlSize size;

  @override
  State<AerosMeasurementInput> createState() => _AerosMeasurementInputState();
}

class _AerosMeasurementInputState extends State<AerosMeasurementInput> {
  late final TextEditingController _controller;
  final FocusNode _focus = FocusNode(debugLabel: 'AerosMeasurementInput');
  final FocusNode _unitFocus = FocusNode(debugLabel: 'AerosMeasurementInput unit');
  final GlobalKey _frameKey = GlobalKey(debugLabel: 'AerosMeasurementInput frame');
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.numericValue?.toString() ?? '',
    );
    _focus.addListener(_onFocus);
  }

  void _onFocus() {
    if (_focus.hasFocus != _focused) setState(() => _focused = _focus.hasFocus);
  }

  @override
  void didUpdateWidget(covariant AerosMeasurementInput old) {
    super.didUpdateWidget(old);
    final newText = widget.numericValue?.toString() ?? '';
    if (_controller.text != newText &&
        widget.numericValue != _parse(_controller.text)) {
      _controller.text = newText;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    _unitFocus.dispose();
    super.dispose();
  }

  num? _parse(String raw) {
    if (raw.trim().isEmpty) return null;
    return num.tryParse(raw.trim());
  }

  void _emit(String raw) {
    widget.onChanged(_parse(raw), widget.unitCode);
  }

  String? get _unitLabel {
    for (final unit in widget.units) {
      if (unit.code == widget.unitCode) return unit.label;
    }
    return widget.unitCode;
  }

  Future<void> _pickUnit() async {
    final frame = _frameKey.currentContext!;
    final code = await AerosSelect.showOptions<String>(
      // From the unit button, so focus comes back to it.
      _unitFocus.context ?? context,
      // Lined up with the end of the field, under it.
      anchorRect: AerosPopover.anchorRectOf(frame),
      align: AerosPopoverAlign.end,
      matchAnchorWidth: false,
      value: widget.unitCode,
      semanticLabel: 'Unit',
      items: [for (final unit in widget.units) AerosSelectItem<String>(value: unit.code, label: unit.label)],
    );
    if (code != null && code != widget.unitCode) widget.onChanged(widget.numericValue, code);
  }

  @override
  Widget build(BuildContext context) {
    final a = context.aerosColors;
    final size = widget.size;
    final hasError = widget.errorText != null && widget.errorText!.isNotEmpty;
    final range = widget.range;
    final helper = widget.helperText ??
        (range == null
            ? null
            : 'Allowed: ${range.min}–${range.max}'
                '${widget.unitCode != null ? ' ${widget.unitCode}' : ''}');
    final unitLabel = _unitLabel;
    final choosable = widget.units.length > 1;

    Widget? unit;
    if (widget.units.isNotEmpty && unitLabel != null) {
      Widget label(Color color) => Text(unitLabel, maxLines: 1, style: size.valueStyle(color: color));
      unit = !choosable
          ? label(a.fgSecondary)
          : AerosPressable(
              onPressed: widget.enabled ? _pickUnit : null,
              focusNode: _unitFocus,
              // Inside the field: the field's own height is the target.
              expandHitTarget: false,
              semanticLabel: 'Unit',
              builder: (context, state) => Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  label(state.hovered || state.pressed || state.focused ? a.fgPrimary : a.fgSecondary),
                  Icon(Icons.keyboard_arrow_down, size: size.iconSize, color: a.fgMuted),
                ],
              ),
            );
    }

    final field = AerosFieldFrame(
      key: _frameKey,
      size: size,
      focused: _focused,
      hasError: hasError,
      enabled: widget.enabled,
      onTap: _focus.requestFocus,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _focus,
              enabled: widget.enabled,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
              ],
              onChanged: _emit,
              style: size.valueStyle(color: a.fgPrimary),
              cursorColor: a.fgPrimary,
              decoration: AerosFieldFrame.bareDecoration(
                hintText: widget.hint,
                hintStyle: size.valueStyle(color: a.fgMuted),
              ),
            ),
          ),
          if (unit != null) ...[
            SizedBox(width: size.gap),
            unit,
          ],
        ],
      ),
    );

    return AerosFormField(
      label: widget.label,
      required: widget.required,
      errorText: widget.errorText,
      helperText: helper,
      labelGap: AerosSpacing.s1_5,
      child: field,
    );
  }
}
