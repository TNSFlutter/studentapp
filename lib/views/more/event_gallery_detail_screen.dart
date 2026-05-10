import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../helpers/app_navigation.dart';
import '../../helpers/theme_adaptive.dart';
import '../../models/event_gallery_models.dart';
import '../../widgets/common_app_bar.dart';

class EventGalleryDetailScreen extends StatelessWidget {
  final EventGalleryItem event;

  const EventGalleryDetailScreen({super.key, required this.event});

  String _dateLabel(String? iso) {
    final t = iso?.trim() ?? '';
    if (t.isEmpty) return 'Date unavailable';
    final parsed = DateTime.tryParse(t)?.toLocal();
    if (parsed == null) return t;
    return DateFormat('dd MMM yyyy, hh:mm a').format(parsed);
  }

  @override
  Widget build(BuildContext context) {
    final title = event.name.trim().isNotEmpty ? event.name : 'Event';
    final description = event.description?.trim() ?? '';
    final dateLabel = _dateLabel(event.eventDate);
    final validImages = event.images
        .map((e) => e.fileImage?.trim() ?? '')
        .where((e) => e.isNotEmpty)
        .toList();

    return Scaffold(
      backgroundColor: ThemeAdaptive.pageBackground(context),
      appBar: CommonAppBar(title: title),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Builder(
              builder: (ctx) {
                final scheme = Theme.of(ctx).colorScheme;
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: scheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: ThemeAdaptive.cardShadow(ctx, lightAlpha: 0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: scheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$dateLabel • ${validImages.length} image${validImages.length == 1 ? '' : 's'}',
                        style: TextStyle(
                          fontSize: 13,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                      if (description.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Text(
                          description,
                          style: TextStyle(
                            fontSize: 14,
                            color: scheme.onSurface.withValues(alpha: 0.88),
                            height: 1.4,
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
              const SizedBox(height: 14),
              if (validImages.isEmpty)
                Builder(
                  builder: (ctx) {
                    final scheme = Theme.of(ctx).colorScheme;
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 28),
                      decoration: BoxDecoration(
                        color: scheme.surface,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.photo_library_outlined,
                            color: scheme.outline,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'No images available for this event.',
                            style: TextStyle(
                              fontSize: 14,
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                )
              else
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: validImages.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 1,
                  ),
                  itemBuilder: (context, index) {
                    final imageUrl = validImages[index];
                    return GestureDetector(
                      onTap: () {
                        AppNavigation.push<void>(
                          context,
                          _EventGalleryImageViewerScreen(
                            title: title,
                            imageUrls: validImages,
                            initialIndex: index,
                          ),
                        );
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (ctx, __, ___) {
                            final scheme = Theme.of(ctx).colorScheme;
                            return ColoredBox(
                              color: scheme.surfaceContainerHighest,
                              child: Icon(
                                Icons.broken_image_outlined,
                                color: scheme.outline,
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
    );
  }
}

class _EventGalleryImageViewerScreen extends StatefulWidget {
  final String title;
  final List<String> imageUrls;
  final int initialIndex;

  const _EventGalleryImageViewerScreen({
    required this.title,
    required this.imageUrls,
    required this.initialIndex,
  });

  @override
  State<_EventGalleryImageViewerScreen> createState() =>
      _EventGalleryImageViewerScreenState();
}

class _EventGalleryImageViewerScreenState
    extends State<_EventGalleryImageViewerScreen> {
  late final PageController _pageController;
  late int _index;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          '${_index + 1}/${widget.imageUrls.length}',
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.imageUrls.length,
        onPageChanged: (value) => setState(() => _index = value),
        itemBuilder: (context, index) {
          final imageUrl = widget.imageUrls[index];
          return InteractiveViewer(
            minScale: 0.8,
            maxScale: 5.0,
            child: Center(
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.broken_image_outlined,
                  color: Colors.white70,
                  size: 56,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
