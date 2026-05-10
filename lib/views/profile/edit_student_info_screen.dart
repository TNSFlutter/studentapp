import 'dart:math' as math;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../controllers/student_profile_controller.dart';
import '../../helpers/network/endpoints.dart';
import '../../models/student_profile_models.dart';
import 'profile_edit_form_controllers.dart';
import 'profile_edit_validators.dart';
import 'profile_theme.dart';

String _dash(String? s) {
  final t = s?.trim() ?? '';
  return t.isEmpty ? '—' : t;
}

String _profilePhotoSheetTitle(String role) {
  return switch (role) {
    'student' => 'edit_info_upload_student_photo'.tr,
    'father' => 'edit_info_upload_father_photo'.tr,
    'mother' => 'edit_info_upload_mother_photo'.tr,
    'guardian' => 'edit_info_upload_guardian_photo'.tr,
    _ => 'edit_info_upload_photo'.tr,
  };
}

String _formatIsoDate(String iso) {
  final d = DateTime.tryParse(iso.trim());
  if (d == null) return iso.isEmpty ? '—' : iso;
  return DateFormat('dd MMM yyyy').format(d);
}

String _transportLabel(int code) {
  return switch (code) {
    0 => 'edit_info_transport_self'.tr,
    1 => 'edit_info_transport_school'.tr,
    _ => '${'edit_info_transport_other'.tr} ($code)',
  };
}

/// Edit Student Info — layout aligned with design screenshots.
class EditStudentInfoScreen extends StatefulWidget {
  final Map<String, dynamic> student;

  const EditStudentInfoScreen({super.key, required this.student});

  @override
  State<EditStudentInfoScreen> createState() => _EditStudentInfoScreenState();
}

