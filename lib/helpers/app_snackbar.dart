import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../services/navigation_service.dart';

enum AlertType { success, error, warning, info, internalInfo }

class AppSnackbar {
  static const Color _successColor = Colors.green;
  static final Color _errorColor = Colors.red;
  static final Color _warningColor = Colors.yellow.shade700;
  static final Color _infoColor = Colors.blue.shade900;
  static const Color _internalInfo = Color(0xff949494);

  /// Single floating overlay snackbar — matches top placement with [Get.snackbar].
  static OverlayEntry? _materialOverlay;

  static void _dismissMaterialOverlay() {
    _materialOverlay?.remove();
    _materialOverlay = null;
  }

  static Widget _materialSnackContent({
    required String title,
    required String message,
    required Color textColor,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: textColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          message,
          style: TextStyle(fontSize: 14, color: textColor),
        ),
      ],
    );
  }

  /// Material fallback when GetX overlay is unavailable — drawn at the **top**
  /// (standard [SnackBar] is always bottom-anchored).
  static void _showMaterialSnackBar({
    required String title,
    required String message,
    required Color backgroundColor,
    required Color textColor,
    required Duration duration,
    required bool dismissible,
  }) {
    final ctx = NavigationService.navigatorKey.currentContext;
    if (ctx == null) {
      debugPrint('Material snackbar skipped: no navigator context ($title)');
      return;
    }

    final overlay = Overlay.maybeOf(ctx, rootOverlay: true);
    if (overlay == null) {
      debugPrint('Material snackbar skipped: no Overlay ($title)');
      return;
    }

    _dismissMaterialOverlay();

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (overlayContext) {
        final topInset = MediaQuery.paddingOf(overlayContext).top;
        final body = Material(
          elevation: 6,
          borderRadius: BorderRadius.circular(12),
          color: backgroundColor,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: _materialSnackContent(
              title: title,
              message: message,
              textColor: textColor,
            ),
          ),
        );

        final shell = dismissible
            ? Dismissible(
                key: const ValueKey<String>('app_snackbar_overlay_dismissible'),
                direction: DismissDirection.horizontal,
                onDismissed: (_) {
                  if (_materialOverlay == entry) {
                    _dismissMaterialOverlay();
                  }
                },
                child: body,
              )
            : body;

        return Stack(
          children: [
            Positioned(
              top: topInset + 8,
              left: 16,
              right: 16,
              child: shell,
            ),
          ],
        );
      },
    );

    _materialOverlay = entry;
    overlay.insert(entry);

    Future<void>.delayed(duration, () {
      if (_materialOverlay == entry) {
        _dismissMaterialOverlay();
      }
    });
  }

  static showSnackbar(
    String title,
    String message,
    AlertType altType, {
    bool dismissible = true,
    double overlayBlur = 0,
    Duration duration = const Duration(seconds: 3),
    Function? onButtonPressed,
    String buttonTitle = "OK",
  }) {
    Color backgroundColor;
    Color textColor = Colors.white;

    switch (altType) {
      case AlertType.success:
        backgroundColor = _successColor;
        break;
      case AlertType.error:
        backgroundColor = _errorColor;
        break;
      case AlertType.warning:
        backgroundColor = _warningColor;
        textColor = Colors.black;
        break;
      case AlertType.info:
        backgroundColor = _infoColor;
        break;

      case AlertType.internalInfo:
        backgroundColor = _internalInfo;
        break;
    }

    void showMaterialFallback() {
      _showMaterialSnackBar(
        title: title,
        message: message,
        backgroundColor: backgroundColor,
        textColor: textColor,
        duration: duration,
        dismissible: dismissible,
      );
    }

    void showGetSnackbar() {
      _dismissMaterialOverlay();
      try {
        final overlayCtx = Get.overlayContext;
        // ShowcaseView / other overlays can break GetX overlay lookup — fall back to Material.
        if (overlayCtx != null &&
            Overlay.maybeOf(overlayCtx, rootOverlay: true) == null) {
          debugPrint(
            'Get.snackbar overlay unavailable ($title) — using top overlay fallback',
          );
          showMaterialFallback();
          return;
        }
        Get.snackbar(
          title,
          message,
          colorText: textColor,
          isDismissible: dismissible,
          backgroundColor: backgroundColor,
          snackPosition: SnackPosition.TOP,
          duration: duration,
          overlayBlur: overlayBlur,
          onTap: (barObject) {},
          titleText: Text(
            title,
            style: TextStyle(fontSize: 16, color: textColor),
          ),
          messageText: Text(
            message,
            style: TextStyle(fontSize: 14, color: textColor),
          ),
          mainButton: onButtonPressed != null
              ? TextButton(
                  onPressed: () {},
                  child: Text(
                    buttonTitle,
                    style: TextStyle(fontSize: 18, color: textColor),
                  ),
                )
              : null,
        );
      } catch (e, st) {
        debugPrint('Get.snackbar failed: $e\n$st');
        showMaterialFallback();
      }
    }

    if (Get.overlayContext != null) {
      showGetSnackbar();
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.overlayContext != null) {
        showGetSnackbar();
      } else {
        debugPrint(
          'Snackbar: post-frame fallback (no Get overlay): $title',
        );
        showMaterialFallback();
      }
    });
  }
}
