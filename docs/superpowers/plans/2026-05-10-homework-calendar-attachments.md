# Homework Calendar & Attachment Viewer Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make the week calendar strip swipeable by week, and replace external attachment links in homework cards with in-app popup viewers (image, PDF, video, audio).

**Architecture:** `WeekCalendarStrip` gains optional `onPrevWeek`/`onNextWeek` swipe callbacks (backward-compatible); a new `attachment_viewer_dialog.dart` widget provides a single `showAttachmentDialog()` entry-point that dispatches to type-specific fullscreen dialogs; `_HomeworkCard` replaces the "open attachment" text button and adds PDF/video/audio icon buttons that call `showAttachmentDialog()`.

**Tech Stack:** Flutter/Dart, `webview_flutter ^4.10.0` (PDF + video in-app), `audioplayers ^6.1.0` (audio playback), existing `InteractiveViewer` for images.

---

## Files

| Action | Path | Responsibility |
|--------|------|----------------|
| Modify | `pubspec.yaml` | Add webview_flutter, audioplayers |
| Create | `lib/widgets/attachment_viewer_dialog.dart` | Image/PDF/video/audio in-app popup dialogs |
| Modify | `lib/widgets/week_calendar_strip.dart` | Add optional swipe-to-change-week gesture |
| Modify | `lib/views/timetable/timetable_screen.dart` | Wire `onPrevWeek`/`onNextWeek` |
| Modify | `lib/views/homework/homework_screen.dart` | Card icons, image tap, in-app popup calls, week swipe |

---

## Task 1: Add packages

**Files:**
- Modify: `pubspec.yaml`

- [ ] **Step 1: Add dependencies**

In `pubspec.yaml`, under `dependencies:`, add these two lines after `url_launcher: ^6.3.2`:

```yaml
  webview_flutter: ^4.10.0
  audioplayers: ^6.1.0
```

- [ ] **Step 2: Install packages**

```bash
flutter pub get
```

Expected: resolves without errors, `.dart_tool/package_config.json` updated.

- [ ] **Step 3: Verify import resolution**

```bash
flutter pub deps | grep -E "webview_flutter|audioplayers"
```

Expected output contains both package names.

- [ ] **Step 4: Commit**

```bash
git add pubspec.yaml pubspec.lock
git commit -m "chore: add webview_flutter and audioplayers packages"
```

---

## Task 2: Create attachment viewer dialog

**Files:**
- Create: `lib/widgets/attachment_viewer_dialog.dart`

- [ ] **Step 1: Create the file with this exact content**

