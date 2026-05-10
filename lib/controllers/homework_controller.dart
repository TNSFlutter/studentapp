import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart' hide FormData, MultipartFile, Response;

import '../helpers/network/api_error_helper.dart';
import '../helpers/network/endpoints.dart';
import '../helpers/network/network_manager.dart';
import '../models/homework_models.dart';

class HomeworkController extends GetxController {
  HomeworkController({NetworkManager? networkManager})
      : _networkManager = networkManager ?? NetworkManager.instance;

  final NetworkManager _networkManager;

  static const int _maxFileBytes = 15 * 1024 * 1024;

  Options _submitOptions() {
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

  /// `POST assignment/submit` — multipart. Returns `null` on success.
  Future<String?> submitAssignment({
    required int assignmentStudentId,
    required String description,
    String? fileImagePath,
    String? pdfFilePath,
    String? audioFilePath,
    List<int>? fileImageBytes,
    String? fileImageName,
    List<int>? pdfFileBytes,
    String? pdfFileName,
    List<int>? audioFileBytes,
    String? audioFileName,
  }) async {
    if (assignmentStudentId <= 0) {
      return 'Invalid assignment.';
    }
    final desc = description.trim();
    if (desc.isEmpty) {
      return 'Please enter a description.';
    }

    try {
      final form = FormData();
      form.fields.add(MapEntry('assignment_student_id', '$assignmentStudentId'));
      form.fields.add(MapEntry('description', desc));

      String? err;
      err = await _appendMultipartFile(
        form,
        fieldName: 'file_image',
        path: fileImagePath,
        bytes: fileImageBytes,
        fileName: fileImageName,
      );
      if (err != null) return err;

      err = await _appendMultipartFile(
        form,
        fieldName: 'pdf_file',
        path: pdfFilePath,
        bytes: pdfFileBytes,
        fileName: pdfFileName,
      );
      if (err != null) return err;

      err = await _appendMultipartFile(
        form,
        fieldName: 'audio_file',
        path: audioFilePath,
        bytes: audioFileBytes,
        fileName: audioFileName,
      );
      if (err != null) return err;

      final dio = _networkManager.getDio();
      final res = await dio.post(
        Endpoints.assignmentSubmit,
        data: form,
        options: _submitOptions(),
      );

      if (res.statusCode != null &&
          res.statusCode! >= 200 &&
          res.statusCode! < 300) {
        final data = res.data;
        if (data is Map) {
          final map = Map<String, dynamic>.from(data);
          if (map['success'] == true) {
            return null;
          }
          return map['message']?.toString() ?? 'Submission failed.';
        }
        return null;
      }
      return 'Submission failed.';
    } on DioException catch (e) {
      return ApiErrorHelper.dioOrFallback(e);
    } catch (e) {
      return e.toString();
    }
  }

  /// Returns an error message, or `null` if nothing to attach or success.
  Future<String?> _appendMultipartFile(
    FormData form, {
    required String fieldName,
    String? path,
    List<int>? bytes,
    String? fileName,
  }) async {
    final p = path?.trim();
    if (p != null && p.isNotEmpty) {
      final f = File(p);
      if (!await f.exists()) {
        return 'File not found ($fieldName).';
      }
      final len = await f.length();
      if (len > _maxFileBytes) {
        return 'Each file must be ${_maxFileBytes ~/ (1024 * 1024)} MB or smaller.';
      }
      final data = await f.readAsBytes();
      if (data.isEmpty) {
        return 'The selected file is empty ($fieldName).';
      }
      final name = _basename(p);
      form.files.add(
        MapEntry(
          fieldName,
          MultipartFile.fromBytes(
            data,
            filename: name.isNotEmpty ? name : fieldName,
          ),
        ),
      );
      return null;
    }
    final b = bytes;
    final n = fileName?.trim();
    if (b != null && b.isNotEmpty && n != null && n.isNotEmpty) {
      if (b.length > _maxFileBytes) {
        return 'Each file must be ${_maxFileBytes ~/ (1024 * 1024)} MB or smaller.';
      }
      form.files.add(
        MapEntry(
          fieldName,
          MultipartFile.fromBytes(b, filename: n),
        ),
      );
    }
    return null;
  }

  Future<HomeworkListResponse> fetchHomework({
    required String yyyyMmDd,
    required int limit,
    String? cursor,
  }) async {
    try {
      final qp = <String, dynamic>{
        'limit': limit,
        if (cursor != null && cursor.trim().isNotEmpty) 'cursor': cursor,
      };

      final response = await _networkManager.getDio().get(
        Endpoints.homework(yyyyMmDd),
        queryParameters: qp,
      );

      if (response.statusCode == 200 && response.data != null) {
        final body = response.data;
        if (body is Map) {
          return HomeworkListResponse.fromJson(
            Map<String, dynamic>.from(body),
          );
        }
      }

      return HomeworkListResponse(
        success: false,
        message: 'Failed to load homework.',
        meta: null,
        data: <HomeworkAssignment>[],
        pagination: HomeworkPagination.empty(),
      );
    } on DioException catch (e) {
      return HomeworkListResponse(
        success: false,
        message: ApiErrorHelper.dioOrFallback(
          e,
          'Something went wrong. Please try again.',
        ),
        meta: null,
        data: <HomeworkAssignment>[],
        pagination: HomeworkPagination.empty(),
      );
    } catch (_) {
      return HomeworkListResponse(
        success: false,
        message: 'Something went wrong. Please try again.',
        meta: null,
        data: <HomeworkAssignment>[],
        pagination: HomeworkPagination.empty(),
      );
    }
  }
}
