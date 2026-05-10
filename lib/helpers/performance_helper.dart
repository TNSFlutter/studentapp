import 'dart:async';

import 'package:flutter/foundation.dart';

/// Helper class to manage performance optimizations and background operations
class PerformanceHelper {
  static final PerformanceHelper _instance = PerformanceHelper._internal();
  factory PerformanceHelper() => _instance;
  PerformanceHelper._internal();

  static PerformanceHelper get instance => _instance;

  /// Execute heavy operations in background to avoid blocking main thread
  static Future<T> runInBackground<T>(Future<T> Function() operation) async {
    return await Future.microtask(operation);
  }

  /// Execute multiple operations in parallel
  static Future<List<T>> runParallel<T>(
    List<Future<T> Function()> operations,
  ) async {
    final futures = operations
        .map((operation) => Future.microtask(operation))
        .toList();
    return await Future.wait(futures);
  }

  /// Debounce function calls to prevent excessive execution
  static Timer? _debounceTimer;
  static void debounce(
    VoidCallback callback, {
    Duration duration = const Duration(milliseconds: 300),
  }) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(duration, callback);
  }

  /// Throttle function calls to limit execution frequency
  static DateTime? _lastThrottleTime;
  static bool throttle(
    VoidCallback callback, {
    Duration duration = const Duration(milliseconds: 100),
  }) {
    final now = DateTime.now();
    if (_lastThrottleTime == null ||
        now.difference(_lastThrottleTime!) >= duration) {
      _lastThrottleTime = now;
      callback();
      return true;
    }
    return false;
  }

  /// Cache data with expiration
  static final Map<String, _CacheEntry> _cache = {};

  static T? getCached<T>(String key) {
    final entry = _cache[key];
    if (entry != null && !entry.isExpired) {
      return entry.data as T;
    }
    _cache.remove(key);
    return null;
  }

  static void setCached<T>(String key, T data, {Duration? expiration}) {
    _cache[key] = _CacheEntry(
      data: data,
      expiration: expiration ?? const Duration(minutes: 5),
      createdAt: DateTime.now(),
    );
  }

  static void clearCache([String? key]) {
    if (key != null) {
      _cache.remove(key);
    } else {
      _cache.clear();
    }
  }

  /// Optimize list operations for large datasets
  static List<T> optimizeList<T>(List<T> list, {int? maxItems}) {
    if (maxItems != null && list.length > maxItems) {
      return list.take(maxItems).toList();
    }
    return list;
  }

  /// Batch operations for better performance
  static Future<List<T>> batchOperations<T>(
    List<T> items,
    Future<void> Function(T) operation, {
    int batchSize = 10,
  }) async {
    final results = <T>[];

    for (int i = 0; i < items.length; i += batchSize) {
      final batch = items.skip(i).take(batchSize);
      await Future.wait(batch.map(operation));
      results.addAll(batch);
    }

    return results;
  }
}

/// Cache entry with expiration
class _CacheEntry {
  final dynamic data;
  final Duration expiration;
  final DateTime createdAt;

  _CacheEntry({
    required this.data,
    required this.expiration,
    required this.createdAt,
  });

  bool get isExpired => DateTime.now().difference(createdAt) > expiration;
}
