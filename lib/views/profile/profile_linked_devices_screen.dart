import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../controllers/auth_controller.dart';
import '../../helpers/device_info_helper.dart';
import '../../helpers/theme_adaptive.dart';
import '../../models/auth_session_models.dart';
import 'profile_theme.dart';

class ProfileLinkedDevicesScreen extends StatefulWidget {
  const ProfileLinkedDevicesScreen({super.key});

  @override
  State<ProfileLinkedDevicesScreen> createState() =>
      _ProfileLinkedDevicesScreenState();
}

class _ProfileLinkedDevicesScreenState extends State<ProfileLinkedDevicesScreen> {
  bool _push = true;
  bool _sms = true;
  bool _wa = false;

  bool _loading = true;
  String? _error;
  List<AuthSessionItem> _sessions = [];
  String _localDeviceId = '';
  bool _logoutAllInProgress = false;

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  Future<void> _loadSessions() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final local = await DeviceInfoHelper.instance.getDeviceInfo();
      if (!mounted) return;
      _localDeviceId = local.deviceId.trim();

      if (!Get.isRegistered<AuthController>()) {
        setState(() {
          _loading = false;
          _error = 'session_not_ready'.tr;
          _sessions = [];
        });
        return;
      }

      final result = await Get.find<AuthController>().fetchAuthSessions();
      if (!mounted) return;

      if (result.error != null) {
        setState(() {
          _loading = false;
          _error = result.error;
          _sessions = [];
        });
        return;
      }

      final sorted = List<AuthSessionItem>.from(result.sessions)
        ..sort((a, b) {
          final ca = _isThisDevice(a);
          final cb = _isThisDevice(b);
          if (ca != cb) return ca ? -1 : 1;
          final ta = a.lastActive;
          final tb = b.lastActive;
          if (ta == null && tb == null) return b.sessionId.compareTo(a.sessionId);
          if (ta == null) return 1;
          if (tb == null) return -1;
          return tb.compareTo(ta);
        });