class _EditStudentInfoScreenState extends State<EditStudentInfoScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;
  bool _loadingProfile = true;
  String? _profileLoadError;
  ProfileEditFormControllers? _edit;
  bool _saving = false;
  final Map<String, String> _fieldErrors = {};

  static const Color _orange = ProfileTheme.headerOrange;
  static const Color _formBg = Color(0xFFF3F4F6);
  static const Color _labelGrey = Color(0xFF6B7280);
  static const Color _borderGrey = Color(0xFFE5E7EB);

  String get _name =>
      widget.student['name']?.toString() ??
      widget.student['student']?.toString() ??
      'Sanjeev Pahwa';

  String get _studentPhotoUrl =>
      widget.student['photo']?.toString().trim() ?? '';

  String get _classLine {
    final c = widget.student['class']?.toString() ?? 'Class II-B';
    final r =
        widget.student['rollNumber']?.toString() ??
        widget.student['rollNo']?.toString() ??
        '3';
    final a =
        widget.student['admissionNo']?.toString() ??
        widget.student['admission_no']?.toString() ??
        '0002';
    return '$c · Roll $r · Adm $a';
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

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 5, vsync: this);
    _tab.addListener(_onTabViewChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadProfile());
  }

  void _onTabViewChanged() {
    if (_tab.indexIsChanging) return;
    setState(() {
      _fieldErrors.clear();
    });
  }

  void _clearFieldError(String key) {
    if (_fieldErrors.remove(key) != null) {
      setState(() {});
    }
  }

  /// Returns `true` if validation passed (no field errors for this tab).
  bool _applyProfileValidation(
    ProfileEditFormControllers e,
    StudentProfilePayload profile,
  ) {
    final tab = _tab.index;
    const prefixes = ['basic', 'academic', 'father', 'mother', 'guardian'];
    final pfx = prefixes[tab];
    final next = <String, String>{};
    for (final en in _fieldErrors.entries) {
      if (!en.key.startsWith('$pfx.')) next[en.key] = en.value;
    }
    void add(String key, String msg) => next['$pfx.$key'] = msg;
    switch (tab) {
      case 0:
        addBasicTabErrors(e, add);
        break;
      case 1:
        addAcademicTabErrors(e, add);
        break;
      case 2:
        addParentTabErrors(e, profile.father, true, add);
        break;
      case 3:
        addParentTabErrors(e, profile.mother, false, add);
        break;
      case 4:
        addGuardianTabErrors(e, add);
        break;
    }
    final hasErr = next.keys.any((k) => k.startsWith('$pfx.'));
    setState(() {
      _fieldErrors
        ..clear()
        ..addAll(next);
    });
    return !hasErr;
  }

  Future<void> _loadProfile() async {
    if (!Get.isRegistered<StudentProfileController>()) {
      Get.put(StudentProfileController());
    }
    final c = Get.find<StudentProfileController>();
    setState(() {
      _loadingProfile = true;
      _profileLoadError = null;
    });
    await c.refreshProfile();
    if (!mounted) return;
    setState(() {
      _loadingProfile = false;
      if (c.profile.value == null && c.loadError.value.isNotEmpty) {
        _profileLoadError = c.loadError.value;
      }
      _fieldErrors.clear();
      _edit?.dispose();
      _edit = c.profile.value != null
          ? ProfileEditFormControllers.fromProfile(c.profile.value!)
          : null;
    });
  }

  Future<void> _reloadProfileAfterMutation() async {
    if (!Get.isRegistered<StudentProfileController>()) return;
    final c = Get.find<StudentProfileController>();
    await c.refreshProfile();
    if (!mounted) return;
    final refreshed = c.profile.value;
    if (refreshed != null && c.meta.value == null) {
      await c.refreshMetaForLocation(
        countryId: refreshed.basic.countryId,
        stateId: refreshed.basic.stateId,
      );
    }
    if (!mounted) return;
    setState(() {
      _fieldErrors.clear();
      if (c.profile.value != null) {
        _edit?.dispose();
        _edit = ProfileEditFormControllers.fromProfile(c.profile.value!);
      }
    });
  }

  /// Refreshes profile data then returns to the previous route (profile page).
  Future<void> _completeSuccessfulPhotoUpload() async {
    await _reloadProfileAfterMutation();
    if (!mounted) return;
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop(true);
    }
  }

  Future<void> _reloadProfileLocationMeta({
    int? countryId,
    int? stateId,
  }) async {
    if (!Get.isRegistered<StudentProfileController>()) return;
    await Get.find<StudentProfileController>().refreshMetaForLocation(
      countryId: countryId,
      stateId: stateId,
    );
    if (mounted) setState(() {});
  }

  /// `POST student/profile/photo` — multipart `role` + `file` (see Postman).
  Future<void> _pickAndUploadPhoto(String role) async {
    if (!Get.isRegistered<StudentProfileController>()) return;
    if (!mounted) return;
    final p = Get.find<StudentProfileController>().profile.value;
    if (p != null && !p.isEditable) {
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        SnackBar(content: Text('edit_info_not_editable'.tr)),
      );
      return;
    }

    final choice = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 4),
                  child: Text(
                    _profilePhotoSheetTitle(role),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text(
                  'edit_info_jpeg_png'.tr,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 8),
                ListTile(
                  leading: const Icon(Icons.camera_alt_outlined),
                  title: Text('edit_info_camera'.tr),
                  onTap: () => Navigator.pop(ctx, 'camera'),
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library_outlined),
                  title: Text('edit_info_gallery'.tr),
                  onTap: () => Navigator.pop(ctx, 'gallery'),
                ),
                ListTile(
                  leading: const Icon(Icons.insert_drive_file_outlined),
                  title: Text('edit_info_choose_file'.tr),
                  onTap: () => Navigator.pop(ctx, 'file'),
                ),
              ],
            ),
          ),
        );
      },
    );
    if (choice == null || !mounted) return;

    switch (choice) {
      case 'camera':
        final x = await ImagePicker().pickImage(
          source: ImageSource.camera,
          imageQuality: 88,
        );
        await _uploadPhotoFromXFile(role, x);
        return;
      case 'gallery':
        final x = await ImagePicker().pickImage(
          source: ImageSource.gallery,
          imageQuality: 88,
        );
        await _uploadPhotoFromXFile(role, x);
        return;
      case 'file':
        final r = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['jpg', 'jpeg', 'png'],
          withData: kIsWeb,
        );
        final picked = r?.files.isNotEmpty == true ? r!.files.first : null;
        if (picked == null || !mounted) return;
        final path = picked.path;
        if (path == null || path.isEmpty) {
          final name = picked.name.trim();
          final err = await Get.find<StudentProfileController>().uploadProfilePhoto(
            role: role,
            fileBytes: picked.bytes,
            fileName: name.isNotEmpty ? name : 'photo.jpg',
          );
          if (!mounted) return;
          if (err != null) {
            ScaffoldMessenger.maybeOf(context)?.showSnackBar(SnackBar(content: Text(err)));
            return;
          }
          await _completeSuccessfulPhotoUpload();
          return;
        }
        final c = Get.find<StudentProfileController>();
        final err = await c.uploadProfilePhoto(role: role, filePath: path);
        if (!mounted) return;
        if (err != null) {
          ScaffoldMessenger.maybeOf(context)?.showSnackBar(SnackBar(content: Text(err)));
          return;
        }
        await _completeSuccessfulPhotoUpload();
        return;
      default:
        return;
    }
  }

  String _filenameFromXFile(XFile x) {
    var n = x.name.trim();
    if (n.isEmpty) {
      final p = x.path.trim();
      if (p.isNotEmpty) {
        final s = p.replaceAll(r'\', '/');
        final i = s.lastIndexOf('/');
        n = i < 0 ? s : s.substring(i + 1);
      }
    }
    return n.isNotEmpty ? n : 'photo.jpg';
  }

  Future<void> _uploadPhotoFromXFile(String role, XFile? x) async {
    if (x == null || !mounted) return;
    List<int> bytes;
    try {
      bytes = await x.readAsBytes();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.maybeOf(context)?.showSnackBar(
          SnackBar(content: Text('${'edit_info_error_read_image'.tr}: $e')),
        );
      }
      return;
    }
    if (!mounted) return;
    if (bytes.isEmpty) {
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        SnackBar(content: Text('edit_info_error_empty_image'.tr)),
      );
      return;
    }
    final c = Get.find<StudentProfileController>();
    final err = await c.uploadProfilePhoto(
      role: role,
      fileBytes: bytes,
      fileName: _filenameFromXFile(x),
    );
    if (!mounted) return;
    if (err != null) {
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(SnackBar(content: Text(err)));
      return;
    }
    await _completeSuccessfulPhotoUpload();
  }

  Future<void> _saveAll() async {
    final edit = _edit;
    if (!Get.isRegistered<StudentProfileController>()) return;
    final c = Get.find<StudentProfileController>();
    final p = c.profile.value;
    if (edit == null || p == null) return;
    if (!p.isEditable) {
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        SnackBar(content: Text('edit_info_not_editable'.tr)),
      );
      return;
    }

    if (!_applyProfileValidation(edit, p)) {
      return;
    }

    setState(() => _saving = true);
    try {
      // One PUT per current tab (Basic does not call Academic, etc.)
      String? err;
      switch (_tab.index) {
        case 0:
          err = await c.updateBasic(edit.toBasicUpdate());
          break;
        case 1:
          err = await c.updateAcademic(edit.toAcademicUpdate());
          break;
        case 2:
          err = await c.updateFather(edit.toFatherUpdate());
          break;
        case 3:
          err = await c.updateMother(edit.toMotherUpdate());
          break;
        case 4:
          err = await c.updateGuardian(edit.toGuardianUpdate());
          break;
      }
      if (!mounted) return;
      if (err != null) {
        ScaffoldMessenger.maybeOf(
          context,
        )?.showSnackBar(SnackBar(content: Text(err)));
        return;
      }
      if (mounted) {
        setState(() => _fieldErrors.clear());
      }
      await c.refreshProfile();
      if (!mounted) return;
      setState(() {
        if (c.profile.value != null) {
          _edit?.dispose();
          _edit = ProfileEditFormControllers.fromProfile(c.profile.value!);
        }
      });
      ScaffoldMessenger.maybeOf(
        context,
      )?.showSnackBar(SnackBar(content: Text('edit_info_saved'.tr)));
      if (_tab.index != 4) {
        Navigator.pop(context);
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  void dispose() {
    _tab.removeListener(_onTabViewChanged);
    _edit?.dispose();
    _tab.dispose();
    super.dispose();
  }

  Widget _buildTabBody() {
    if (_loadingProfile) {
      return const Center(child: CircularProgressIndicator());
    }
    if (!Get.isRegistered<StudentProfileController>()) {
      return _profileMissingView('edit_info_profile_not_available'.tr);
    }
    final c = Get.find<StudentProfileController>();
    final p = c.profile.value;
    if (p == null) {
      return _profileMissingView(
        _profileLoadError ?? 'edit_info_error_load_profile'.tr,
      );
    }
    final m = c.meta.value;
    final edit = _edit;
    if (edit == null) {
      return const Center(child: CircularProgressIndicator());
    }
    final allowEdit = p.isEditable;
    return Column(
      children: [
        if (!allowEdit)
          Material(
            color: const Color(0xFFFFF7ED),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    color: Color(0xFFEA580C),
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'edit_info_read_only_notice'.tr,
                      style: const TextStyle(
                        fontSize: 13,
                        height: 1.35,
                        color: Color(0xFF9A3412),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        Expanded(
          child: TabBarView(
            controller: _tab,
            physics: const BouncingScrollPhysics(),
            children: [
              _BasicTabContent(
                profile: p,
                meta: m,
                edit: edit,
                allowEdit: allowEdit,
                fieldErrors: _fieldErrors,
                onClearError: _clearFieldError,
                onFormChanged: () => setState(() {}),
                onLocationMetaUpdated: _reloadProfileLocationMeta,
              ),
              _AcademicTabContent(
                profile: p,
                meta: m,
                edit: edit,
                allowEdit: allowEdit,
                fieldErrors: _fieldErrors,
                onClearError: _clearFieldError,
                onFormChanged: () => setState(() {}),
              ),
              _ParentTabContent(
                isFather: true,
                block: p.father,
                edit: edit,
                allowEdit: allowEdit,
                fieldErrors: _fieldErrors,
                onClearError: _clearFieldError,
              ),
              _ParentTabContent(
                isFather: false,
                block: p.mother,
                edit: edit,
                allowEdit: allowEdit,
                fieldErrors: _fieldErrors,
                onClearError: _clearFieldError,
              ),
              _DocsTabContent(
                orange: _orange,
                profile: p,
                meta: m,
                edit: edit,
                allowEdit: allowEdit,
                fieldErrors: _fieldErrors,
                onClearError: _clearFieldError,
                onSynced: _reloadProfileAfterMutation,
                onPickPhoto: _pickAndUploadPhoto,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _profileMissingView(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15, color: Color(0xFF6B7280)),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _loadProfile,
              style: FilledButton.styleFrom(backgroundColor: _orange),
              child: Text('common_retry'.tr),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _formBg,
      body: Column(
        children: [
          _header(context),
          _customTabRow(),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: _formBg,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              clipBehavior: Clip.antiAlias,
              child: _buildTabBody(),
            ),
          ),
          _footerActions(context),
        ],
      ),
    );
  }

  bool _footerSaveEnabled() {
    if (_loadingProfile || _saving || _edit == null) return false;
    if (!Get.isRegistered<StudentProfileController>()) return false;
    final p = Get.find<StudentProfileController>().profile.value;
    if (p == null) return false;
    return p.isEditable;
  }

  Widget _header(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(color: _orange),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
          child: Column(
            children: [
              Row(
                children: [
                  Material(
                    color: Colors.white.withValues(alpha: 0.22),
                    borderRadius: BorderRadius.circular(10),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () => Navigator.pop(context),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        child: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'edit_info_title'.tr,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 44),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 12, 8, 4),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.white,
                      child: ClipOval(
                        child: _studentPhotoUrl.isNotEmpty
                            ? Image.network(
                                _studentPhotoUrl,
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Text(
                                  _initials(_name),
                                  style: const TextStyle(
                                    color: _orange,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                              )
                            : Text(
                                _initials(_name),
                                style: const TextStyle(
                                  color: _orange,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _classLine,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.95),
                              fontSize: 13,
                              height: 1.25,
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
    );
  }

  Widget _customTabRow() {
    final tabs = <(IconData, String)>[
      (Icons.person_outline_rounded, 'edit_info_tab_basic'.tr),
      (Icons.calendar_today_outlined, 'edit_info_tab_academic'.tr),
      (Icons.man_2_outlined, 'edit_info_tab_father'.tr),
      (Icons.woman_2_outlined, 'edit_info_tab_mother'.tr),
      (Icons.description_outlined, 'edit_info_tab_docs'.tr),
    ];
    return Container(
      width: double.infinity,
      color: _orange,
      padding: const EdgeInsets.fromLTRB(6, 0, 6, 12),
      child: Row(
        children: List.generate(tabs.length, (i) {
          final sel = _tab.index == i;
          return Expanded(
            child: InkWell(
              onTap: () => _tab.animateTo(i),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: sel
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.22),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        tabs[i].$1,
                        size: 22,
                        color: sel ? _orange : Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      tabs[i].$2,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: sel
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.75),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: sel ? Colors.white : Colors.transparent,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _footerActions(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        12 + MediaQuery.paddingOf(context).bottom,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF6B7280),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            child: Text('common_cancel'.tr),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Obx(() {
              final _ = Get.isRegistered<StudentProfileController>()
                  ? Get.find<StudentProfileController>().profile.value
                  : null;
              final canSave = _footerSaveEnabled();
              return FilledButton(
                onPressed:
                    (_saving || !canSave) ? null : () => _saveAll(),
                style: FilledButton.styleFrom(
                  backgroundColor: _orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _saving
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        'edit_info_save_changes'.tr,
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

// —— Shared field widgets ——

class _LabeledField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? hint;
  final IconData? suffix;
  final bool orangeBorder;
  final bool multiline;
  final String? errorText;
  final bool markRequired;
  final VoidCallback? onInput;
  final bool readOnly;

  const _LabeledField({
    required this.label,
    required this.controller,
    this.hint,
    this.suffix,
    this.orangeBorder = false,
    this.multiline = false,
    this.errorText,
    this.markRequired = false,
    this.onInput,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    final hasErr = errorText != null && errorText!.isNotEmpty;
    final borderColor = hasErr
        ? const Color(0xFFDC2626)
        : (orangeBorder
              ? ProfileTheme.headerOrange
              : _EditStudentInfoScreenState._borderGrey);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _EditStudentInfoScreenState._labelGrey,
                ),
              ),
            ),
            if (markRequired)
              const Text(
                ' *',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFFDC2626),
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          readOnly: readOnly,
          maxLines: multiline ? 3 : 1,
          onChanged: readOnly ? null : (_) => onInput?.call(),
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            errorText: hasErr ? errorText : null,
            hintText: hint,
            isDense: true,
            filled: true,
            fillColor: readOnly ? const Color(0xFFF9FAFB) : Colors.white,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 12,
              vertical: multiline ? 12 : 12,
            ),
            suffixIcon: suffix != null
                ? Icon(suffix, color: ProfileTheme.headerOrange, size: 20)
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: borderColor,
                width: orangeBorder ? 1.5 : 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: borderColor,
                width: orangeBorder ? 1.5 : 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: ProfileTheme.headerOrange,
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFDC2626)),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFFDC2626),
                width: 1.4,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionCaps extends StatelessWidget {
  final String text;
  const _SectionCaps(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, top: 4),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.7,
          color: _EditStudentInfoScreenState._labelGrey,
        ),
      ),
    );
  }
}

class _WhiteSheet extends StatelessWidget {
  final List<Widget> children;
  const _WhiteSheet({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}

InputDecoration _profileSelectDecoration([String? errorText]) {
  const borderGrey = Color(0xFFE5E7EB);
  final hasErr = errorText != null && errorText.isNotEmpty;
  return InputDecoration(
    isDense: true,
    filled: true,
    fillColor: Colors.white,
    errorText: hasErr ? errorText : null,
    errorMaxLines: 2,
    suffixIcon: const Icon(
      Icons.keyboard_arrow_down_rounded,
      color: Color(0xFF9CA3AF),
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
        color: hasErr ? const Color(0xFFDC2626) : borderGrey,
      ),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
        color: hasErr ? const Color(0xFFDC2626) : borderGrey,
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
        color: hasErr ? const Color(0xFFDC2626) : ProfileTheme.headerOrange,
        width: hasErr ? 1.4 : 1.5,
      ),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFDC2626)),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFDC2626), width: 1.4),
    ),
  );
}

List<DropdownMenuItem<int>> _fkIntItems(
  List<ProfileMetaOption> options,
  int selectedId,
  String missingLabel,
) {
  final ids = {for (final o in options) o.id};
  final items = <DropdownMenuItem<int>>[];
  if (selectedId > 0 && !ids.contains(selectedId)) {
    items.add(
      DropdownMenuItem(
        value: selectedId,
        child: Text(missingLabel, maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
    );
  }
  for (final o in options) {
    items.add(
      DropdownMenuItem(
        value: o.id,
        child: Text(o.label, maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
    );
  }
  return items;
}

List<DropdownMenuItem<int?>> _fkNullableItems(
  List<ProfileMetaOption> options,
  int? selectedId,
  String missingLabel, {
  required String clearLabel,
}) {
  final ids = {for (final o in options) o.id};
  final items = <DropdownMenuItem<int?>>[
    DropdownMenuItem<int?>(value: null, child: Text(clearLabel)),
  ];
  if (selectedId != null && selectedId > 0 && !ids.contains(selectedId)) {
    items.add(
      DropdownMenuItem<int?>(
        value: selectedId,
        child: Text(missingLabel, maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
    );
  }
  for (final o in options) {
    items.add(
      DropdownMenuItem<int?>(
        value: o.id,
        child: Text(o.label, maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
    );
  }
  return items;
}

class _IntFkDropdown extends StatelessWidget {
  final String label;
  final List<ProfileMetaOption> options;
  final int selectedId;
  final ValueChanged<int> onChanged;
  final String missingLabel;
  final String? errorText;
  final bool markRequired;
  final VoidCallback? onClear;
  final bool enabled;

  const _IntFkDropdown({
    required this.label,
    required this.options,
    required this.selectedId,
    required this.onChanged,
    required this.missingLabel,
    this.errorText,
    this.markRequired = false,
    this.onClear,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final items = _fkIntItems(options, selectedId, missingLabel);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _EditStudentInfoScreenState._labelGrey,
                ),
              ),
            ),
            if (markRequired)
              const Text(
                ' *',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFFDC2626),
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        if (items.isEmpty)
          Text(
            'edit_info_no_options'.tr,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          )
        else
          DropdownButtonFormField<int?>(
            isExpanded: true,
            decoration: _profileSelectDecoration(errorText),
            value: selectedId > 0 ? selectedId : null,
            items: [
              DropdownMenuItem<int?>(
                value: null,
                child: Text('common_select'.tr),
              ),
              ...items.map(
                (e) => DropdownMenuItem<int?>(value: e.value, child: e.child),
              ),
            ],
            onChanged: enabled
                ? (v) {
                    onClear?.call();
                    if (v != null) onChanged(v);
                  }
                : null,
          ),
      ],
    );
  }
}

class _NullableFkDropdown extends StatelessWidget {
  final String label;
  final List<ProfileMetaOption> options;
  final int? selectedId;
  final ValueChanged<int?> onChanged;
  final String missingLabel;
  final String clearLabel;
  final VoidCallback? onClear;
  final bool enabled;

  const _NullableFkDropdown({
    required this.label,
    required this.options,
    required this.selectedId,
    required this.onChanged,
    required this.missingLabel,
    this.clearLabel = '—',
    this.onClear,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final items = _fkNullableItems(
      options,
      selectedId,
      missingLabel,
      clearLabel: clearLabel,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: _EditStudentInfoScreenState._labelGrey,
          ),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<int?>(
          isExpanded: true,
          decoration: _profileSelectDecoration(),
          value: () {
            final s = selectedId;
            return (s != null && s > 0) ? s : null;
          }(),
          items: items,
          onChanged: enabled
              ? (v) {
                  onClear?.call();
                  onChanged(v);
                }
              : null,
        ),
      ],
    );
  }
}

class _TransportFkDropdown extends StatelessWidget {
  final String label;
  final int selectedCode;
  final ValueChanged<int> onChanged;
  final bool enabled;

  const _TransportFkDropdown({
    required this.label,
    required this.selectedCode,
    required this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: _EditStudentInfoScreenState._labelGrey,
          ),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<int>(
          isExpanded: true,
          decoration: _profileSelectDecoration(),
          value: selectedCode,
          items: [
            DropdownMenuItem(value: 0, child: Text(_transportLabel(0))),
            DropdownMenuItem(value: 1, child: Text(_transportLabel(1))),
          ],
          onChanged: enabled
              ? (v) {
                  if (v != null) onChanged(v);
                }
              : null,
        ),
      ],
    );
  }
}

// —— Basic tab ——

class _BasicTabContent extends StatelessWidget {
  final StudentProfilePayload profile;
  final StudentProfileMetaPayload? meta;
  final ProfileEditFormControllers edit;
  final bool allowEdit;
  final Map<String, String> fieldErrors;
  final void Function(String key) onClearError;
  final VoidCallback onFormChanged;
  final Future<void> Function({int? countryId, int? stateId})
  onLocationMetaUpdated;

  const _BasicTabContent({
    required this.profile,
    required this.meta,
    required this.edit,
    required this.allowEdit,
    required this.fieldErrors,
    required this.onClearError,
    required this.onFormChanged,
    required this.onLocationMetaUpdated,
  });

  String? _e(String k) => fieldErrors['basic.$k'];
  void _c(String k) => onClearError('basic.$k');

  @override
  Widget build(BuildContext context) {
    final b = profile.basic;
    final ro = !allowEdit;
    final genders = meta?.genderOptions ?? const <ProfileMetaOption>[];
    final bloods = meta?.bloodGroups ?? const <ProfileMetaOption>[];
    final castes = meta?.castes ?? const <ProfileMetaOption>[];
    final nationalities = meta?.nationalities ?? const <ProfileMetaOption>[];
    final religions = meta?.religions ?? const <ProfileMetaOption>[];
    final countries = meta?.countries ?? const <ProfileMetaOption>[];
    final states = meta?.states ?? const <ProfileMetaOption>[];
    final cities = meta?.cities ?? const <ProfileMetaOption>[];

    Future<void> onCountryChanged(int? v) async {
      edit.countryId = v;
      edit.stateId = null;
      edit.cityId = null;
      onFormChanged();
      await onLocationMetaUpdated(countryId: v, stateId: null);
    }

    Future<void> onStateChanged(int? v) async {
      edit.stateId = v;
      edit.cityId = null;
      onFormChanged();
      final countryForMeta =
          edit.countryId ?? (b.countryId > 0 ? b.countryId : null);
      await onLocationMetaUpdated(countryId: countryForMeta, stateId: v);
    }

    return ListView(
      key: ValueKey<int>(profile.summary.studentId),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        const _SectionCaps('BASIC DETAILS'),
        _WhiteSheet(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _LabeledField(
                    label: 'First name',
                    controller: edit.basicFirstName,
                    suffix: Icons.edit_outlined,
                    orangeBorder: true,
                    markRequired: true,
                    errorText: _e('firstName'),
                    readOnly: ro,
                    onInput: () => _c('firstName'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _LabeledField(
                    label: 'Last name',
                    controller: edit.basicLastName,
                    suffix: Icons.edit_outlined,
                    markRequired: true,
                    errorText: _e('lastName'),
                    readOnly: ro,
                    onInput: () => _c('lastName'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _LabeledField(
              label: 'Date of birth',
              controller: edit.basicDobIso,
              hint: 'yyyy-MM-dd',
              suffix: Icons.calendar_today_outlined,
              markRequired: true,
              errorText: _e('dob'),
              readOnly: ro,
              onInput: () => _c('dob'),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _IntFkDropdown(
                    label: 'Gender',
                    options: genders,
                    selectedId: edit.genderId,
                    missingLabel: 'Gender #${edit.genderId}',
                    markRequired: true,
                    errorText: _e('gender'),
                    enabled: allowEdit,
                    onClear: () => _c('gender'),
                    onChanged: (v) {
                      edit.genderId = v;
                      onFormChanged();
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _IntFkDropdown(
                    label: 'Blood group',
                    options: bloods,
                    selectedId: edit.bloodGroupId,
                    missingLabel: b.bloodGroupLabel.trim().isNotEmpty
                        ? b.bloodGroupLabel.trim()
                        : 'Blood #${edit.bloodGroupId}',
                    markRequired: true,
                    errorText: _e('blood'),
                    enabled: allowEdit,
                    onClear: () => _c('blood'),
                    onChanged: (v) {
                      edit.bloodGroupId = v;
                      onFormChanged();
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _IntFkDropdown(
                    label: 'Category',
                    options: castes,
                    selectedId: edit.casteId,
                    missingLabel:
                        (b.casteLabel != null &&
                            b.casteLabel!.trim().isNotEmpty)
                        ? b.casteLabel!.trim()
                        : 'Category #${edit.casteId}',
                    markRequired: true,
                    errorText: _e('caste'),
                    enabled: allowEdit,
                    onClear: () => _c('caste'),
                    onChanged: (v) {
                      edit.casteId = v;
                      onFormChanged();
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _IntFkDropdown(
                    label: 'Nationality',
                    options: nationalities,
                    selectedId: edit.nationalityId,
                    missingLabel:
                        (b.nationalityLabel != null &&
                            b.nationalityLabel!.trim().isNotEmpty)
                        ? b.nationalityLabel!.trim()
                        : 'Nationality #${edit.nationalityId}',
                    markRequired: true,
                    errorText: _e('nationality'),
                    enabled: allowEdit,
                    onClear: () => _c('nationality'),
                    onChanged: (v) {
                      edit.nationalityId = v;
                      onFormChanged();
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _NullableFkDropdown(
              label: 'Religion',
              options: religions,
              selectedId: edit.religionId,
              missingLabel: b.religionLabel?.trim().isNotEmpty == true
                  ? b.religionLabel!.trim()
                  : 'Religion #${edit.religionId}',
              clearLabel: '— Not specified —',
              enabled: allowEdit,
              onChanged: (v) {
                edit.religionId = v;
                onFormChanged();
              },
            ),
            const SizedBox(height: 14),
            _LabeledField(
              label: 'Aadhar number',
              controller: edit.basicAadhaar,
              suffix: Icons.edit_outlined,
              readOnly: ro,
              onInput: () => _c('aadhaar'),
            ),
            const SizedBox(height: 14),
            _LabeledField(
              label: 'Identification mark',
              controller: edit.basicIdMark,
              hint: 'e.g. mole on left cheek',
              readOnly: ro,
              onInput: () => _c('idMark'),
            ),
            const SizedBox(height: 14),
            _LabeledField(
              label: 'Email',
              controller: edit.basicEmail,
              hint: 'Enter email',
              markRequired: true,
              errorText: _e('email'),
              readOnly: ro,
              onInput: () => _c('email'),
            ),
          ],
        ),
        const _SectionCaps('ADDRESS'),
        _WhiteSheet(
          children: [
            _LabeledField(
              label: 'Address line 1',
              controller: edit.basicAddr1,
              suffix: Icons.edit_outlined,
              orangeBorder: true,
              markRequired: true,
              errorText: _e('addr1'),
              readOnly: ro,
              onInput: () => _c('addr1'),
            ),
            const SizedBox(height: 14),
            _LabeledField(
              label: 'Address line 2',
              controller: edit.basicAddr2,
              hint: 'Optional',
              readOnly: ro,
              onInput: () => _c('addr2'),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _NullableFkDropdown(
                    label: 'Country',
                    options: countries,
                    selectedId: edit.countryId,
                    missingLabel: b.countryLabel.trim().isNotEmpty
                        ? b.countryLabel.trim()
                        : 'Country',
                    clearLabel: '—',
                    enabled: allowEdit,
                    onClear: () => _c('country'),
                    onChanged: onCountryChanged,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _NullableFkDropdown(
                    label: 'State',
                    options: states,
                    selectedId: edit.stateId,
                    missingLabel: b.stateLabel.trim().isNotEmpty
                        ? b.stateLabel.trim()
                        : 'State',
                    clearLabel: '—',
                    enabled: allowEdit,
                    onClear: () => _c('state'),
                    onChanged: onStateChanged,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _NullableFkDropdown(
                    label: 'City',
                    options: cities,
                    selectedId: edit.cityId,
                    missingLabel: b.cityLabel.trim().isNotEmpty
                        ? b.cityLabel.trim()
                        : 'City',
                    clearLabel: '—',
                    enabled: allowEdit,
                    onClear: () => _c('city'),
                    onChanged: (v) {
                      edit.cityId = v;
                      onFormChanged();
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _LabeledField(
                    label: 'PIN code',
                    controller: edit.basicPincode,
                    hint: 'Enter PIN',
                    markRequired: true,
                    errorText: _e('pincode'),
                    readOnly: ro,
                    onInput: () => _c('pincode'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

// —— Academic tab ——

class _AcademicTabContent extends StatelessWidget {
  final StudentProfilePayload profile;
  final StudentProfileMetaPayload? meta;
  final ProfileEditFormControllers edit;
  final bool allowEdit;
  final Map<String, String> fieldErrors;
  final void Function(String key) onClearError;
  final VoidCallback onFormChanged;

  const _AcademicTabContent({
    required this.profile,
    required this.meta,
    required this.edit,
    required this.allowEdit,
    required this.fieldErrors,
    required this.onClearError,
    required this.onFormChanged,
  });

  String? _e(String k) => fieldErrors['academic.$k'];
  void _c(String k) => onClearError('academic.$k');

  @override
  Widget build(BuildContext context) {
    final adm = profile.adminAcademicReadonly;
    final ac = profile.academicEditable;
    final ro = !allowEdit;
    final houses = meta?.houses ?? const <ProfileMetaOption>[];
    final streams = meta?.streams ?? const <ProfileMetaOption>[];
    final feeSchemes = meta?.feeSchemes ?? const <ProfileMetaOption>[];
    final admMsg = adm.message.trim().isNotEmpty
        ? adm.message
        : 'Contact school admin to update';

    return ListView(
      key: ValueKey<int>(profile.summary.studentId + 100000),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        Row(
          children: [
            const Icon(
              Icons.lock_outline_rounded,
              color: Color(0xFFDC2626),
              size: 18,
            ),
            const SizedBox(width: 8),
            const Text(
              'ADMIN-LOCKED FIELDS',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.6,
                color: Color(0xFFDC2626),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF1F2),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFFECACA)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _lockedField('Class section', adm.classSection),
              _lockedField('Roll No.', '${adm.rollNo}'),
              _lockedField('Admission No.', adm.admissionNo),
              _lockedField('Admission date', _formatIsoDate(adm.admissionDate)),
              const SizedBox(height: 10),
              Text(
                admMsg,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFFDC2626),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const _SectionCaps('EDITABLE FIELDS'),
        _WhiteSheet(
          children: [
            _TransportFkDropdown(
              label: 'Transport',
              selectedCode: edit.transportSelf,
              enabled: allowEdit,
              onChanged: (v) {
                edit.transportSelf = v;
                onFormChanged();
              },
            ),
            const SizedBox(height: 14),
            _NullableFkDropdown(
              label: 'House',
              options: houses,
              selectedId: edit.houseId,
              missingLabel: _dash(ac.houseLabel),
              clearLabel: '— None —',
              enabled: allowEdit,
              onClear: () => _c('house'),
              onChanged: (v) {
                edit.houseId = v;
                onFormChanged();
              },
            ),
            const SizedBox(height: 14),
            _NullableFkDropdown(
              label: 'Stream',
              options: streams,
              selectedId: edit.streamId,
              missingLabel: _dash(ac.streamLabel),
              clearLabel: '— None —',
              enabled: allowEdit,
              onClear: () => _c('stream'),
              onChanged: (v) {
                edit.streamId = v;
                onFormChanged();
              },
            ),
            const SizedBox(height: 14),
            _NullableFkDropdown(
              label: 'Fee category',
              options: feeSchemes,
              selectedId: edit.feeSchemeId,
              missingLabel: ac.feeSchemeLabel.trim().isNotEmpty
                  ? ac.feeSchemeLabel.trim()
                  : 'Fee scheme',
              clearLabel: '— None —',
              enabled: allowEdit,
              onClear: () => _c('feeScheme'),
              onChanged: (v) {
                edit.feeSchemeId = v;
                onFormChanged();
              },
            ),
            const SizedBox(height: 14),
            _LabeledField(
              label: 'CBSE Reg. No.',
              controller: edit.acadCbse,
              hint: 'Enter CBSE registration number',
              readOnly: ro,
              onInput: () => _c('cbse'),
            ),
            const SizedBox(height: 14),
            _LabeledField(
              label: 'Exam roll no.',
              controller: edit.acadExamRoll,
              hint: 'Digits only (or leave empty)',
              errorText: _e('examRoll'),
              readOnly: ro,
              onInput: () => _c('examRoll'),
            ),
            const SizedBox(height: 14),
            _LabeledField(
              label: 'SRN',
              controller: edit.acadSrn,
              hint: 'Digits only (or leave empty)',
              errorText: _e('srn'),
              readOnly: ro,
              onInput: () => _c('srn'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _lockedField(String k, String v) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 118,
            child: Text(
              k,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
          ),
          Expanded(
            child: Text(
              v,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// —— Father / Mother tab ——

class _ParentTabContent extends StatelessWidget {
  final bool isFather;
  final ProfileParentBlock block;
  final ProfileEditFormControllers edit;
  final bool allowEdit;
  final Map<String, String> fieldErrors;
  final void Function(String key) onClearError;

  const _ParentTabContent({
    required this.isFather,
    required this.block,
    required this.edit,
    required this.allowEdit,
    required this.fieldErrors,
    required this.onClearError,
  });

  String get _pfx => isFather ? 'father' : 'mother';
  String? _e(String k) => fieldErrors['$_pfx.$k'];
  void _c(String k) => onClearError('$_pfx.$k');

  @override
  Widget build(BuildContext context) {
    final title = isFather ? "Father's Details" : "Mother's Details";
    final letter = isFather ? 'F' : 'M';
    final tint = isFather ? const Color(0xFF2563EB) : const Color(0xFFDB2777);
    final onFile = block.hasParent;
    final badgeBg = onFile ? const Color(0xFFDCFCE7) : const Color(0xFFFFE4E6);
    final badgeFg = onFile ? const Color(0xFF166534) : const Color(0xFFBE123C);
    final badgeIcon = onFile ? Icons.check_circle_rounded : Icons.info_outline;
    final badgeText = onFile
        ? (isFather ? 'Father on file' : 'Mother on file')
        : 'Not on file';

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: tint.withValues(alpha: 0.12),
                child: Text(
                  letter,
                  style: TextStyle(
                    color: tint,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 17,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Personal & contact info',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(badgeIcon, color: badgeFg, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      badgeText,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: badgeFg,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _WhiteSheet(children: _parentFields(!allowEdit)),
      ],
    );
  }

  List<Widget> _parentFields(bool readOnly) {
    return [
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: _LabeledField(
              label: 'First name',
              controller: isFather ? edit.fatherFirst : edit.motherFirst,
              suffix: Icons.edit_outlined,
              orangeBorder: true,
              markRequired: true,
              errorText: _e('firstName'),
              readOnly: readOnly,
              onInput: () => _c('firstName'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _LabeledField(
              label: 'Last name',
              controller: isFather ? edit.fatherLast : edit.motherLast,
              hint: 'Enter',
              markRequired: true,
              errorText: _e('lastName'),
              readOnly: readOnly,
              onInput: () => _c('lastName'),
            ),
          ),
        ],
      ),
      const SizedBox(height: 14),
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: _LabeledField(
              label: 'Profession',
              controller: isFather
                  ? edit.fatherProfession
                  : edit.motherProfession,
              hint: 'Enter',
              readOnly: readOnly,
              onInput: () => _c('profession'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _LabeledField(
              label: 'Qualification',
              controller: isFather
                  ? edit.fatherQualification
                  : edit.motherQualification,
              hint: 'Enter',
              readOnly: readOnly,
              onInput: () => _c('qualification'),
            ),
          ),
        ],
      ),
      const SizedBox(height: 14),
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: _RupeeField(
              label: 'Annual income',
              hint: 'Enter',
              controller: isFather ? edit.fatherIncome : edit.motherIncome,
              readOnly: readOnly,
              onInput: () => _c('income'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _PhonePrefixField(
              label: 'Mobile',
              hint: 'Enter',
              controller: isFather ? edit.fatherMobile : edit.motherMobile,
              markRequired: true,
              errorText: _e('mobile'),
              readOnly: readOnly,
              onInput: () => _c('mobile'),
            ),
          ),
        ],
      ),
      const SizedBox(height: 14),
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: _LabeledField(
              label: 'Aadhar card',
              controller: isFather ? edit.fatherAadhaar : edit.motherAadhaar,
              hint: 'Enter',
              readOnly: readOnly,
              onInput: () => _c('aadhaar'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _LabeledField(
              label: 'Date of birth',
              controller: isFather ? edit.fatherDob : edit.motherDob,
              hint: 'yyyy-MM-dd',
              suffix: Icons.calendar_today_outlined,
              readOnly: readOnly,
              onInput: () => _c('dob'),
            ),
          ),
        ],
      ),
      const SizedBox(height: 14),
      _LabeledField(
        label: 'Email',
        controller: isFather ? edit.fatherEmail : edit.motherEmail,
        hint: 'Enter email',
        errorText: _e('email'),
        readOnly: readOnly,
        onInput: () => _c('email'),
      ),
      const SizedBox(height: 14),
      _LabeledField(
        label: 'Home address',
        controller: isFather ? edit.fatherPresent : edit.motherPresent,
        suffix: Icons.edit_outlined,
        orangeBorder: true,
        multiline: true,
        readOnly: readOnly,
        onInput: () => _c('present'),
      ),
      const SizedBox(height: 14),
      _LabeledField(
        label: 'Office address',
        controller: isFather ? edit.fatherOffice : edit.motherOffice,
        hint: 'Enter office address',
        multiline: true,
        readOnly: readOnly,
        onInput: () => _c('office'),
      ),
    ];
  }
}

class _RupeeField extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController controller;
  final VoidCallback? onInput;
  final bool readOnly;

  const _RupeeField({
    required this.label,
    this.hint,
    required this.controller,
    this.onInput,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: _EditStudentInfoScreenState._labelGrey,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          key: ValueKey<String>('rupee-$label-${controller.text}'),
          controller: controller,
          readOnly: readOnly,
          onChanged: readOnly ? null : (_) => onInput?.call(),
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            hintText: hint,
            isDense: true,
            filled: true,
            fillColor: readOnly ? const Color(0xFFF9FAFB) : Colors.white,
            prefixText: '₹ ',
            prefixStyle: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF374151),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: _EditStudentInfoScreenState._borderGrey,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: _EditStudentInfoScreenState._borderGrey,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PhonePrefixField extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController controller;
  final String? errorText;
  final bool markRequired;
  final VoidCallback? onInput;
  final bool readOnly;

  const _PhonePrefixField({
    required this.label,
    this.hint,
    required this.controller,
    this.errorText,
    this.markRequired = false,
    this.onInput,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    final hasErr = errorText != null && errorText!.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _EditStudentInfoScreenState._labelGrey,
                ),
              ),
            ),
            if (markRequired)
              const Text(
                ' *',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFFDC2626),
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        TextFormField(
          key: ValueKey<String>('phone-$label-${controller.text}'),
          controller: controller,
          readOnly: readOnly,
          onChanged: readOnly ? null : (_) => onInput?.call(),
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            errorText: hasErr ? errorText : null,
            hintText: hint,
            isDense: true,
            filled: true,
            fillColor: readOnly ? const Color(0xFFF9FAFB) : Colors.white,
            prefixText: '+91 ',
            prefixStyle: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF374151),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: hasErr
                    ? const Color(0xFFDC2626)
                    : _EditStudentInfoScreenState._borderGrey,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: hasErr
                    ? const Color(0xFFDC2626)
                    : _EditStudentInfoScreenState._borderGrey,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFDC2626)),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFFDC2626),
                width: 1.4,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// —— Docs tab ——

class _DocsTabContent extends StatefulWidget {
  final Color orange;
  final StudentProfilePayload profile;
  final StudentProfileMetaPayload? meta;
  final ProfileEditFormControllers edit;
  final bool allowEdit;
  final Map<String, String> fieldErrors;
  final void Function(String key) onClearError;
  final Future<void> Function() onSynced;
  final void Function(String role) onPickPhoto;

  const _DocsTabContent({
    required this.orange,
    required this.profile,
    required this.meta,
    required this.edit,
    required this.allowEdit,
    required this.fieldErrors,
    required this.onClearError,
    required this.onSynced,
    required this.onPickPhoto,
  });

  @override
  State<_DocsTabContent> createState() => _DocsTabContentState();
}

class _DocsTabContentState extends State<_DocsTabContent> {
  int _docChip = 0;

  bool _hasPhoto(String? url) => url != null && url.trim().isNotEmpty;

  Future<void> _onPhotoRoleTap(String role) async {
    final ph = widget.profile.photos;
    final String? url = switch (role) {
      'student' => ph.student,
      'father' => ph.father,
      'mother' => ph.mother,
      'guardian' => ph.guardian,
      _ => null,
    };
    final has = _hasPhoto(url);
    if (widget.allowEdit) {
      widget.onPickPhoto(role);
      return;
    }
    if (!has || url == null) return;
    final normalized = _normalizeDocumentLaunchUrl(url.trim()) ?? url.trim();
    final uri = Uri.tryParse(normalized);
    if (uri == null || !uri.hasScheme) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open this photo link.')),
      );
      return;
    }
    try {
      if (!await canLaunchUrl(uri)) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cannot open this link on this device.')),
        );
        return;
      }
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open link: $e')),
      );
    }
  }

  List<String> get _chipLabels {
    final docTypes = widget.meta?.documentTypes ?? [];
    if (docTypes.isNotEmpty) {
      return docTypes.map((e) {
        final t = e.label.trim();
        return t.isNotEmpty ? t : 'Document type';
      }).toList();
    }
    return ['Birth Certificate', 'TC', 'Aadhar Card', 'Other'];
  }

  List<int?> get _chipDocTypeIds {
    final docTypes = widget.meta?.documentTypes ?? [];
    if (docTypes.isNotEmpty) {
      return docTypes.map((e) => e.id).toList();
    }
    return List<int?>.filled(_chipLabels.length, null);
  }

  int? get _selectedDocTypeId {
    final ids = _chipDocTypeIds;
    final chip = _chipIndex;
    if (chip < 0 || chip >= ids.length) return null;
    return ids[chip];
  }

  int get _chipIndex {
    final n = _chipLabels.length;
    if (n <= 0) return 0;
    return math.min(_docChip, n - 1);
  }

  Future<void> _finishDocumentUpload(String? err) async {
    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          backgroundColor: const Color(0xFFB91C1C),
          content: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.error_outline_rounded, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(child: Text(err)),
            ],
          ),
        ),
      );
      return;
    }
    await widget.onSynced();
    if (!mounted) return;
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        backgroundColor: const Color(0xFF15803D),
        content: const Row(
          children: [
            Icon(Icons.check_circle_outline_rounded, color: Colors.white),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Document uploaded successfully.',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _uploadDocTypeDescription() {
    final labels = _chipLabels;
    if (labels.isEmpty) return 'document';
    final i = _chipIndex.clamp(0, labels.length - 1);
    return labels[i];
  }

  void _showDocumentUploadingSnackBar() {
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        backgroundColor: const Color(0xFF1F2937),
        clipBehavior: Clip.antiAlias,
        duration: const Duration(days: 1),
        content: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: Colors.white,
                backgroundColor: Colors.white.withValues(alpha: 0.2),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Uploading…',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Sending ${_uploadDocTypeDescription()} — please wait.',
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.25,
                      color: Colors.white.withValues(alpha: 0.88),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _runDocumentUpload(Future<String?> Function() upload) async {
    if (!mounted) return;
    _showDocumentUploadingSnackBar();
    final err = await upload();
    await _finishDocumentUpload(err);
  }

  Future<void> _uploadDocumentFromPicker(ImageSource? source) async {
    if (!widget.allowEdit) return;
    String? path;
    if (source == ImageSource.camera || source == ImageSource.gallery) {
      final x = await ImagePicker().pickImage(
        source: source!,
        imageQuality: 88,
      );
      path = x?.path;
    } else {
      final r = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
        withData: kIsWeb,
      );
      final picked = r?.files.isNotEmpty == true ? r!.files.first : null;
      if (picked == null || !mounted) return;
      path = picked.path;
      if (path != null && path.isNotEmpty) {
        await _runDocumentUpload(
          () => Get.find<StudentProfileController>().uploadProfileDocument(
                filePath: path,
                docTypeId: _selectedDocTypeId,
              ),
        );
        return;
      }
      final bytes = picked.bytes;
      final name = picked.name.trim();
      if (bytes == null || bytes.isEmpty || name.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              behavior: SnackBarBehavior.floating,
              content: Text('Could not read the selected file.'),
            ),
          );
        }
        return;
      }
      await _runDocumentUpload(
        () => Get.find<StudentProfileController>().uploadProfileDocument(
              fileBytes: bytes,
              fileName: name,
              docTypeId: _selectedDocTypeId,
            ),
      );
      return;
    }
    if (path == null || !mounted) return;
    await _runDocumentUpload(
      () => Get.find<StudentProfileController>().uploadProfileDocument(
            filePath: path,
            docTypeId: _selectedDocTypeId,
          ),
    );
  }

  Future<void> _confirmDeleteDocument(int documentId) async {
    if (!widget.allowEdit) return;
    final go = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete document?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('common_cancel'.tr),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (go != true || !mounted) return;
    final err = await Get.find<StudentProfileController>()
        .deleteProfileDocument(documentId);
    if (!mounted) return;
    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Document removed.')));
    await widget.onSynced();
    if (mounted) setState(() {});
  }

  int? _documentIdFromMap(Map<String, dynamic> d) {
    for (final k in ['id', 'document_id', 'DocumentID']) {
      final v = d[k];
      if (v == null) continue;
      if (v is int) return v;
      final p = int.tryParse(v.toString());
      if (p != null && p > 0) return p;
    }
    return null;
  }

  /// URL/path from API document object (several possible keys).
  String? _documentUrlFromMap(Map<String, dynamic> d) {
    for (final k in [
      'url',
      'file_url',
      'document_url',
      'file_path',
      'path',
      'link',
      'download_url',
      'view_url',
      'attachment',
      'href',
      'public_url',
    ]) {
      final v = d[k]?.toString().trim();
      if (v != null && v.isNotEmpty) return v;
    }
    return null;
  }

  String? _normalizeDocumentLaunchUrl(String raw) {
    var t = raw.trim();
    if (t.isEmpty) return null;
    if (t.startsWith('//')) {
      t = 'https:$t';
    }
    final direct = Uri.tryParse(t);
    if (direct != null &&
        direct.hasScheme &&
        (direct.scheme == 'http' || direct.scheme == 'https')) {
      return t;
    }
    final base = Endpoints.baseURL;
    final path = t.startsWith('/') ? t.substring(1) : t;
    return '$base$path';
  }

  Future<void> _openDocumentFromMap(Map<String, dynamic> d) async {
    final raw = _documentUrlFromMap(d);
    if (raw == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No file link is available for this document.'),
        ),
      );
      return;
    }
    final normalized = _normalizeDocumentLaunchUrl(raw);
    final uri = normalized != null ? Uri.tryParse(normalized) : null;
    if (uri == null || !uri.hasScheme) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open this file link.')),
      );
      return;
    }
    try {
      if (!await canLaunchUrl(uri)) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cannot open this file on this device.')),
        );
        return;
      }
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open file: $e')),
      );
    }
  }
  int _checklistSectionKey(ProfileDocumentsChecklist resolved) {
    var idSum = 0;
    for (final d in widget.profile.documents) {
      final v = d['id'] ?? d['document_id'];
      if (v is int) {
        idSum += v;
      } else {
        idSum += int.tryParse(v?.toString() ?? '') ?? 0;
      }
    }
    return Object.hash(
      resolved.birthCertificateProvided,
      resolved.tcProvided,
      resolved.studentSubCategoryProvided,
      widget.profile.documents.length,
      idSum,
    );
  }

  String? _ge(String k) => widget.fieldErrors['guardian.$k'];
  void _gc(String k) => widget.onClearError('guardian.$k');

  @override
  Widget build(BuildContext context) {
    final ph = widget.profile.photos;
    final canMutateDocs = widget.allowEdit;
    final ro = !widget.allowEdit;
    final chipLabels = _chipLabels;
    final chip = _chipIndex;
    final uploadLabel = chipLabels.isEmpty ? 'Document' : chipLabels[chip];
    final ch = widget.profile.documentsChecklist.resolvedForDisplay(
      documents: widget.profile.documents,
      basic: widget.profile.basic,
      documentTypes: widget.meta?.documentTypes,
    );

    return ListView(
      key: ValueKey<int>(widget.profile.summary.studentId + 200000),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        const _SectionCaps('PHOTOS'),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _PhotoCircle(
              title: 'Student',
              subtitle: canMutateDocs
                  ? (_hasPhoto(ph.student) ? 'View' : 'Upload')
                  : (_hasPhoto(ph.student) ? 'View' : '—'),
              filled: _hasPhoto(ph.student),
              borderColor: const Color(0xFF3B82F6),
              dashed: !_hasPhoto(ph.student),
              iconColor: const Color(0xFF93C5FD),
              badgeIcon: Icons.upload_rounded,
              imageUrl: ph.student,
              onTap: () => _onPhotoRoleTap('student'),
            ),
            _PhotoCircle(
              title: 'Father',
              subtitle: canMutateDocs
                  ? (_hasPhoto(ph.father) ? 'View' : 'Upload')
                  : (_hasPhoto(ph.father) ? 'View' : '—'),
              filled: _hasPhoto(ph.father),
              borderColor: const Color(0xFF3B82F6),
              dashed: !_hasPhoto(ph.father),
              iconColor: const Color(0xFFBFDBFE),
              imageUrl: ph.father,
              onTap: () => _onPhotoRoleTap('father'),
            ),
            _PhotoCircle(
              title: 'Mother',
              subtitle: canMutateDocs
                  ? (_hasPhoto(ph.mother) ? 'View' : 'Upload')
                  : (_hasPhoto(ph.mother) ? 'View' : '—'),
              filled: _hasPhoto(ph.mother),
              borderColor: const Color(0xFFEC4899),
              dashed: !_hasPhoto(ph.mother),
              iconColor: const Color(0xFFFBCFE8),
              imageUrl: ph.mother,
              onTap: () => _onPhotoRoleTap('mother'),
            ),
            _PhotoCircle(
              title: 'Guardian',
              subtitle: canMutateDocs
                  ? (_hasPhoto(ph.guardian) ? 'View' : 'Upload')
                  : (_hasPhoto(ph.guardian) ? 'View' : '—'),
              filled: _hasPhoto(ph.guardian),
              borderColor: const Color(0xFF9333EA),
              dashed: !_hasPhoto(ph.guardian),
              iconColor: const Color(0xFFE9D5FF),
              imageUrl: ph.guardian,
              onTap: () => _onPhotoRoleTap('guardian'),
            ),
          ],
        ),
        const SizedBox(height: 18),
        const _SectionCaps('GUARDIAN'),
        _WhiteSheet(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _LabeledField(
                    label: 'First name',
                    controller: widget.edit.guardianFirst,
                    markRequired: true,
                    errorText: _ge('firstName'),
                    readOnly: ro,
                    onInput: () => _gc('firstName'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _LabeledField(
                    label: 'Last name',
                    controller: widget.edit.guardianLast,
                    markRequired: true,
                    errorText: _ge('lastName'),
                    readOnly: ro,
                    onInput: () => _gc('lastName'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _LabeledField(
                    label: 'Profession',
                    controller: widget.edit.guardianProfession,
                    readOnly: ro,
                    onInput: () => _gc('profession'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _LabeledField(
                    label: 'Qualification',
                    controller: widget.edit.guardianQualification,
                    readOnly: ro,
                    onInput: () => _gc('qualification'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _RupeeField(
                    label: 'Annual income',
                    controller: widget.edit.guardianIncome,
                    readOnly: ro,
                    onInput: () => _gc('income'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _PhonePrefixField(
                    label: 'Mobile',
                    controller: widget.edit.guardianMobile,
                    markRequired: true,
                    errorText: _ge('mobile'),
                    readOnly: ro,
                    onInput: () => _gc('mobile'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _LabeledField(
                    label: 'Aadhar',
                    controller: widget.edit.guardianAadhaar,
                    readOnly: ro,
                    onInput: () => _gc('aadhaar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _LabeledField(
                    label: 'Date of birth',
                    controller: widget.edit.guardianDob,
                    hint: 'yyyy-MM-dd',
                    readOnly: ro,
                    onInput: () => _gc('dob'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _LabeledField(
              label: 'Email',
              controller: widget.edit.guardianEmail,
              errorText: _ge('email'),
              readOnly: ro,
              onInput: () => _gc('email'),
            ),
            const SizedBox(height: 14),
            _LabeledField(
              label: 'Present address',
              controller: widget.edit.guardianPresent,
              multiline: true,
              readOnly: ro,
              onInput: () => _gc('present'),
            ),
          ],
        ),
        const SizedBox(height: 22),
        const _SectionCaps('UPLOADED DOCUMENTS'),
        if (widget.profile.documents.isEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              'No documents uploaded.',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
          )
        else
          for (final d in widget.profile.documents)
            _docFileCard(
              context,
              _docMapTitle(d),
              _docMapTag(d),
              const Color(0xFF3B82F6),
              _docMapMeta(d),
              documentId: _documentIdFromMap(d),
              allowDelete: canMutateDocs,
              onView: () => _openDocumentFromMap(d),
            ),
        const SizedBox(height: 18),
        const _SectionCaps('UPLOAD NEW DOCUMENT'),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select document type',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: List.generate(chipLabels.length, (i) {
                  final sel = chip == i;
                  return FilterChip(
                    label: Text(chipLabels[i]),
                    selected: sel,
                    onSelected: canMutateDocs
                        ? (_) => setState(() => _docChip = i)
                        : null,
                    showCheckmark: true,
                    checkmarkColor: widget.orange,
                    selectedColor: Colors.white,
                    backgroundColor: const Color(0xFFF3F4F6),
                    side: BorderSide(
                      color: sel ? widget.orange : const Color(0xFFE5E7EB),
                      width: sel ? 1.5 : 1,
                    ),
                    labelStyle: TextStyle(
                      color: sel ? widget.orange : const Color(0xFF6B7280),
                      fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                      fontSize: 12,
                    ),
                  );
                }),
              ),
              const SizedBox(height: 16),
              CustomPaint(
                painter: _DashedRectPainter(color: widget.orange),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Icon(
                        Icons.upload_rounded,
                        size: 40,
                        color: widget.orange,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Upload $uploadLabel',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        'PDF, JPG or PNG · Max 10 MB',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _DocSourceButton(
                              label: 'Camera',
                              icon: Icons.camera_alt_outlined,
                              color: widget.orange,
                              onPressed: canMutateDocs
                                  ? () => _uploadDocumentFromPicker(
                                        ImageSource.camera,
                                      )
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _DocSourceButton(
                              label: 'Files',
                              icon: Icons.folder_open_rounded,
                              color: const Color(0xFF2563EB),
                              onPressed: canMutateDocs
                                  ? () => _uploadDocumentFromPicker(null)
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _DocSourceButton(
                              label: 'Gallery',
                              icon: Icons.photo_library_outlined,
                              color: const Color(0xFF9333EA),
                              onPressed: canMutateDocs
                                  ? () => _uploadDocumentFromPicker(
                                        ImageSource.gallery,
                                      )
                                  : null,
                            ),
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
        const SizedBox(height: 18),
        Container(
          key: ValueKey<int>(_checklistSectionKey(ch)),
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Document checklist',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
              ),
              const SizedBox(height: 12),
              _checkRow(
                ok: ch.birthCertificateProvided,
                title: 'Birth Certificate',
                status: ch.birthCertificateProvided ? 'Provided' : 'Pending',
                statusColor: ch.birthCertificateProvided
                    ? const Color(0xFF16A34A)
                    : widget.orange,
              ),
              _checkRow(
                ok: ch.tcProvided,
                title: 'Transfer Certificate (TC)',
                status: ch.tcProvided ? 'Provided' : 'Pending',
                statusColor: ch.tcProvided
                    ? const Color(0xFF16A34A)
                    : widget.orange,
              ),
              _checkRow(
                ok: ch.studentSubCategoryProvided,
                title: 'Student sub-category',
                status: ch.studentSubCategoryProvided ? 'Provided' : 'Pending',
                statusColor: ch.studentSubCategoryProvided
                    ? const Color(0xFF16A34A)
                    : widget.orange,
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _docMapTitle(Map<String, dynamic> d) {
    for (final k in ['file_name', 'name', 'title', 'original_name']) {
      final v = d[k]?.toString().trim();
      if (v != null && v.isNotEmpty) return v;
    }
    return 'Document';
  }

  String _docMapTag(Map<String, dynamic> d) {
    for (final k in ['document_type', 'type_name', 'type', 'category']) {
      final v = d[k]?.toString().trim();
      if (v != null && v.isNotEmpty) return v;
    }
    return 'File';
  }

  String _docMapMeta(Map<String, dynamic> d) {
    for (final k in ['size_label', 'meta', 'uploaded_at', 'updated_at']) {
      final v = d[k]?.toString().trim();
      if (v != null && v.isNotEmpty) return v;
    }
    return '';
  }

  Widget _docFileCard(
    BuildContext context,
    String name,
    String tag,
    Color c,
    String meta, {
    int? documentId,
    bool allowDelete = true,
    VoidCallback? onView,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.insert_drive_file_rounded, color: c, size: 36),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: c.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        tag,
                        style: TextStyle(
                          fontSize: 11,
                          color: c,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      meta,
                      style: const TextStyle(
                        fontSize: 11,
                        color: _EditStudentInfoScreenState._labelGrey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          _squareIconBtn(
            Icons.visibility_outlined,
            const Color(0xFF16A34A),
            onTap: onView,
          ),
          if (allowDelete)
            _squareIconBtn(
              Icons.delete_outline_rounded,
              ProfileTheme.feeDueRed,
              onTap: documentId != null
                  ? () => _confirmDeleteDocument(documentId)
                  : null,
            ),
        ],
      ),
    );
  }

  Widget _squareIconBtn(IconData i, Color c, {VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.only(left: 6),
      child: Material(
        color: c.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Icon(i, color: c, size: 20),
          ),
        ),
      ),
    );
  }

  Widget _checkRow({
    required bool ok,
    required String title,
    required String status,
    required Color statusColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: ok ? const Color(0xFFDCFCE7) : const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: ok ? const Color(0xFF86EFAC) : const Color(0xFFE5E7EB),
              ),
            ),
            child: ok
                ? const Icon(
                    Icons.check_rounded,
                    color: Color(0xFF16A34A),
                    size: 18,
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Text(
            status,
            style: TextStyle(
              color: statusColor,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _PhotoCircle extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool filled;
  final Color borderColor;
  final bool dashed;
  final Color iconColor;
  final IconData? badgeIcon;
  final String? imageUrl;
  final VoidCallback? onTap;

  const _PhotoCircle({
    required this.title,
    required this.subtitle,
    required this.filled,
    required this.borderColor,
    required this.dashed,
    required this.iconColor,
    this.badgeIcon,
    this.imageUrl,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final url = imageUrl?.trim() ?? '';
    final showNet =
        url.isNotEmpty &&
        (url.startsWith('http://') || url.startsWith('https://'));

    return SizedBox(
      width: 76,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Column(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  CustomPaint(
                    painter: _CircleBorderPainter(
                      color: borderColor,
                      dashed: dashed,
                      strokeWidth: 2,
                    ),
                    child: SizedBox(
                      width: 60,
                      height: 60,
                      child: showNet
                          ? ClipOval(
                              child: IgnorePointer(
                                child: Image.network(
                                  url,
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Icon(
                                    filled
                                        ? Icons.person_rounded
                                        : Icons.image_outlined,
                                    color: iconColor,
                                    size: 28,
                                  ),
                                ),
                              ),
                            )
                          : Icon(
                              filled
                                  ? Icons.person_rounded
                                  : Icons.image_outlined,
                              color: iconColor,
                              size: 28,
                            ),
                    ),
                  ),
                  Positioned(
                    right: -2,
                    bottom: -2,
                    child: CircleAvatar(
                      radius: 11,
                      backgroundColor: ProfileTheme.headerOrange,
                      child: Icon(
                        badgeIcon ?? Icons.add_rounded,
                        size: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: filled
                      ? ProfileTheme.headerOrange
                      : const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CircleBorderPainter extends CustomPainter {
  final Color color;
  final bool dashed;
  final double strokeWidth;

  _CircleBorderPainter({
    required this.color,
    required this.dashed,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2 - strokeWidth / 2;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    if (!dashed) {
      canvas.drawCircle(c, r, paint);
      return;
    }
    const dash = 4.0;
    const gap = 3.0;
    final rect = Rect.fromCircle(center: c, radius: r);
    final path = Path()..addOval(rect);
    for (final metric in path.computeMetrics()) {
      double d = 0;
      while (d < metric.length) {
        canvas.drawPath(metric.extractPath(d, d + dash), paint);
        d += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _DashedRectPainter extends CustomPainter {
  final Color color;
  _DashedRectPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final r = RRect.fromRectAndRadius(
      Rect.fromLTWH(1, 1, size.width - 2, size.height - 2),
      const Radius.circular(14),
    );
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    const dash = 6.0;
    const gap = 4.0;
    final path = Path()..addRRect(r);
    for (final metric in path.computeMetrics()) {
      double d = 0;
      while (d < metric.length) {
        canvas.drawPath(metric.extractPath(d, d + dash), paint);
        d += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _DocSourceButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback? onPressed;

  const _DocSourceButton({
    required this.label,
    required this.icon,
    required this.color,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: color.withValues(alpha: 0.65)),
        padding: const EdgeInsets.symmetric(vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
