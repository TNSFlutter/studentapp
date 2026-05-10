import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../constants/app_colors.dart';
import '../../controllers/student_controller.dart';
import '../../helpers/theme_adaptive.dart';
import '../../models/available_sessions_models.dart';

/// Full-screen session picker (same flow as the former modal sheet).
class SessionSwitchScreen extends StatefulWidget {
  final void Function(Map<String, dynamic> updatedMap)? onStudentContextUpdated;

  const SessionSwitchScreen({super.key, this.onStudentContextUpdated});

  @override
  State<SessionSwitchScreen> createState() => _SessionSwitchScreenState();
}

class _SessionSwitchScreenState extends State<SessionSwitchScreen> {
  late final StudentController _controller = Get.isRegistered<StudentController>()
      ? Get.find<StudentController>()
      : Get.put(StudentController());

  bool _loading = true;
  bool _submitting = false;
  String? _error;
  List<AvailableSessionItem> _sessions = const [];
  int? _targetClassStudentId;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final res = await _controller.fetchAvailableSessions();
    if (!mounted) return;
    if (!res.success) {
      setState(() {
        _loading = false;
        _error = res.message.isNotEmpty
            ? res.message
            : 'session_switch_load_error'.tr;
      });
      return;
    }
    if (res.sessions.isEmpty) {
      setState(() {
        _sessions = const [];
        _targetClassStudentId = null;
        _loading = false;
        _error = 'session_switch_empty'.tr;
      });
      return;
    }
    int? initial;
    for (final e in res.sessions) {
      if (e.isSelected && e.classStudentId != null) {
        initial = e.classStudentId;
        break;
      }
    }
    initial ??= res.sessions
        .map((e) => e.classStudentId)
        .firstWhere((id) => id != null, orElse: () => null);

    setState(() {
      _sessions = res.sessions;
      _targetClassStudentId = initial;
      _loading = false;
      _error = null;
    });
  }

  AvailableSessionItem? get _initialSelected {
    for (final e in _sessions) {
      if (e.isSelected) return e;
    }
    return null;
  }

  Future<void> _apply() async {
    final id = _targetClassStudentId;
    if (id == null || _submitting) return;
    final initial = _initialSelected?.classStudentId;
    if (initial != null && id == initial) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('session_switch_already_active'.tr)),
      );
      return;
    }

    setState(() => _submitting = true);
    final res = await _controller.changeSession(id);
    if (!mounted) return;

    if (!res.success) {
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            res.message.isNotEmpty ? res.message : 'session_switch_failed'.tr,
          ),
        ),
      );
      return;
    }

    await _controller.refreshAfterSessionChange();
    if (!mounted) return;

    setState(() => _submitting = false);

    final cb = widget.onStudentContextUpdated;
    if (cb != null) {
      cb(_controller.dashboardMapForSelectedStudent());
    }

    final msg = res.message.isNotEmpty
        ? res.message
        : 'session_switch_success'.tr;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      appBar: AppBar(
        title: Text('session_switch_title'.tr),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: Text(
              'session_switch_subtitle'.tr,
              style: TextStyle(
                fontSize: 13,
                color: scheme.onSurfaceVariant,
                height: 1.35,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: _loading
                ? Center(
                    child: CircularProgressIndicator(color: scheme.primary),
                  )
                : _error != null
                    ? Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _error!,
                              textAlign: TextAlign.center,
                              style: TextStyle(color: scheme.error),
                            ),
                            const SizedBox(height: 12),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _loading = true;
                                  _error = null;
                                });
                                _load();
                              },
                              child: Text('common_retry'.tr),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                        itemCount: _sessions.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final e = _sessions[index];
                          final cid = e.classStudentId;
                          final on =
                              cid != null && _targetClassStudentId == cid;
                          final canSwitch = cid != null;

                          return Material(
                            color: ThemeAdaptive.neutralFill(context),
                            borderRadius: BorderRadius.circular(12),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: !canSwitch || _submitting
                                  ? null
                                  : () => setState(
                                        () => _targetClassStudentId = cid,
                                      ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Flexible(
                                                child: Text(
                                                  e.name.isNotEmpty
                                                      ? e.name
                                                      : '—',
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w700,
                                                    color: scheme.onSurface,
                                                  ),
                                                ),
                                              ),
                                              if (e.isCurrentYear) ...[
                                                const SizedBox(width: 8),
                                                Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    horizontal: 8,
                                                    vertical: 2,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color:
                                                        ThemeAdaptive.softTint(
                                                      context,
                                                      const Color(0xFFDCFCE7),
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            999),
                                                  ),
                                                  child: Text(
                                                    'session_switch_current_year'
                                                        .tr,
                                                    style: const TextStyle(
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      color: Color(0xFF15803D),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            [
                                              if ((e.classSection ?? '')
                                                  .isNotEmpty)
                                                e.classSection!,
                                              if (e.rollNo != null)
                                                '${'profile_roll'.tr} ${e.rollNo}',
                                            ].join(' · '),
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: scheme.onSurfaceVariant,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Switch.adaptive(
                                      value: on,
                                      onChanged: !canSwitch || _submitting
                                          ? null
                                          : (v) {
                                              if (v) {
                                                setState(
                                                  () =>
                                                      _targetClassStudentId =
                                                          cid,
                                                );
                                              }
                                            },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
          if (!_loading && _error == null)
            Padding(
              padding: EdgeInsets.fromLTRB(20, 8, 20, 12 + bottomInset),
              child: FilledButton(
                onPressed: _submitting ||
                        _targetClassStudentId == null ||
                        _targetClassStudentId ==
                            _initialSelected?.classStudentId
                    ? null
                    : _apply,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.accentOrange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _submitting
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text('session_switch_apply'.tr),
              ),
            ),
        ],
      ),
    );
  }
}
