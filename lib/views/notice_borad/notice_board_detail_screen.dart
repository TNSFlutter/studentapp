import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../constants/app_colors.dart';
import '../../helpers/theme_adaptive.dart';
import '../../models/notice_board_models.dart';
import '../../widgets/common_app_bar.dart';

class NoticeBoardDetailScreen extends StatelessWidget {
  final NoticeItem notice;

  const NoticeBoardDetailScreen({super.key, required this.notice});

  Future<void> _openUrl(String raw) async {
    final t = raw.trim();
    if (t.isEmpty) return;
    final uri = Uri.tryParse(t);
    if (uri == null || !uri.hasScheme) return;
    if (!await canLaunchUrl(uri)) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  String _dateLabel(String raw) {
    final d = DateTime.tryParse(raw.replaceAll(' ', 'T'))?.toLocal();
    if (d != null) {
      return '${d.day.toString().padLeft(2, '0')}/'
          '${d.month.toString().padLeft(2, '0')}/${d.year} '
          '${d.hour.toString().padLeft(2, '0')}:'
          '${d.minute.toString().padLeft(2, '0')}';
    }
    return raw;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final title = notice.name.trim().isNotEmpty ? notice.name : 'Notice';
    final desc = (notice.description ?? '').trim();
    final img = notice.fileImage?.trim();
    final video = notice.video?.trim();
    final pdf = notice.pdfImage?.trim();
    final link = notice.link?.trim();
    final audio = notice.audioImage?.trim();

    return Scaffold(
      backgroundColor: ThemeAdaptive.pageBackground(context),
      appBar: CommonAppBar(title: title),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              decoration: BoxDecoration(
                color: scheme.surface,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: ThemeAdaptive.cardShadow(context),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: scheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      [
                        if (notice.createdBy != null &&
                            notice.createdBy!.isNotEmpty)
                          notice.createdBy!,
                        _dateLabel(notice.createdOn),
                      ].join(' · '),
                      style: TextStyle(
                        fontSize: 13,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    if (img != null && img.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: AspectRatio(
                          aspectRatio: 16 / 9,
                          child: Image.network(
                            img,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, progress) {
                              if (progress == null) return child;
                              return ColoredBox(
                                color: scheme.surfaceContainerHighest,
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    color: AppColors.accentOrange,
                                    strokeWidth: 2,
                                  ),
                                ),
                              );
                            },
                            errorBuilder: (_, __, ___) => ColoredBox(
                              color: scheme.surfaceContainerHighest,
                              child: Icon(
                                Icons.broken_image_outlined,
                                size: 48,
                                color: scheme.outline,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                    if (desc.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      SelectableText(
                        desc,
                        style: TextStyle(
                          fontSize: 15,
                          height: 1.45,
                          color: scheme.onSurface.withValues(alpha: 0.92),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  if (video != null && video.isNotEmpty)
                    OutlinedButton.icon(
                      onPressed: () => _openUrl(video),
                      icon: const Icon(Icons.play_circle_outline_rounded),
                      label: const Text('Video'),
                    ),
                  if (pdf != null && pdf.isNotEmpty)
                    OutlinedButton.icon(
                      onPressed: () => _openUrl(pdf),
                      icon: const Icon(Icons.picture_as_pdf_outlined),
                      label: const Text('PDF'),
                    ),
                  if (link != null && link.isNotEmpty)
                    OutlinedButton.icon(
                      onPressed: () => _openUrl(link),
                      icon: const Icon(Icons.link_rounded),
                      label: const Text('Link'),
                    ),
                  if (audio != null && audio.isNotEmpty)
                    OutlinedButton.icon(
                      onPressed: () => _openUrl(audio),
                      icon: const Icon(Icons.audiotrack_outlined),
                      label: const Text('Audio'),
                    ),
                  if (img != null && img.isNotEmpty)
                    OutlinedButton.icon(
                      onPressed: () => _openUrl(img),
                      icon: const Icon(Icons.image_outlined),
                      label: const Text('Image'),
                    ),
                ],
              ),
            ],
          ),
        ),
    );
  }
}
