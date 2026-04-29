import 'package:flutter/material.dart';
import '../theme/aeros_theme_extension.dart';
import '../tokens/colors.dart';
import '../tokens/radii.dart';
import '../tokens/spacing.dart';
import '../tokens/typography.dart';
import 'aeros_attribute_models.dart';

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
    final hasError = widget.errorText != null && widget.errorText!.isNotEmpty;
    final borderColor = hasError ? AerosColors.danger : a.borderDefault;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
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
                    style: TextStyle(color: AerosColors.danger),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AerosSpacing.s2),
        ],
        if (widget.value != null)
          _AttachedFile(
            file: widget.value!,
            formatBytes: _formatBytes,
            onReplace: widget.enabled ? _pick : null,
            onRemove: widget.enabled ? widget.onRemove : null,
            busy: _busy,
          )
        else
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.enabled && !_busy ? _pick : null,
              borderRadius: AerosRadii.brLg,
              child: DottedDashedBorder(
                color: borderColor,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AerosSpacing.s4,
                    AerosSpacing.s5,
                    AerosSpacing.s4,
                    AerosSpacing.s5,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _busy
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: a.fgPrimary,
                              ),
                            )
                          : Icon(
                              Icons.cloud_upload_outlined,
                              size: 22,
                              color: a.fgSecondary,
                            ),
                      const SizedBox(height: AerosSpacing.s2),
                      Text(
                        widget.hint,
                        style: AerosTypography.bodyMd(color: a.fgPrimary)
                            .copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.acceptHint,
                        style: AerosTypography.caption(color: a.fgMuted),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        if (hasError) ...[
          const SizedBox(height: AerosSpacing.s1),
          Text(
            widget.errorText!,
            style: AerosTypography.caption(color: AerosColors.dangerText),
          ),
        ],
      ],
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
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AerosSpacing.s3,
        vertical: AerosSpacing.s2,
      ),
      decoration: BoxDecoration(
        color: a.bgSubtle,
        borderRadius: AerosRadii.brMd,
        border: Border.all(color: a.borderDefault),
      ),
      child: Row(
        children: [
          Icon(Icons.description_outlined, size: 22, color: a.fgSecondary),
          const SizedBox(width: AerosSpacing.s3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  file.name,
                  style: AerosTypography.bodyMd(color: a.fgPrimary)
                      .copyWith(fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
                if (file.sizeBytes != null)
                  Text(
                    formatBytes(file.sizeBytes!),
                    style: AerosTypography.caption(color: a.fgMuted),
                  ),
              ],
            ),
          ),
          if (onReplace != null)
            TextButton(
              onPressed: busy ? null : onReplace,
              child: Text(
                'Replace',
                style: AerosTypography.bodySm(color: a.brandPrimary)
                    .copyWith(fontWeight: FontWeight.w600),
              ),
            ),
          if (onRemove != null)
            IconButton(
              onPressed: busy ? null : onRemove,
              tooltip: 'Remove',
              icon: Icon(Icons.close, size: 18, color: a.fgMuted),
            ),
        ],
      ),
    );
  }
}

/// Lightweight dashed-border container used by the empty file-upload state.
class DottedDashedBorder extends StatelessWidget {
  const DottedDashedBorder({super.key, required this.color, required this.child});

  final Color color;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: _DashedBorderDecoration(color: color),
      child: child,
    );
  }
}

class _DashedBorderDecoration extends Decoration {
  const _DashedBorderDecoration({required this.color});
  final Color color;

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) =>
      _DashedBorderPainter(color: color);
}

class _DashedBorderPainter extends BoxPainter {
  _DashedBorderPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final size = configuration.size ?? Size.zero;
    final rect = offset & size;
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(12));
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    const dashWidth = 6.0;
    const dashSpace = 4.0;
    final path = Path()..addRRect(rrect);
    final dashed = Path();
    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final next = distance + dashWidth;
        dashed.addPath(
          metric.extractPath(distance, next.clamp(0, metric.length)),
          Offset.zero,
        );
        distance = next + dashSpace;
      }
    }
    canvas.drawPath(dashed, paint);
  }
}
