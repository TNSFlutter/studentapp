import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:studentapp/helpers/app_feature_guide.dart';
import 'package:studentapp/widgets/common_app_bar.dart';

import '../../helpers/app_navigation.dart';
import '../../helpers/select_student_tour_helper.dart';
import '../../helpers/theme_adaptive.dart';
import '../../constants/app_colors.dart';
import '../../helpers/feature_guide_showcase_ui.dart';
import '../../controllers/student_controller.dart';
import '../../controllers/student_profile_controller.dart';
import '../../models/student_models.dart';
import '../../services/navigation_service.dart';
import '../dashboard/dashboard_screen.dart';

class SelectStudentScreen extends StatefulWidget {
  const SelectStudentScreen({super.key});

  @override
  State<SelectStudentScreen> createState() => _SelectStudentScreenState();
}

class _SelectStudentScreenState extends State<SelectStudentScreen> {
  late final StudentController studentController;

  final GlobalKey _firstCardTourKey = GlobalKey();
  bool _tourScheduled = false;
  bool _tourStarted = false;
  int _tourStartAttempts = 0;

  String _initials(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((e) => e.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      final single = parts.first;
      return single.length >= 2
          ? single.substring(0, 2).toUpperCase()
          : single.toUpperCase();
    }
    return ('${parts[0][0]}${parts[1][0]}').toUpperCase();
  }

  String _displayInitials(Student student) {
    final fromApi = student.initials?.trim() ?? '';
    if (fromApi.isNotEmpty) return fromApi.toUpperCase();
    return _initials(student.student);
  }

  /// Only present/absent — hide chip for API `unknown`, `-`, empty, etc.
  bool _shouldShowAttendanceChip(Student student) {
    final v = student.attendanceToday.trim().toLowerCase();
    return v == 'present' ||
        v == 'p' ||
        v == 'absent' ||
        v == 'a';
  }

  ({String text, Color bg, Color fg}) _attendanceChipForKnownStatus(
    BuildContext context,
    Student student,
  ) {
    final v = student.attendanceToday.trim().toLowerCase();
    if (v == 'present' || v == 'p') {
      return (
        text: '✓ Present today',
        bg: ThemeAdaptive.softTint(context, const Color(0xFFDCFCE7)),
        fg: const Color(0xFF15803D),
      );
    }
    return (
      text: '✕ Absent today',
      bg: ThemeAdaptive.softTint(context, const Color(0xFFFFE4E6)),
      fg: const Color(0xFFB91C1C),
    );
  }

  ({String text, Color bg, Color fg}) _feeChip(
    BuildContext context,
    Student student,
  ) {
    if (student.pendingFee > 0) {
      return (
        text: '• ₹${student.pendingFee} due',
        bg: ThemeAdaptive.softTint(context, const Color(0xFFFFE4E6)),
        fg: const Color(0xFFB91C1C),
      );
    }
    return (
      text: '• ₹0 due',
      bg: ThemeAdaptive.neutralFill(context),
      fg: Theme.of(context).colorScheme.onSurfaceVariant,
    );
  }

  (Color, Color) _avatarColors(BuildContext context, int index) {
    const initialsFg = <Color>[
      Color(0xFF1D4ED8),
      Color(0xFFBE185D),
      Color(0xFF4F46E5),
    ];
    final fg = initialsFg[index % initialsFg.length];
    return (ThemeAdaptive.neutralFill(context), fg);
  }

  Widget _chip({required String text, required Color bg, required Color fg}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: fg,
          height: 1.2,
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    studentController = Get.put(StudentController());
    if (!Get.isRegistered<StudentProfileController>()) {
      Get.put(StudentProfileController());
    }
    _registerSelectStudentShowcase();
  }

  void _registerSelectStudentShowcase() {
    try {
      ShowcaseView.getNamed(AppFeatureGuide.selectStudentTourScope)
          .unregister();
    } catch (_) {}
    ShowcaseView.register(
      scope: AppFeatureGuide.selectStudentTourScope,
      blurValue: FeatureGuideShowcaseUi.selectStudentBlur,
      overlayOpacity: FeatureGuideShowcaseUi.selectStudentDimOpacity,
      overlayColor: FeatureGuideShowcaseUi.registerDimOverlay,
      skipIfTargetNotPresent: true,
      globalTooltipActionConfig: const TooltipActionConfig(
        position: TooltipActionPosition.inside,
        alignment: MainAxisAlignment.end,
        gapBetweenContentAndAction: 14,
      ),
      globalTooltipActions: [
        TooltipActionButton(
          type: TooltipDefaultActionType.skip,
          name: 'guide_got_it'.tr,
          backgroundColor: AppColors.accentOrange,
          textStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 14,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          borderRadius: BorderRadius.circular(14),
        ),
      ],
    );
  }

  void _unregisterSelectStudentShowcase() {
    try {
      ShowcaseView.getNamed(AppFeatureGuide.selectStudentTourScope)
          .unregister();
    } catch (_) {}
  }

