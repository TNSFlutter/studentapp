import 'dart:async';

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
          onWebResourceError: (_) {
            if (mounted) setState(() => _loading = false);
          },
        ),
      );
    final uri = Uri.tryParse(widget.url);
    if (uri != null) {
      _controller.loadRequest(uri);
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _loading = false);
      });
    }
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
  final List<StreamSubscription<dynamic>> _subs = [];

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _subs.add(_player.onPlayerStateChanged.listen((state) {
      if (mounted) setState(() => _playing = state == PlayerState.playing);
    }));
    _subs.add(_player.onPositionChanged.listen((pos) {
      if (mounted) setState(() => _position = pos);
    }));
    _subs.add(_player.onDurationChanged.listen((dur) {
      if (mounted) setState(() => _duration = dur);
    }));
    _subs.add(_player.onPlayerComplete.listen((_) {
      if (mounted) setState(() => _playing = false);
    }));
  }

  @override
  void dispose() {
    for (final s in _subs) {
      s.cancel();
    }
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
