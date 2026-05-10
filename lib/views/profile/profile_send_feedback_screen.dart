import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../services/feedback_service.dart';
import '../../helpers/theme_adaptive.dart';
import 'profile_theme.dart';

class ProfileSendFeedbackScreen extends StatefulWidget {
  const ProfileSendFeedbackScreen({super.key});

  @override
  State<ProfileSendFeedbackScreen> createState() =>
      _ProfileSendFeedbackScreenState();
}

class _ProfileSendFeedbackScreenState extends State<ProfileSendFeedbackScreen> {
  static const _typeSlugs = [
    'bug_report',
    'suggestion',
    'compliment',
    'other',
  ];

  int _stars = 4;
  int _type = 0;
  final _subject = TextEditingController();
  final _body = TextEditingController();

  String? _attachmentPath;
  List<int>? _attachmentBytes;
  String? _attachmentName;
  bool _submitting = false;

  @override
  void dispose() {
    _subject.dispose();
    _body.dispose();
    super.dispose();
  }

  Future<void> _pickAttachment() async {
    final r = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png'],
      withData: kIsWeb,
    );
    if (!mounted) return;
    final file = r?.files.isNotEmpty == true ? r!.files.first : null;
    if (file == null) return;
    final path = file.path;
    if (path != null && path.isNotEmpty) {
      setState(() {
        _attachmentPath = path;
        _attachmentBytes = null;
        _attachmentName =
            file.name.trim().isNotEmpty ? file.name.trim() : path.split('/').last;
      });
      return;
    }
    final bytes = file.bytes;
    final name = file.name.trim();
    if (bytes != null && bytes.isNotEmpty && name.isNotEmpty) {
      setState(() {
        _attachmentPath = null;
        _attachmentBytes = bytes;
        _attachmentName = name;
      });
      return;
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('feedback_file_read_error'.tr)),
      );
    }
  }

  void _clearAttachment() {
    setState(() {
      _attachmentPath = null;
      _attachmentBytes = null;
      _attachmentName = null;
    });
  }

  Future<void> _submit() async {
    if (_submitting) return;
    FocusScope.of(context).unfocus();
    setState(() => _submitting = true);
    final err = await FeedbackService.submit(
      rating: _stars,
      feedbackType: _typeSlugs[_type.clamp(0, _typeSlugs.length - 1)],
      subject: _subject.text,
      description: _body.text,
      attachmentPath: _attachmentPath,
      attachmentBytes: _attachmentBytes,
      attachmentFileName: _attachmentName,
    );
    if (!mounted) return;
    setState(() => _submitting = false);

    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('feedback_sent'.tr)),
    );
    _subject.clear();
    _body.clear();
    _clearAttachment();
    setState(() {
      _stars = 4;
      _type = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final types = [
      'feedback_type_bug'.tr,
      'feedback_type_suggestion'.tr,
      'feedback_type_compliment'.tr,
      'feedback_type_other'.tr,
    ];
    return Scaffold(
      backgroundColor: ThemeAdaptive.pageBackground(context),
      appBar: AppBar(
        backgroundColor: ProfileTheme.headerOrange,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text('profile_send_feedback'.tr),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'feedback_experience'.tr,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: scheme.onSurface,
            ),
          ),
          Text(
            'feedback_help_improve'.tr,
            style: TextStyle(
              color: scheme.onSurfaceVariant,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (i) {
              return IconButton(
                onPressed: _submitting ? null : () => setState(() => _stars = i + 1),
                icon: Icon(
                  i < _stars ? Icons.star_rounded : Icons.star_outline_rounded,
                  color: ProfileTheme.headerOrange,
                  size: 36,
                ),
              );
            }),
          ),
          Center(
            child: Text(
              '$_stars ${'feedback_out_of_5'.tr}',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: scheme.onSurface,
              ),
            ),
          ),
          const SizedBox(height: 20),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(types.length, (i) {
                final sel = _type == i;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(types[i]),
                    selected: sel,
                    onSelected: _submitting
                        ? null
                        : (_) => setState(() => _type = i),
                    selectedColor: ProfileTheme.headerOrange,
                    backgroundColor: ThemeAdaptive.neutralFill(context),
                    labelStyle: TextStyle(
                      color: sel ? Colors.white : scheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                    side: BorderSide(
                      color: sel ? ProfileTheme.headerOrange : scheme.outlineVariant,
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _subject,
            readOnly: _submitting,
            style: TextStyle(color: scheme.onSurface),
            decoration: _dec(context, 'feedback_subject'.tr),
            textCapitalization: TextCapitalization.sentences,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _body,
            readOnly: _submitting,
            style: TextStyle(color: scheme.onSurface),
            maxLines: 5,
            decoration: _dec(context, 'common_description'.tr),
            textCapitalization: TextCapitalization.sentences,
          ),
          const SizedBox(height: 16),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _submitting ? null : _pickAttachment,
              borderRadius: BorderRadius.circular(14),
              child: Ink(
                height: 100,
                decoration: BoxDecoration(
                  color: scheme.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: ProfileTheme.headerOrange,
                    width: 1.2,
                  ),
                ),
                child: _attachmentName != null
                    ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.attach_file,
                              color: ProfileTheme.headerOrange,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _attachmentName!,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: scheme.onSurface,
                                ),
                              ),
                            ),
                            IconButton(
                              tooltip: 'common_remove'.tr,
                              onPressed: _submitting ? null : _clearAttachment,
                              icon: Icon(Icons.close, color: scheme.onSurfaceVariant),
                            ),
                          ],
                        ),
                      )
                    : DottedBorderPlaceholder(),
              ),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton(
              onPressed: _submitting ? null : _submit,
              style: FilledButton.styleFrom(
                backgroundColor: ProfileTheme.headerOrange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: _submitting
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : Text('feedback_submit'.tr),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _dec(BuildContext context, String hint) {
    final scheme = Theme.of(context).colorScheme;
    return InputDecoration(
      filled: true,
      fillColor: scheme.surfaceContainerHighest,
      hintText: hint,
      hintStyle: TextStyle(color: scheme.onSurfaceVariant),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: scheme.outlineVariant),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: scheme.outlineVariant),
      ),
    );
  }
}

class DottedBorderPlaceholder extends StatelessWidget {
  const DottedBorderPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return CustomPaint(
      painter: _DashPainter(color: ProfileTheme.headerOrange),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.cloud_upload_outlined, color: ProfileTheme.headerOrange),
          const SizedBox(height: 6),
          Text(
            'feedback_tap_attach'.tr,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: scheme.onSurface,
            ),
          ),
          Text(
            'feedback_attach_note'.tr,
            style: TextStyle(
              fontSize: 12,
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _DashPainter extends CustomPainter {
  _DashPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final r = RRect.fromRectAndRadius(
      Rect.fromLTWH(1, 1, size.width - 2, size.height - 2),
      const Radius.circular(12),
    );
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    const dash = 5.0;
    const gap = 4.0;
    final path = Path()..addRRect(r);
    for (final metric in path.computeMetrics()) {
      double d = 0;
      while (d < metric.length) {
        final extract = metric.extractPath(d, d + dash);
        canvas.drawPath(extract, paint);
        d += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashPainter oldDelegate) =>
      oldDelegate.color != color;
}
