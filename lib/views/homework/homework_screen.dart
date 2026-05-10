import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../constants/app_colors.dart';
import '../../controllers/homework_controller.dart';
import '../../helpers/datetime_helper.dart';
import '../../helpers/theme_adaptive.dart';
import '../../models/homework_models.dart';
import '../../widgets/attachment_viewer_dialog.dart';
import '../../widgets/common_app_bar.dart';
import '../../widgets/week_calendar_strip.dart';

class HomeworkScreen extends StatefulWidget {
  const HomeworkScreen({super.key});

  @override
  State<HomeworkScreen> createState() => _HomeworkScreenState();
}

class _HomeworkScreenState extends State<HomeworkScreen> {
  static const int _pageLimit = 10;

  final HomeworkController _homeworkController = HomeworkController();

  late DateTime _focusedDate;
  late DateTime _selectedDate;

  final List<HomeworkAssignment> _items = [];

  bool _loading = false;
  bool _loadingMore = false;
  String? _errorMessage;
  bool _hasNextPage = false;
  String? _nextCursor;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _focusedDate = DateTime(now.year, now.month, 1);
    _selectedDate = DateTime(now.year, now.month, now.day);
    _fetchHomework(reset: true);
  }

  @override
  void dispose() {
    _homeworkController.dispose();
    super.dispose();
  }

  Future<void> _fetchHomework({required bool reset}) async {
    if (_loading || _loadingMore) return;
    if (!reset && !_hasNextPage) return;

    if (reset) {
      setState(() {
        _loading = true;
        _errorMessage = null;
        _items.clear();
        _nextCursor = null;
        _hasNextPage = false;
      });
    } else {
      setState(() => _loadingMore = true);
    }

    final dateStr = DateTimeHelper.dateForApi(_selectedDate);
    final cursor = !reset &&
            _nextCursor != null &&
            _nextCursor!.trim().isNotEmpty
        ? _nextCursor
        : null;

    final parsed = await _homeworkController.fetchHomework(
      yyyyMmDd: dateStr,
      limit: _pageLimit,
      cursor: cursor,
    );

    if (!mounted) return;

    if (parsed.success) {
      setState(() {
        if (reset) {
          _items
            ..clear()
            ..addAll(parsed.data);
        } else {
          _items.addAll(parsed.data);
        }
        final p = parsed.pagination;
        _hasNextPage = p.hasNextPage;
        _nextCursor = p.nextCursor;
        _loading = false;
        _loadingMore = false;
      });
      return;
    }

    setState(() {
      _errorMessage = parsed.message.isNotEmpty
          ? parsed.message
          : 'homework_error_load'.tr;
      _loading = false;
      _loadingMore = false;
    });
  }

  void _syncSelectedToFocusedMonth() {
    final now = DateTime.now();
    if (now.year == _focusedDate.year && now.month == _focusedDate.month) {
      _selectedDate = DateTime(now.year, now.month, now.day);
    } else {
      _selectedDate = DateTime(_focusedDate.year, _focusedDate.month, 1);
    }
  }

  void _onDayPicked(DateTime day) {
    setState(() {
      _selectedDate = DateTime(day.year, day.month, day.day);
      _focusedDate = DateTime(day.year, day.month, 1);
    });
    _fetchHomework(reset: true);
  }

  void _onPrevWeek() {
    setState(() {
      _selectedDate = _selectedDate.subtract(const Duration(days: 7));
      _focusedDate = DateTime(_selectedDate.year, _selectedDate.month, 1);
    });
    _fetchHomework(reset: true);
  }

  void _onNextWeek() {
    setState(() {
      _selectedDate = _selectedDate.add(const Duration(days: 7));
      _focusedDate = DateTime(_selectedDate.year, _selectedDate.month, 1);
    });
    _fetchHomework(reset: true);
  }

  void _openSubmitHomework(HomeworkAssignment item) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(ctx).bottom,
        ),
        child: _SubmitHomeworkSheet(
          item: item,
          controller: _homeworkController,
          onSubmitted: () {
            Navigator.of(ctx).pop();
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('homework_submitted'.tr)),
            );
            _fetchHomework(reset: true);
          },
        ),
      ),
    );
  }

  void _showHomeworkDetail(HomeworkAssignment item) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.55,
        minChildSize: 0.35,
        maxChildSize: 0.92,
        builder: (_, scrollController) => Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                item.title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(ctx).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                item.formattedHomeworkDate ??
                    item.formattedDate ??
                    (item.homeworkDate ?? ''),
                style: TextStyle(fontSize: 13, color: Theme.of(ctx).colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: SelectableText(
                    item.bodyText.replaceAll('\r\n', '\n'),
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.45,
                      color: Theme.of(ctx).colorScheme.onSurface.withValues(alpha: 0.87),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (item.fileImage != null &&
                      item.fileImage!.trim().isNotEmpty)
                    OutlinedButton.icon(
                      onPressed: () => showAttachmentDialog(
                        ctx,
                        AttachmentType.image,
                        item.fileImage!,
                      ),
                      icon: const Icon(Icons.image_outlined, size: 18),
                      label: Text('homework_attachment'.tr),
                    ),
                  if (item.pdfImage != null &&
                      item.pdfImage!.trim().isNotEmpty)
                    OutlinedButton.icon(
                      onPressed: () => showAttachmentDialog(
                        ctx,
                        AttachmentType.pdf,
                        item.pdfImage!,
                      ),
                      icon: const Icon(Icons.picture_as_pdf_outlined,
                          size: 18),
                      label: Text('homework_pdf'.tr),
                    ),
                  if (item.video != null && item.video!.trim().isNotEmpty)
                    OutlinedButton.icon(
                      onPressed: () => showAttachmentDialog(
                        ctx,
                        AttachmentType.video,
                        item.video!,
                      ),
                      icon: const Icon(Icons.play_circle_outline, size: 18),
                      label: Text('homework_video'.tr),
                    ),
                  if (item.audioImage != null &&
                      item.audioImage!.trim().isNotEmpty)
                    OutlinedButton.icon(
                      onPressed: () => showAttachmentDialog(
                        ctx,
                        AttachmentType.audio,
                        item.audioImage!,
                      ),
                      icon: const Icon(Icons.music_note_outlined, size: 18),
                      label: Text('homework_audio'.tr),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: ThemeAdaptive.warmPageBackground(context),
      appBar: CommonAppBar(title: 'homework_title'.tr),
      body: RefreshIndicator(
          color: AppColors.accentOrange,
          onRefresh: () => _fetchHomework(reset: true),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 24),
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: scheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: ThemeAdaptive.cardShadow(context),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: WeekCalendarStrip(
                      focusedDate: _focusedDate,
                      selectedDate: _selectedDate,
                      monthTitle:
                          '< ${localizedMonthName(_focusedDate.month).toUpperCase()} >',
                      onDayPicked: _onDayPicked,
                      onPrevMonth: () {
                        setState(() {
                          _focusedDate = DateTime(
                            _focusedDate.year,
                            _focusedDate.month - 1,
                            1,
                          );
                          _syncSelectedToFocusedMonth();
                        });
                        _fetchHomework(reset: true);
                      },
                      onNextMonth: () {
                        setState(() {
                          _focusedDate = DateTime(
                            _focusedDate.year,
                            _focusedDate.month + 1,
                            1,
                          );
                          _syncSelectedToFocusedMonth();
                        });
                        _fetchHomework(reset: true);
                      },
                      onPrevWeek: _onPrevWeek,
                      onNextWeek: _onNextWeek,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'homework_today'.tr,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: scheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (_loading && _items.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 32),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: AppColors.accentOrange,
                            ),
                          ),
                        )
                      else if (_errorMessage != null && _items.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          child: Column(
                            children: [
                              Text(
                                _errorMessage!,
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.red.shade700),
                              ),
                              const SizedBox(height: 12),
                              TextButton(
                                onPressed: () =>
                                    _fetchHomework(reset: true),
                                child: Text('common_retry'.tr),
                              ),
                            ],
                          ),
                        )
                      else if (_items.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          child: Text(
                            '${'homework_none_for'.tr} ${DateTimeHelper.formatStandardDate(_selectedDate)}.',
                            style: TextStyle(
                              fontSize: 14,
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        )
                      else
                        ..._items.map((item) => _HomeworkCard(
                              item: item,
                              onViewMore: () =>
                                  _showHomeworkDetail(item),
                              onOpenMedia: (type, url) =>
                                  showAttachmentDialog(context, type, url),
                              onSubmitHomework: item.showUploadButton &&
                                      !item.isSubmitted &&
                                      !item.studentSubmitted &&
                                      item.assignmentStudentId > 0
                                  ? () => _openSubmitHomework(item)
                                  : null,
                            )),
                      if (_hasNextPage) ...[
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: _loadingMore
                                ? null
                                : () =>
                                    _fetchHomework(reset: false),
                            child: _loadingMore
                                ? const SizedBox(
                                    height: 22,
                                    width: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.accentOrange,
                                    ),
                                  )
                                : Text('common_load_more'.tr),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
    );
  }
}

