import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/auth_controller.dart';
import '../../helpers/theme_adaptive.dart';
import 'profile_theme.dart';

class ProfileChangePasswordUiScreen extends StatefulWidget {
  const ProfileChangePasswordUiScreen({super.key});

  @override
  State<ProfileChangePasswordUiScreen> createState() =>
      _ProfileChangePasswordUiScreenState();
}

class _ProfileChangePasswordUiScreenState
    extends State<ProfileChangePasswordUiScreen> {
  final _current = TextEditingController();
  final _newPwd = TextEditingController();
  final _confirm = TextEditingController();

  bool _curVis = false;
  bool _newVis = false;
  bool _confVis = false;
  bool _submitting = false;

  @override
  void dispose() {
    _current.dispose();
    _newPwd.dispose();
    _confirm.dispose();
    super.dispose();
  }

  bool _hasMin8(String s) => s.trim().length >= 8;
  bool _hasUpper(String s) => RegExp(r'[A-Z]').hasMatch(s);
  bool _hasSpecial(String s) => RegExp(r'[@$!%*?&]').hasMatch(s);

  /// Rough strength 0–1 for the progress bar (UI hint only).
  double _strength01(String s) {
    if (s.isEmpty) return 0;
    var n = 0.0;
    if (_hasMin8(s)) n += 0.35;
    if (_hasUpper(s)) n += 0.25;
    if (RegExp(r'[a-z]').hasMatch(s)) n += 0.15;
    if (RegExp(r'\d').hasMatch(s)) n += 0.15;
    if (_hasSpecial(s)) n += 0.1;
    return n.clamp(0.0, 1.0);
  }

  String _strengthLabel(double v) {
    if (v < 0.35) return 'pwd_weak'.tr;
    if (v < 0.65) return 'pwd_fair'.tr;
    if (v < 0.9) return 'pwd_good'.tr;
    return 'pwd_strong'.tr;
  }

  Future<void> _submit() async {
    final oldP = _current.text;
    final newP = _newPwd.text;
    final conf = _confirm.text;

    if (oldP.trim().isEmpty) {
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        SnackBar(content: Text('pwd_enter_current'.tr)),
      );
      return;
    }
    if (!_hasMin8(newP)) {
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        SnackBar(content: Text('pwd_min_8'.tr)),
      );
      return;
    }
    if (newP != conf) {
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        SnackBar(content: Text('pwd_mismatch'.tr)),
      );
      return;
    }
    if (oldP == newP) {
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        SnackBar(content: Text('pwd_must_differ'.tr)),
      );
      return;
    }

    if (!Get.isRegistered<AuthController>()) {
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        SnackBar(content: Text('session_not_ready'.tr)),
      );
      return;
    }

    setState(() => _submitting = true);
    final err = await Get.find<AuthController>().changePasswordAuthenticated(
      oldPassword: oldP,
      newPassword: newP,
    );
    if (!mounted) return;
    setState(() => _submitting = false);

    if (err != null) {
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(SnackBar(content: Text(err)));
      return;
    }

    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final s = _newPwd.text;
    final strength = _strength01(s);
    final has8 = _hasMin8(s);
    final hasUp = _hasUpper(s);
    final hasSpec = _hasSpecial(s);

    return Scaffold(
      backgroundColor: ThemeAdaptive.pageBackground(context),
      appBar: AppBar(
        backgroundColor: ProfileTheme.headerOrange,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text('profile_change_password'.tr),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: scheme.surface,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.lock_rounded,
                size: 36,
                color: ProfileTheme.headerOrange,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'pwd_update_title'.tr,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'pwd_update_subtitle'.tr,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: scheme.onSurfaceVariant,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          _pwdField(
            context,
            controller: _current,
            hint: 'pwd_current'.tr,
            visible: _curVis,
            toggle: () => setState(() => _curVis = !_curVis),
          ),
          const SizedBox(height: 14),
          _pwdField(
            context,
            controller: _newPwd,
            hint: 'pwd_new'.tr,
            visible: _newVis,
            toggle: () => setState(() => _newVis = !_newVis),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: strength,
              minHeight: 6,
              backgroundColor: ThemeAdaptive.softTint(
                context,
                Colors.orange.shade100,
              ),
              color: ProfileTheme.headerOrange,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              _strengthLabel(strength),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: ProfileTheme.headerOrange,
              ),
            ),
          ),
          const SizedBox(height: 14),
          _pwdField(
            context,
            controller: _confirm,
            hint: 'pwd_confirm_new'.tr,
            visible: _confVis,
            toggle: () => setState(() => _confVis = !_confVis),
            suffix: Icon(
              _confirm.text.isNotEmpty && _confirm.text == _newPwd.text
                  ? Icons.check_circle
                  : Icons.check_circle_outline,
              color: _confirm.text.isNotEmpty && _confirm.text == _newPwd.text
                  ? const Color(0xFF16A34A)
                  : scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),
          _checkRow(context, has8, 'pwd_rule_8'.tr),
          _checkRow(context, hasUp, 'pwd_rule_upper'.tr),
          _checkRow(context, hasSpec, 'pwd_rule_special'.tr),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: FilledButton(
              onPressed: _submitting ? null : _submit,
              style: FilledButton.styleFrom(
                backgroundColor: ProfileTheme.headerOrange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: _submitting
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text('pwd_update_btn'.tr),
            ),
          ),
        ],
      ),
    );
  }

  Widget _pwdField(
    BuildContext context, {
    required TextEditingController controller,
    required String hint,
    required bool visible,
    required VoidCallback toggle,
    Widget? suffix,
    void Function(String)? onChanged,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return TextField(
      controller: controller,
      obscureText: !visible,
      onChanged: onChanged,
      style: TextStyle(color: scheme.onSurface),
      decoration: InputDecoration(
        filled: true,
        fillColor: scheme.surfaceContainerHighest,
        hintText: hint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        suffixIcon: suffix ??
            IconButton(
              icon: Icon(
                visible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                color: scheme.onSurfaceVariant,
              ),
              onPressed: toggle,
            ),
      ),
    );
  }

  Widget _checkRow(BuildContext context, bool ok, String text) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            ok ? Icons.check_circle : Icons.cancel_outlined,
            color: ok ? const Color(0xFF16A34A) : scheme.onSurfaceVariant,
            size: 20,
          ),
          const SizedBox(width: 10),
          Text(
            text,
            style: TextStyle(fontSize: 14, color: scheme.onSurface),
          ),
        ],
      ),
    );
  }
}