```dart
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../constants/app_colors.dart';

enum AttachmentType { image, pdf, video, audio }

/// Opens an in-app popup for the given attachment type and URL.
void showAttachmentDialog(
  BuildContext context,
  AttachmentType type,
  String url,
) {
  showDialog<void>(
    context: context,
    barrierColor: Colors.black87,
    builder: (_) {
      switch (type) {
        case AttachmentType.image:
          return _ImageDialog(url: url);
        case AttachmentType.pdf:
          return _WebViewDialog(
            title: 'PDF',
            url:
                'https://docs.google.com/gview?embedded=true&url=${Uri.encodeComponent(url)}',
          );
        case AttachmentType.video:
          return _WebViewDialog(title: 'Video', url: _toEmbedUrl(url));
        case AttachmentType.audio:
          return _AudioDialog(url: url);
      }
    },
  );
}

String _toEmbedUrl(String rawUrl) {
  final uri = Uri.tryParse(rawUrl);
  if (uri == null) return rawUrl;
  if (uri.host.contains('youtube.com') || uri.host.contains('youtu.be')) {
    String? id;
    if (uri.host.contains('youtu.be')) {
      id = uri.pathSegments.isNotEmpty ? uri.pathSegments.first : null;
    } else {
      id = uri.queryParameters['v'];
    }
    if (id != null && id.isNotEmpty) {
      return 'https://www.youtube.com/embed/$id?autoplay=1';
    }
  }
  return rawUrl;
}

// ---------------------------------------------------------------------------
// Image
// ---------------------------------------------------------------------------

class _ImageDialog extends StatelessWidget {
  const _ImageDialog({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      backgroundColor: Colors.black,
      child: Stack(
        fit: StackFit.expand,
        children: [
          InteractiveViewer(
            child: Center(
              child: Image.network(
                url,
                fit: BoxFit.contain,
                loadingBuilder: (_, child, event) {
                  if (event == null) return child;
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  );
                },
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.broken_image_outlined,
                  color: Colors.white54,
                  size: 64,
                ),
              ),
            ),
          ),
          Positioned(
            top: 40,
            right: 12,
            child: SafeArea(
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 28),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// PDF / Video (WebView)
// ---------------------------------------------------------------------------

class _WebViewDialog extends StatefulWidget {
  const _WebViewDialog({required this.title, required this.url});

  final String title;
  final String url;

  @override
  State<_WebViewDialog> createState() => _WebViewDialogState();
}

class _WebViewDialogState extends State<_WebViewDialog> {
  late final WebViewController _controller;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) {
            if (mounted) setState(() => _loading = false);
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
          backgroundColor: AppColors.accentOrange,
          foregroundColor: Colors.white,
        ),
        body: Stack(
          children: [
            WebViewWidget(controller: _controller),
            if (_loading)
              const Center(
                child: CircularProgressIndicator(color: AppColors.accentOrange),
              ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Audio
// ---------------------------------------------------------------------------

class _AudioDialog extends StatefulWidget {
  const _AudioDialog({required this.url});

  final String url;

  @override
  State<_AudioDialog> createState() => _AudioDialogState();
}

class _AudioDialogState extends State<_AudioDialog> {
  late final AudioPlayer _player;
  bool _playing = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _player.onPlayerStateChanged.listen((state) {
      if (mounted) setState(() => _playing = state == PlayerState.playing);
    });
    _player.onPositionChanged.listen((pos) {
      if (mounted) setState(() => _position = pos);
    });
    _player.onDurationChanged.listen((dur) {
      if (mounted) setState(() => _duration = dur);
    });
    _player.onPlayerComplete.listen((_) {
      if (mounted) setState(() => _playing = false);
    });
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _togglePlay() async {
    if (_playing) {
      await _player.pause();
    } else {
      if (_duration > Duration.zero && _position >= _duration) {
        await _player.seek(Duration.zero);
      }
      await _player.play(UrlSource(widget.url));
    }
  }

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final maxMs = _duration.inMilliseconds.toDouble();
    final posMs = _position.inMilliseconds
        .toDouble()
        .clamp(0.0, maxMs > 0 ? maxMs : 1.0);

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Audio', textAlign: TextAlign.center),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.audio_file_outlined,
            size: 56,
            color: AppColors.accentOrange,
          ),
          const SizedBox(height: 16),
          Slider(
            value: posMs,
            max: maxMs > 0 ? maxMs : 1.0,
            activeColor: AppColors.accentOrange,
            onChanged: maxMs > 0
                ? (v) => _player.seek(Duration(milliseconds: v.round()))
                : null,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_fmt(_position),
                    style: const TextStyle(fontSize: 12)),
                Text(_fmt(_duration),
                    style: const TextStyle(fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(height: 8),
          IconButton(
            iconSize: 56,
            icon: Icon(
              _playing
                  ? Icons.pause_circle_filled
                  : Icons.play_circle_filled,
            ),
            color: AppColors.accentOrange,
            onPressed: _togglePlay,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
```

- [ ] **Step 2: Verify no analysis errors**

```bash
flutter analyze lib/widgets/attachment_viewer_dialog.dart
```

Expected: no errors (warnings about `url_launcher` removal are OK if any).

- [ ] **Step 3: Commit**

```bash
git add lib/widgets/attachment_viewer_dialog.dart
git commit -m "feat: add in-app attachment viewer (image, PDF, video, audio)"
```

---

## Task 3: Make WeekCalendarStrip swipeable by week