class _HomeworkCard extends StatelessWidget {
  final HomeworkAssignment item;
  final VoidCallback onViewMore;
  final void Function(AttachmentType type, String url) onOpenMedia;
  final VoidCallback? onSubmitHomework;

  const _HomeworkCard({
    required this.item,
    required this.onViewMore,
    required this.onOpenMedia,
    this.onSubmitHomework,
  });

  @override
  Widget build(BuildContext context) {
    final preview = item.bodyText.replaceAll('\r\n', ' ');
    final short =
        preview.length > 140 ? '${preview.substring(0, 140)}…' : preview;
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: ThemeAdaptive.cardShadow(context, lightAlpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: AppColors.accentOrange,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      item.subjectAbbrev,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item.title.isNotEmpty ? item.title : 'homework_title'.tr,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: scheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              short,
              style: TextStyle(
                fontSize: 14,
                color: scheme.onSurface.withValues(alpha: 0.9),
              ),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  homeworkDateLabel(item),
                  style: TextStyle(
                    fontSize: 12,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (item.pdfImage != null &&
                        item.pdfImage!.trim().isNotEmpty)
                      GestureDetector(
                        onTap: () =>
                            onOpenMedia(AttachmentType.pdf, item.pdfImage!),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4),
                          child: Icon(
                            Icons.picture_as_pdf_outlined,
                            size: 22,
                            color: AppColors.accentOrange,
                          ),
                        ),
                      ),
                    if (item.video != null && item.video!.trim().isNotEmpty)
                      GestureDetector(
                        onTap: () =>
                            onOpenMedia(AttachmentType.video, item.video!),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4),
                          child: Icon(
                            Icons.play_circle_outline,
                            size: 22,
                            color: AppColors.accentOrange,
                          ),
                        ),
                      ),
                    if (item.audioImage != null &&
                        item.audioImage!.trim().isNotEmpty)
                      GestureDetector(
                        onTap: () => onOpenMedia(
                            AttachmentType.audio, item.audioImage!),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4),
                          child: Icon(
                            Icons.music_note_outlined,
                            size: 22,
                            color: AppColors.accentOrange,
                          ),
                        ),
                      ),
                    if ((item.pdfImage?.trim().isNotEmpty ?? false) ||
                        (item.video?.trim().isNotEmpty ?? false) ||
                        (item.audioImage?.trim().isNotEmpty ?? false))
                      const SizedBox(width: 6),
                    GestureDetector(
                      onTap: onViewMore,
                      child: Text(
                        'common_view_more'.tr,
                        style: TextStyle(
                          fontSize: 14,
                          color: scheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (onSubmitHomework != null) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: onSubmitHomework,
                  icon: const Icon(Icons.cloud_upload_outlined, size: 20),
                  label: Text('homework_submit'.tr),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.accentOrange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
            if (item.fileImage != null &&
                item.fileImage!.trim().isNotEmpty) ...[
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () =>
                    onOpenMedia(AttachmentType.image, item.fileImage!),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Image.network(
                      item.fileImage!,
                      fit: BoxFit.cover,
                      loadingBuilder: (c, w, ev) {
                        if (ev == null) return w;
                        return Container(
                          color: Colors.grey.shade200,
                          alignment: Alignment.center,
                          child: const SizedBox(
                            width: 28,
                            height: 28,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.accentOrange,
                            ),
                          ),
                        );
                      },
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.grey.shade200,
                        alignment: Alignment.center,
                        child: Icon(Icons.broken_image_outlined,
                            color: Colors.grey.shade500),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SubmitHomeworkSheet extends StatefulWidget {
  final HomeworkAssignment item;
  final HomeworkController controller;
  final VoidCallback onSubmitted;

  const _SubmitHomeworkSheet({
    required this.item,
    required this.controller,
    required this.onSubmitted,
  });

  @override
  State<_SubmitHomeworkSheet> createState() => _SubmitHomeworkSheetState();
}

class _SubmitHomeworkSheetState extends State<_SubmitHomeworkSheet> {
  final _description = TextEditingController();
  bool _submitting = false;

  String? _imgPath;
  List<int>? _imgBytes;
  String? _imgName;

  String? _pdfPath;
  List<int>? _pdfBytes;
  String? _pdfName;

  String? _audioPath;
  List<int>? _audioBytes;
  String? _audioName;

  @override
  void dispose() {
    _description.dispose();
    super.dispose();
  }

  Future<void> _pick({
    required List<String> extensions,
    required void Function(String? path, List<int>? bytes, String? name) setSlot,
  }) async {
    final r = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: extensions,
      withData: kIsWeb,
    );
    if (!mounted) return;
    final file = r?.files.isNotEmpty == true ? r!.files.first : null;
    if (file == null) return;
    final path = file.path;
    if (path != null && path.isNotEmpty) {
      setSlot(path, null, file.name.trim().isNotEmpty ? file.name : _tail(path));
      setState(() {});
      return;
    }
    final bytes = file.bytes;
    final name = file.name.trim();
    if (bytes != null && bytes.isNotEmpty && name.isNotEmpty) {
      setSlot(null, bytes, name);
      setState(() {});
      return;
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('homework_error_read_file'.tr)),
      );
    }
  }

  static String _tail(String path) {
    final s = path.replaceAll(r'\', '/');
    final i = s.lastIndexOf('/');
    return i < 0 ? s : s.substring(i + 1);
  }

  Future<void> _submit() async {
    if (_submitting) return;
    FocusScope.of(context).unfocus();
    setState(() => _submitting = true);
    final err = await widget.controller.submitAssignment(
      assignmentStudentId: widget.item.assignmentStudentId,
      description: _description.text,
      fileImagePath: _imgPath,
      pdfFilePath: _pdfPath,
      audioFilePath: _audioPath,
      fileImageBytes: _imgBytes,
      fileImageName: _imgName,
      pdfFileBytes: _pdfBytes,
      pdfFileName: _pdfName,
      audioFileBytes: _audioBytes,
      audioFileName: _audioName,
    );
    if (!mounted) return;
    setState(() => _submitting = false);
    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
      return;
    }
    widget.onSubmitted();
  }

  Widget _attachmentRow({
    required String label,
    required String? name,
    required VoidCallback onPick,
    required VoidCallback onClear,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(
        name ?? 'homework_none_selected'.tr,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 13,
          color: name != null ? Colors.black87 : Colors.grey.shade600,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (name != null)
            IconButton(
              tooltip: 'common_remove'.tr,
              onPressed: _submitting ? null : onClear,
              icon: const Icon(Icons.close),
            ),
          TextButton(
            onPressed: _submitting ? null : onPick,
            child: Text('common_choose'.tr),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              widget.item.title.isNotEmpty
                  ? widget.item.title
                  : 'homework_title'.tr,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              '${'homework_assignment'.tr} #${widget.item.assignmentStudentId}',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _description,
              readOnly: _submitting,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: 'common_description'.tr,
                hintText: 'homework_description_hint'.tr,
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 8),
            Text(
              'homework_optional_attachments'.tr,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 8),
            _attachmentRow(
              label: 'homework_image'.tr,
              name: _imgName,
              onPick: () => _pick(
                extensions: ['jpg', 'jpeg', 'png', 'webp', 'heic'],
                setSlot: (p, b, n) {
                  _imgPath = p;
                  _imgBytes = b;
                  _imgName = n;
                },
              ),
              onClear: () {
                _imgPath = null;
                _imgBytes = null;
                _imgName = null;
                setState(() {});
              },
            ),
            _attachmentRow(
              label: 'homework_pdf'.tr,
              name: _pdfName,
              onPick: () => _pick(
                extensions: ['pdf'],
                setSlot: (p, b, n) {
                  _pdfPath = p;
                  _pdfBytes = b;
                  _pdfName = n;
                },
              ),
              onClear: () {
                _pdfPath = null;
                _pdfBytes = null;
                _pdfName = null;
                setState(() {});
              },
            ),
            _attachmentRow(
              label: 'homework_audio'.tr,
              name: _audioName,
              onPick: () => _pick(
                extensions: ['m4a', 'mp3', 'aac', 'wav'],
                setSlot: (p, b, n) {
                  _audioPath = p;
                  _audioBytes = b;
                  _audioName = n;
                },
              ),
              onClear: () {
                _audioPath = null;
                _audioBytes = null;
                _audioName = null;
                setState(() {});
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _submitting
                        ? null
                        : () => Navigator.of(context).pop(),
                    child: Text('common_cancel'.tr),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: FilledButton(
                    onPressed: _submitting ? null : _submit,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.accentOrange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
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
                        : Text('common_submit'.tr),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

String homeworkDateLabel(HomeworkAssignment item) {
  final fh = item.formattedHomeworkDate?.trim();
  if (fh != null && fh.isNotEmpty) return fh;
  final fd = item.formattedDate?.trim();
  if (fd != null && fd.isNotEmpty) return fd;
  final iso = item.homeworkDate ?? item.date;
  if (iso == null || iso.trim().isEmpty) return '';
  final d = DateTime.tryParse(iso.trim());
  if (d == null) return iso.trim();
  return DateTimeHelper.formatStandardDate(d);
}
