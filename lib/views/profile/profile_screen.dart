import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../helpers/app_navigation.dart';
import '../../helpers/theme_adaptive.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/student_controller.dart';
import '../../controllers/student_profile_controller.dart';
import '../../models/student_profile_models.dart';
import '../../widgets/bottom_navigation.dart';
import '../dashboard/dashboard_screen.dart';
import '../fees/fee_screen.dart';
import '../message/message_screen.dart';
import 'edit_student_info_screen.dart';
import 'profile_app_settings_screen.dart';
import 'profile_change_password_ui_screen.dart';
import 'profile_help_support_screen.dart';
import 'profile_linked_devices_screen.dart';
import 'profile_logout_screen.dart';
import 'profile_notification_settings_screen.dart';
import 'profile_personal_info_screen.dart';
import 'profile_send_feedback_screen.dart';
import 'profile_terms_privacy_screen.dart';
import 'profile_theme.dart';

class ProfileScreen extends StatefulWidget {
  final Map<String, dynamic> selectedStudent;
  final bool showBottomNav;

  const ProfileScreen({
    super.key,
    required this.selectedStudent,
    this.showBottomNav = false,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final StudentProfileController _profileCtrl;

  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<StudentProfileController>()) {
      Get.put(StudentProfileController());
    }
    _profileCtrl = Get.find<StudentProfileController>();
    if (!Get.isRegistered<StudentController>()) {
      Get.put(StudentController());
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _profileCtrl.refreshProfile();
    });
  }

  Map<String, dynamic> get _selectedStudent => widget.selectedStudent;

  String _fallbackStudentName() =>
      _selectedStudent['name']?.toString() ??
      _selectedStudent['student']?.toString() ??
      'Student';

  String _studentNameFromSummary(ProfileSummary s) {
    final n = s.fullName.trim();
    return n.isNotEmpty ? n : _fallbackStudentName();
  }

  String _studentPhotoUrl(ProfileSummary? s) {
    final fromSummary = s?.photo?.trim() ?? '';
    if (fromSummary.isNotEmpty) return fromSummary;
    return _selectedStudent['photo']?.toString().trim() ?? '';
  }

  String _studentClass(ProfileSummary? s) {
    final v = s?.classSection.trim() ?? '';
    if (v.isNotEmpty) return v;
    return _selectedStudent['class']?.toString().trim() ?? '—';
  }

  String _studentRoll(ProfileSummary? s) {
    if (s != null && s.rollNo > 0) return '${s.rollNo}';
    return _selectedStudent['rollNumber']?.toString().trim().isNotEmpty == true
        ? _selectedStudent['rollNumber'].toString().trim()
        : (_selectedStudent['rollNo']?.toString().trim().isNotEmpty == true
              ? _selectedStudent['rollNo'].toString().trim()
              : '—');
  }

  String _studentAdmissionNo(ProfileSummary? s) {
    final v = s?.admissionNo.trim() ?? '';
    if (v.isNotEmpty) return v;
    return _selectedStudent['admissionNo']?.toString().trim().isNotEmpty == true
        ? _selectedStudent['admissionNo'].toString().trim()
        : (_selectedStudent['admission_no']?.toString().trim().isNotEmpty ==
                  true
              ? _selectedStudent['admission_no'].toString().trim()
              : '—');
  }

  int _childrenCountForStats() {
    // Profile now represents only the currently selected child.
    return 1;
  }

  String _parentDisplayName() {
    if (Get.isRegistered<AuthController>()) {
      final u = Get.find<AuthController>().currentUser;
      final n = u?.name.trim();
      if (n != null && n.isNotEmpty) return n;
    }
    return 'Parent';
  }

  String _parentPhone() {
    if (Get.isRegistered<AuthController>()) {
      final p =
          Get.find<AuthController>().currentUser?.phoneNumber.trim() ?? '';
      if (p.isNotEmpty) {
        if (p.startsWith('+')) return p;
        return '+91 $p';
      }
    }
    return '';
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

  void _onBottomNavTap(int index) {
    if (index == 4) return;
    AppNavigation.pushReplacement(
      context,
      DashboardScreen(
        selectedStudent: _selectedStudent,
        initialNavIndex: index,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final parentName = _parentDisplayName();
    final phone = _parentPhone();
    final phoneLine = phone.isNotEmpty ? phone : 'profile_add_phone'.tr;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: RefreshIndicator(
        onRefresh: () => _profileCtrl.refreshProfile(),
        child: Obx(() {
          final summary = _profileCtrl.profile.value?.summary;
          final childName = summary != null
              ? _studentNameFromSummary(summary)
              : _fallbackStudentName();
          final childCount = _childrenCountForStats();
          final err = _profileCtrl.loadError.value;
          final loading = _profileCtrl.isLoading.value && summary == null;

          return CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: _header(
                  context,
                  childName,
                  _studentClass(summary),
                  _studentRoll(summary),
                  _studentAdmissionNo(summary),
                  _studentPhotoUrl(summary),
                ),
              ),
              SliverToBoxAdapter(child: _quickStats(childCount: childCount)),
              if (loading)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: SizedBox(
                        width: 28,
                        height: 28,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  ),
                ),
              if (err.isNotEmpty && summary == null && !loading)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: Builder(
                      builder: (context) {
                        final scheme = Theme.of(context).colorScheme;
                        return Material(
                          color: scheme.errorContainer,
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  err,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: scheme.onErrorContainer,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () => _profileCtrl.refreshProfile(),
                                  child: Text('common_retry'.tr),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 20)),
              SliverToBoxAdapter(
                child: _sectionTitle('profile_section_account'.tr),
              ),
              SliverToBoxAdapter(
                child: _menuBlock([
                  _MenuRow(
                    icon: Icons.person_rounded,
                    iconBg: ThemeAdaptive.neutralFill(context),
                    iconColor: const Color(0xFF2563EB),
                    title: 'profile_personal_info'.tr,
                    subtitle: 'profile_personal_info_subtitle'.tr,
                    onTap: () => AppNavigation.push<void>(
                      context,
                      EditStudentInfoScreen(student: _selectedStudent),
                    ),
                  ),
                  _MenuRow(
                    icon: Icons.lock_rounded,
                    iconBg: ThemeAdaptive.neutralFill(context),
                    iconColor: const Color(0xFF059669),
                    title: 'profile_change_password'.tr,
                    subtitle: 'profile_change_password_subtitle'.tr,
                    onTap: () async {
                      final ok = await AppNavigation.push<bool>(
                        context,
                        const ProfileChangePasswordUiScreen(),
                      );
                      if (!context.mounted) return;
                      if (ok == true) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('profile_password_updated'.tr),
                          ),
                        );
                      }
                    },
                  ),
                  _MenuRow(
                    icon: Icons.smartphone_rounded,
                    iconBg: ThemeAdaptive.neutralFill(context),
                    iconColor: ProfileTheme.headerOrange,
                    title: 'profile_linked_devices'.tr,
                    subtitle: 'profile_linked_devices_subtitle'.tr,
                    onTap: () => AppNavigation.push(
                      context,
                      const ProfileLinkedDevicesScreen(),
                    ),
                  ),
                ]),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
              SliverToBoxAdapter(
                child: _sectionTitle('profile_section_preferences'.tr),
              ),
              SliverToBoxAdapter(
                child: _menuBlock([
                  _MenuRow(
                    icon: Icons.notifications_active_rounded,
                    iconBg: ThemeAdaptive.neutralFill(context),
                    iconColor: const Color(0xFF2563EB),
                    title: 'notifications_title'.tr,
                    subtitle: 'profile_notifications_subtitle'.tr,
                    onTap: () => AppNavigation.push(
                      context,
                      const ProfileNotificationSettingsScreen(),
                    ),
                  ),
                  _MenuRow(
                    icon: Icons.settings_rounded,
                    iconBg: ThemeAdaptive.neutralFill(context),
                    iconColor: const Color(0xFF7C3AED),
                    title: 'profile_app_settings'.tr,
                    subtitle: 'profile_app_settings_subtitle'.tr,
                    onTap: () => AppNavigation.push(
                      context,
                      const ProfileAppSettingsScreen(),
                    ),
                  ),
                ]),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
              SliverToBoxAdapter(
                child: _sectionTitle('profile_section_support'.tr),
              ),
              SliverToBoxAdapter(
                child: _menuBlock([
                  _MenuRow(
                    icon: Icons.support_agent_rounded,
                    iconBg: ThemeAdaptive.neutralFill(context),
                    iconColor: const Color(0xFF059669),
                    title: 'profile_help_support'.tr,
                    subtitle: 'profile_help_support_subtitle'.tr,
                    onTap: () => AppNavigation.push(
                      context,
                      const ProfileHelpSupportScreen(),
                    ),
                  ),
                  _MenuRow(
                    icon: Icons.edit_note_rounded,
                    iconBg: ThemeAdaptive.neutralFill(context),
                    iconColor: const Color(0xFFCA8A04),
                    title: 'profile_send_feedback'.tr,
                    subtitle: 'profile_send_feedback_subtitle'.tr,
                    onTap: () => AppNavigation.push(
                      context,
                      const ProfileSendFeedbackScreen(),
                    ),
                  ),
                  _MenuRow(
                    icon: Icons.article_outlined,
                    iconBg: ThemeAdaptive.neutralFill(context),
                    iconColor: const Color(0xFF2563EB),
                    title: 'profile_terms_privacy'.tr,
                    subtitle: 'App version 1.2.4',
                    onTap: () => AppNavigation.push(
                      context,
                      const ProfileTermsPrivacyScreen(),
                    ),
                  ),
                ]),
              ),
              SliverToBoxAdapter(
                child: _logoutCard(
                  context,
                  parentName: parentName,
                  phone: phoneLine,
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          );
        }),
      ),
      bottomNavigationBar: widget.showBottomNav
          ? CustomBottomNavigation(currentIndex: 4, onTap: _onBottomNavTap)
          : null,
    );
  }

  Widget _header(
    BuildContext context,
    String studentName,
    String classLabel,
    String rollNo,
    String admissionNo,
    String studentPhotoUrl,
  ) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(color: ProfileTheme.headerOrange),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (!widget.showBottomNav)
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 44,
                        minHeight: 44,
                      ),
                      onPressed: () => Navigator.of(context).maybePop(),
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                      tooltip: MaterialLocalizations.of(
                        context,
                      ).backButtonTooltip,
                    )
                  else
                    const SizedBox(width: 40),
                  Expanded(
                    child: Text(
                      'profile_title'.tr,
                      textAlign: widget.showBottomNav
                          ? TextAlign.start
                          : TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.notifications_none_rounded,
                      color: Colors.white,
                      size: 26,
                    ),
                    style: IconButton.styleFrom(
                      side: const BorderSide(color: Colors.white, width: 1.2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                height: 1,
                color: Colors.white.withValues(alpha: 0.3),
              ),
              const SizedBox(height: 10),
              Stack(
                clipBehavior: Clip.none,
                children: [
                  CircleAvatar(
                    radius: 48,
                    backgroundColor: Colors.white,
                    child: ClipOval(
                      child: studentPhotoUrl.isNotEmpty
                          ? Image.network(
                              studentPhotoUrl,
                              width: 96,
                              height: 96,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Center(
                                child: Text(
                                  _initials(studentName),
                                  style: const TextStyle(
                                    color: ProfileTheme.headerOrange,
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            )
                          : Center(
                              child: Text(
                                _initials(studentName),
                                style: const TextStyle(
                                  color: ProfileTheme.headerOrange,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                    ),
                  ),
                  Positioned(
                    right: -4,
                    bottom: -2,
                    child: Material(
                      color: Colors.white,
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: () {
                          AppNavigation.push(
                            context,
                            const ProfilePersonalInfoScreen(),
                          );
                        },
                        child: const Padding(
                          padding: EdgeInsets.all(6),
                          child: Icon(
                            Icons.edit_square,
                            size: 16,
                            color: ProfileTheme.headerOrange,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                studentName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  _studentMetaChip('${'common_class'.tr} $classLabel'),
                  _studentMetaChip('${'profile_roll'.tr} $rollNo'),
                  _studentMetaChip('${'profile_adm'.tr} $admissionNo'),
                ],
              ),
              const SizedBox(height: 12),
              const SizedBox(height: 6),
            ],
          ),
        ),
      ),
    );
  }

  Widget _studentMetaChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _quickStats({required int childCount}) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final childLabel = childCount == 1
        ? '1 ${'profile_child'.tr}'
        : '$childCount ${'profile_children'.tr}';
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Container(
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(
                alpha: theme.brightness == Brightness.dark ? 0.28 : 0.08,
              ),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _statCell(
                  label: 'profile_children'.tr,
                  value: childLabel,
                  valueColor: scheme.onSurface,
                  tint: ThemeAdaptive.neutralFill(context),
                ),
              ),
              Container(width: 1, color: scheme.outlineVariant),
              Expanded(
                child: _statCell(
                  label: 'profile_fee_due'.tr,
                  value: 'profile_see_fee_tab'.tr,
                  valueColor: ProfileTheme.feeDueRed,
                  tint: ThemeAdaptive.neutralFill(context),
                  onTap: () => AppNavigation.push(
                    context,
                    const FeeScreen(showBackButton: true),
                  ),
                ),
              ),
              Container(width: 1, color: scheme.outlineVariant),
              Expanded(
                child: _statCell(
                  label: 'notifications_title'.tr,
                  value: 'nav_messages'.tr,
                  valueColor: ProfileTheme.notifGreen,
                  tint: ThemeAdaptive.neutralFill(context),
                  onTap: () => AppNavigation.push(
                    context,
                    const MessageScreen(showBackButton: true),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statCell({
    required String label,
    required String value,
    required Color valueColor,
    required Color tint,
    VoidCallback? onTap,
  }) {
    final scheme = Theme.of(context).colorScheme;
    final content = ColoredBox(
      color: tint,
      child: SizedBox.expand(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  color: scheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                value,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: valueColor,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (onTap == null) return content;
    return Material(
      color: Colors.transparent,
      child: InkWell(onTap: onTap, child: content),
    );
  }

  Widget _sectionTitle(String t) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          t,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.9,
            color: scheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  Widget _menuBlock(List<_MenuRow> rows) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(
                alpha: theme.brightness == Brightness.dark ? 0.28 : 0.05,
              ),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            for (int i = 0; i < rows.length; i++) ...[
              rows[i],
              if (i != rows.length - 1)
                Divider(height: 1, thickness: 1, color: scheme.outlineVariant),
            ],
          ],
        ),
      ),
    );
  }

  Widget _logoutCard(
    BuildContext context, {
    required String parentName,
    required String phone,
  }) {
    final scheme = Theme.of(context).colorScheme;
    final initials = _initials(parentName);
    final signedLine = phone.isNotEmpty && phone != 'profile_add_phone'.tr
        ? '${'profile_signed_in_as'.tr} $phone'
        : 'profile_signed_in'.tr;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Material(
        color: scheme.errorContainer,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            AppNavigation.push(
              context,
              ProfileLogoutScreen(
                parentName: parentName,
                phone: phone,
                initials: initials,
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: scheme.outlineVariant),
            ),
            child: Row(
              children: [
                Icon(Icons.logout_rounded, color: scheme.onErrorContainer),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'more_sign_out'.tr,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: scheme.onErrorContainer,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        signedLine,
                        style: TextStyle(
                          fontSize: 12,
                          color: scheme.onErrorContainer.withValues(alpha: 0.85),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: scheme.onErrorContainer),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _MenuRow({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: iconBg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: iconColor, size: 22),
      ),
      title: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.w600, color: scheme.onSurface),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
      ),
      trailing: Icon(Icons.chevron_right, color: scheme.onSurfaceVariant),
      onTap: onTap,
    );
  }
}
