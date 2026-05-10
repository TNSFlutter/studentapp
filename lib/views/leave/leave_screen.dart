import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../helpers/app_navigation.dart';
import '../../helpers/theme_adaptive.dart';
import '../../controllers/leave_controller.dart';
import '../../models/leave_models.dart';
import '../../widgets/common_app_bar.dart';
import 'apply_leave_screen.dart';
import 'leave_detail_screen.dart';

class LeaveScreen extends StatefulWidget {
  const LeaveScreen({super.key});

  @override
  State<LeaveScreen> createState() => _LeaveScreenState();
}

class _LeaveScreenState extends State<LeaveScreen> {
  final LeaveController _leaveController = LeaveController();
  bool _loading = true;
  String? _error;
  LeaveListSummary _summary = LeaveListSummary.empty();
  List<LeaveItem> _items = const [];
  String _activeFilter = 'all';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final res = await _leaveController.fetchLeaveList(limit: 10);
    if (!mounted) return;
    setState(() {
      _loading = false;
      if (res.success) {
        _summary = res.summary;
        _items = res.data;
      } else {
        _error = res.message.isNotEmpty ? res.message : 'leave_error_load'.tr;
      }
    });
  }

  List<LeaveItem> get _filteredItems {
    if (_activeFilter == 'all') return _items;
    return _items
        .where((e) => e.status.toLowerCase() == _activeFilter.toLowerCase())
        .toList();
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return const Color(0xFF15803D);
      case 'rejected':
        return const Color(0xFFBE123C);
      default:
        return const Color(0xFFA16207);
    }
  }

  Color _statusBg(BuildContext context, String status) {
    final light = switch (status.toLowerCase()) {
      'approved' => const Color(0xFFDCFCE7),
      'rejected' => const Color(0xFFFFE4E6),
      _ => const Color(0xFFFEF3C7),
    };
    return ThemeAdaptive.softTint(context, light);
  }

  Widget _summaryTile(String count, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.22),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              count,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w800,
                height: 1,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.95),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _filterChip(BuildContext context, String key, String label) {
    final scheme = Theme.of(context).colorScheme;
    final active = _activeFilter == key;
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: GestureDetector(
          onTap: () => setState(() => _activeFilter = key),
          child: Container(
            height: 36,
            decoration: BoxDecoration(
              color: active ? const Color(0xFFFF7A21) : ThemeAdaptive.neutralFill(context),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: active ? const Color(0xFFFF7A21) : scheme.outlineVariant,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              label,
              style: TextStyle(
                color: active ? Colors.white : scheme.onSurfaceVariant,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: ThemeAdaptive.pageBackground(context),
      appBar: CommonAppBar(title: 'more_leave'.tr),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 20),
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFF7A21),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  _summaryTile('${_summary.total}', 'common_total'.tr),
                  const SizedBox(width: 8),
                  _summaryTile('${_summary.approved}', 'common_approved'.tr),
                  const SizedBox(width: 8),
                  _summaryTile('${_summary.pending}', 'common_pending'.tr),
                  const SizedBox(width: 8),
                  _summaryTile('${_summary.rejected}', 'common_rejected'.tr),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _filterChip(context, 'all', 'notif_type_all'.tr),
                _filterChip(context, 'pending', 'common_pending'.tr),
                _filterChip(context, 'approved', 'common_approved'.tr),
                _filterChip(context, 'rejected', 'common_rejected'.tr),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              'leave_recent_applications'.tr,
              style: TextStyle(
                fontSize: 11,
                color: scheme.onSurfaceVariant,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 10),
            if (_loading)
              const Padding(
                padding: EdgeInsets.only(top: 40),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_error != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: scheme.errorContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _error!,
                  style: TextStyle(
                    color: scheme.onErrorContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
            else if (_filteredItems.isEmpty)
              Container(
                padding: const EdgeInsets.all(20),
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
                child: Text(
                  'leave_no_applications'.tr,
                  style: TextStyle(color: scheme.onSurfaceVariant),
                ),
              )
            else
              ..._filteredItems.map(
                (e) => GestureDetector(
                  onTap: () async {
                    final changed = await AppNavigation.push<bool>(
                      context,
                      LeaveDetailScreen(leaveId: e.id),
                    );
                    if (changed == true && mounted) _load();
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: scheme.surface,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: ThemeAdaptive.cardShadow(context, lightAlpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                e.leaveType.name,
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 18,
                                  color: scheme.onSurface,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: _statusBg(context, e.status),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                e.status,
                                style: TextStyle(
                                  color: _statusColor(e.status),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${e.totalDays} day(s) · ${e.formattedDateRange}',
                          style: TextStyle(
                            color: scheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          e.description,
                          style: TextStyle(
                            color: scheme.onSurface,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${'leave_applied'.tr} ${e.formattedAppliedOn}',
                          style: TextStyle(
                            color: scheme.onSurfaceVariant,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 6, 14, 12),
          child: SizedBox(
            height: 52,
            child: ElevatedButton.icon(
              onPressed: () async {
                final applied = await AppNavigation.push<bool>(
                  context,
                  const ApplyLeaveScreen(),
                );
                if (applied == true && mounted) _load();
              },
              icon: const Icon(Icons.add_rounded, color: Colors.white),
              label: Text(
                'leave_apply'.tr,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF7A21),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
