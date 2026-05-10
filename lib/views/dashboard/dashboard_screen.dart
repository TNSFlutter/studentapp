import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:showcaseview/showcaseview.dart';

import '../../constants/app_colors.dart';
import '../../helpers/app_feature_guide.dart';
import '../../helpers/feature_guide_showcase_ui.dart';
import '../../widgets/bottom_navigation.dart';
import '../../widgets/bottom_nav_scope.dart';
import '../fees/fee_screen.dart';
import '../homework/homework_screen.dart';
import '../message/message_screen.dart';
import '../more/more_screen.dart';
import 'home_screen.dart';

class DashboardScreen extends StatefulWidget {
  final Map<String, dynamic> selectedStudent;
  final int initialNavIndex;

  /// One-shot pulse/highlight on the home student card (e.g. after choosing a child).
  final bool emphasizeStudentOnEntry;

  const DashboardScreen({
    super.key,
    required this.selectedStudent,
    this.initialNavIndex = 0,
    this.emphasizeStudentOnEntry = false,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentNavIndex = 0;

  late Map<String, dynamic> _studentMap;

  /// Cleared after first highlight window so rebuilds (tour) don't re-trigger flash.
  late bool _emphasizeStudentEntry;
  late List<Widget> _screens;

  /// Wraps targets with [Showcase] — enabled only after a short delay so APIs/snackbars run first.
  bool _allowGuideUI = false;

  /// User has not finished the persisted tour yet (may wait for Home tab).
  bool _wantGuideTour = false;

  final AppFeatureGuideKeys _guideKeys = AppFeatureGuideKeys();

  bool _guideCompletionHandled = false;

  bool _guideTourStarted = false;

  /// Delay before attaching Showcase so network errors / Get.snackbar are not blocked by showcase overlay.
  static const Duration _guideAttachDelay = Duration(milliseconds: 500);

  static const Duration _guideAttachDelayAfterHomeTap = Duration(milliseconds: 200);

  void _maybeScheduleFeatureGuide() {
    if (!_allowGuideUI ||
        _guideCompletionHandled ||
        _guideTourStarted ||
        _currentNavIndex != 0) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_allowGuideUI || _currentNavIndex != 0) return;
      _startFeatureGuide();
    });
  }

  /// Turns on Showcase wrappers + registers controller when Home is visible (never during cold API spam).
  void _activateGuideChromeIfReady() {
    if (!mounted ||
        !_wantGuideTour ||
        AppFeatureGuide.isCompleted ||
        _allowGuideUI ||
        _guideCompletionHandled) {
      return;
    }
    if (_currentNavIndex != 0) return;

    // Register before setState: [Showcase] mounts during the rebuild and
    // initState calls getScope — registration cannot wait until post-frame.
    _registerFeatureGuideView();

    setState(() {
      _allowGuideUI = true;
      _rebuildScreens();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _maybeScheduleFeatureGuide();
    });
  }

  void _scheduleGuideActivation({required Duration delay}) {
    Future<void>.delayed(delay, () {
      if (!mounted) return;
      _activateGuideChromeIfReady();
    });
  }

  void _rebuildScreens() {
    final guideKeys = _allowGuideUI ? _guideKeys : null;
    _screens = [
      HomeScreen(
        selectedStudent: _studentMap,
        onStudentContextUpdated: _onStudentContextUpdated,
        guideKeys: guideKeys,
        emphasizeStudentCard: _emphasizeStudentEntry,
      ),
      const HomeworkScreen(),
      const FeeScreen(showBackButton: false),
      const MessageScreen(showBackButton: false),
      MoreScreen(
        selectedStudent: _studentMap,
        onStudentContextUpdated: _onStudentContextUpdated,
      ),
    ];
  }

  void _onStudentContextUpdated(Map<String, dynamic> map) {
    setState(() {
      _studentMap = Map<String, dynamic>.from(map);
      _rebuildScreens();
    });
  }

  void _registerFeatureGuideView() {
    try {
      ShowcaseView.getNamed(AppFeatureGuide.dashboardShowcaseScope)
          .unregister();
    } catch (_) {}
    final scheme = Theme.of(context).colorScheme;
    ShowcaseView.register(
      scope: AppFeatureGuide.dashboardShowcaseScope,
      blurValue: FeatureGuideShowcaseUi.dashboardBlur,
      overlayOpacity: FeatureGuideShowcaseUi.dashboardDimOpacity,
      overlayColor: FeatureGuideShowcaseUi.dashboardDimOverlay(context),
      enableAutoScroll: true,
      skipIfTargetNotPresent: true,
      onDismiss: (_) => _completeFeatureGuide(),
      onFinish: () => _completeFeatureGuide(),
      globalTooltipActionConfig: const TooltipActionConfig(
        position: TooltipActionPosition.inside,
        alignment: MainAxisAlignment.spaceBetween,
        actionGap: 12,
        gapBetweenContentAndAction: 16,
      ),
      globalFloatingActionWidget: (showcaseContext) => FloatingActionWidget(
        left: 16,
        bottom: 16,
        child: SafeArea(
          minimum: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Material(
              elevation: 12,
              shadowColor: Colors.black.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(18),
              color: Theme.of(showcaseContext).colorScheme.surface,
              child: InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: () {
                  try {
                    ShowcaseView.get().dismiss();
                  } catch (_) {}
                  _completeFeatureGuide();
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 14,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.flag_rounded,
                        size: 22,
                        color: AppColors.accentOrange,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'guide_skip'.tr,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                          color: AppColors.accentOrange,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      globalTooltipActions: [
        TooltipActionButton(
          type: TooltipDefaultActionType.previous,
          name: 'guide_previous'.tr,
          hideActionWidgetForShowcase: [_guideKeys.studentCard],
          backgroundColor: scheme.surfaceContainerLow,
          textStyle: TextStyle(
            color: scheme.onSurface,
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: scheme.outlineVariant),
        ),
        TooltipActionButton(
          type: TooltipDefaultActionType.next,
          name: 'guide_next'.tr,
          hideActionWidgetForShowcase: [_guideKeys.bottomNavigation],
          backgroundColor: AppColors.accentOrange,
          textStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 14,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          borderRadius: BorderRadius.circular(14),
        ),
        TooltipActionButton(
          type: TooltipDefaultActionType.skip,
          name: 'guide_finish_tour'.tr,
          hideActionWidgetForShowcase: [
            _guideKeys.studentCard,
            _guideKeys.payNowButton,
            ..._guideKeys.quickActionKeys,
            _guideKeys.recentNotifications,
          ],
          backgroundColor: AppColors.accentOrange,
          textStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 14,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          borderRadius: BorderRadius.circular(14),
        ),
      ],
    );
  }

  void _startFeatureGuide() {
    if (!mounted || !_allowGuideUI || _guideTourStarted) return;
    _guideTourStarted = true;
    ShowcaseView.getNamed(AppFeatureGuide.dashboardShowcaseScope).startShowCase([
      _guideKeys.studentCard,
      _guideKeys.payNowButton,
      ..._guideKeys.quickActionKeys,
      _guideKeys.recentNotifications,
      _guideKeys.bottomNavigation,
    ]);
  }

  void _completeFeatureGuide() {
    if (_guideCompletionHandled) return;
    _guideCompletionHandled = true;
    _wantGuideTour = false;
    AppFeatureGuide.markCompleted();
    try {
      ShowcaseView.getNamed(AppFeatureGuide.dashboardShowcaseScope).unregister();
    } catch (_) {}
    if (!mounted) return;
    setState(() {
      _allowGuideUI = false;
      _rebuildScreens();
    });
  }

  @override
  void initState() {
    super.initState();
    _studentMap = Map<String, dynamic>.from(widget.selectedStudent);
    _currentNavIndex = widget.initialNavIndex.clamp(0, 4);
    _emphasizeStudentEntry = widget.emphasizeStudentOnEntry;
    _wantGuideTour = !AppFeatureGuide.isCompleted;
    _allowGuideUI = false;
    _rebuildScreens();

    if (_emphasizeStudentEntry) {
      Future<void>.delayed(const Duration(milliseconds: 2600), () {
        if (!mounted) return;
        setState(() => _emphasizeStudentEntry = false);
      });
    }

    if (_wantGuideTour) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scheduleGuideActivation(delay: _guideAttachDelay);
      });
    }
  }

  @override
  void dispose() {
    try {
      ShowcaseView.getNamed(AppFeatureGuide.dashboardShowcaseScope).unregister();
    } catch (_) {}
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BottomNavScope(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 260),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          child: KeyedSubtree(
            key: ValueKey<int>(_currentNavIndex),
            child: _screens[_currentNavIndex],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavigation(
        currentIndex: _currentNavIndex,
        featureGuideKeys: _allowGuideUI ? _guideKeys : null,
        onTap: (index) {
          if (index == _currentNavIndex) return;
          setState(() {
            _currentNavIndex = index;
          });
          if (index == 0 &&
              _wantGuideTour &&
              !_allowGuideUI &&
              !_guideCompletionHandled) {
            _scheduleGuideActivation(delay: _guideAttachDelayAfterHomeTap);
          }
          _maybeScheduleFeatureGuide();
        },
      ),
    );
  }
}
