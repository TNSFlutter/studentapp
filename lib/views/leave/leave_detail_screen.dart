import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../controllers/leave_controller.dart';
import '../../helpers/theme_adaptive.dart';
import '../../models/leave_models.dart';
import '../../widgets/common_app_bar.dart';

class LeaveDetailScreen extends StatefulWidget {
  final int leaveId;
  const LeaveDetailScreen({super.key, required this.leaveId});

  @override
  State<LeaveDetailScreen> createState() => _LeaveDetailScreenState();
}

class _LeaveDetailScreenState extends State<LeaveDetailScreen> {
  final LeaveController _controller = LeaveController();
  bool _loading = true;
  bool _deleting = false;
  String? _error;
  LeaveItem? _item;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final res = await _controller.fetchLeaveDetail(widget.leaveId);
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

  Future<void> _delete() async {
    setState(() => _deleting = true);
    final res = await _controller.deleteLeave(widget.leaveId);
    if (!mounted) return;
    setState(() => _deleting = false);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res.message)));
    if (res.success) Navigator.pop(context, true);
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

  Widget _detailRow(ColorScheme scheme, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 92,
            child: Text(
              label,
              style: TextStyle(
                color: scheme.onSurfaceVariant,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value.isEmpty ? '-' : value,
              style: TextStyle(
                color: scheme.onSurface,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: const CommonAppBar(title: 'Leave Detail'),
      backgroundColor: ThemeAdaptive.pageBackground(context),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: scheme.error),
                    ),
                  ),
                )
              : _item == null
                  ? Center(
                      child: Text(
                        'No details available.',
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
                                      _item!.leaveType.name,
                                      style: TextStyle(
                                        fontSize: 20,
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
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Divider(height: 1, color: scheme.outlineVariant),
                              const SizedBox(height: 12),
                              _detailRow(scheme, 'Duration', _item!.formattedDateRange),
                              _detailRow(scheme, 'Days', '${_item!.totalDays} day(s)'),
                              _detailRow(scheme, 'Applied', _item!.formattedAppliedOn),
                              if (_item!.formattedApprovedOn.isNotEmpty)
                                _detailRow(
                                  scheme,
                                  'Approved on',
                                  _item!.formattedApprovedOn,
                                ),
                              const SizedBox(height: 2),
                              Text(
                                'Reason',
                                style: TextStyle(
                                  color: scheme.onSurfaceVariant,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: ThemeAdaptive.neutralFill(context),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: scheme.outlineVariant,
                                  ),
                                ),
                                child: Text(
                                  _item!.description,
                                  style: TextStyle(
                                    color: scheme.onSurface,
                                    fontSize: 14,
                                    height: 1.35,
                                  ),
                                ),
                              ),
                              if ((_item!.documentUrl ?? '').isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 12),
                                  child: OutlinedButton.icon(
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: scheme.primary,
                                      side: BorderSide(color: scheme.outline),
                                    ),
                                    onPressed: () async {
                                      final uri = Uri.tryParse(_item!.documentUrl!);
                                      if (uri != null && uri.hasScheme) {
                                        await launchUrl(uri);
                                      }
                                    },
                                    icon: const Icon(Icons.attach_file_rounded),
                                    label: const Text('Open document'),
                                  ),
                                ),
                              const SizedBox(height: 12),
                              OutlinedButton(
                                onPressed: _deleting ? null : _delete,
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: scheme.error,
                                  side: BorderSide(color: scheme.error.withValues(alpha: 0.5)),
                                ),
                                child: _deleting
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      )
                                    : const Text('Delete Leave'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
    );
  }
}
