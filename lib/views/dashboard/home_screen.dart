import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../constants/app_colors.dart';
import '../../helpers/app_feature_guide.dart';
import '../../helpers/feature_guide_showcase_ui.dart';
import '../../helpers/app_navigation.dart';
import '../../helpers/theme_adaptive.dart';
import '../../controllers/fee_controller.dart';
import '../../controllers/live_class_controller.dart';
import '../../controllers/notifications_controller.dart';
import '../../helpers/notification_ui_helper.dart';
import '../../models/live_class_models.dart';
import '../../models/pending_fee_models.dart';
import '../../models/recent_notifications_models.dart';
import '../attendance/attendance_screen.dart';
import '../calender/calender_screen.dart';
import '../fees/fee_screen.dart';
import '../homework/homework_screen.dart';
import '../leave/leave_screen.dart';
import '../message/message_screen.dart';
import '../more/datesheet_screen.dart';
import '../more/event_gallery_screen.dart';
import '../more/gate_pass_screen.dart';
import '../more/live_class_screen.dart';
import '../more/syllabus_screen.dart';
import '../notice_borad/notice_board_screen.dart';
import '../profile/profile_screen.dart';
import '../select_student/select_student_screen.dart';
import '../settings/change_language_screen.dart';
import '../test/class_test_screen.dart';
import '../test/exam_result_screen.dart';
import '../timetable/timetable_screen.dart';

/// Dashboard accent aligned with design reference (~#FF7A21).
class _DashboardPalette {
  static const Color accentOrange = Color(0xFFFF7A21);

  static const Color qaHomeworkFg = Color(0xFF2563EB);
  static const Color qaBusFg = Color(0xFFE67E22);
  static const Color qaLeaveFg = Color(0xFF16A34A);
  static const Color qaGateFg = Color(0xFF0891B2);
  static const Color qaFeesFg = Color(0xFFD97706);
  static const Color qaAttendanceFg = Color(0xFF9333EA);
  static const Color qaNoticeFg = Color(0xFF047857);
  static const Color qaGalleryFg = Color(0xFFDB2777);
}

class HomeScreen extends StatefulWidget {
  final Map<String, dynamic> selectedStudent;
  final void Function(Map<String, dynamic> updatedMap)? onStudentContextUpdated;

  /// When non-null, wraps key areas with [Showcase] for the first-time tour.
  final AppFeatureGuideKeys? guideKeys;

  /// Brief orange emphasis on the header student card (e.g. after pick from select-student).
  final bool emphasizeStudentCard;