**Files:**
- Modify: `lib/widgets/week_calendar_strip.dart`

- [ ] **Step 1: Replace the entire file content**

Replace `lib/widgets/week_calendar_strip.dart` with:

```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../constants/app_colors.dart';

/// Sunday = first column (matches [DateTime.weekday]: Sun 7 % 7 = 0).
DateTime _sundayStartOfWeek(DateTime d) {
  return DateTime(d.year, d.month, d.day)
      .subtract(Duration(days: d.weekday % 7));
}

/// Week row + month header matching the timetable screen calendar UX.
/// Optionally supports swipe-left (next week) and swipe-right (prev week)
/// by passing [onPrevWeek] and [onNextWeek].
class WeekCalendarStrip extends StatelessWidget {
  const WeekCalendarStrip({
    super.key,
    required this.focusedDate,
    required this.selectedDate,
    required this.monthTitle,
    required this.onDayPicked,
    required this.onPrevMonth,
    required this.onNextMonth,
    this.onPrevWeek,
    this.onNextWeek,
  });

  /// First day of the month whose label is shown; used to grey out days outside that month.
  final DateTime focusedDate;
  final DateTime selectedDate;
  final String monthTitle;
  final ValueChanged<DateTime> onDayPicked;
  final VoidCallback onPrevMonth;
  final VoidCallback onNextMonth;

  /// Called when the user swipes right across the week row (go back one week).
  final VoidCallback? onPrevWeek;

  /// Called when the user swipes left across the week row (go forward one week).
  final VoidCallback? onNextWeek;

  @override
  Widget build(BuildContext context) {
    final short = [
      'weekday_sun'.tr,
      'weekday_mon'.tr,
      'weekday_tue'.tr,
      'weekday_wed'.tr,
      'weekday_thu'.tr,
      'weekday_fri'.tr,
      'weekday_sat'.tr,
    ];
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: onPrevMonth,
              icon: Icon(
                Icons.chevron_left,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            Text(
              monthTitle,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.accentOrange,
              ),
            ),
            IconButton(
              onPressed: onNextMonth,
              icon: Icon(
                Icons.chevron_right,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            WeekdayLabel('weekday_short_sun'.tr),
            WeekdayLabel('weekday_short_mon'.tr),
            WeekdayLabel('weekday_short_tue'.tr),
            WeekdayLabel('weekday_short_wed'.tr),
            WeekdayLabel('weekday_short_thu'.tr),
            WeekdayLabel('weekday_short_fri'.tr),
            WeekdayLabel('weekday_short_sat'.tr),
          ],
        ),
        const SizedBox(height: 16),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onHorizontalDragEnd: (details) {
            final v = details.primaryVelocity;
            if (v == null) return;
            if (v < -300) {
              onNextWeek?.call();
            } else if (v > 300) {
              onPrevWeek?.call();
            }
          },
          child: Row(
            children: List.generate(7, (i) {
              final weekStart = _sundayStartOfWeek(selectedDate);
              final d = weekStart.add(Duration(days: i));
              final inMonth = d.month == focusedDate.month;
              final isSel = selectedDate.year == d.year &&
                  selectedDate.month == d.month &&
                  selectedDate.day == d.day;
              final shortDow = short[d.weekday % 7];
              return Expanded(
                child: WeekDayCell(
                  day: d.day,
                  shortDow: shortDow,
                  selected: isSel,
                  muted: !inMonth,
                  onTap: () => onDayPicked(d),
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          height: 2,
          width: 40,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.outlineVariant,
            borderRadius: BorderRadius.circular(1),
          ),
        ),
      ],
    );
  }
}

class WeekdayLabel extends StatelessWidget {
  const WeekdayLabel(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Expanded(
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            color: scheme.onSurface,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class WeekDayCell extends StatelessWidget {
  const WeekDayCell({
    super.key,
    required this.day,
    required this.shortDow,
    required this.selected,
    required this.muted,
    required this.onTap,
  });

  final int day;
  final String shortDow;
  final bool selected;
  final bool muted;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Center(
          child: selected
              ? Container(
                  width: 60,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFFFFA44F),
                        AppColors.accentOrange,
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          shortDow.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '$day',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : Text(
                  '$day',
                  style: TextStyle(
                    color: muted
                        ? scheme.onSurfaceVariant.withValues(alpha: 0.45)
                        : scheme.onSurface,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ),
    );
  }
}

String localizedMonthName(int month) {
  final months = [
    'month_january'.tr,
    'month_february'.tr,
    'month_march'.tr,
    'month_april'.tr,
    'month_may'.tr,
    'month_june'.tr,
    'month_july'.tr,
    'month_august'.tr,
    'month_september'.tr,
    'month_october'.tr,
    'month_november'.tr,
    'month_december'.tr,
  ];
  return months[month - 1];
}
```

