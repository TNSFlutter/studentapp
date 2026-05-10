import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:studentapp/widgets/common_app_bar.dart';

import '../../constants/app_colors.dart';
import '../../helpers/app_navigation.dart';
import '../../helpers/theme_adaptive.dart';
import '../../controllers/event_gallery_controller.dart';
import '../../models/event_gallery_models.dart';
import 'event_gallery_detail_screen.dart';

class EventGalleryScreen extends StatefulWidget {
  const EventGalleryScreen({super.key});

  @override
  State<EventGalleryScreen> createState() => _EventGalleryScreenState();
}

class _EventGalleryScreenState extends State<EventGalleryScreen> {
  final EventGalleryController _eventGalleryController = EventGalleryController();
  final List<EventGalleryItem> _events = [];
  bool _loading = true;
  String? _error;
  int _total = 0;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final parsed = await _eventGalleryController.fetchEvents(limit: 10);
    if (!mounted) return;

    if (!parsed.success) {
      setState(() {
        _error = parsed.message.isNotEmpty
            ? parsed.message
            : 'event_gallery_error_load'.tr;
        _events.clear();
        _total = 0;
        _loading = false;
      });
      return;
    }

    setState(() {
      _events
        ..clear()
        ..addAll(parsed.data);
      _total = parsed.pagination.total;
      _loading = false;
      _error = null;
    });
  }

  String _dateLabel(String? iso) {
    final t = iso?.trim() ?? '';
    if (t.isEmpty) return 'common_date_unavailable'.tr;
    final parsed = DateTime.tryParse(t)?.toLocal();
    if (parsed == null) return t;
    return DateFormat('dd MMM yyyy, hh:mm a').format(parsed);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: ThemeAdaptive.pageBackground(context),
      appBar: CommonAppBar(title: 'more_events_gallery'.tr),
      body: RefreshIndicator(
          color: AppColors.accentOrange,
          onRefresh: _loadEvents,
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
                        'event_gallery_title'.tr,
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
                            onPressed: _loadEvents,
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
                  else if (_events.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      child: Text(
                        'event_gallery_none'.tr,
                        style: TextStyle(
                          fontSize: 14,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    )
                  else
                    _buildEventsGrid(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          ),
    );
  }

  Widget _buildEventsGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.8,
      ),
      itemCount: _events.length,
      itemBuilder: (context, index) {
        final event = _events[index];
        return _buildEventCard(
          context,
          event: event,
        );
      },
    );
  }

  Widget _buildEventCard(BuildContext context, {required EventGalleryItem event}) {
    final scheme = Theme.of(context).colorScheme;
    final title = event.name.trim().isNotEmpty ? event.name : 'event_gallery_event'.tr;
    final count = event.totalImages == 1
        ? '1 ${'event_gallery_photo'.tr}'
        : '${event.totalImages} ${'event_gallery_photos'.tr}';
    final dateTime = _dateLabel(event.eventDate);
    final cover = event.coverImage;

    return GestureDetector(
      onTap: () {
        AppNavigation.push<void>(
          context,
          EventGalleryDetailScreen(event: event),
        );
      },
      child: Container(
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
            // Event Image
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                  image: cover != null
                      ? DecorationImage(
                          image: NetworkImage(cover),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: Stack(
                  children: [
                    if (cover == null)
                      ColoredBox(
                        color: scheme.surfaceContainerHighest,
                        child: Center(
                          child: Icon(
                            Icons.photo_library_outlined,
                            color: scheme.outline,
                            size: 40,
                          ),
                        ),
                      ),
                    Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.3),
                      ],
                    ),
                  ),
                    ),
                  ],
                ),
              ),
            ),
            // Event Details
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
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
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      count,
                      style: TextStyle(
                        fontSize: 12,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      dateTime,
                      style: TextStyle(
                        fontSize: 10,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

}
