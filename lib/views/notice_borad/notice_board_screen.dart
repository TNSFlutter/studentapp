import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../constants/app_colors.dart';
import '../../helpers/app_navigation.dart';
import '../../helpers/theme_adaptive.dart';
import '../../controllers/notice_board_controller.dart';
import '../../models/notice_board_models.dart';
import '../../widgets/common_app_bar.dart';
import 'notice_board_detail_screen.dart';

class NoticeBoardScreen extends StatefulWidget {
  const NoticeBoardScreen({super.key});

  @override
  State<NoticeBoardScreen> createState() => _NoticeBoardScreenState();
}

class _NoticeBoardScreenState extends State<NoticeBoardScreen> {
  final NoticeBoardController _api = NoticeBoardController();
  final ScrollController _scrollController = ScrollController();

  final List<NoticeItem> _items = [];
  String? _error;
  bool _loading = true;
  bool _loadingMore = false;
  int _total = 0;
  String? _nextCursor;
  bool _hasNextPage = false;

  static const int _pageLimit = 10;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _refresh(reset: true);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_loading || _loadingMore || !_hasNextPage || _nextCursor == null) {
      return;
    }
    final pos = _scrollController.position;
    if (!pos.hasViewportDimension) return;
    if (pos.pixels >= pos.maxScrollExtent - 240) {
      _loadMore();
    }
  }

  Future<void> _refresh({bool reset = false}) async {
    if (reset) {
      setState(() {
        _loading = true;
        _error = null;
        _nextCursor = null;
        _hasNextPage = false;
      });
    }

    final parsed = await _api.fetchNotices(limit: _pageLimit, cursor: null);
    if (!mounted) return;

    if (!parsed.success) {
      setState(() {
        _error = parsed.message.isNotEmpty
            ? parsed.message
            : 'Could not load notices.';
        _items.clear();
        _total = 0;
        _nextCursor = null;
        _hasNextPage = false;
        _loading = false;
      });
      return;
    }

    setState(() {
      _items
        ..clear()
        ..addAll(parsed.data);
      _total = parsed.pagination.total;
      _nextCursor = parsed.pagination.nextCursor;
      _hasNextPage = parsed.pagination.hasNextPage;
      _error = null;
      _loading = false;
    });
  }

  Future<void> _loadMore() async {
    if (_loadingMore || !_hasNextPage || _nextCursor == null) return;
    setState(() => _loadingMore = true);

    final parsed = await _api.fetchNotices(
      limit: _pageLimit,
      cursor: _nextCursor,
    );
    if (!mounted) return;

    if (!parsed.success) {
      setState(() => _loadingMore = false);
      return;
    }

    setState(() {
      _items.addAll(parsed.data);
      _nextCursor = parsed.pagination.nextCursor;
      _hasNextPage = parsed.pagination.hasNextPage;
      _loadingMore = false;
    });
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

  Future<void> _openUrl(String raw) async {
    final t = raw.trim();
    if (t.isEmpty) return;
    final uri = Uri.tryParse(t);
    if (uri == null || !uri.hasScheme) return;
    if (!await canLaunchUrl(uri)) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: ThemeAdaptive.pageBackground(context),
      appBar: const CommonAppBar(title: 'Notice Board'),
      body: RefreshIndicator(
          color: AppColors.accentOrange,
          onRefresh: () => _refresh(reset: true),
          child: CustomScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                sliver: SliverToBoxAdapter(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Notices',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: scheme.onSurface,
                        ),
                      ),
                      if (!_loading && _total > 0)
                        Text(
                          '$_total total',
                          style: TextStyle(
                            fontSize: 13,
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              if (_error != null)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 24,
                    ),
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
                          onPressed: () => _refresh(reset: true),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              else if (_loading)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppColors.accentOrange,
                    ),
                  ),
                )
              else if (_items.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Text(
                      'No notices yet.',
                      style: TextStyle(
                        fontSize: 14,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        if (index >= _items.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: Center(
                              child: _loadingMore
                                  ? const CircularProgressIndicator(
                                      color: AppColors.accentOrange,
                                      strokeWidth: 2,
                                    )
                                  : const SizedBox.shrink(),
                            ),
                          );
                        }
                        final item = _items[index];
                        return Padding(
                          padding: EdgeInsets.only(bottom: index < _items.length - 1 ? 12 : 0),
                          child: _NoticeTile(
                            item: item,
                            dateLabel: _dateLabel(item.createdOn),
                            onTap: () {
                              AppNavigation.push<void>(
                                context,
                                NoticeBoardDetailScreen(
                                  notice: item,
                                ),
                              );
                            },
                            onOpenMedia: item.primaryMediaUrl != null
                                ? () => _openUrl(item.primaryMediaUrl!)
                                : null,
                          ),
                        );
                      },
                      childCount: _items.length + (_hasNextPage ? 1 : 0),
                    ),
                  ),
                ),
            ],
          ),
          ),
    );
  }
}

class _NoticeTile extends StatelessWidget {
  final NoticeItem item;
  final String dateLabel;
  final VoidCallback onTap;
  final VoidCallback? onOpenMedia;

  const _NoticeTile({
    required this.item,
    required this.dateLabel,
    required this.onTap,
    this.onOpenMedia,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final title = item.name.trim().isNotEmpty ? item.name : 'Notice';
    final desc = (item.description ?? '').trim();
    final thumb = item.fileImage?.trim();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Ink(
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
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (thumb != null && thumb.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Image.network(
                        thumb,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return ColoredBox(
                            color: scheme.surfaceContainerHighest,
                            child: Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.accentOrange,
                                value: progress.expectedTotalBytes != null
                                    ? progress.cumulativeBytesLoaded /
                                        progress.expectedTotalBytes!
                                    : null,
                              ),
                            ),
                          );
                        },
                        errorBuilder: (_, __, ___) => ColoredBox(
                          color: scheme.surfaceContainerHighest,
                          child: Icon(
                            Icons.image_not_supported_outlined,
                            color: scheme.outline,
                            size: 40,
                          ),
                        ),
                      ),
                    ),
                  ),
                if (thumb != null && thumb.isNotEmpty) const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                          if (desc.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Text(
                              desc,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 14,
                                color: scheme.onSurfaceVariant,
                                height: 1.35,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (onOpenMedia != null) ...[
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: onOpenMedia,
                        icon: const Icon(Icons.open_in_new_rounded),
                        color: scheme.primary,
                        tooltip: 'Open attachment',
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    if (item.createdBy != null && item.createdBy!.isNotEmpty)
                      Text(
                        item.createdBy!,
                        style: TextStyle(
                          fontSize: 12,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    if (item.createdBy != null && item.createdBy!.isNotEmpty)
                      Text(
                        ' · ',
                        style: TextStyle(
                          fontSize: 12,
                          color: scheme.onSurfaceVariant.withValues(alpha: 0.8),
                        ),
                      ),
                    Text(
                      dateLabel,
                      style: TextStyle(
                        fontSize: 12,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: scheme.outline,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
