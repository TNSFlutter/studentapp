import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:studentapp/views/test/class_test_screen.dart';
import 'package:studentapp/views/test/exam_result_screen.dart';

import '../../constants/app_colors.dart';
import '../../helpers/app_navigation.dart';
import '../../helpers/datetime_helper.dart';
import '../../helpers/theme_adaptive.dart';
import '../../controllers/auth_controller.dart';
import '../settings/change_language_screen.dart';
import '../attendance/attendance_screen.dart';
import '../calender/calender_screen.dart';
import '../fees/fee_screen.dart';
import '../homework/homework_screen.dart';
import '../message/message_screen.dart';
import '../notice_borad/notice_board_screen.dart';
import '../profile/profile_screen.dart';
import '../timetable/timetable_screen.dart';
// import '../track/track_bus_screen.dart'; // Track Bus temporarily hidden from menu
import 'datesheet_screen.dart';
import 'event_gallery_screen.dart';
import 'gate_pass_screen.dart';
import 'live_class_screen.dart';
import 'syllabus_screen.dart';
import '../dashboard/session_switch_screen.dart';

class MoreScreen extends StatefulWidget {
  final Map<String, dynamic> selectedStudent;
  final void Function(Map<String, dynamic> updatedMap)? onStudentContextUpdated;

  const MoreScreen({
    super.key,
    this.selectedStudent = const {},
    this.onStudentContextUpdated,
  });

  @override
  State<MoreScreen> createState() => _MoreScreenState();
}

class _MoreScreenState extends State<MoreScreen> {
  String get _studentName {
    final value = widget.selectedStudent['name']?.toString().trim() ?? '';
    return value.isNotEmpty ? value : 'Himanshi Mehra';
  }

  String get _studentClass {
    final value = widget.selectedStudent['class']?.toString().trim() ?? '';
    return value.isNotEmpty ? value : '5-B';
  }

  String get _classLabel {
    return _studentClass.toLowerCase().startsWith('class ')
        ? _studentClass
        : 'Class $_studentClass';
  }

  String get _rollNo {
    final value =
        widget.selectedStudent['rollNumber']?.toString().trim().isNotEmpty ==
            true
        ? widget.selectedStudent['rollNumber'].toString().trim()
        : widget.selectedStudent['rollNo']?.toString().trim() ?? '';
    return value.isNotEmpty ? value : '3';
  }

