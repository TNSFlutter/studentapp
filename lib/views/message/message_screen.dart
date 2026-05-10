import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:studentapp/widgets/common_app_bar.dart';

import '../../constants/app_colors.dart';
import '../../controllers/notifications_controller.dart';
import '../../helpers/theme_adaptive.dart';
import '../../helpers/notification_ui_helper.dart';
import '../../models/recent_notifications_models.dart';

class MessageScreen extends StatefulWidget {
  final bool showBackButton;
  const MessageScreen({super.key, required this.showBackButton});

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  static const int _limit = 10;

  final NotificationsController _notificationsController =
      NotificationsController();

  bool _showFilter = false;
  String _selectedNotificationType = 'All';

  final TextEditingController _searchController = TextEditingController();

  final List<StudentNotificationItem> _items = [];
  int _nextOffset = 0;
  bool _loading = true;
  bool _loadingMore = false;
  String? _error;
  bool _hasNext = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() => setState(() {}));
    _fetch(reset: true);
  }

  @override
  void dispose() {
    _notificationsController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  String get _searchQuery => _searchController.text;

  List<StudentNotificationItem> get _filteredItems {
    final q = _searchQuery.trim().toLowerCase();
    if (q.isEmpty) return List<StudentNotificationItem>.from(_items);
    return _items
        .where(
          (n) =>
              n.displayTitle.toLowerCase().contains(q) ||
              n.message.toLowerCase().contains(q),
        )
        .toList();
  }

  List<StudentNotificationItem> get _todayItems {
    final now = DateTime.now();
    return _filteredItems.where((n) {
      final d = DateTime.tryParse(n.sendDate)?.toLocal();
      return d != null && isSameCalendarDay(d, now);
    }).toList();
  }

  List<StudentNotificationItem> get _previousItems {
    final now = DateTime.now();
    return _filteredItems.where((n) {
      final d = DateTime.tryParse(n.sendDate)?.toLocal();
      return d == null || !isSameCalendarDay(d, now);
    }).toList();
  }

  bool _passesTypeFilter(StudentNotificationItem n) {
    if (_selectedNotificationType == 'All') return true;
    final name = (n.messageType.name ?? '').toLowerCase();
    final sub = (n.subject ?? '').toLowerCase();
    final combined = '$name $sub ${n.message}'.toLowerCase();
    switch (_selectedNotificationType) {
      case 'Class Test':
        return combined.contains('test') || combined.contains('class');
      case 'Results':
        return combined.contains('result') || combined.contains('scored');
      case 'Homework':
        return combined.contains('homework') || combined.contains('home work');
      case 'School Update':
        return combined.contains('school') || combined.contains('meet');
      case 'Absent Alert':
        return combined.contains('absent');
      case 'Fees':
        return combined.contains('fee');
      default:
        return true;
    }
  }

  List<StudentNotificationItem> get _todayFiltered =>
      _todayItems.where(_passesTypeFilter).toList();

  List<StudentNotificationItem> get _previousFiltered =>
      _previousItems.where(_passesTypeFilter).toList();

  String _notificationTypeLabel(String type) {
    switch (type) {
      case 'All':
        return 'notif_type_all'.tr;
      case 'Class Test':
        return 'notif_type_class_test'.tr;
      case 'Results':
        return 'notif_type_results'.tr;
      case 'Homework':
        return 'notif_type_homework'.tr;
      case 'School Update':
        return 'notif_type_school_update'.tr;
      case 'Absent Alert':
        return 'notif_type_absent_alert'.tr;
      case 'Fees':
        return 'notif_type_fees'.tr;
      default:
        return type;
    }
  }

  Future<void> _fetch({required bool reset}) async {
    if (_loadingMore) return;
    if (!reset && !_hasNext) return;

    final requestOffset = reset ? 0 : _nextOffset;

    if (reset) {
      setState(() {
        _loading = true;
        _error = null;
        _items.clear();
        _hasNext = false;
        _nextOffset = 0;
      });
    } else {
      setState(() => _loadingMore = true);
    }

    final parsed = await _notificationsController.fetchRecentNotifications(
      limit: _limit,
      offset: requestOffset,
    );

    if (!mounted) return;

    if (parsed.success) {
      setState(() {
        if (reset) {
          _items
            ..clear()
            ..addAll(parsed.data);
        } else {
          _items.addAll(parsed.data);
        }
        final p = parsed.pagination;
        _hasNext = p.hasNextPage;
        _nextOffset = requestOffset + _limit;
        _loading = false;
        _loadingMore = false;
      });
      return;
    }

    setState(() {
      _error = parsed.message.isNotEmpty
          ? parsed.message
          : 'notif_error_load'.tr;
      _loading = false;
      _loadingMore = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CommonAppBar(
        title: 'notifications_title'.tr,
        showBackButton: widget.showBackButton,
        showNotificationIcon: false,
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(color: theme.scaffoldBackgroundColor),
            child: RefreshIndicator(
              color: AppColors.accentOrange,
              onRefresh: () => _fetch(reset: true),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.all(20),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: scheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.accentOrange.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.search, color: scheme.onSurface, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              decoration: InputDecoration(
                                hintText: 'search_here'.tr,
                                hintStyle: TextStyle(
                                  color: scheme.onSurfaceVariant,
                                  fontSize: 14,
                                ),
                                border: InputBorder.none,
                                isDense: true,
                              ),
                              style: TextStyle(
                                fontSize: 14,
                                color: scheme.onSurface,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _showFilter = true;
                              });
                            },
                            child: Icon(
                              Icons.filter_list,
                              color: scheme.onSurface,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                    ),

                    if (_loading && _items.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 48),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppColors.accentOrange,
                          ),
                        ),
                      )
                    else if (_error != null && _items.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            Text(
                              _error!,
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.red.shade700),
                            ),
                            TextButton(
                              onPressed: () => _fetch(reset: true),
                              child: Text('common_retry'.tr),
                            ),
                          ],
                        ),
                      )
                    else ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'notifications_today'.tr,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: scheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 16),
                            if (_todayFiltered.isEmpty)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Text(
                                  'notifications_none_today'.tr,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: scheme.onSurfaceVariant,
                                  ),
                                ),
                              )
                            else
                              ..._todayFiltered.map(
                                (n) => Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: _notificationCardFromItem(n),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'notifications_previous'.tr,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: scheme.onSurface,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            if (_items.isNotEmpty && _filteredItems.isEmpty)
                              Text(
                                'notifications_no_match'.tr,
                                style: TextStyle(
                                  color: scheme.onSurfaceVariant,
                                  fontSize: 14,
                                ),
                              )
                            else if (_previousFiltered.isEmpty &&
                                _todayFiltered.isEmpty &&
                                _filteredItems.isEmpty)
                              Text(
                                'notifications_none_yet'.tr,
                                style: TextStyle(
                                  color: scheme.onSurfaceVariant,
                                  fontSize: 14,
                                ),
                              )
                            else if (_previousFiltered.isEmpty &&
                                _todayFiltered.isNotEmpty &&
                                _filteredItems.length > _todayFiltered.length)
                              Text(
                                'notifications_no_older'.tr,
                                style: TextStyle(
                                  color: scheme.onSurfaceVariant,
                                  fontSize: 14,
                                ),
                              )
                            else
                              ..._previousFiltered.map(
                                (n) => Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: _notificationCardFromItem(n),
                                ),
                              ),
                            if (_loadingMore)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 16),
                                child: Center(
                                  child: SizedBox(
                                    width: 28,
                                    height: 28,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.accentOrange,
                                    ),
                                  ),
                                ),
                              ),
                            if (_hasNext &&
                                !_loadingMore &&
                                _searchQuery.trim().isEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: SizedBox(
                                  width: double.infinity,
                                  child: OutlinedButton(
                                    onPressed: () => _fetch(reset: false),
                                    child: Text('common_load_more'.tr),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ),

          if (_showFilter)
            Positioned.fill(
              child: Container(
                color: Colors.black.withValues(alpha: 0.5),
                child: Column(
                  children: [
                    const Spacer(),
                    Container(
                      margin: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: scheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Center(
                                    child: Text(
                                      'common_filter'.tr,
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: scheme.onSurface,
                                      ),
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    setState(() => _showFilter = false);
                                  },
                                  child: Icon(
                                    Icons.close,
                                    color: scheme.onSurface,
                                    size: 24,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'notifications_type'.tr,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: scheme.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                GridView.count(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  crossAxisCount: 3,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 12,
                                  childAspectRatio: 2.5,
                                  children: [
                                    _buildNotificationTypeButton('All'),
                                    _buildNotificationTypeButton('Class Test'),
                                    _buildNotificationTypeButton('Results'),
                                    _buildNotificationTypeButton('Homework'),
                                    _buildNotificationTypeButton(
                                      'School Update',
                                    ),
                                    _buildNotificationTypeButton(
                                      'Absent Alert',
                                    ),
                                    _buildNotificationTypeButton('Fees'),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _selectedNotificationType = 'All';
                                        _showFilter = false;
                                      });
                                    },
                                    child: Container(
                                      height: 48,
                                      decoration: BoxDecoration(
                                        color: scheme.surface,
                                        border: Border.all(
                                          color: AppColors.accentOrange,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        'common_reset'.tr,
                                        style: TextStyle(
                                          color: AppColors.accentOrange,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() => _showFilter = false);
                                    },
                                    child: Container(
                                      height: 48,
                                      decoration: BoxDecoration(
                                        color: AppColors.accentOrange,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        'common_apply'.tr,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _notificationCardFromItem(StudentNotificationItem n) {
    final h = n.iconHint;
    final (bg, fg) = notificationAccent(h);
    return _buildNotificationCard(
      icon: notificationIcon(h),
      iconBg: bg,
      iconFg: fg,
      title: n.displayTitle,
      message: n.bodyPreview(maxChars: 320),
      date: notificationTimeLabel(n.sendDate),
    );
  }

  Widget _buildNotificationCard({
    required IconData icon,
    required Color iconBg,
    required Color iconFg,
    required String title,
    required String message,
    required String date,
  }) {
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
            child: Icon(icon, color: iconFg, size: 24),
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
                const SizedBox(height: 8),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 14,
                    color: scheme.onSurface.withValues(alpha: 0.85),
                  ),
                  maxLines: 6,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    date,
                    style: TextStyle(
                      fontSize: 12,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationTypeButton(String type) {
    final scheme = Theme.of(context).colorScheme;
    final isSelected = _selectedNotificationType == type;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedNotificationType = type;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accentOrange : scheme.surface,
          border: Border.all(
            color: isSelected
                ? AppColors.accentOrange
                : scheme.outlineVariant,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            _notificationTypeLabel(type),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : scheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}