      setState(() {
        _loading = false;
        _error = null;
        _sessions = sorted;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = e.toString();
          _sessions = [];
        });
      }
    }
  }

  Future<void> _onLogoutAllOther() async {
    if (!Get.isRegistered<AuthController>() || _logoutAllInProgress) return;
    setState(() => _logoutAllInProgress = true);
    final err = await Get.find<AuthController>().logoutAllOtherDevices();
    if (!mounted) return;
    setState(() => _logoutAllInProgress = false);
    if (err != null) {
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        SnackBar(content: Text(err)),
      );
      return;
    }
    ScaffoldMessenger.maybeOf(context)?.showSnackBar(
      SnackBar(content: Text('linked_devices_logged_out_others'.tr)),
    );
    await _loadSessions();
  }

  bool _isThisDevice(AuthSessionItem s) {
    if (_localDeviceId.isEmpty || s.deviceId.isEmpty) return false;
    return _localDeviceId.toLowerCase() == s.deviceId.toLowerCase();
  }

  String _relativeTime(DateTime? t) {
    if (t == null) return '—';
    final d = DateTime.now().difference(t);
    if (d.isNegative) return 'linked_devices_just_now'.tr;
    if (d.inSeconds < 45) return 'linked_devices_just_now'.tr;
    if (d.inMinutes < 60) return '${d.inMinutes}m ago';
    if (d.inHours < 24) return '${d.inHours}h ago';
    if (d.inDays < 7) return '${d.inDays}d ago';
    return DateFormat.yMMMd().format(t.toLocal());
  }

  String _expiresLine(DateTime? t) {
    if (t == null) return '${'linked_devices_expires'.tr}: —';
    final local = t.toLocal();
    return '${'linked_devices_expires'.tr} ${DateFormat('MMM d, y · HH:mm').format(local)}';
  }

  String _deviceTitle(AuthSessionItem s) {
    if (s.deviceName != null && s.deviceName!.trim().isNotEmpty) {
      return s.deviceName!.trim();
    }
    return switch (s.deviceType) {
      'ios' => 'linked_devices_ios'.tr,
      'android' => 'linked_devices_android'.tr,
      'web' => 'linked_devices_web'.tr,
      '' => 'linked_devices_unknown'.tr,
      final o => o[0].toUpperCase() + o.substring(1),
    };
  }

  String _deviceDetail(AuthSessionItem s) {
    final platform = s.deviceType.isEmpty ? 'linked_devices_unknown'.tr : s.deviceType;
    final last = _relativeTime(s.lastActive);
    final shortId = s.deviceId.length > 10
        ? '…${s.deviceId.substring(s.deviceId.length - 8)}'
        : s.deviceId;
    return '$platform · ${'linked_devices_last_active'.tr} $last · $shortId';
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final countLabel = _loading
        ? 'linked_devices_loading'.tr
        : '${_sessions.length} ${'linked_devices_active_sessions'.tr}';

    return Scaffold(
      backgroundColor: ThemeAdaptive.pageBackground(context),
      appBar: AppBar(
        backgroundColor: ProfileTheme.headerOrange,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('profile_linked_devices'.tr),
            Text(
              countLabel,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        color: ProfileTheme.headerOrange,
        onRefresh: _loadSessions,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: ThemeAdaptive.softTint(
                  context,
                  const Color(0xFFDCFCE7),
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.check_circle, color: scheme.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'linked_devices_limit_note'.tr,
                      style: TextStyle(fontSize: 13, color: scheme.onSurface),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'linked_devices_active_sessions_heading'.tr,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            if (_loading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Center(
                  child: CircularProgressIndicator(color: ProfileTheme.headerOrange),
                ),
              )
            else if (_error != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Column(
                  children: [
                    Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: scheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: _loadSessions,
                      style: FilledButton.styleFrom(
                        backgroundColor: ProfileTheme.headerOrange,
                        foregroundColor: Colors.white,
                      ),
                      child: Text('common_retry'.tr),
                    ),
                  ],
                ),
              )
            else if (_sessions.isEmpty)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text(
                    'linked_devices_none'.tr,
                    style: TextStyle(color: scheme.onSurfaceVariant),
                  ),
                ),
              )
            else
              ..._sessions.map(
                (s) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _deviceCard(
                    context,
                    title: _deviceTitle(s),
                    detail: _deviceDetail(s),
                    expiresLine: _expiresLine(s.expiresAt),
                    isThisDevice: _isThisDevice(s),
                  ),
                ),
              ),
            const SizedBox(height: 20),
            Text(
              'linked_devices_notification_preferences'.tr,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            _toggleTile(
              context,
              'linked_devices_push'.tr,
              'linked_devices_push_sub'.tr,
              _push,
              (v) => setState(() => _push = v),
            ),
            _toggleTile(
              context,
              'linked_devices_sms'.tr,
              'linked_devices_sms_sub'.tr,
              _sms,
              (v) => setState(() => _sms = v),
            ),
            _toggleTile(
              context,
              'linked_devices_wa'.tr,
              'linked_devices_wa_sub'.tr,
              _wa,
              (v) => setState(() => _wa = v),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: scheme.errorContainer,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: scheme.outlineVariant),
              ),
              child: Row(
                children: [
                  Icon(Icons.lock_outline, color: scheme.error),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'linked_devices_logout_all_others'.tr,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: scheme.onErrorContainer,
                          ),
                        ),
                        Text(
                          'linked_devices_keep_this'.tr,
                          style: TextStyle(
                            fontSize: 12,
                            color: scheme.onErrorContainer.withValues(alpha: 0.85),
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: _loading || _logoutAllInProgress
                        ? null
                        : _onLogoutAllOther,
                    style: TextButton.styleFrom(foregroundColor: scheme.error),
                    child: _logoutAllInProgress
                        ? SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: scheme.error,
                            ),
                          )
                        : Text('common_apply'.tr),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _deviceCard(
    BuildContext context, {
    required String title,
    required String detail,
    required String expiresLine,
    required bool isThisDevice,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(14),
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
          CircleAvatar(
            backgroundColor: ThemeAdaptive.neutralFill(context),
            child: Icon(Icons.smartphone, color: scheme.onSurfaceVariant),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: scheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  detail,
                  style: TextStyle(
                    fontSize: 12,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  expiresLine,
                  style: TextStyle(
                    fontSize: 11,
                    color: scheme.onSurfaceVariant.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (isThisDevice)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: ThemeAdaptive.softTint(
                  context,
                  const Color(0xFFDCFCE7),
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'linked_devices_this_device'.tr,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: scheme.primary,
                ),
              ),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: ThemeAdaptive.neutralFill(context),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'linked_devices_other'.tr,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _toggleTile(
    BuildContext context,
    String title,
    String sub,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: scheme.onSurface,
                  ),
                ),
                Text(
                  sub,
                  style: TextStyle(
                    fontSize: 12,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: ProfileTheme.headerOrange,
          ),
        ],
      ),
    );
  }
}