  const HomeScreen({
    super.key,
    required this.selectedStudent,
    this.onStudentContextUpdated,
    this.guideKeys,
    this.emphasizeStudentCard = false,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const int _homeRecentNotificationsLimit = 3;

  /// Showcase description keys — order must match `_quickActionTiles`.
  static const List<String> _quickActionGuideDescKeys = [
    'guide_qa_fee',
    'guide_qa_attendance',
    'guide_qa_homework',
    'guide_qa_messages',
    'guide_qa_results',
    'guide_qa_class_test',
    'guide_qa_timetable',
    'guide_qa_datesheet',
    'guide_qa_syllabus',
    'guide_qa_holiday',
    'guide_qa_gallery',
    'guide_qa_notice_board',
    'guide_qa_leave',
    'guide_qa_gate_pass',
    'guide_qa_language',
  ];

  final NotificationsController _notificationsController =
      NotificationsController();
  final FeeController _feeController = FeeController();
  final LiveClassController _liveClassController = LiveClassController();

  PendingFeeData? _pendingFee;
  bool _pendingFeeLoading = false;
  String? _pendingFeeError;
  final List<LiveClassItem> _liveClasses = [];
  bool _liveClassLoading = false;
  String? _liveClassError;

  String get _studentName =>
      widget.selectedStudent['name']?.toString() ?? 'Himanshi Mehra';

  String get _studentClass =>
      widget.selectedStudent['class']?.toString() ?? 'Class 5-B';

  String get _rollNo =>
      widget.selectedStudent['rollNumber']?.toString() ??
      widget.selectedStudent['rollNo']?.toString() ??
      '3';

  String get _studentPhotoUrl =>
      widget.selectedStudent['photo']?.toString().trim() ?? '';

  String get _academicYear =>
      widget.selectedStudent['academicYear']?.toString().trim() ?? '';

  String get _attendanceToday =>
      widget.selectedStudent['attendanceToday']?.toString().trim() ?? '';

  bool get _attendanceTodayKnown {
    final v = _attendanceToday.toLowerCase();
    return v == 'present' ||
        v == 'p' ||
        v == 'absent' ||
        v == 'a';
  }

  String get _schoolDisplay {
    final s = widget.selectedStudent['schoolName']?.toString().trim() ?? '';
    return s.isNotEmpty ? s : 'Janta Shiksha Sadan';
  }

  int? get _classStudentId {
    final raw = widget.selectedStudent['classStudentId'];
    if (raw is int) return raw;
    return int.tryParse(raw?.toString() ?? '');
  }

  /// Same pastel-on-surface blend as attendance pills ([ThemeAdaptive.softTint]
  /// with mix `0.52` on [ColorScheme.surfaceContainerHigh]).
  Color _dashboardAccentFill(BuildContext context, Color lightPastel) {
    final scheme = Theme.of(context).colorScheme;
    return ThemeAdaptive.softTint(
      context,
      lightPastel,
      darkMix: 0.52,
      darkBlendBase: scheme.surfaceContainerHigh,
    );
  }

  String _initials(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((e) => e.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      return parts[0].length >= 2
          ? parts[0].substring(0, 2).toUpperCase()
          : parts[0].toUpperCase();
    }
    return ('${parts[0][0]}${parts[1][0]}').toUpperCase();
  }

  ({Widget leading, String label, Color bg, Color fg}) _attendancePill(
    BuildContext context,
  ) {
    final normalized = _attendanceToday.toLowerCase();
    if (normalized == 'present' || normalized == 'p') {
      const fg = Color(0xFF15803D);
      return (
        leading: const Icon(Icons.check_circle_rounded, size: 14, color: fg),
        label: 'dashboard_present_today'.tr,
        bg: _dashboardAccentFill(context, const Color(0xFFDCFCE7)),
        fg: fg,
      );
    }
    assert(
      normalized == 'absent' || normalized == 'a',
      '_attendancePill should only be used when [_attendanceTodayKnown]',
    );
    const fg = Color(0xFFB91C1C);
    return (
      leading: const Icon(Icons.cancel_rounded, size: 14, color: fg),
      label: 'Absent today',
      bg: _dashboardAccentFill(context, const Color(0xFFFFE4E6)),
      fg: fg,
    );
  }

  List<StudentNotificationItem> _recentNotifications = [];
  bool _recentNotifLoading = false;
  String? _recentNotifError;

  bool _studentEntryHighlight = false;

  @override
  void initState() {
    super.initState();
    _studentEntryHighlight = widget.emphasizeStudentCard;
    if (_studentEntryHighlight) {
      Future<void>.delayed(const Duration(milliseconds: 2400), () {
        if (!mounted) return;
        setState(() => _studentEntryHighlight = false);
      });
    }
    _reloadDashboardData();
  }

  @override
  void didUpdateWidget(covariant HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldClassStudentId = () {
      final raw = oldWidget.selectedStudent['classStudentId'];
      if (raw is int) return raw;
      return int.tryParse(raw?.toString() ?? '');
    }();
    final oldSession =
        oldWidget.selectedStudent['academicYear']?.toString().trim() ?? '';
    if (oldClassStudentId != _classStudentId || oldSession != _academicYear) {
      _reloadDashboardData();
    }
  }

  @override
  void dispose() {
    _notificationsController.dispose();
    _feeController.dispose();
    super.dispose();
  }

  void _reloadDashboardData() {
    _loadRecentNotifications();
    _loadPendingFee();
    _loadLiveClasses();
    _loadPaymentConfig();
  }

  /// Pull-to-refresh: await all home API loads so the indicator stays until done.
  Future<void> _onPullToRefresh() async {
    await Future.wait<void>([
      _loadRecentNotifications(),
      _loadPendingFee(),
      _loadLiveClasses(),
      _loadPaymentConfig(),
    ]);
  }

  Future<void> _loadPaymentConfig() async {
    // Requirement: fetch once from dashboard and cache globally for payment flow.
    await _feeController.fetchPaymentConfig();
  }

  Future<void> _loadLiveClasses() async {
    setState(() {
      _liveClassLoading = true;
      _liveClassError = null;
    });
    final date = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final parsed = await _liveClassController.fetchLiveClasses(
      yyyyMmDd: date,
      limit: 10,
    );
    if (!mounted) return;
    if (parsed.success) {
      setState(() {
        _liveClasses
          ..clear()
          ..addAll(parsed.data);
        _liveClassLoading = false;
      });
      return;
    }
    setState(() {
      _liveClasses.clear();
      _liveClassError = parsed.message.isNotEmpty
          ? parsed.message
          : 'home_error_live_classes'.tr;
      _liveClassLoading = false;
    });
  }

  String _liveClassDate(String? iso) {
    final t = iso?.trim() ?? '';
    if (t.isEmpty) return 'common_date_unavailable'.tr;
    final dt = DateTime.tryParse(t)?.toLocal();
    if (dt == null) return t;
    return DateFormat('dd MMM yyyy, hh:mm a').format(dt);
  }

  String _liveClassTitle(LiveClassItem c) {
    if (c.heading.trim().isNotEmpty) return c.heading.trim();
    if (c.name.trim().isNotEmpty) return c.name.trim();
    return 'more_live_class'.tr;
  }

  Widget _featureGuideWrap({
    required GlobalKey Function(AppFeatureGuideKeys g) pick,
    required String titleKey,
    required String descKey,
    required Widget child,
  }) {
    final g = widget.guideKeys;
    if (g == null) return child;
    return FeatureGuideShowcaseUi.dashboardShowcase(
      context: context,
      showcaseKey: pick(g),
      title: titleKey.tr,
      description: descKey.tr,
      child: child,
    );
  }

  Future<void> _joinLiveClass(LiveClassItem c) async {
    final link = c.link?.trim() ?? '';
    if (link.isEmpty) return;
    final uri = Uri.tryParse(link);
    if (uri == null || !uri.hasScheme) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Widget _buildLiveClassSection() {
    if (_liveClassLoading) {
      return const SizedBox.shrink();
    }
    if (_liveClassError != null || _liveClasses.isEmpty) {
      // Requirement: if data is empty then no need to show live class section.
      return const SizedBox.shrink();
    }

    final scheme = Theme.of(context).colorScheme;
    final top = _liveClasses.take(2).toList();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'more_live_class'.tr,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: scheme.onSurface,
                ),
              ),
              GestureDetector(
                onTap: () {
                  AppNavigation.push(context, const LiveClassScreen());
                },
                child: Text(
                  'common_view_all'.tr,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _DashboardPalette.accentOrange,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            decoration: BoxDecoration(
              color: scheme.surface,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: ThemeAdaptive.cardShadow(context, lightAlpha: 0.06),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                for (int i = 0; i < top.length; i++) ...[
                  ListTile(
                    contentPadding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
                    leading: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: ThemeAdaptive.neutralFill(context),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.video_camera_front_rounded,
                        color: _DashboardPalette.accentOrange,
                      ),
                    ),
                    title: Text(
                      _liveClassTitle(top[i]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: scheme.onSurface,
                      ),
                    ),
                    subtitle: Text(
                      '${top[i].subjectName} • ${top[i].classSectionName}\n${_liveClassDate(top[i].startTime)}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.35,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    trailing: top[i].joinNow
                        ? TextButton(
                            onPressed: () => _joinLiveClass(top[i]),
                            child: Text(
                              'common_join'.tr,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: _DashboardPalette.accentOrange,
                              ),
                            ),
                          )
                        : null,
                  ),
                  if (i != top.length - 1)
                    Divider(height: 1, color: scheme.outlineVariant),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _loadPendingFee() async {
    setState(() {
      _pendingFeeLoading = true;
      _pendingFeeError = null;
    });
    final parsed = await _feeController.fetchPendingFee(limit: 10);
    if (!mounted) return;
    if (parsed.success && parsed.data != null) {
      setState(() {
        _pendingFee = parsed.data;
        _pendingFeeLoading = false;
      });
      return;
    }
    setState(() {
      _pendingFee = null;
      _pendingFeeError = parsed.message.isNotEmpty
          ? parsed.message
          : 'fees_error_pending'.tr;
      _pendingFeeLoading = false;
    });
  }

  String _formatPendingMoney(num n) {
    return NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    ).format(n);
  }

  bool get _hasPendingFee =>
      _pendingFee != null &&
      !_pendingFee!.isPaid &&
      _pendingFee!.pendingFee > 0;

  Future<void> _loadRecentNotifications() async {
    setState(() {
      _recentNotifLoading = true;
      _recentNotifError = null;
    });
    final parsed = await _notificationsController.fetchRecentNotifications(
      limit: _homeRecentNotificationsLimit,
      offset: 0,
    );
    if (!mounted) return;
    if (parsed.success) {
      setState(() {
        _recentNotifications = parsed.data;
        _recentNotifLoading = false;
      });
      return;
    }
    setState(() {
      _recentNotifError = parsed.message.isNotEmpty
          ? parsed.message
          : 'notif_error_load'.tr;
      _recentNotifLoading = false;
    });
  }

  Widget _buildRecentNotificationContent() {
    final scheme = Theme.of(context).colorScheme;
    if (_recentNotifLoading) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Center(
          child: SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(
              color: scheme.primary,
              strokeWidth: 2,
            ),
          ),
        ),
      );
    }
    if (_recentNotifError != null) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              _recentNotifError!,
              textAlign: TextAlign.center,
              style: TextStyle(color: scheme.error, fontSize: 14),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _loadRecentNotifications,
              child: Text('common_retry'.tr),
            ),
          ],
        ),
      );
    }
    final show = _recentNotifications
        .take(_homeRecentNotificationsLimit)
        .toList();
    if (show.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        child: Text(
          'notifications_none_yet'.tr,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: scheme.onSurfaceVariant),
        ),
      );
    }
    return Column(
      children: List.generate(show.length, (i) {
        final n = show[i];
        final raw = notificationAccent(n.iconHint);
        final bg = ThemeAdaptive.neutralFill(context);
        final fg = raw.$2;
        return _CompactNotificationRow(
          icon: notificationIcon(n.iconHint),
          iconBg: bg,
          iconFg: fg,
          title: n.displayTitle,
          description: n.bodyPreview(),
          timeLabel: notificationTimeLabel(n.sendDate),
          showDividerBelow: i < show.length - 1,
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.paddingOf(context).top;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: ThemeAdaptive.pageBackground(context),
      body: RefreshIndicator(
        onRefresh: _onPullToRefresh,
        color: AppColors.accentOrange,
        edgeOffset: topPad + 8,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                decoration: const BoxDecoration(
                  color: _DashboardPalette.accentOrange,
                ),
              padding: EdgeInsets.fromLTRB(16, topPad + 12, 16, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _HeaderIconButton(
                        icon: Icons.home_rounded,
                        showBadge: false,
                        onTap: () {},
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              _schoolDisplay,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Colors.white.withValues(alpha: 0.98),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 2),
                          ],
                        ),
                      ),
                      _HeaderIconButton(
                        icon: Icons.notifications_none_rounded,
                        showBadge: true,
                        onTap: () {
                          AppNavigation.push(
                            context,
                            const MessageScreen(showBackButton: true),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  _featureGuideWrap(
                    pick: (k) => k.studentCard,
                    titleKey: 'guide_student_card_title',
                    descKey: 'guide_student_card_desc',
                    child: AnimatedContainer(
                    duration: const Duration(milliseconds: 420),
                    curve: Curves.easeOutCubic,
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: scheme.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _studentEntryHighlight
                            ? AppColors.accentOrange
                            : Colors.transparent,
                        width: _studentEntryHighlight ? 2.5 : 0,
                      ),
                      boxShadow: [
                        if (_studentEntryHighlight)
                          BoxShadow(
                            color: AppColors.accentOrange.withValues(
                              alpha: 0.32,
                            ),
                            blurRadius: 22,
                            spreadRadius: 0,
                            offset: const Offset(0, 6),
                          ),
                        BoxShadow(
                          color: ThemeAdaptive.cardShadow(context),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color: AppColors.accentOrange.withValues(
                                  alpha: theme.brightness == Brightness.dark
                                      ? 0.18
                                      : 0.10,
                                ),
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: ClipOval(
                                child: _studentPhotoUrl.isNotEmpty
                                    ? Image.network(
                                        _studentPhotoUrl,
                                        width: 52,
                                        height: 52,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => Text(
                                          _initials(_studentName),
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color:
                                                _DashboardPalette.accentOrange,
                                          ),
                                        ),
                                      )
                                    : Text(
                                        _initials(_studentName),
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: _DashboardPalette.accentOrange,
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _studentName,
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                      color: scheme.onSurface,
                                      letterSpacing: -0.3,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '$_studentClass • Roll No. $_rollNo',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: scheme.onSurfaceVariant,
                                      height: 1.2,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: [
                                        if (_attendanceTodayKnown) ...[
                                          Builder(
                                            builder: (_) {
                                              final pill =
                                                  _attendancePill(context);
                                              return _StatusPill(
                                                leading: pill.leading,
                                                label: pill.label,
                                                bg: pill.bg,
                                                fg: pill.fg,
                                              );
                                            },
                                          ),
                                          const SizedBox(width: 8),
                                        ],
                                        if (_pendingFeeLoading)
                                          _StatusPill(
                                            label: 'dashboard_loading_fee'.tr,
                                            bg: ThemeAdaptive.neutralFill(context),
                                            fg: scheme.onSurfaceVariant,
                                          )
                                        else if (_pendingFeeError != null)
                                          _StatusPill(
                                            label:
                                                'dashboard_fee_unavailable'.tr,
                                            bg: ThemeAdaptive.neutralFill(context),
                                            fg: scheme.onSurfaceVariant,
                                          )
                                        else if (_hasPendingFee)
                                          _StatusPill(
                                            label:
                                                '${_formatPendingMoney(_pendingFee!.pendingFee)} due',
                                            bg: _dashboardAccentFill(
                                              context,
                                              const Color(0xFFFFE4E6),
                                            ),
                                            fg: const Color(0xFFE11D48),
                                          )
                                        else
                                          _StatusPill(
                                            label: 'dashboard_no_fee_due'.tr,
                                            bg: _dashboardAccentFill(
                                              context,
                                              const Color(0xFFE8F8EF),
                                            ),
                                            fg: const Color(0xFF15803D),
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            _StudentChipButton(
                              label: 'dashboard_switch'.tr,
                              icon: Icons.keyboard_arrow_down_rounded,
                              bg: ThemeAdaptive.neutralFill(context),
                              fg: _DashboardPalette.accentOrange,
                              iconColor: _DashboardPalette.accentOrange,
                              borderColor: scheme.outlineVariant,
                              onTap: () {
                                AppNavigation.push<void>(
                                  context,
                                  const SelectStudentScreen(),
                                );
                              },
                            ),
                            const SizedBox(width: 8),
                            _StudentChipButton(
                              label: 'nav_profile'.tr,
                              icon: Icons.person_rounded,
                              bg: ThemeAdaptive.neutralFill(context),
                              fg: _DashboardPalette.accentOrange,
                              iconColor: _DashboardPalette.accentOrange,
                              borderColor: scheme.outlineVariant,
                              onTap: () {
                                AppNavigation.push<void>(
                                  context,
                                  ProfileScreen(
                                    selectedStudent: widget.selectedStudent,
                                    showBottomNav: false,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: _PaymentDueCard(
                loading: _pendingFeeLoading,
                errorMessage: _pendingFeeError,
                onRetry: _loadPendingFee,
                pending: _pendingFee,
                payNowShowcaseKey: widget.guideKeys?.payNowButton,
                onPay: () {
                  AppNavigation.push<void>(
                    context,
                    const FeeScreen(showBackButton: true),
                  );
                },
              ),
            ),

            const SizedBox(height: 18),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
                decoration: BoxDecoration(
                  color: scheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: ThemeAdaptive.cardShadow(context, lightAlpha: 0.06),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'dashboard_quick_actions'.tr,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: scheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 16),
                    GridView.count(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 4,
                      childAspectRatio: 0.78,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 14,
                      children: _quickActionTiles(),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            _buildLiveClassSection(),
            if (_liveClasses.isNotEmpty) const SizedBox(height: 20),

            _featureGuideWrap(
              pick: (k) => k.recentNotifications,
              titleKey: 'guide_notifications_title',
              descKey: 'guide_notifications_desc',
              child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'dashboard_recent_notifications'.tr,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: scheme.onSurface,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          AppNavigation.push(
                            context,
                            const MessageScreen(showBackButton: true),
                          );
                        },
                        child: Text(
                          'common_view_all'.tr,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: _DashboardPalette.accentOrange,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Container(
                    decoration: BoxDecoration(
                      color: scheme.surface,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: ThemeAdaptive.cardShadow(
                            context,
                            lightAlpha: 0.06,
                          ),
                          blurRadius: 14,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: _buildRecentNotificationContent(),
                  ),
                ],
              ),
            ),
            ),

            SizedBox(height: MediaQuery.paddingOf(context).bottom + 24),
          ],
        ),
      ),
      ),
    );
  }

  (Color bg, Color fg) _quickActionPalette(BuildContext context, int index) {
    const fgCycle = <Color>[
      _DashboardPalette.qaHomeworkFg,
      _DashboardPalette.qaBusFg,
      _DashboardPalette.qaLeaveFg,
      _DashboardPalette.qaGateFg,
      _DashboardPalette.qaFeesFg,
      _DashboardPalette.qaAttendanceFg,
      _DashboardPalette.qaNoticeFg,
      _DashboardPalette.qaGalleryFg,
    ];
    final fg = fgCycle[index % fgCycle.length];
    return (ThemeAdaptive.neutralFill(context), fg);
  }

  List<Widget> _quickActionTiles() {
    void nav(Widget page) {
      AppNavigation.push<void>(context, page);
    }

    final tiles = <(IconData, String, VoidCallback)>[
      (
        Icons.currency_rupee_rounded,
        'more_fee'.tr,
        () => nav(const FeeScreen(showBackButton: true)),
      ),
      (
        Icons.person_2_rounded,
        'more_attendance'.tr,
        () => nav(const AttendanceScreen()),
      ),
      (
        Icons.book_rounded,
        'more_homework'.tr,
        () => nav(const HomeworkScreen()),
      ),
      (
        Icons.notifications_rounded,
        'more_notification'.tr,
        () => nav(const MessageScreen(showBackButton: true)),
      ),
      (
        Icons.pie_chart_rounded,
        'more_results'.tr,
        () => nav(const ExamResultScreen()),
      ),
      (
        Icons.assignment_turned_in_rounded,
        'more_class_test'.tr,
        () => nav(const ClassTestScreen()),
      ),
      (
        Icons.access_time_rounded,
        'more_timetable'.tr,
        () => nav(const TimetableScreen()),
      ),
      (
        Icons.event_note_rounded,
        'more_datesheet'.tr,
        () => nav(const DatesheetScreen()),
      ),
      (
        Icons.menu_book_rounded,
        'more_syllabus'.tr,
        () => nav(const SyllabusScreen()),
      ),
      (
        Icons.calendar_month_rounded,
        'more_holiday_calendar'.tr,
        () => nav(const CalendarScreen()),
      ),
      // (
      //   Icons.directions_bus_rounded,
      //   'Track Bus',
      //   () => nav(const TrackBusScreen()),
      // ),
      (
        Icons.photo_library_rounded,
        'more_events_gallery'.tr,
        () => nav(const EventGalleryScreen()),
      ),
      (
        Icons.notifications_active_rounded,
        'more_notice_board'.tr,
        () => nav(const NoticeBoardScreen()),
      ),
      (
        Icons.event_busy_rounded,
        'more_leave'.tr,
        () => nav(const LeaveScreen()),
      ),
      (
        Icons.qr_code_rounded,
        'more_gate_pass'.tr,
        () => nav(const GatePassScreen()),
      ),
      (
        Icons.translate_rounded,
        'more_change_language'.tr,
        () => nav(const ChangeLanguageScreen()),
      ),
    ];

    assert(
      tiles.length == AppFeatureGuide.quickActionTileCount,
      'Keep AppFeatureGuide.quickActionTileCount and _quickActionGuideDescKeys in sync.',
    );
    assert(_quickActionGuideDescKeys.length == AppFeatureGuide.quickActionTileCount);

    final g = widget.guideKeys;
    final widgets = <Widget>[];
    for (var i = 0; i < tiles.length; i++) {
      final p = _quickActionPalette(context, i);
      Widget tile = _buildQuickActionItem(
        icon: tiles[i].$1,
        label: tiles[i].$2,
        bg: p.$1,
        fg: p.$2,
        onTap: tiles[i].$3,
      );
      if (g != null) {
        tile = FeatureGuideShowcaseUi.dashboardShowcase(
          context: context,
          showcaseKey: g.quickActionKeys[i],
          title: tiles[i].$2,
          description: _quickActionGuideDescKeys[i].tr,
          child: tile,
        );
      }
      widgets.add(tile);
    }
    return widgets;
  }

  Widget _buildQuickActionItem({
    required IconData icon,
    required String label,
    required Color bg,
    required Color fg,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(14),
              ),
              alignment: Alignment.center,
              child: Icon(icon, color: fg, size: 26),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                height: 1.2,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final bool showBadge;
  final VoidCallback onTap;

  const _HeaderIconButton({
    required this.icon,
    required this.showBadge,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: 44,
          height: 44,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.22),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.45),
                  ),
                ),
                alignment: Alignment.center,
                child: Icon(icon, color: Colors.white, size: 22),
              ),
              if (showBadge)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFFEF4444),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final Widget? leading;
  final String label;
  final Color bg;
  final Color fg;

  const _StatusPill({
    this.leading,
    required this.label,
    required this.bg,
    required this.fg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (leading != null) ...[leading!, const SizedBox(width: 4)],
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}

class _StudentChipButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color bg;
  final Color fg;
  final Color iconColor;
  final Color borderColor;
  final VoidCallback onTap;

  const _StudentChipButton({
    required this.label,
    required this.icon,
    required this.bg,
    required this.fg,
    required this.iconColor,
    required this.borderColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: fg,
                ),
              ),
              const SizedBox(width: 2),
              Icon(icon, size: 18, color: iconColor),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _payNowButtonWithOptionalShowcase({
  required BuildContext context,
  required GlobalKey? showcaseKey,
  required VoidCallback onPay,
}) {
  final button = ElevatedButton(
    onPressed: onPay,
    style: ElevatedButton.styleFrom(
      backgroundColor: _DashboardPalette.accentOrange,
      foregroundColor: Colors.white,
      elevation: 0,
      padding: const EdgeInsets.symmetric(
        horizontal: 22,
        vertical: 14,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
    ),
    child: Text(
      'fees_pay_now'.tr,
      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
    ),
  );
  if (showcaseKey == null) return button;
  return FeatureGuideShowcaseUi.dashboardShowcase(
    context: context,
    showcaseKey: showcaseKey,
    title: 'guide_pay_now_title'.tr,
    description: 'guide_pay_now_desc'.tr,
    child: button,
  );
}

class _PaymentDueCard extends StatelessWidget {
  final bool loading;
  final String? errorMessage;
  final VoidCallback onRetry;
  final PendingFeeData? pending;
  final VoidCallback onPay;

  /// When set with [pending] fee UI visible, wraps Pay now with the dashboard showcase.
  final GlobalKey? payNowShowcaseKey;

  const _PaymentDueCard({
    required this.loading,
    required this.errorMessage,
    required this.onRetry,
    required this.pending,
    required this.onPay,
    this.payNowShowcaseKey,
  });

  String _formatMoney(num n) {
    return NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    ).format(n);
  }

  String _subtitle(PendingFeeData d) {
    final unique = d.accountHeads
        .map((h) => h.accountHeadName)
        .toSet()
        .toList();
    if (unique.isEmpty) return 'dashboard_pending_balance'.tr;
    if (unique.length <= 2) return unique.join(' · ');
    return '${unique[0]} · ${unique[1]} +${unique.length - 2} more';
  }

  String _periods(PendingFeeData d) {
    final names = d.accountHeads.map((h) => h.feePeriodName).toSet().toList()
      ..sort();
    if (names.isNotEmpty) return names.join(', ');
    return d.feePeriodName;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    if (loading) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 28),
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: ThemeAdaptive.cardShadow(context),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Center(
          child: SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(
              color: scheme.primary,
              strokeWidth: 2,
            ),
          ),
        ),
      );
    }

    if (errorMessage != null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: ThemeAdaptive.cardShadow(context),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              errorMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(color: scheme.error, fontSize: 14),
            ),
            TextButton(onPressed: onRetry, child: Text('common_retry'.tr)),
          ],
        ),
      );
    }

    final d = pending;
    final show = d != null && !d.isPaid && d.pendingFee > 0;
    if (!show) {
      return const SizedBox.shrink();
    }

    final periods = _periods(d);
    final banner = periods.isNotEmpty
        ? '${'dashboard_pending_fee'.tr} — $periods'
        : 'dashboard_pending_fee'.tr;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: ThemeAdaptive.cardShadow(context),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            color: scheme.errorContainer,
            child: Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  size: 20,
                  color: scheme.error,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    banner,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: scheme.onErrorContainer,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _subtitle(d),
                        style: TextStyle(
                          fontSize: 12,
                          color: scheme.onSurfaceVariant,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _formatMoney(d.pendingFee),
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: scheme.onSurface,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                _payNowButtonWithOptionalShowcase(
                  context: context,
                  showcaseKey: payNowShowcaseKey,
                  onPay: onPay,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CompactNotificationRow extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconFg;
  final String title;
  final String description;
  final String timeLabel;
  final bool showDividerBelow;

  const _CompactNotificationRow({
    required this.icon,
    required this.iconBg,
    required this.iconFg,
    required this.title,
    this.description = '',
    required this.timeLabel,
    required this.showDividerBelow,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconBg,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(icon, color: iconFg, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: scheme.onSurface,
                            ),
                          ),
                        ),
                        Text(
                          timeLabel,
                          style: TextStyle(
                            fontSize: 13,
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    if (description.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.35,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        if (showDividerBelow)
          Divider(
            height: 1,
            thickness: 1,
            color: scheme.outlineVariant,
          ),
      ],
    );
  }
}
