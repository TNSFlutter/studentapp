import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:studentapp/widgets/common_app_bar.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../constants/app_colors.dart';
import '../../helpers/theme_adaptive.dart';
import '../../controllers/live_class_controller.dart';
import '../../models/live_class_models.dart';

class LiveClassScreen extends StatefulWidget {
  const LiveClassScreen({super.key});

  @override
  State<LiveClassScreen> createState() => _LiveClassScreenState();
}

class _LiveClassScreenState extends State<LiveClassScreen> {
  DateTime _selectedDate = DateTime.now();
  late DateTime _currentMonth = DateTime(_selectedDate.year, _selectedDate.month);
  final LiveClassController _liveClassController = LiveClassController();
  final List<LiveClassItem> _classes = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadClassesForSelectedDate();
  }

  Future<void> _loadClassesForSelectedDate() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final date = DateFormat('yyyy-MM-dd').format(_selectedDate);
    final parsed = await _liveClassController.fetchLiveClasses(
      yyyyMmDd: date,
      limit: 10,
    );
    if (!mounted) return;
    if (!parsed.success) {
      setState(() {
        _error = parsed.message.isNotEmpty
            ? parsed.message
            : 'Could not load live classes.';
        _classes.clear();
        _loading = false;
      });
      return;
    }
    setState(() {
      _classes
        ..clear()
        ..addAll(parsed.data);
      _loading = false;
      _error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: ThemeAdaptive.pageBackground(context),
      appBar: const CommonAppBar(title: 'Live Class'),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Calendar Section
            _buildCalendarSection(),
            const SizedBox(height: 20),

            if (_loading)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: CircularProgressIndicator(
                  color: scheme.primary,
                ),
              ),
            if (!_loading && _error != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: scheme.error,
                        fontSize: 14,
                      ),
                    ),
                    TextButton(
                      onPressed: _loadClassesForSelectedDate,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            if (!_loading && _error == null && _classes.isNotEmpty) ...[
              _buildActiveLiveClassSection(),
              const SizedBox(height: 20),
              _buildUpcomingLiveClassSection(),
              const SizedBox(height: 20),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarSection() {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.all(20),
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
        children: [
          // Month Navigation
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    _currentMonth = DateTime(
                      _currentMonth.year,
                      _currentMonth.month - 1,
                    );
                  });
                },
                child: const Icon(
                  Icons.chevron_left,
                  color: AppColors.accentOrange,
                  size: 24,
                ),
              ),
              Text(
                _getMonthName(_currentMonth.month).toUpperCase(),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.accentOrange,
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _currentMonth = DateTime(
                      _currentMonth.year,
                      _currentMonth.month + 1,
                    );
                  });
                },
                child: const Icon(
                  Icons.chevron_right,
                  color: AppColors.accentOrange,
                  size: 24,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Days of Week Header
          Row(
            children: ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT']
                .map(
                  (d) => Expanded(
                    child: Center(
                      child: Text(
                        d,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: scheme.onSurface,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 12),

          // Calendar Dates
          _buildCalendarDates(),
          const SizedBox(height: 12),

          // Bottom Indicator
          Container(
            width: 40,
            height: 2,
            decoration: BoxDecoration(
              color: scheme.outlineVariant,
              borderRadius: BorderRadius.circular(1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarDates() {
    final scheme = Theme.of(context).colorScheme;
    final firstDayOfMonth = DateTime(
      _currentMonth.year,
      _currentMonth.month,
      1,
    );
    final lastDayOfMonth = DateTime(
      _currentMonth.year,
      _currentMonth.month + 1,
      0,
    );
    final firstWeekday =
        firstDayOfMonth.weekday % 7; // Convert to 0-6 (Sun-Sat)

    List<Widget> dateWidgets = [];

    // Add empty cells for days before the first day of the month
    for (int i = 0; i < firstWeekday; i++) {
      dateWidgets.add(const Expanded(child: SizedBox()));
    }

    // Add date cells
    for (int day = 1; day <= lastDayOfMonth.day; day++) {
      final date = DateTime(_currentMonth.year, _currentMonth.month, day);
      final isSelected =
          date.day == _selectedDate.day &&
          date.month == _selectedDate.month &&
          date.year == _selectedDate.year;

      dateWidgets.add(
        Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _selectedDate = date;
              });
              _loadClassesForSelectedDate();
            },
            child: Container(
              height: 40,
              margin: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? const LinearGradient(
                        colors: [AppColors.accentOrange, Color(0xFFFFD700)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      )
                    : null,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  day.toString(),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : scheme.onSurface,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        Row(children: dateWidgets.take(7).toList()),
        if (dateWidgets.length > 7)
          Row(children: dateWidgets.skip(7).take(7).toList()),
        if (dateWidgets.length > 14)
          Row(children: dateWidgets.skip(14).take(7).toList()),
        if (dateWidgets.length > 21)
          Row(children: dateWidgets.skip(21).take(7).toList()),
        if (dateWidgets.length > 28)
          Row(children: dateWidgets.skip(28).take(7).toList()),
      ],
    );
  }

  Widget _buildActiveLiveClassSection() {
    final scheme = Theme.of(context).colorScheme;
    final active = _classes.where((e) => e.isLive).toList();
    if (active.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Active Live Class',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          for (int i = 0; i < active.length; i++) ...[
            if (i > 0) const SizedBox(height: 12),
            _buildLiveClassCard(item: active[i]),
          ],
        ],
      ),
    );
  }

  Widget _buildUpcomingLiveClassSection() {
    final scheme = Theme.of(context).colorScheme;
    final upcoming = _classes.where((e) => !e.isLive).toList();
    if (upcoming.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Upcoming Live Class',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          for (int i = 0; i < upcoming.length; i++) ...[
            if (i > 0) const SizedBox(height: 12),
            _buildLiveClassCard(item: upcoming[i]),
          ],
        ],
      ),
    );
  }

  String _subjectBadge(String s) {
    final t = s.trim();
    if (t.isEmpty) return 'CLS';
    if (t.length >= 3) return t.substring(0, 3).toUpperCase();
    return t.toUpperCase();
  }

  String _dateTime(String? startIso) {
    final t = startIso?.trim() ?? '';
    if (t.isEmpty) return 'Date unavailable';
    final dt = DateTime.tryParse(t)?.toLocal();
    if (dt == null) return t;
    return DateFormat('dd MMM yyyy, hh:mm a').format(dt);
  }

  Future<void> _joinClass(LiveClassItem item) async {
    final link = item.link?.trim() ?? '';
    if (link.isEmpty) return;
    final uri = Uri.tryParse(link);
    if (uri == null || !uri.hasScheme) return;
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open class link')),
      );
    }
  }

  Widget _buildLiveClassCard({required LiveClassItem item}) {
    final scheme = Theme.of(context).colorScheme;
    final title = item.heading.isNotEmpty
        ? item.heading
        : (item.name.isNotEmpty ? item.name : 'Live Class');
    final topic = item.description.isNotEmpty
        ? 'Topic- ${item.description}'
        : 'Topic- ${item.subjectName}';
    final duration = 'Duration- ${item.duration} mins';
    final dateTime = _dateTime(item.startTime);
    final showJoinButton = item.joinNow;
    final subjectIcon = _subjectBadge(item.subjectName);

    return Material(
      color: scheme.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _joinClass(item),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
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
                  // Subject Icon
                  Container(
                    width: 50,
                    height: 50,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.accentOrange, Color(0xFFFFD700)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        subjectIcon,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Class Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: scheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          topic,
                          style: TextStyle(
                            fontSize: 14,
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          duration,
                          style: TextStyle(
                            fontSize: 14,
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      dateTime,
                      style: TextStyle(
                        fontSize: 12,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.open_in_new_rounded,
                    size: 18,
                    color: showJoinButton
                        ? AppColors.accentOrange
                        : scheme.onSurfaceVariant,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month - 1];
  }
}
