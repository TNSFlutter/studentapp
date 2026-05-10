import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart' hide FormData, MultipartFile, Response;

import '../helpers/network/api_error_helper.dart';
import '../helpers/network/endpoints.dart';
import '../helpers/network/network_manager.dart';
import '../models/student_profile_models.dart';
import '../models/student_profile_update_models.dart';

class StudentProfileController extends GetxController {
  StudentProfileController({NetworkManager? networkManager})
    : _networkManager = networkManager ?? NetworkManager.instance;

  final NetworkManager _networkManager;

  final Rxn<StudentProfilePayload> profile = Rxn();
  final Rxn<StudentProfileMetaPayload> meta = Rxn();
  final RxBool isLoading = false.obs;
  final RxString loadError = ''.obs;

  Options _getOptions() {
    final appPlatform = switch (defaultTargetPlatform) {
      TargetPlatform.android => 'android',
      TargetPlatform.iOS => 'ios',
      TargetPlatform.macOS => 'macos',
      TargetPlatform.windows => 'windows',
      TargetPlatform.linux => 'linux',
      TargetPlatform.fuchsia => 'fuchsia',
    };
    return Options(
      headers: {'X-App-Platform': appPlatform, 'X-App-Version': '1.0.0'},
    );
  }

  void clearCache() {
    profile.value = null;
    meta.value = null;
    loadError.value = '';
  }

  /// `GET student/profile/meta` — at most one of [countryId] / [stateId] (not both).
  Future<StudentProfileMetaPayload?> _fetchMetaPayload(
    Dio dio,
    Options opts, {
    int? countryId,
    int? stateId,
  }) async {
    final qp = <String, dynamic>{};
    if (countryId != null && countryId > 0) {
      qp['country_id'] = countryId;
    } else if (stateId != null && stateId > 0) {
      qp['state_id'] = stateId;
    }
    final res = await dio.get(
      Endpoints.studentProfileMeta,
      options: opts,
      queryParameters: qp.isEmpty ? null : qp,
    );
    if (res.statusCode != 200 || res.data is! Map) return null;
    final parsed = StudentProfileMetaApiResponse.fromJson(
      Map<String, dynamic>.from(res.data as Map),
    );
    if (!parsed.success || parsed.data == null) return null;
    return parsed.data;
  }

  /// Loads meta lists for [countryId] / [stateId] (e.g. after user changes address).
  /// Merges `states` from the country-scoped call and `cities` from the state-scoped call.
  Future<void> refreshMetaForLocation({int? countryId, int? stateId}) async {
    try {
      final dio = _networkManager.getDio();
      final opts = _getOptions();
      final merged = await _mergeMetaForLocation(
        dio,
        opts,
        countryId: countryId ?? 0,
        stateId: stateId ?? 0,
      );
      if (merged != null) {
        meta.value = merged;
      }
    } on DioException catch (e) {
      loadError.value = ApiErrorHelper.dioOrFallback(e);
    } catch (e) {
      loadError.value = e.toString();
    }
  }

  Future<StudentProfileMetaPayload?> _mergeMetaForLocation(
    Dio dio,
    Options opts, {
    required int countryId,
    required int stateId,
  }) async {
    StudentProfileMetaPayload? metaPayload;
    if (countryId > 0) {
      metaPayload = await _fetchMetaPayload(dio, opts, countryId: countryId);
    }
    metaPayload ??= await _fetchMetaPayload(dio, opts);
    if (metaPayload == null) return null;

    if (stateId > 0) {
      final byState = await _fetchMetaPayload(dio, opts, stateId: stateId);
      if (byState != null && byState.cities.isNotEmpty) {
        metaPayload = metaPayload.copyWith(cities: byState.cities);
      }
    }
    return metaPayload;
  }

