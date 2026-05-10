import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../controllers/leave_controller.dart';
import '../../helpers/theme_adaptive.dart';
import '../../models/leave_models.dart';
import '../../widgets/common_app_bar.dart';

class ApplyLeaveScreen extends StatefulWidget {
  const ApplyLeaveScreen({super.key});

  @override
  State<ApplyLeaveScreen> createState() => _ApplyLeaveScreenState();
}

class _ApplyLeaveScreenState extends State<ApplyLeaveScreen> {
  final LeaveController _controller = LeaveController();
  final TextEditingController _reasonCtrl = TextEditingController();
  bool _loading = true;
  bool _submitting = false;
  String? _error;
  LeaveStudentInfo _student = LeaveStudentInfo.empty();
  List<LeaveType> _types = const [];
  LeaveType? _selectedType;
  DateTime? _fromDate;
  DateTime? _toDate;
  String? _documentPath;
  String? _documentName;
  final ImagePicker _imagePicker = ImagePicker();

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
    final res = await _controller.fetchLeaveTypes();
    if (!mounted) return;
    setState(() {
      _loading = false;
      if (res.success) {
        _student = res.student;
        _types = res.data;
        if (_types.isNotEmpty) _selectedType = _types.first;
      } else {
        _error = res.message;
      }
    });
  }

  String _dateLabel(DateTime? d) {
    if (d == null) return 'Select date';
    final m = <int, String>{
      1: 'Jan',
      2: 'Feb',
      3: 'Mar',
      4: 'Apr',
      5: 'May',
      6: 'Jun',
      7: 'Jul',
      8: 'Aug',
      9: 'Sep',
      10: 'Oct',
      11: 'Nov',
      12: 'Dec',
    };
    return '${d.day.toString().padLeft(2, '0')} ${m[d.month]} ${d.year}';
  }

  Future<void> _pickDate(bool isFrom) async {
    final now = DateTime.now();
    final initial = isFrom ? (_fromDate ?? now) : (_toDate ?? _fromDate ?? now);
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 2),
      initialDate: initial,
    );
    if (picked == null) return;
    setState(() {
      if (isFrom) {
        _fromDate = picked;
        if (_toDate != null && _toDate!.isBefore(_fromDate!)) {
          _toDate = _fromDate;
        }
      } else {
        _toDate = picked;
      }
    });
  }

  Future<void> _pickDocumentFromFiles() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf', 'jpg', 'jpeg', 'png'],
      allowMultiple: false,
    );
    if (result == null || result.files.isEmpty) return;
    final file = result.files.first;
    if (file.path == null) return;
    setState(() {
      _documentPath = file.path!;
      _documentName = file.name;
    });
  }

  Future<void> _pickDocumentFromGallery() async {
    final image = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (image == null) return;
    setState(() {
      _documentPath = image.path;
      _documentName = image.name;
    });
  }

  Future<void> _pickDocumentFromCamera() async {
    final image = await _imagePicker.pickImage(source: ImageSource.camera);
    if (image == null) return;
    setState(() {
      _documentPath = image.path;
      _documentName = image.name;
    });
  }

  Future<void> _pickDocument() async {
    await showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const ListTile(
                  title: Text(
                    'Upload document',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library_outlined),
                  title: const Text('Choose from Gallery'),
                  onTap: () async {
                    Navigator.pop(context);
                    await _pickDocumentFromGallery();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt_outlined),
                  title: const Text('Take Photo'),
                  onTap: () async {
                    Navigator.pop(context);
                    await _pickDocumentFromCamera();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.insert_drive_file_outlined),
                  title: const Text('Choose File'),
                  onTap: () async {
                    Navigator.pop(context);
                    await _pickDocumentFromFiles();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _toApiDate(DateTime d) {
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '${d.year}-$m-$day';
  }

  Future<void> _submit() async {
    if (_submitting) return;
    if (_selectedType == null || _fromDate == null || _toDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select leave type and dates.')),
      );
      return;
    }
    final reason = _reasonCtrl.text.trim();
    if (reason.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter reason.')),
      );
      return;
    }

    setState(() => _submitting = true);
    final res = await _controller.applyLeave(
      leaveTypeId: _selectedType!.id,
      fromDate: _toApiDate(_fromDate!),
      toDate: _toApiDate(_toDate!),
      description: reason,
      documentPath: _documentPath,
    );
    if (!mounted) return;
    setState(() => _submitting = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(res.message)),
    );
    if (res.success) Navigator.pop(context, true);
  }

  @override
  void dispose() {
    _reasonCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: const CommonAppBar(title: 'Apply for Leave'),
      backgroundColor: ThemeAdaptive.pageBackground(context),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Text(
                    _error!,
                    style: TextStyle(color: scheme.error),
                  ),
                )
              : Column(
                  children: [
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF7A21),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 22,
                                  backgroundColor: const Color(0xFFFFEDD5),
                                  child: ClipOval(
                                    child: (_student.photo ?? '').isNotEmpty
                                        ? Image.network(
                                            _student.photo!,
                                            width: 44,
                                            height: 44,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) =>
                                                Text(_student.initials),
                                          )
                                        : Text(
                                            _student.initials,
                                            style: const TextStyle(
                                              color: Color(0xFF9A3412),
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _student.name,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      Text(
                                        '${_student.classSection} · Roll ${_student.rollNo}',
                                        style: TextStyle(
                                          color: Colors.white.withValues(alpha: 0.92),
                                        ),
                                      ),
                                      if (_student.sessionName.isNotEmpty)
                                        Text(
                                          _student.sessionName,
                                          style: TextStyle(
                                            color: Colors.white.withValues(alpha: 0.85),
                                            fontSize: 12,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                if (_selectedType != null)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.22),
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: Text(
                                      '${_selectedType!.daysRemaining} days left',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
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
                                Text(
                                  'Leave type *',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: scheme.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: _types
                                      .map(
                                        (e) => ChoiceChip(
                                          label: Text(e.name),
                                          selected: _selectedType?.id == e.id,
                                          selectedColor: const Color(0xFFFF7A21),
                                          labelStyle: TextStyle(
                                            color: _selectedType?.id == e.id
                                                ? Colors.white
                                                : scheme.onSurfaceVariant,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          backgroundColor: ThemeAdaptive.neutralFill(context),
                                          onSelected: (_) =>
                                              setState(() => _selectedType = e),
                                        ),
                                      )
                                      .toList(),
                                ),
                                const SizedBox(height: 14),
                                Divider(height: 1, color: scheme.outlineVariant),
                                const SizedBox(height: 14),
                                Text(
                                  'From date *',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: scheme.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                _dateField(context, _dateLabel(_fromDate), () => _pickDate(true)),
                                const SizedBox(height: 12),
                                Text(
                                  'To date *',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: scheme.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                _dateField(context, _dateLabel(_toDate), () => _pickDate(false)),
                                if (_fromDate != null && _toDate != null) ...[
                                  const SizedBox(height: 12),
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: ThemeAdaptive.softTint(
                                        context,
                                        const Color(0xFFFFF7ED),
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: scheme.outlineVariant,
                                      ),
                                    ),
                                    child: Text(
                                      'Duration: ${_toDate!.difference(_fromDate!).inDays + 1} day(s)',
                                      style: TextStyle(
                                        color: scheme.primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 12),
                                Text(
                                  'Reason *',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: scheme.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextField(
                                  controller: _reasonCtrl,
                                  maxLines: 4,
                                  decoration: InputDecoration(
                                    hintText: 'Describe the reason',
                                    filled: true,
                                    fillColor: scheme.surfaceContainerHighest,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: scheme.outlineVariant,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Attach medical certificate (optional)',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: scheme.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                InkWell(
                                  onTap: _pickDocument,
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: scheme.outlineVariant,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                      color: ThemeAdaptive.softTint(
                                        context,
                                        const Color(0xFFFFFBEB),
                                      ),
                                    ),
                                    child: Text(
                                      _documentName ?? 'Upload document',
                                      style: TextStyle(
                                        color: scheme.onSurface,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 14),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: ThemeAdaptive.softTint(
                                      context,
                                      const Color(0xFFFFF7ED),
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: scheme.outlineVariant),
                                  ),
                                  child: Text(
                                    'Leave must be applied 1 day in advance.\nMedical leaves may require a certificate.',
                                    style: TextStyle(color: scheme.onSurfaceVariant),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SafeArea(
                      top: false,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(14, 6, 14, 12),
                        child: Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancel'),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              flex: 2,
                              child: ElevatedButton(
                                onPressed: _submitting ? null : _submit,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFF7A21),
                                  foregroundColor: Colors.white,
                                ),
                                child: _submitting
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Text('Submit Application'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _dateField(BuildContext context, String value, VoidCallback onTap) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: scheme.outlineVariant),
          color: scheme.surface,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                value,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: scheme.onSurface,
                ),
              ),
            ),
            Icon(
              Icons.calendar_today_rounded,
              size: 18,
              color: scheme.primary,
            ),
          ],
        ),
      ),
    );
  }
}
