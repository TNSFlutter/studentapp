import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../helpers/network/api_error_helper.dart';
import '../helpers/network/endpoints.dart';
import '../helpers/network/network_manager.dart';

/// `POST feedback` — multipart form (matches Postman parents/feedback).
class FeedbackService {
  FeedbackService._();

  static const int maxAttachmentBytes = 5 * 1024 * 1024;

  static Options _appOptions() {
    final appPlatform = switch (defaultTargetPlatform) {
      TargetPlatform.android => 'android',
      TargetPlatform.iOS => 'ios',
      TargetPlatform.macOS => 'macos',
      TargetPlatform.windows => 'windows',
      TargetPlatform.linux => 'linux',
      TargetPlatform.fuchsia => 'fuchsia',
    };
    return Options(
      headers: {
        'X-App-Platform': appPlatform,
        'X-App-Version': '1.0.0',
      },
    );
  }

  static String _basename(String path) {
    final normalized = path.replaceAll(r'\', '/');
    final i = normalized.lastIndexOf('/');
    return i < 0 ? normalized : normalized.substring(i + 1);
  }

  /// Returns `null` on success, user-facing error string otherwise.
  ///
  /// Provide either [attachmentPath] or both [attachmentBytes] and
  /// [attachmentFileName] (e.g. web picker).
  static Future<String?> submit({
    required int rating,
    required String feedbackType,
    required String subject,
    required String description,
    String? attachmentPath,
    List<int>? attachmentBytes,
    String? attachmentFileName,
  }) async {
    if (rating < 1 || rating > 5) {
      return 'Please choose a rating from 1 to 5 stars.';
    }
    final sub = subject.trim();
    final desc = description.trim();
    if (sub.isEmpty) {
      return 'Please enter a subject.';
    }
    if (desc.isEmpty) {
      return 'Please enter a description.';
    }

    try {
      final form = FormData();
      form.fields.add(MapEntry('rating', '$rating'));
      form.fields.add(MapEntry('feedback_type', feedbackType.trim()));
      form.fields.add(MapEntry('subject', sub));
      form.fields.add(MapEntry('description', desc));

      final hasPath =
          attachmentPath != null && attachmentPath.trim().isNotEmpty;
      final hasBytes = attachmentBytes != null &&
          attachmentBytes.isNotEmpty &&
          attachmentFileName != null &&
          attachmentFileName.trim().isNotEmpty;

      if (hasPath) {
        final p = attachmentPath.trim();
        final f = File(p);
        if (!await f.exists()) {
          return 'Attachment file not found.';
        }
        final len = await f.length();
        if (len > maxAttachmentBytes) {
          return 'Attachment must be 5 MB or smaller.';
        }
        final bytes = await f.readAsBytes();
        if (bytes.isEmpty) {
          return 'The selected attachment is empty.';
        }
        final name = _basename(p);
        form.files.add(
          MapEntry(
            'attachment',
            MultipartFile.fromBytes(
              bytes,
              filename: name.isNotEmpty ? name : 'attachment.jpg',
            ),
          ),
        );
      } else if (hasBytes) {
        if (attachmentBytes.length > maxAttachmentBytes) {
          return 'Attachment must be 5 MB or smaller.';
        }
        final name = attachmentFileName.trim();
        form.files.add(
          MapEntry(
            'attachment',
            MultipartFile.fromBytes(
              attachmentBytes,
              filename: name.isNotEmpty ? name : 'attachment.jpg',
            ),
          ),
        );
      }

      final dio = NetworkManager.instance.getDio();
      final res = await dio.post(
        Endpoints.feedback,
        data: form,
        options: _appOptions(),
      );

      if (res.statusCode != null &&
          res.statusCode! >= 200 &&
          res.statusCode! < 300) {
        final data = res.data;
        if (data is Map) {
          final map = Map<String, dynamic>.from(data);
          final ok = map['success'] == true;
          if (ok) {
            return null;
          }
          return map['message']?.toString() ?? 'Could not send feedback.';
        }
        return null;
      }
      return 'Could not send feedback.';
    } on DioException catch (e) {
      return ApiErrorHelper.dioOrFallback(e);
    } catch (e) {
      return e.toString();
    }
  }
}