  /// Loads `GET student/profile` and cascaded `GET student/profile/meta` calls:
  /// `?country_id=` when the student has a country, then `?state_id=` to attach cities.
  Future<void> refreshProfile() async {
    isLoading.value = true;
    loadError.value = '';
    try {
      final dio = _networkManager.getDio();
      final opts = _getOptions();

      final pRes = await dio.get(Endpoints.studentProfile, options: opts);

      if (pRes.statusCode != 200 || pRes.data == null) {
        loadError.value = 'Failed to load profile (${pRes.statusCode}).';
        return;
      }
      if (pRes.data is! Map) {
        loadError.value = 'Invalid response from server.';
        return;
      }

      final pBody = Map<String, dynamic>.from(pRes.data as Map);
      final pParsed = StudentProfileApiResponse.fromJson(pBody);

      if (!pParsed.success || pParsed.data == null) {
        loadError.value = pParsed.message.isNotEmpty
            ? pParsed.message
            : 'Profile unavailable.';
        profile.value = null;
        meta.value = null;
        return;
      }

      profile.value = pParsed.data;
      final basic = pParsed.data!.basic;

      final merged = await _mergeMetaForLocation(
        dio,
        opts,
        countryId: basic.countryId,
        stateId: basic.stateId,
      );

      if (merged == null) {
        loadError.value = 'Could not load profile options.';
        meta.value = null;
      } else {
        meta.value = merged;
      }
    } on DioException catch (e) {
      loadError.value = ApiErrorHelper.dioOrFallback(e);
      profile.value = null;
      meta.value = null;
    } catch (e) {
      loadError.value = e.toString();
      profile.value = null;
      meta.value = null;
    } finally {
      isLoading.value = false;
    }
  }

  Options _jsonPutOptions() {
    final base = _getOptions();
    final h = Map<String, dynamic>.from(base.headers ?? {});
    h[Headers.contentTypeHeader] = Headers.jsonContentType;
    return Options(headers: h);
  }

  /// Returns `null` on success, otherwise an error message.
  String? _mutationMessage(Response<dynamic> res) {
    final code = res.statusCode ?? 0;
    if (code < 200 || code >= 300) {
      return 'Request failed ($code).';
    }
    final data = res.data;
    if (data is Map) {
      final m = Map<String, dynamic>.from(data);
      if (m['success'] == true) return null;
      final msg = m['message']?.toString();
      if (msg != null && msg.isNotEmpty) return msg;
      return 'Request failed.';
    }
    return null;
  }

  /// Blocks PUT/upload/delete when the school has disabled profile edits.
  String? _guardProfileEditable() {
    final p = profile.value;
    if (p == null) return 'Profile not loaded.';
    if (!p.isEditable) {
      return 'Profile editing is disabled by your school.';
    }
    return null;
  }

