import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:studentapp/controllers/outpass_controller.dart';
import 'package:studentapp/helpers/theme_adaptive.dart';
import 'package:studentapp/models/outpass_models.dart';
import 'package:studentapp/widgets/common_app_bar.dart';

import '../../helpers/app_navigation.dart';
import 'package:url_launcher/url_launcher.dart';

class GatePassScreen extends StatefulWidget {
  const GatePassScreen({super.key});

  @override
  State<GatePassScreen> createState() => _GatePassScreenState();
}

class _GatePassScreenState extends State<GatePassScreen> {
  final OutpassController _controller = OutpassController();
  bool _loading = true;
  String? _error;
  List<OutpassItem> _items = const [];

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
    final res = await _controller.fetchOutpassList(limit: 10);
    if (!mounted) return;
    setState(() {
      _loading = false;
      if (res.success) {
        _items = res.data;
      } else {
        _error = res.message.isNotEmpty
            ? res.message
            : 'gate_pass_error_load'.tr;
      }
    });
  }

  Color _statusFg(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return const Color(0xFF15803D);
      case 'rejected':
        return const Color(0xFFBE123C);
      default:
        return const Color(0xFFA16207);
    }
  }

  Color _statusBg(BuildContext context, String status) {
    final light = switch (status.toLowerCase()) {
      'approved' => const Color(0xFFDCFCE7),
      'rejected' => const Color(0xFFFFE4E6),
      _ => const Color(0xFFFEF3C7),
    };
    return ThemeAdaptive.softTint(context, light);
  }

  Widget _outpassCard(BuildContext context, OutpassItem item) {
    final scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: () async {
        await AppNavigation.push<void>(
          context,
          _OutpassDetailScreen(outpassId: item.id),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
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
            Row(
              children: [
                Expanded(
                  child: Text(
                    item.visitors?.isNotEmpty == true
                        ? item.visitors!
                        : 'gate_pass_outpass'.tr,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: scheme.onSurface,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: _statusBg(context, item.status),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    item.status,
                    style: TextStyle(
                      color: _statusFg(item.status),
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              item.relation?.isNotEmpty == true
                  ? '${item.relation} · ${item.contactNo ?? ''}'
                  : (item.contactNo ?? ''),
              style: TextStyle(
                color: scheme.onSurfaceVariant,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              item.description?.isNotEmpty == true
                  ? item.description!
                  : (item.reason?.isNotEmpty == true ? item.reason! : '-'),
              style: TextStyle(color: scheme.onSurface, fontSize: 13),
            ),
            const SizedBox(height: 8),
            Text(
              item.formattedOut ?? item.outDateTime ?? '-',
              style: TextStyle(
                color: scheme.onSurfaceVariant,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: CommonAppBar(title: 'more_gate_pass'.tr),
      backgroundColor: ThemeAdaptive.pageBackground(context),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.all(14),
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFF7A21),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'gate_pass_title'.tr,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '${_items.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'gate_pass_recent'.tr,
              style: TextStyle(
                fontSize: 11,
                color: scheme.onSurfaceVariant,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 8),
            if (_loading)
              const Padding(
                padding: EdgeInsets.only(top: 40),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_error != null)
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: scheme.errorContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _error!,
                  style: TextStyle(
                    color: scheme.onErrorContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
            else if (_items.isEmpty)
              Container(
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
                child: Text(
                  'gate_pass_none'.tr,
                  style: TextStyle(color: scheme.onSurfaceVariant),
                ),
              )
            else
              ..._items.map((e) => _outpassCard(context, e)),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 6, 14, 12),
          child: SizedBox(
            height: 52,
            child: ElevatedButton.icon(
              onPressed: () async {
                final applied = await AppNavigation.push<bool>(
                  context,
                  const _ApplyOutpassScreen(),
                );
                if (applied == true && mounted) _load();
              },
              icon: const Icon(Icons.add_rounded, color: Colors.white),
              label: Text(
                'gate_pass_apply'.tr,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF7A21),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _OutpassDetailScreen extends StatefulWidget {
  final int outpassId;
  const _OutpassDetailScreen({required this.outpassId});

  @override
  State<_OutpassDetailScreen> createState() => _OutpassDetailScreenState();
}

class _OutpassDetailScreenState extends State<_OutpassDetailScreen> {
  final OutpassController _controller = OutpassController();
  bool _loading = true;
  String? _error;
  OutpassItem? _item;
  bool _cancelling = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final res = await _controller.fetchOutpassDetail(widget.outpassId);
    if (!mounted) return;
    setState(() {
      _loading = false;
      if (res.success) {
        _item = res.data;
      } else {
        _error = res.message;
      }
    });
  }

  Widget _row(BuildContext context, String label, String value) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                color: scheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '-' : value,
              style: TextStyle(
                color: scheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _cancelOutpass() async {
    if (_cancelling) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('gate_pass_cancel'.tr),
        content: Text('gate_pass_cancel_confirm'.tr),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('common_no'.tr),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('common_yes'.tr),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    setState(() => _cancelling = true);
    final res = await _controller.cancelOutpass(widget.outpassId);
    if (!mounted) return;
    setState(() => _cancelling = false);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(res.message)));
    if (res.success) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: CommonAppBar(title: 'gate_pass_detail'.tr),
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
          : _item == null
          ? Center(
              child: Text(
                'gate_pass_no_details'.tr,
                style: TextStyle(color: scheme.onSurfaceVariant),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(14),
              children: [
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
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'gate_pass_detail'.tr,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: scheme.onSurface,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: _statusBg(context, _item!.status),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              _item!.status,
                              style: TextStyle(
                                color: _statusFg(_item!.status),
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Divider(height: 1, color: scheme.outlineVariant),
                      const SizedBox(height: 12),
                      _row(context, 'gate_pass_visitor'.tr, _item!.visitors ?? ''),
                      _row(context, 'gate_pass_relation'.tr, _item!.relation ?? ''),
                      _row(context, 'gate_pass_contact'.tr, _item!.contactNo ?? ''),
                      _row(
                        context,
                        'gate_pass_out_time'.tr,
                        _item!.formattedOut ?? _item!.outDateTime ?? '',
                      ),
                      _row(context, 'gate_pass_address'.tr, _item!.address ?? ''),
                      _row(context, 'common_description'.tr, _item!.description ?? ''),
                      if ((_item!.documentUrl ?? '').isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: _OutpassDocumentInlinePreview(
                            documentUrl: _item!.documentUrl!,
                          ),
                        ),
                      if ((_item!.remarks ?? '').isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
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
                              _item!.remarks!,
                              style: TextStyle(color: scheme.onSurfaceVariant),
                            ),
                          ),
                        ),
                      if (_item!.status.toLowerCase() == 'pending') ...[
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: _cancelling ? null : _cancelOutpass,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: scheme.error,
                              side: BorderSide(color: scheme.error.withValues(alpha: 0.5)),
                            ),
                            child: _cancelling
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text('gate_pass_cancel'.tr),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Color _statusFg(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return const Color(0xFF15803D);
      case 'rejected':
        return const Color(0xFFBE123C);
      default:
        return const Color(0xFFA16207);
    }
  }

  Color _statusBg(BuildContext context, String status) {
    final light = switch (status.toLowerCase()) {
      'approved' => const Color(0xFFDCFCE7),
      'rejected' => const Color(0xFFFFE4E6),
      _ => const Color(0xFFFEF3C7),
    };
    return ThemeAdaptive.softTint(context, light);
  }
}

/// Shows the outpass document inline; tap opens a fullscreen viewer with pinch zoom.
class _OutpassDocumentInlinePreview extends StatelessWidget {
  const _OutpassDocumentInlinePreview({required this.documentUrl});

  final String documentUrl;

  Future<void> _openInBrowser(BuildContext context) async {
    final uri = Uri.tryParse(documentUrl.trim());
    if (uri == null || !uri.hasScheme) return;
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!context.mounted || ok) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('gate_pass_error_load'.tr)),
    );
  }

  void _openZoom(BuildContext context) {
    Navigator.of(context).push<void>(
      PageRouteBuilder<void>(
        opaque: false,
        barrierDismissible: true,
        barrierColor: Colors.black87,
        pageBuilder: (_, __, ___) =>
            _OutpassDocumentZoomPage(imageUrl: documentUrl),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final uri = Uri.tryParse(documentUrl.trim());
    if (uri == null || !uri.hasScheme) {
      return const SizedBox.shrink();
    }

    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'gate_pass_attached_document'.tr,
          style: TextStyle(
            color: scheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Material(
          color: ThemeAdaptive.neutralFill(context),
          borderRadius: BorderRadius.circular(12),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _openZoom(context),
                  child: AspectRatio(
                    aspectRatio: 16 / 10,
                    child: Image.network(
                      documentUrl,
                      fit: BoxFit.cover,
                      alignment: Alignment.center,
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return Center(
                          child: SizedBox(
                            width: 32,
                            height: 32,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: scheme.primary,
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, _, __) {
                        return Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.insert_drive_file_outlined,
                                size: 40,
                                color: scheme.onSurfaceVariant,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'gate_pass_open_document'.tr,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: scheme.onSurfaceVariant,
                                ),
                              ),
                              TextButton(
                                onPressed: () => _openInBrowser(context),
                                child: Text('gate_pass_open_in_browser'.tr),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Row(
                  children: [
                    Icon(
                      Icons.zoom_in_map_rounded,
                      size: 18,
                      color: scheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'gate_pass_tap_to_zoom'.tr,
                        style: TextStyle(
                          fontSize: 13,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _OutpassDocumentZoomPage extends StatelessWidget {
  const _OutpassDocumentZoomPage({required this.imageUrl});

  final String imageUrl;

  Future<void> _openInBrowser(BuildContext context) async {
    final uri = Uri.tryParse(imageUrl.trim());
    if (uri == null || !uri.hasScheme) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Center(
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 5,
              panEnabled: true,
              boundaryMargin: const EdgeInsets.all(120),
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
                width: size.width,
                height: size.height,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return SizedBox(
                    width: 100,
                    height: 100,
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Colors.white.withValues(alpha: 0.85),
                        strokeWidth: 2,
                      ),
                    ),
                  );
                },
                errorBuilder: (context, _, __) {
                  return Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.broken_image_outlined,
                          size: 48,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () => _openInBrowser(context),
                          child: Text(
                            'gate_pass_open_in_browser'.tr,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 28),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white24,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ApplyOutpassScreen extends StatefulWidget {
  const _ApplyOutpassScreen();

  @override
  State<_ApplyOutpassScreen> createState() => _ApplyOutpassScreenState();
}

class _ApplyOutpassScreenState extends State<_ApplyOutpassScreen> {
  final OutpassController _controller = OutpassController();
  final TextEditingController _contactCtrl = TextEditingController();
  final TextEditingController _relationCtrl = TextEditingController();
  final TextEditingController _visitorCtrl = TextEditingController();
  final TextEditingController _descriptionCtrl = TextEditingController();
  final TextEditingController _addressCtrl = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();

  bool _loadingReasons = true;
  bool _submitting = false;
  String? _error;
  DateTime? _outDateTime;
  List<OutpassReason> _reasons = const [];
  OutpassReason? _selectedReason;
  String? _documentPath;
  String? _documentName;

  @override
  void initState() {
    super.initState();
    _loadReasons();
  }

  Future<void> _loadReasons() async {
    final res = await _controller.fetchReasons();
    if (!mounted) return;
    setState(() {
      _loadingReasons = false;
      if (res.success) {
        _reasons = res.data;
      } else {
        _error = res.message;
      }
    });
  }

  Future<void> _pickDateTime() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      firstDate: now.subtract(const Duration(days: 1)),
      lastDate: now.add(const Duration(days: 365)),
      initialDate: _outDateTime ?? now,
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_outDateTime ?? now),
    );
    if (time == null) return;
    setState(() {
      _outDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  String _formattedOutDateTime() {
    final dt = _outDateTime;
    if (dt == null) return 'gate_pass_select_out_datetime'.tr;
    return DateFormat('dd MMM yyyy, hh:mm a').format(dt);
  }

  String _apiDateTime(DateTime dt) => DateFormat('yyyy-MM-dd HH:mm').format(dt);

  Future<void> _pickFromFiles() async {
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

  Future<void> _pickFromGallery() async {
    final image = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (image == null) return;
    setState(() {
      _documentPath = image.path;
      _documentName = image.name;
    });
  }

  Future<void> _pickFromCamera() async {
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: Text('edit_info_gallery'.tr),
                onTap: () async {
                  Navigator.pop(context);
                  await _pickFromGallery();
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined),
                title: Text('edit_info_camera'.tr),
                onTap: () async {
                  Navigator.pop(context);
                  await _pickFromCamera();
                },
              ),
              ListTile(
                leading: const Icon(Icons.insert_drive_file_outlined),
                title: Text('gate_pass_files'.tr),
                onTap: () async {
                  Navigator.pop(context);
                  await _pickFromFiles();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _submit() async {
    if (_submitting) return;
    if (_outDateTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('gate_pass_select_out_datetime'.tr)),
      );
      return;
    }
    if (_contactCtrl.text.trim().isEmpty ||
        _relationCtrl.text.trim().isEmpty ||
        _visitorCtrl.text.trim().isEmpty ||
        _descriptionCtrl.text.trim().isEmpty ||
        _addressCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('gate_pass_fill_required'.tr)),
      );
      return;
    }
    setState(() => _submitting = true);
    final res = await _controller.applyOutpass(
      outDateTime: _apiDateTime(_outDateTime!),
      reasonId: _selectedReason?.id,
      contactNo: _contactCtrl.text.trim(),
      relation: _relationCtrl.text.trim(),
      visitors: _visitorCtrl.text.trim(),
      description: _descriptionCtrl.text.trim(),
      address: _addressCtrl.text.trim(),
      documentPath: _documentPath,
    );
    if (!mounted) return;
    setState(() => _submitting = false);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(res.message)));
    if (res.success) Navigator.pop(context, true);
  }

  @override
  void dispose() {
    _contactCtrl.dispose();
    _relationCtrl.dispose();
    _visitorCtrl.dispose();
    _descriptionCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: CommonAppBar(title: 'gate_pass_apply'.tr),
      backgroundColor: ThemeAdaptive.pageBackground(context),
      body: _loadingReasons
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Text(
                _error!,
                style: TextStyle(color: scheme.error),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(14),
              children: [
                _dateField(
                  context: context,
                  label: 'gate_pass_out_datetime'.tr,
                  value: _formattedOutDateTime(),
                  onTap: _pickDateTime,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<OutpassReason?>(
                  initialValue: _selectedReason,
                  decoration: InputDecoration(
                    labelText: 'gate_pass_reason_optional'.tr,
                    filled: true,
                    fillColor: scheme.surfaceContainerHighest,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  items: [
                    DropdownMenuItem<OutpassReason?>(
                      value: null,
                      child: Text('common_none'.tr),
                    ),
                    ..._reasons.map(
                      (r) => DropdownMenuItem<OutpassReason?>(
                        value: r,
                        child: Text(r.name),
                      ),
                    ),
                  ],
                  onChanged: (v) => setState(() => _selectedReason = v),
                ),
                const SizedBox(height: 12),
                _textField(context, _contactCtrl, 'gate_pass_contact_no'.tr),
                const SizedBox(height: 10),
                _textField(context, _relationCtrl, 'gate_pass_relation_required'.tr),
                const SizedBox(height: 10),
                _textField(context, _visitorCtrl, 'gate_pass_visitors_required'.tr),
                const SizedBox(height: 10),
                _textField(context, _descriptionCtrl, 'gate_pass_description_required'.tr, maxLines: 3),
                const SizedBox(height: 10),
                _textField(context, _addressCtrl, 'gate_pass_address_required'.tr, maxLines: 2),
                const SizedBox(height: 10),
                InkWell(
                  onTap: _pickDocument,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: scheme.outlineVariant),
                      borderRadius: BorderRadius.circular(10),
                      color: ThemeAdaptive.softTint(
                        context,
                        const Color(0xFFFFFBEB),
                      ),
                    ),
                    child: Text(
                      _documentName ?? 'gate_pass_attach_optional'.tr,
                      style: TextStyle(color: scheme.onSurface),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _submitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF7A21),
                    foregroundColor: Colors.white,
                  ),
                  child: _submitting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text('gate_pass_submit'.tr),
                ),
              ],
            ),
    );
  }

  Widget _textField(
    BuildContext context,
    TextEditingController controller,
    String label, {
    int maxLines = 1,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: scheme.surfaceContainerHighest,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _dateField({
    required BuildContext context,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: scheme.outlineVariant),
          color: scheme.surface,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      color: scheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(
                      color: scheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.calendar_today_rounded, size: 18, color: scheme.primary),
          ],
        ),
      ),
    );
  }
}