  String get _admissionNo {
    final value =
        widget.selectedStudent['admissionNo']?.toString().trim() ?? '';
    return value.isNotEmpty ? value : '5478';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final List<_MoreItem> items = [
      _MoreItem(
        id: 'profile',
        icon: Icons.person_outline_rounded,
        titleKey: 'nav_profile',
      ),
      _MoreItem(
        id: 'switch_session',
        icon: Icons.swap_horiz_rounded,
        titleKey: 'more_switch_session',
      ),
      _MoreItem(id: 'fee', icon: Icons.currency_rupee_rounded, titleKey: 'more_fee'),
      _MoreItem(
        id: 'attendance',
        icon: Icons.person_2_rounded,
        titleKey: 'more_attendance',
      ),
      _MoreItem(
        id: 'homework',
        icon: Icons.book_rounded,
        titleKey: 'more_homework',
      ),
      _MoreItem(
        id: 'notification',
        icon: Icons.notifications,
        titleKey: 'more_notification',
      ),
      _MoreItem(id: 'results', icon: Icons.pie_chart, titleKey: 'more_results'),
      _MoreItem(
        id: 'class_test',
        icon: Icons.assignment_turned_in,
        titleKey: 'more_class_test',
      ),
      _MoreItem(
        id: 'timetable',
        icon: Icons.access_time,
        titleKey: 'more_timetable',
      ),
      _MoreItem(
        id: 'datesheet',
        icon: Icons.event_note,
        titleKey: 'more_datesheet',
      ),
      _MoreItem(
        id: 'syllabus',
        icon: Icons.menu_book,
        titleKey: 'more_syllabus',
      ),
      _MoreItem(
        id: 'live_class',
        icon: Icons.video_call,
        titleKey: 'more_live_class',
      ),
      _MoreItem(
        id: 'holiday_calendar',
        icon: Icons.calendar_month,
        titleKey: 'more_holiday_calendar',
      ),
      // _MoreItem(
      //   id: 'track_bus',
      //   icon: Icons.directions_bus,
      //   titleKey: 'more_track_bus',
      // ),
      _MoreItem(
        id: 'events_gallery',
        icon: Icons.photo_library,
        titleKey: 'more_events_gallery',
      ),
      _MoreItem(
        id: 'notice_board',
        icon: Icons.notifications_active,
        titleKey: 'more_notice_board',
      ),
      _MoreItem(
        id: 'gate_pass',
        icon: Icons.qr_code,
        titleKey: 'more_gate_pass',
      ),
      _MoreItem(
        id: 'change_language',
        icon: Icons.translate,
        titleKey: 'more_change_language',
      ),
      _MoreItem(id: 'sign_out', icon: Icons.logout, titleKey: 'more_sign_out'),
    ];

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Container(
        decoration: BoxDecoration(color: theme.scaffoldBackgroundColor),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: scheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(
                            alpha: theme.brightness == Brightness.dark
                                ? 0.28
                                : 0.05,
                          ),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        for (int i = 0; i < items.length; i++) ...[
                          _buildRow(items[i]),
                          if (i != items.length - 1)
                            Divider(
                              height: 1,
                              thickness: 1,
                              color: scheme.outlineVariant,
                            ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFA44F), AppColors.accentOrange],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: scheme.onPrimary,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.school, color: AppColors.accentOrange),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${timeOfDayGreeting()}, $_studentName',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.cardWhite,
                  ),
                ),
                Text(
                  '$_classLabel | Roll No: $_rollNo | Adm No: $_admissionNo',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.cardWhite,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: scheme.onPrimary.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(Icons.notifications, color: scheme.onPrimary),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(_MoreItem item) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return InkWell(
      onTap: () {
        switch (item.id) {
          case 'profile':
            AppNavigation.push<void>(
              context,
              ProfileScreen(
                selectedStudent: widget.selectedStudent,
                showBottomNav: false,
              ),
            );
            break;
          case 'switch_session':
            AppNavigation.push<void>(
              context,
              SessionSwitchScreen(
                onStudentContextUpdated: widget.onStudentContextUpdated,
              ),
            );
            break;
          case 'fee':
            AppNavigation.push(context, const FeeScreen(showBackButton: true));
            break;
          case 'attendance':
            AppNavigation.push(context, const AttendanceScreen());
            break;
          // case 'track_bus':
          //   AppNavigation.push(context, const TrackBusScreen());
          //   break;
          case 'holiday_calendar':
            AppNavigation.push(context, const CalendarScreen());
            break;
          case 'homework':
            AppNavigation.push(context, const HomeworkScreen());
            break;
          case 'notification':
            AppNavigation.push(
              context,
              const MessageScreen(showBackButton: true),
            );
            break;
          case 'class_test':
            AppNavigation.push(context, const ClassTestScreen());
            break;
          case 'results':
            AppNavigation.push(context, const ExamResultScreen());
            break;
          case 'timetable':
            AppNavigation.push(context, const TimetableScreen());
            break;
          case 'datesheet':
            AppNavigation.push(context, const DatesheetScreen());
            break;
          case 'syllabus':
            AppNavigation.push(context, const SyllabusScreen());
            break;
          case 'live_class':
            AppNavigation.push(context, const LiveClassScreen());
            break;
          case 'events_gallery':
            AppNavigation.push(context, const EventGalleryScreen());
            break;
          case 'notice_board':
            AppNavigation.push(context, const NoticeBoardScreen());
            break;
          case 'gate_pass':
            AppNavigation.push(context, const GatePassScreen());
            break;
          case 'change_language':
            AppNavigation.push(context, const ChangeLanguageScreen());
            break;
          case 'sign_out':
            _showLogoutDialog();
            break;
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: ThemeAdaptive.neutralFill(context),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(item.icon, color: AppColors.accentOrange, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                item.titleKey.tr,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: scheme.onSurface,
                ),
              ),
            ),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                border: Border.all(color: scheme.outlineVariant),
                shape: BoxShape.circle,
              ),
              child: const Center(child: Icon(Icons.chevron_right, size: 16)),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        final scheme = Theme.of(dialogContext).colorScheme;
        return Dialog(
          backgroundColor: scheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'logout_confirm_title'.tr,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: scheme.onSurface,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'logout_confirm_subtitle'.tr,
                  style: TextStyle(
                    fontSize: 16,
                    color: scheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.of(dialogContext).pop();
                          _performLogout();
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.accentOrange,
                          side: const BorderSide(
                            color: AppColors.accentOrange,
                            width: 1,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text(
                          'common_yes'.tr,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: () {
                          Navigator.of(dialogContext).pop();
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.accentOrange,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text(
                          'common_cancel'.tr,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _performLogout() async {
    await Get.find<AuthController>().logout();
  }
}

class _MoreItem {
  final String id;
  final IconData icon;
  final String titleKey;

  const _MoreItem({
    required this.id,
    required this.icon,
    required this.titleKey,
  });
}