- [ ] **Step 2: Verify no analysis errors**

```bash
flutter analyze lib/widgets/week_calendar_strip.dart
```

Expected: no errors.

- [ ] **Step 3: Commit**

```bash
git add lib/widgets/week_calendar_strip.dart
git commit -m "feat: add swipe-to-change-week to WeekCalendarStrip"
```

---

## Task 4: Wire week swipe in timetable screen

**Files:**
- Modify: `lib/views/timetable/timetable_screen.dart:104-110` (add two new methods)
- Modify: `lib/views/timetable/timetable_screen.dart:154-181` (pass new callbacks)

- [ ] **Step 1: Add `_onPrevWeek` and `_onNextWeek` after the existing `_onDayPicked` method (around line 110)**

After `_onDayPicked` (which ends around line 110), add:

```dart
  void _onPrevWeek() {
    setState(() {
      _selectedDate = _selectedDate.subtract(const Duration(days: 7));
      _focusedDate = DateTime(_selectedDate.year, _selectedDate.month, 1);
    });
    _fetchTimetable();
  }

  void _onNextWeek() {
    setState(() {
      _selectedDate = _selectedDate.add(const Duration(days: 7));
      _focusedDate = DateTime(_selectedDate.year, _selectedDate.month, 1);
    });
    _fetchTimetable();
  }
```

- [ ] **Step 2: Pass the new callbacks to `WeekCalendarStrip` (around line 154)**

In the `WeekCalendarStrip(...)` call, add after `onNextMonth: () { ... },`:

```dart
                      onPrevWeek: _onPrevWeek,
                      onNextWeek: _onNextWeek,
```

- [ ] **Step 3: Verify no analysis errors**

```bash
flutter analyze lib/views/timetable/timetable_screen.dart
```

Expected: no errors.

- [ ] **Step 4: Commit**

```bash
git add lib/views/timetable/timetable_screen.dart
git commit -m "feat: wire week swipe navigation in timetable screen"
```

---

## Task 5: Update homework screen — week swipe, card icons, in-app popups

**Files:**
- Modify: `lib/views/homework/homework_screen.dart`

This task rewrites three sections of the file:
1. New week-swipe handlers in `_HomeworkScreenState`
2. Pass week-swipe + new `onOpenMedia` callback to `_HomeworkCard`
3. Rewrite `_HomeworkCard` to show attachment icons and use in-app image popup

- [ ] **Step 1: Add import at the top of the file**

After the existing imports, add:

```dart
import '../../widgets/attachment_viewer_dialog.dart';
```

- [ ] **Step 2: Add `_onPrevWeek` and `_onNextWeek` after `_onDayPicked` (around line 126)**

After `_onDayPicked` method, add:

```dart
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
```

- [ ] **Step 3: Pass `onPrevWeek`/`onNextWeek` to `WeekCalendarStrip`**

In the `WeekCalendarStrip(...)` call (around line 287), add after `onNextMonth: () { ... },`:

```dart
                      onPrevWeek: _onPrevWeek,
                      onNextWeek: _onNextWeek,
```

- [ ] **Step 4: Update `_showHomeworkDetail` to use in-app popups**

In `_showHomeworkDetail`, find the `Wrap` with the three `OutlinedButton.icon` widgets (around line 225–250) and replace the entire `Wrap(...)` block with:

