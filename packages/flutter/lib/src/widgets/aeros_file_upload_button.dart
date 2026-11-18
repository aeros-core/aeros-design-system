import 'package:flutter/material.dart';
import '../foundation/aeros_control_size.dart';
import '../foundation/aeros_focus_ring.dart';
import '../foundation/aeros_pressable.dart';
import '../foundation/aeros_state_layer.dart';
import '../foundation/aeros_surface.dart';
import '../theme/aeros_theme_extension.dart';
import '../tokens/aeros_theme_tokens.g.dart';
import '../tokens/spacing.dart';
import '../tokens/typography.dart';
import 'aeros_attribute_models.dart';
import 'aeros_button.dart';
import 'aeros_form_field.dart';

/// Trigger button for an artwork / asset upload.
///
/// The design system does NOT manage uploads itself — it delegates to the
/// host app. [onPickFile] is called when the buyer taps "Choose file" and
/// must return a populated [AerosFileRef] (or `null` if they cancelled).
/// The host typically opens a platform file picker, uploads the bytes via
/// the backend `Asset` API, then resolves to the asset id.
///
/// While [onPickFile] is awaited the button shows a spinner.
class AerosFileUploadButton extends StatefulWidget {
  const AerosFileUploadButton({
    super.key,
    required this.value,
    required this.onPickFile,
    this.onRemove,
    this.label,
    this.hint = 'Upload artwork',
    this.acceptHint = 'PDF, AI, PNG, JPG up to 10 MB',
    this.required = false,
    this.enabled = true,
    this.errorText,
  });

  /// Currently attached file (if any). Pass `null` for the empty state.
  final AerosFileRef? value;

  /// Callback that opens the host's file picker / uploader. Returns the
  /// resolved asset reference, or `null` if cancelled.
  final Future<AerosFileRef?> Function() onPickFile;

  final VoidCallback? onRemove;

  final String? label;
  final String hint;
  final String acceptHint;
  final bool required;
  final bool enabled;
  final String? errorText;

  @override
  State<AerosFileUploadButton> createState() => _AerosFileUploadButtonState();
}

class _AerosFileUploadButtonState extends State<AerosFileUploadButton> {
  bool _busy = false;

  Future<void> _pick() async {
    if (!widget.enabled || _busy) return;
    setState(() => _busy = true);
    try {
      await widget.onPickFile();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(0)} KB';
    return '${(bytes / 1024 / 1024).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    final a = context.aerosColors;
    final semantic = context.aerosSemantic;
    final hasError = widget.errorText != null && widget.errorText!.isNotEmpty;
    final file = widget.value;

    final Widget body;
    if (file != null) {
      body = _AttachedFile(
        file: file,
        formatBytes: _formatBytes,
        onReplace: widget.enabled ? _pick : null,
        onRemove: widget.enabled ? widget.onRemove : null,
        busy: _busy,
      );
    } else {
      body = AerosPressable(
        onPressed: widget.enabled && !_busy ? _pick : null,
        // A drop zone is far larger than the minimum target.
        expandHitTarget: false,
        builder: (context, state) => AerosFocusRing(
          focused: state.focused,
          radius: _radius,
          tone: hasError ? AerosFocusRingTone.danger : AerosFocusRingTone.neutral,
          child: CustomPaint(
            painter: _DashedOutlinePainter(
              color: hasError
                  ? semantic.danger
                  : state.hovered || state.pressed
                      ? a.fgMuted
                      : a.borderStrong,
            ),
            child: AnimatedContainer(
              duration: AerosStateLayer.duration(context),
              curve: AerosStateLayer.curve,
              decoration: BoxDecoration(
                color: AerosStateLayer.resolve(
                  a,
                  Colors.transparent,
                  hovered: state.hovered,
                  pressed: state.pressed,
                ),
                borderRadius: _radius,
              ),
              padding: const EdgeInsets.symmetric(horizontal: AerosSpacing.s4, vertical: AerosSpacing.s5),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox.square(
                    dimension: AerosSizeTokens.iconLg,
                    child: _busy
                        ? CircularProgressIndicator(strokeWidth: AerosMetricTokens.borderThick, color: a.fgPrimary)
                        : Icon(Icons.cloud_upload_outlined, size: AerosSizeTokens.iconLg, color: a.fgMuted),
                  ),
                  const SizedBox(height: AerosSpacing.s2),
                  Text(widget.hint, textAlign: TextAlign.center, style: AerosTypography.labelSm(color: a.fgPrimary)),
                  const SizedBox(height: AerosSpacing.s0_5),
                  Text(
                    widget.acceptHint,
                    textAlign: TextAlign.center,
                    style: AerosTypography.caption(color: a.fgMuted),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return AerosFormField(
      label: widget.label,
      required: widget.required,
      errorText: widget.errorText,
      labelGap: AerosSpacing.s1_5,
      child: widget.enabled ? body : Opacity(opacity: AerosMetricTokens.opacityDisabled, child: body),
    );
  }
}

class _AttachedFile extends StatelessWidget {
  const _AttachedFile({
    required this.file,
    required this.formatBytes,
    required this.onReplace,
    required this.onRemove,
    required this.busy,
  });

  final AerosFileRef file;
  final String Function(int) formatBytes;
  final VoidCallback? onReplace;
  final VoidCallback? onRemove;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final a = context.aerosColors;
    return AerosSurface(
      padding: const EdgeInsetsDirectional.fromSTEB(AerosSpacing.s3, AerosSpacing.s2, AerosSpacing.s2, AerosSpacing.s2),
      child: Row(
        children: [
          Icon(Icons.description_outlined, size: AerosSizeTokens.iconLg, color: a.fgMuted),
          const SizedBox(width: AerosSpacing.s3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  file.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AerosTypography.labelSm(color: a.fgPrimary),
                ),
                if (file.sizeBytes != null)
                  Text(formatBytes(file.sizeBytes!), style: AerosTypography.caption(color: a.fgMuted)),
              ],
            ),
          ),
          if (onReplace != null) ...[
            const SizedBox(width: AerosSpacing.s2),
            AerosButton(
              label: 'Replace',
              variant: AerosButtonVariant.ghost,
              size: AerosControlSize.sm,
              loading: busy,
              onPressed: onReplace,
            ),
          ],
          if (onRemove != null)
            AerosButton.icon(
              icon: const Icon(Icons.close),
              semanticLabel: 'Remove',
              size: AerosControlSize.sm,
              onPressed: busy ? null : onRemove,
            ),
        ],
      ),
    );
  }
}

const BorderRadius _radius = BorderRadius.all(Radius.circular(AerosShapeTokens.surface));

/// The dashed hairline of the empty drop zone — the same dash as
/// [AerosEmptyState].
class _DashedOutlinePainter extends CustomPainter {
  const _DashedOutlinePainter({required this.color});

  final Color color;

  static const double _width = AerosMetricTokens.borderHairline;
  static const double _dash = AerosSpacing.s1;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = (Offset.zero & size).deflate(_width / 2);
    final outline = Path()..addRRect(_radius.toRRect(rect));
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = _width
      ..color = color;
    for (final metric in outline.computeMetrics()) {
      for (var at = 0.0; at < metric.length; at += _dash * 2) {
        canvas.drawPath(metric.extractPath(at, at + _dash), paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DashedOutlinePainter old) => old.color != color;
}