  void _tryScheduleTour() {
    debugPrint(
      '[SelectStudent] tryScheduleTour: '
      'scheduled=$_tourScheduled, started=$_tourStarted, '
      'loading=${studentController.isLoading.value}, '
      'students=${studentController.students.length}',
    );
    if (!SelectStudentTourHelper.shouldScheduleTour(
      isLoading: studentController.isLoading.value,
      hasStudents: studentController.students.isNotEmpty,
      isTourScheduled: _tourScheduled,
      tourStarted: _tourStarted,
    )) {
      return;
    }

    _tourScheduled = true;
    _tourStartAttempts = 0;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _tourStarted) return;
      _startTourWhenTargetReady();
    });
  }

  void _startTourWhenTargetReady() {
    if (!mounted || _tourStarted) {
      return;
    }

    final ctx = _firstCardTourKey.currentContext;
    if (ctx == null || !ctx.mounted) {
      _tourStartAttempts++;
      if (_tourStartAttempts > 20) {
        debugPrint('[SelectStudent] tour target never mounted; giving up');
        _tourScheduled = false;
        return;
      }
      Future<void>.delayed(const Duration(milliseconds: 80), () {
        if (mounted) _startTourWhenTargetReady();
      });
      return;
    }

    final routeIsCurrent = ModalRoute.of(ctx)?.isCurrent ?? true;
    final overlay = Overlay.maybeOf(ctx, rootOverlay: true);
    if (!routeIsCurrent || overlay == null) {
      _tourStartAttempts++;
      if (_tourStartAttempts > 20) {
        debugPrint('[SelectStudent] tour overlay/route not ready; giving up');
        _tourScheduled = false;
        return;
      }
      Future<void>.delayed(const Duration(milliseconds: 80), () {
        if (mounted) _startTourWhenTargetReady();
      });
      return;
    }

    try {
      debugPrint('[SelectStudent] startShowCase');
      ShowcaseView.getNamed(AppFeatureGuide.selectStudentTourScope)
          .startShowCase([_firstCardTourKey]);
      _tourStarted = true;
    } catch (e) {
      _tourStartAttempts++;
      if (_tourStartAttempts > 20) {
        _tourScheduled = false;
        debugPrint('[SelectStudent] tour failed to start: $e');
        return;
      }
      Future<void>.delayed(const Duration(milliseconds: 80), () {
        if (mounted) _startTourWhenTargetReady();
      });
    }
  }

  @override
  void dispose() {
    _unregisterSelectStudentShowcase();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: ThemeAdaptive.pageBackground(context),
        appBar: CommonAppBar(
          title: 'Select Student',
          showBackButton: false,
          showNotificationIcon: false,
        ),
        body: Column(
          children: [
            // Main Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'YOUR CHILDREN',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.9,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Student Cards
                    Expanded(
                      child: Obx(() {
                        final isLoading = studentController.isLoading.value;
                        final hasStudents =
                            studentController.students.isNotEmpty;

                        if (isLoading) {
                          return Center(
                            child: CircularProgressIndicator(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          );
                        }

                        if (!hasStudents) {
                          return Center(
                            child: Text(
                              'No students found',
                              style: TextStyle(
                                fontSize: 16,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          );
                        }

                        final scheme = Theme.of(context).colorScheme;
                        return ListView.builder(
                          key: ValueKey<String>(
                            studentController.students
                                .map((s) => s.studentId)
                                .join(','),
                          ),
                          padding: EdgeInsets.zero,
                          itemCount: studentController.students.length + 1,
                          itemBuilder: (context, index) {
                            if (index == studentController.students.length) {
                              return Padding(
                                padding: EdgeInsets.only(top: 12),
                                child: Center(
                                  child: Text(
                                    'Tap a card to open their dashboard',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: scheme.onSurfaceVariant,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              );
                            }
                            final student = studentController.students[index];
                            final isSelected =
                                studentController.selectedStudentIndex.value ==
                                index;
                            final showAttendance =
                                _shouldShowAttendanceChip(student);
                            final attendanceChip = showAttendance
                                ? _attendanceChipForKnownStatus(
                                    context,
                                    student,
                                  )
                                : null;
                            final feeChip = _feeChip(context, student);
                            final avatar = _avatarColors(context, index);
                            final classLabel = (student.classSection ?? '—')
                                .trim();
                            final rollLabel =
                                (student.rollNo != null && student.rollNo! > 0)
                                ? '${student.rollNo}'
                                : '—';

                            final card = Padding(
                              key: ValueKey<int>(student.studentId),
                              padding: EdgeInsets.only(
                                bottom:
                                    index ==
                                        studentController.students.length - 1
                                    ? 0
                                    : 12,
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () => _selectStudent(student, index),
                                  borderRadius: BorderRadius.circular(14),
                                  child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.fromLTRB(
                                      14,
                                      14,
                                      14,
                                      14,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? ThemeAdaptive.neutralFillStrong(
                                              context,
                                            )
                                          : scheme.surface,
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                        color: isSelected
                                            ? AppColors.accentOrange
                                            : scheme.outlineVariant,
                                        width: isSelected ? 2 : 1,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: ThemeAdaptive.cardShadow(
                                            context,
                                            lightAlpha: 0.06,
                                          ),
                                          blurRadius: 10,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Stack(
                                      clipBehavior: Clip.none,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                CircleAvatar(
                                                  radius: 26,
                                                  backgroundColor: avatar.$1,
                                                  child: ClipOval(
                                                    child:
                                                        (student.photo !=
                                                                null &&
                                                            student.photo!
                                                                .trim()
                                                                .isNotEmpty)
                                                        ? Image.network(
                                                            student.photo!,
                                                            width: 52,
                                                            height: 52,
                                                            fit: BoxFit.cover,
                                                            errorBuilder: (_, __, ___) {
                                                              return Center(
                                                                child: Text(
                                                                  _displayInitials(
                                                                    student,
                                                                  ),
                                                                  style: TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontSize:
                                                                        15,
                                                                    color:
                                                                        avatar
                                                                            .$2,
                                                                  ),
                                                                ),
                                                              );
                                                            },
                                                          )
                                                        : Center(
                                                            child: Text(
                                                              _displayInitials(
                                                                student,
                                                              ),
                                                              style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 15,
                                                                color:
                                                                    avatar.$2,
                                                              ),
                                                            ),
                                                          ),
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                                Expanded(
                                                  child: Padding(
                                                    padding: EdgeInsets.only(
                                                      right: isSelected
                                                          ? 72
                                                          : 0,
                                                    ),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          student.student,
                                                          style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 16,
                                                            color: scheme
                                                                .onSurface,
                                                          ),
                                                          maxLines: 2,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                        const SizedBox(
                                                          height: 4,
                                                        ),
                                                        Text(
                                                          'Class $classLabel · Roll $rollLabel',
                                                          style: TextStyle(
                                                            fontSize: 13,
                                                            color: scheme
                                                                .onSurfaceVariant,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 12),
                                            Wrap(
                                              spacing: 8,
                                              runSpacing: 8,
                                              children: [
                                                if (attendanceChip != null)
                                                  _chip(
                                                    text: attendanceChip.text,
                                                    bg: attendanceChip.bg,
                                                    fg: attendanceChip.fg,
                                                  ),
                                                _chip(
                                                  text: feeChip.text,
                                                  bg: feeChip.bg,
                                                  fg: feeChip.fg,
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        if (isSelected)
                                          Positioned(
                                            top: 0,
                                            right: 0,
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                    vertical: 5,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: AppColors.accentOrange,
                                                borderRadius:
                                                    BorderRadius.circular(999),
                                              ),
                                              child: const Text(
                                                'ACTIVE',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w800,
                                                  fontSize: 10,
                                                  letterSpacing: 0.6,
                                                ),
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );

                            if (index == 0) {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                if (mounted) _tryScheduleTour();
                              });

                              return FeatureGuideShowcaseUi
                                  .selectStudentCardShowcase(
                                context: context,
                                showcaseKey: _firstCardTourKey,
                                title: 'guide_select_student_title'.tr,
                                description: 'guide_select_student_desc'.tr,
                                child: card,
                              );
                            }

                            return card;
                          },
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
    );
  }

  Future<void> _selectStudent(Student student, int index) async {
    if (index < 0 || index >= studentController.students.length) return;

    // Close overlay only — do not unregister here. [Showcase] children may still
    // rebuild until this route is disposed; unregistering early causes
    // "No ShowcaseView registered for scope _selectStudentTour".
    try {
      ShowcaseView.getNamed(AppFeatureGuide.selectStudentTourScope).dismiss();
    } catch (_) {}
    _tourStarted = false;

    studentController.selectedStudentIndex.value = index;

    final ok = await studentController.selectStudent(student.studentId);
    if (!mounted) return;
    if (!ok) return;

    if (Get.isRegistered<StudentProfileController>()) {
      Get.find<StudentProfileController>().clearCache();
    }

    _continueToDashboard();
  }

  void _continueToDashboard() {
    final selectedStudent = studentController.selectedStudent;
    if (selectedStudent == null) return;

    final map = studentController.dashboardMapForSelectedStudent();

    Route<void> buildRoute() {
      return AppNavigation.pageRouteSmoothEnter<void>(
        (_) => DashboardScreen(
          selectedStudent: map,
          emphasizeStudentOnEntry: true,
        ),
      );
    }

    void replace() {
      NavigationService.navigator?.pushReplacement(buildRoute());
    }

    // Same GlobalKey as GetMaterialApp — avoids Overlay issues from Get.off + Get.snackbar.
    if (NavigationService.navigator != null) {
      replace();
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) => replace());
    }
  }
}