```dart
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (item.fileImage != null &&
                      item.fileImage!.trim().isNotEmpty)
                    OutlinedButton.icon(
                      onPressed: () => showAttachmentDialog(
                        context,
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
                        context,
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
                        context,
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
                        context,
                        AttachmentType.audio,
                        item.audioImage!,
                      ),
                      icon:
                          const Icon(Icons.music_note_outlined, size: 18),
                      label: Text('homework_audio'.tr),
                    ),
                ],
              ),
```

- [ ] **Step 5: Update `_HomeworkCard` constructor**

Replace the `_HomeworkCard` class signature from:

```dart
class _HomeworkCard extends StatelessWidget {
  final HomeworkAssignment item;
  final VoidCallback onViewMore;
  final void Function(String?) onOpenAttachment;
  final VoidCallback? onSubmitHomework;

  const _HomeworkCard({
    required this.item,
    required this.onViewMore,
    required this.onOpenAttachment,
    this.onSubmitHomework,
  });
```

To:

```dart
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
```

- [ ] **Step 6: Update the card footer row (date label + icons + view more)**

Replace the existing bottom `Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, ...)` block (the one containing the date label and "View More" text) with:

```dart
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
                    if (item.pdfImage != null ||
                        item.video != null ||
                        item.audioImage != null)
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
```

- [ ] **Step 7: Replace image section — make it tappable and remove external TextButton**

Replace the existing image section (the block starting `if (item.fileImage != null && item.fileImage!.trim().isNotEmpty) ...[`) with:

```dart
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
```

- [ ] **Step 8: Update the `_HomeworkCard` call site in `build()` (around line 372)**

Replace:

```dart
                        ..._items.map((item) => _HomeworkCard(
                              item: item,
                              onViewMore: () =>
                                  _showHomeworkDetail(item),
                              onOpenAttachment: _openUrl,
                              onSubmitHomework: item.showUploadButton &&
                                      !item.isSubmitted &&
                                      !item.studentSubmitted &&
                                      item.assignmentStudentId > 0
                                  ? () => _openSubmitHomework(item)
                                  : null,
                            )),
```

With:

```dart
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
```

- [ ] **Step 9: Remove now-unused `url_launcher` import and `_openUrl` method**

Remove this import from the top:
```dart
import 'package:url_launcher/url_launcher.dart';
```

Remove the `_openUrl` method (lines 128–137).

- [ ] **Step 10: Verify no analysis errors**

```bash
flutter analyze lib/views/homework/homework_screen.dart
```

Expected: no errors. If `url_launcher` is still used elsewhere in the codebase keep the import.

- [ ] **Step 11: Run full analysis**

```bash
flutter analyze
```

Expected: no errors.

- [ ] **Step 12: Commit**

```bash
git add lib/views/homework/homework_screen.dart
git commit -m "feat: homework card attachment icons and in-app media popups"
```

---

## Self-Review Checklist

| Requirement | Task |
|-------------|------|
| Calendar swipe by week (homework) | Task 3 + Task 5 steps 2–3 |
| Calendar swipe by week (timetable) | Task 3 + Task 4 |
| Month navigation still works | Task 3 (unchanged `onPrevMonth`/`onNextMonth`) |
| PDF icon on card | Task 5 step 6 |
| Video icon on card | Task 5 step 6 |
| Audio icon on card | Task 5 step 6 |
| Image tap → in-app popup | Task 5 step 7 |
| PDF icon tap → in-app popup | Task 2 + Task 5 step 8 |
| Video icon tap → in-app popup (YouTube embed) | Task 2 `_toEmbedUrl` |
| Audio icon tap → in-app popup with player | Task 2 `_AudioDialog` |
| Detail sheet buttons → in-app popup | Task 5 step 4 |
| Submit homework unaffected | `_SubmitHomeworkSheet` untouched |
| No external browser navigation | `url_launcher` removed from card |
| "View More" text preserved | Task 5 step 6 |