  Future<String?> updateBasic(ProfileBasicUpdate body) async {
    final blocked = _guardProfileEditable();
    if (blocked != null) return blocked;
    try {
      final dio = _networkManager.getDio();
      final res = await dio.put(
        Endpoints.studentProfileBasic,
        data: body.toJson(),
        options: _jsonPutOptions(),
      );
      return _mutationMessage(res);
    } on DioException catch (e) {
      return ApiErrorHelper.dioOrFallback(e);
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> updateAcademic(ProfileAcademicUpdate body) async {
    final blocked = _guardProfileEditable();
    if (blocked != null) return blocked;
    try {
      final dio = _networkManager.getDio();
      final res = await dio.put(
        Endpoints.studentProfileAcademic,
        data: body.toJson(),
        options: _jsonPutOptions(),
      );
      return _mutationMessage(res);
    } on DioException catch (e) {
      return ApiErrorHelper.dioOrFallback(e);
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> updateFather(ProfileParentUpdate body) async {
    final blocked = _guardProfileEditable();
    if (blocked != null) return blocked;
    try {
      final dio = _networkManager.getDio();
      final res = await dio.put(
        Endpoints.studentProfileFather,
        data: body.toJsonFather(),
        options: _jsonPutOptions(),
      );
      return _mutationMessage(res);
    } on DioException catch (e) {
      return ApiErrorHelper.dioOrFallback(e);
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> updateMother(ProfileParentUpdate body) async {
    final blocked = _guardProfileEditable();
    if (blocked != null) return blocked;
    try {
      final dio = _networkManager.getDio();
      final res = await dio.put(
        Endpoints.studentProfileMother,
        data: body.toJsonMother(),
        options: _jsonPutOptions(),
      );
      return _mutationMessage(res);
    } on DioException catch (e) {
      return ApiErrorHelper.dioOrFallback(e);
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> updateGuardian(ProfileGuardianUpdate body) async {
    final blocked = _guardProfileEditable();
    if (blocked != null) return blocked;
    try {
      final dio = _networkManager.getDio();
      final res = await dio.put(
        Endpoints.studentProfileGuardian,
        data: body.toJson(),
        options: _jsonPutOptions(),
      );
      return _mutationMessage(res);
    } on DioException catch (e) {
      return ApiErrorHelper.dioOrFallback(e);
    } catch (e) {
      return e.toString();
    }
  }

  /// Multipart `POST student/profile/photo`.
  ///
  /// Field rules (matches Postman collection):
  ///   - role      : always required (student | father | mother | guardian)
  ///   - file      : always required (multipart)
  ///   - student_id, class_student_id:
  ///       * mother   -> NOT sent (session is enough)
  ///       * student  -> required
  ///       * father   -> required
  ///       * guardian -> required
  ///
  /// IMPORTANT: A fresh `FormData` and a fresh `MultipartFile.fromBytes` is built
  /// for every call so chained uploads (student -> father -> guardian) cannot
  /// reuse a finalized stream — that reuse is what produces a misleading
  /// "file is required" from the server on the 2nd/3rd call.
  Future<String?> uploadProfilePhoto({
    required String role,
    String? filePath,
    List<int>? fileBytes,
    String? fileName,
  }) async {
    final blocked = _guardProfileEditable();
    if (blocked != null) return blocked;
    const allowed = {'student', 'father', 'mother', 'guardian'};
    final r = role.trim().toLowerCase();
    if (!allowed.contains(r)) {
      return 'Invalid photo role.';
    }

    // ---- 1. Read bytes ONCE up-front. Never reuse a MultipartFile instance.
    List<int>? bytes;
    String? sourceName;

    if (filePath != null && filePath.trim().isNotEmpty) {
      final p = filePath.trim();
      final f = File(p);
      if (!await f.exists()) return 'File not found.';
      bytes = await f.readAsBytes();
      sourceName = _basename(p);
    } else if (fileBytes != null && fileBytes.isNotEmpty) {
      bytes = List<int>.from(fileBytes); // defensive copy
      sourceName = (fileName ?? '').trim().isNotEmpty ? fileName!.trim() : null;
    }

    if (bytes == null || bytes.isEmpty) {
      return 'No file selected.';
    }
    if (sourceName == null || sourceName.isEmpty) {
      return 'File name is required.';
    }

    final filename = _photoUploadFilename(sourceName);
    final mediaType = MultipartFile.lookupMediaType(filename);

    // ---- 2. Validate that we have the IDs we need BEFORE hitting the network.
    final payload = profile.value;
    final sid = payload?.summary.studentId ?? 0;
    final csid = payload?.summary.classStudentId ?? 0;

    if (r != 'mother') {
      if (sid <= 0 || csid <= 0) {
        // This is the real cause of the "file is required" message you saw —
        // the server rejects the multipart parse when the expected context ids
        // are missing for father/student/guardian, then surfaces a generic
        // "file is required" error. Refuse early with a clear message.
        return 'Student context is missing. Please reload the profile and try again.';
      }
    }

    // ---- 3. Build a brand-new FormData per call.
    final form = FormData();
    form.fields.add(MapEntry('role', r));

    if (r != 'mother') {
      form.fields.add(MapEntry('student_id', '$sid'));
      form.fields.add(MapEntry('class_student_id', '$csid'));
    }

    // Build the MultipartFile LAST and add it LAST.
    form.files.add(
      MapEntry(
        'file',
        MultipartFile.fromBytes(
          bytes,
          filename: filename,
          contentType: mediaType,
        ),
      ),
    );

    try {
      final dio = _networkManager.getDio();
      final res = await dio.post(
        Endpoints.studentProfilePhoto,
        data: form,
        options:
            _getOptions(), // do NOT set Content-Type manually for multipart
      );
      return _mutationMessage(res);
    } on DioException catch (e) {
      return ApiErrorHelper.dioOrFallback(e);
    } catch (e) {
      return e.toString();
    }
  }

  /// Multipart: `doc_type_id` (text, empty when unset) then `file`, matching
  /// `POST student/profile/documents` (Postman form-data).
  Future<String?> uploadProfileDocument({
    String? filePath,
    List<int>? fileBytes,
    String? fileName,
    int? docTypeId,
  }) async {
    final blocked = _guardProfileEditable();
    if (blocked != null) return blocked;
    try {
      late final MultipartFile part;
      if (filePath != null && filePath.trim().isNotEmpty) {
        final fp = filePath.trim();
        final f = File(fp);
        if (!await f.exists()) {
          return 'File not found.';
        }
        final bytes = await f.readAsBytes();
        if (bytes.isEmpty) {
          return 'The selected file is empty.';
        }
        final filename = _documentUploadFilename(_basename(fp));
        final mediaType = MultipartFile.lookupMediaType(filename);
        part = MultipartFile.fromBytes(
          bytes,
          filename: filename,
          contentType: mediaType,
        );
      } else if (fileBytes != null &&
          fileBytes.isNotEmpty &&
          fileName != null &&
          fileName.trim().isNotEmpty) {
        final filename = _documentUploadFilename(fileName.trim());
        part = MultipartFile.fromBytes(
          fileBytes,
          filename: filename,
          contentType: MultipartFile.lookupMediaType(filename),
        );
      } else {
        return 'No file selected.';
      }

      final dio = _networkManager.getDio();
      final form = FormData();
      form.fields.add(
        MapEntry(
          'doc_type_id',
          docTypeId != null && docTypeId > 0 ? '$docTypeId' : '',
        ),
      );
      form.files.add(MapEntry('file', part));

      final res = await dio.post(
        Endpoints.studentProfileDocuments,
        data: form,
        options: _getOptions(),
      );
      return _mutationMessage(res);
    } on DioException catch (e) {
      return ApiErrorHelper.dioOrFallback(e);
    } catch (e) {
      return e.toString();
    }
  }

  static String _basename(String path) {
    final normalized = path.replaceAll(r'\', '/');
    final i = normalized.lastIndexOf('/');
    return i < 0 ? normalized : normalized.substring(i + 1);
  }

  /// Ensures a filename extension so Laravel `image` rules accept the upload.
  static String _photoUploadFilename(String raw) {
    var n = raw.trim();
    if (n.isEmpty) n = 'photo.jpg';
    final lower = n.toLowerCase();
    const ok = ['.jpg', '.jpeg', '.png', '.webp', '.heic'];
    if (!ok.any(lower.endsWith)) n = '$n.jpg';
    return n;
  }

  static String _documentUploadFilename(String raw) {
    var n = raw.trim();
    if (n.isEmpty) n = 'document.pdf';
    final lower = n.toLowerCase();
    const ok = ['.pdf', '.jpg', '.jpeg', '.png', '.webp'];
    if (!ok.any(lower.endsWith)) n = '$n.pdf';
    return n;
  }

  Future<String?> deleteProfileDocument(int documentId) async {
    if (documentId <= 0) return 'Invalid document.';
    final blocked = _guardProfileEditable();
    if (blocked != null) return blocked;
    try {
      final dio = _networkManager.getDio();
      final res = await dio.delete(
        Endpoints.studentProfileDocument(documentId),
        options: _getOptions(),
      );
      return _mutationMessage(res);
    } on DioException catch (e) {
      return ApiErrorHelper.dioOrFallback(e);
    } catch (e) {
      return e.toString();
    }
  }
}
