import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:studentapp/widgets/common_app_bar.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../constants/app_colors.dart';
import '../../controllers/syllabus_controller.dart';
import '../../helpers/theme_adaptive.dart';
import '../../models/syllabus_models.dart';

class SyllabusScreen extends StatefulWidget {
  const SyllabusScreen({super.key});

  @override
  State<SyllabusScreen> createState() => _SyllabusScreenState();
}

class _SyllabusScreenState extends State<SyllabusScreen> {
  final SyllabusController _syllabusController = SyllabusController();

  final List<SyllabusItem> _items = [];

  bool _loading = true;
  String? _error;
  int _total = 0;

  @override
  void initState() {
    super.initState();
    _loadSyllabus();
  }

  @override
  void dispose() {
    _syllabusController.dispose();
    super.dispose();
  }

  Future<void> _loadSyllabus() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final parsed = await _syllabusController.fetchSyllabus(limit: 10);
    if (!mounted) return;
    if (!parsed.success) {
      setState(() {
        _error = parsed.message.isNotEmpty
            ? parsed.message
            : 'syllabus_error_load'.tr;
        _items.clear();
        _total = 0;
        _loading = false;
      });
      return;
    }
    setState(() {
      _items
        ..clear()
        ..addAll(parsed.data);
      _total = parsed.pagination.total;
      _loading = false;
    });
  }

  String _badgeText(SyllabusItem item) {
    final sub = item.subjectName.trim();
    if (sub.length >= 2) return sub.substring(0, 2).toUpperCase();
    if (sub.isNotEmpty) return sub.substring(0, 1).toUpperCase();
    final ex = item.examName.trim();
    if (ex.length >= 2) return ex.substring(0, 2).toUpperCase();
    if (ex.isNotEmpty) return ex.substring(0, 1).toUpperCase();
    return 'syllabus_badge'.tr;
  }

  String _subtitle(SyllabusItem item) {
    final parts = <String>[];
    if (item.subjectName.isNotEmpty) parts.add(item.subjectName);
    if (item.className.isNotEmpty) parts.add(item.className);
    if (item.examName.isNotEmpty) parts.add(item.examName);
    return parts.join(' · ');
  }

  String _dateLabel(SyllabusItem item) {
    final d = DateTime.tryParse(item.date)?.toLocal();
    if (d != null) {
      return '${d.day.toString().padLeft(2, '0')}/'
          '${d.month.toString().padLeft(2, '0')}/${d.year}';
    }
    final c = DateTime.tryParse(item.createdOn)?.toLocal();
    if (c != null) {
      return '${c.day.toString().padLeft(2, '0')}/'
          '${c.month.toString().padLeft(2, '0')}/${c.year}';
    }
    return item.date.isNotEmpty ? item.date : item.createdOn;
  }

  Future<void> _openUrl(String raw) async {
    final t = raw.trim();
    if (t.isEmpty) return;
    final uri = Uri.tryParse(t);
    if (uri == null || !uri.hasScheme) return;
    if (!await canLaunchUrl(uri)) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _openPrimary(SyllabusItem item) async {
    final pdf = item.primaryPdfUrl;
    if (pdf != null && pdf.isNotEmpty) {
      await _openUrl(pdf);
      return;
    }
    if (item.primaryFileUrl.trim().isNotEmpty) {
      await _openUrl(item.primaryFileUrl);
      return;
    }
    final videoUrl = item.upload.video.trim().isNotEmpty
        ? item.upload.video.trim()
        : item.video.trim();
    if (videoUrl.isNotEmpty) {
      await _openUrl(videoUrl);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: ThemeAdaptive.pageBackground(context),
      appBar: CommonAppBar(title: 'more_syllabus'.tr),
      body: RefreshIndicator(
          color: AppColors.accentOrange,
          onRefresh: _loadSyllabus,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'more_syllabus'.tr,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: scheme.onSurface,
                        ),
                      ),
                      if (!_loading && _total > 0)
                        Text(
                          '$_total ${'common_total'.tr}',
                          style: TextStyle(
                            fontSize: 13,
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Column(
                        children: [
                          Text(
                            _error!,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.red.shade700,
                              fontSize: 14,
                            ),
                          ),
                          TextButton(
                            onPressed: _loadSyllabus,
                            child: Text('common_retry'.tr),
                          ),
                        ],
                      ),
                    )
                  else if (_loading)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 48),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppColors.accentOrange,
                        ),
                      ),
                    )
                  else if (_items.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      child: Text(
                        'syllabus_none'.tr,
                        style: TextStyle(
                          fontSize: 14,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    )
                  else
                    ...List.generate(_items.length * 2 - 1, (i) {
                      if (i.isOdd) return const SizedBox(height: 12);
                      final item = _items[i ~/ 2];
                      return _buildSyllabusCard(item);
                    }),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          ),
    );
  }

  Widget _buildSyllabusCard(SyllabusItem item) {
    final desc = item.description.trim();
    final title = item.name.trim().isNotEmpty ? item.name : item.examName;
    final videoUrl = item.upload.video.trim().isNotEmpty
        ? item.upload.video.trim()
        : item.video.trim();
    final hasOpen = item.primaryFileUrl.isNotEmpty ||
        (item.primaryPdfUrl != null) ||
        videoUrl.isNotEmpty;

    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: ThemeAdaptive.cardShadow(context, lightAlpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFFFA44F), AppColors.accentOrange],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    _badgeText(item),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: scheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _subtitle(item),
                      style: TextStyle(
                        fontSize: 13,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    if (desc.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        desc,
                        style: TextStyle(
                          fontSize: 14,
                          color: scheme.onSurface,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          if (item.primaryFileUrl.isNotEmpty) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.network(
                  item.primaryFileUrl,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return ColoredBox(
                      color: scheme.surfaceContainerHighest,
                      child: Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                          color: AppColors.accentOrange,
                        ),
                      ),
                    );
                  },
                  errorBuilder: (_, __, ___) => ColoredBox(
                    color: scheme.surfaceContainerHighest,
                    child: Icon(
                      Icons.broken_image_outlined,
                      size: 40,
                      color: scheme.outline,
                    ),
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _dateLabel(item),
                style: TextStyle(
                  fontSize: 12,
                  color: scheme.onSurfaceVariant,
                ),
              ),
              if (hasOpen)
                TextButton(
                  onPressed: () => _openPrimary(item),
                  child: Text(
                    'common_open'.tr,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.primaryBlue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
