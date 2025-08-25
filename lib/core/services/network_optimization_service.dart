import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';

/// Service for optimizing network requests and providing offline support
class NetworkOptimizationService {
  static final Logger _logger = Logger();
  static NetworkOptimizationService? _instance;
  
  static NetworkOptimizationService get instance {
    _instance ??= NetworkOptimizationService._();
    return _instance!;
  }

  NetworkOptimizationService._();

  final Map<String, CachedResponse> _responseCache = {};
  final Map<String, Timer> _cacheTimers = {};
  bool _isOnline = true;
  StreamController<bool>? _connectivityController;

  /// Initialize network optimization service
  Future<void> initialize() async {
    try {
      // Initialize connectivity monitoring
      _connectivityController = StreamController<bool>.broadcast();
      _startConnectivityMonitoring();
      
      // Load cached responses from disk
      await _loadCacheFromDisk();
      
      _logger.i('Network optimization service initialized');
    } catch (e) {
      _logger.e('Failed to initialize network optimization service: $e');
    }
  }

  /// Get connectivity stream
  Stream<bool> get connectivityStream => _connectivityController?.stream ?? const Stream.empty();

  /// Check if device is online
  bool get isOnline => _isOnline;

  /// Cache a network response
  void cacheResponse(
    String key,
    Map<String, dynamic> data, {
    Duration cacheDuration = const Duration(minutes: 30),
  }) {
    try {
      final cachedResponse = CachedResponse(
        data: data,
        timestamp: DateTime.now(),
        duration: cacheDuration,
      );

      _responseCache[key] = cachedResponse;

      // Set up cache expiration timer
      _cacheTimers[key]?.cancel();
      _cacheTimers[key] = Timer(cacheDuration, () {
        _responseCache.remove(key);
        _cacheTimers.remove(key);
      });

      // Persist to disk
      _saveCacheToDisk();

      _logger.d('Cached response for key: $key');
    } catch (e) {
      _logger.e('Failed to cache response: $e');
    }
  }

  /// Get cached response
  Map<String, dynamic>? getCachedResponse(String key) {
    try {
      final cachedResponse = _responseCache[key];
      if (cachedResponse == null) return null;

      // Check if cache is still valid
      final now = DateTime.now();
      final expiryTime = cachedResponse.timestamp.add(cachedResponse.duration);
      
      if (now.isAfter(expiryTime)) {
        // Cache expired, remove it
        _responseCache.remove(key);
        _cacheTimers[key]?.cancel();
        _cacheTimers.remove(key);
        return null;
      }

      _logger.d('Retrieved cached response for key: $key');
      return cachedResponse.data;
    } catch (e) {
      _logger.e('Failed to get cached response: $e');
      return null;
    }
  }

  /// Clear specific cache entry
  void clearCache(String key) {
    try {
      _responseCache.remove(key);
      _cacheTimers[key]?.cancel();
      _cacheTimers.remove(key);
      _logger.d('Cleared cache for key: $key');
    } catch (e) {
      _logger.e('Failed to clear cache: $e');
    }
  }

  /// Clear all cached responses
  void clearAllCache() {
    try {
      _responseCache.clear();
      for (final timer in _cacheTimers.values) {
        timer.cancel();
      }
      _cacheTimers.clear();
      _deleteCacheFile();
      _logger.i('Cleared all cached responses');
    } catch (e) {
      _logger.e('Failed to clear all cache: $e');
    }
  }

  /// Get cache statistics
  CacheStatistics getCacheStatistics() {
    try {
      int totalSize = 0;
      int validEntries = 0;
      int expiredEntries = 0;
      final now = DateTime.now();

      for (final entry in _responseCache.entries) {
        final cachedResponse = entry.value;
        final expiryTime = cachedResponse.timestamp.add(cachedResponse.duration);
        
        if (now.isAfter(expiryTime)) {
          expiredEntries++;
        } else {
          validEntries++;
        }

        // Estimate size (rough calculation)
        totalSize += jsonEncode(cachedResponse.data).length;
      }

      return CacheStatistics(
        totalEntries: _responseCache.length,
        validEntries: validEntries,
        expiredEntries: expiredEntries,
        estimatedSizeBytes: totalSize,
      );
    } catch (e) {
      _logger.e('Failed to get cache statistics: $e');
      return const CacheStatistics(
        totalEntries: 0,
        validEntries: 0,
        expiredEntries: 0,
        estimatedSizeBytes: 0,
      );
    }
  }

  /// Clean up expired cache entries
  void cleanupExpiredCache() {
    try {
      final now = DateTime.now();
      final expiredKeys = <String>[];

      for (final entry in _responseCache.entries) {
        final cachedResponse = entry.value;
        final expiryTime = cachedResponse.timestamp.add(cachedResponse.duration);
        
        if (now.isAfter(expiryTime)) {
          expiredKeys.add(entry.key);
        }
      }

      for (final key in expiredKeys) {
        _responseCache.remove(key);
        _cacheTimers[key]?.cancel();
        _cacheTimers.remove(key);
      }

      if (expiredKeys.isNotEmpty) {
        _saveCacheToDisk();
        _logger.i('Cleaned up ${expiredKeys.length} expired cache entries');
      }
    } catch (e) {
      _logger.e('Failed to cleanup expired cache: $e');
    }
  }

  /// Start monitoring connectivity
  void _startConnectivityMonitoring() {
    // Simple connectivity check using HTTP request
    Timer.periodic(const Duration(seconds: 30), (timer) async {
      try {
        final result = await InternetAddress.lookup('google.com');
        final wasOnline = _isOnline;
        _isOnline = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
        
        if (wasOnline != _isOnline) {
          _connectivityController?.add(_isOnline);
          _logger.i('Connectivity changed: ${_isOnline ? 'Online' : 'Offline'}');
        }
      } catch (e) {
        final wasOnline = _isOnline;
        _isOnline = false;
        
        if (wasOnline != _isOnline) {
          _connectivityController?.add(_isOnline);
          _logger.i('Connectivity changed: Offline');
        }
      }
    });
  }

  /// Save cache to disk for persistence
  Future<void> _saveCacheToDisk() async {
    try {
      if (kIsWeb) return; // Skip disk operations on web

      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/network_cache.json');

      final cacheData = <String, dynamic>{};
      for (final entry in _responseCache.entries) {
        cacheData[entry.key] = {
          'data': entry.value.data,
          'timestamp': entry.value.timestamp.toIso8601String(),
          'duration': entry.value.duration.inMilliseconds,
        };
      }

      await file.writeAsString(jsonEncode(cacheData));
    } catch (e) {
      _logger.e('Failed to save cache to disk: $e');
    }
  }

  /// Load cache from disk
  Future<void> _loadCacheFromDisk() async {
    try {
      if (kIsWeb) return; // Skip disk operations on web

      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/network_cache.json');

      if (!await file.exists()) return;

      final content = await file.readAsString();
      final cacheData = jsonDecode(content) as Map<String, dynamic>;

      final now = DateTime.now();
      for (final entry in cacheData.entries) {
        final data = entry.value as Map<String, dynamic>;
        final timestamp = DateTime.parse(data['timestamp'] as String);
        final duration = Duration(milliseconds: data['duration'] as int);
        
        // Only load non-expired cache entries
        if (now.isBefore(timestamp.add(duration))) {
          final cachedResponse = CachedResponse(
            data: data['data'] as Map<String, dynamic>,
            timestamp: timestamp,
            duration: duration,
          );
          
          _responseCache[entry.key] = cachedResponse;
          
          // Set up expiration timer
          final remainingTime = timestamp.add(duration).difference(now);
          if (remainingTime.isNegative) continue;
          
          _cacheTimers[entry.key] = Timer(remainingTime, () {
            _responseCache.remove(entry.key);
            _cacheTimers.remove(entry.key);
          });
        }
      }

      _logger.i('Loaded ${_responseCache.length} cache entries from disk');
    } catch (e) {
      _logger.e('Failed to load cache from disk: $e');
    }
  }

  /// Delete cache file
  Future<void> _deleteCacheFile() async {
    try {
      if (kIsWeb) return; // Skip disk operations on web

      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/network_cache.json');

      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      _logger.e('Failed to delete cache file: $e');
    }
  }

  /// Dispose resources
  void dispose() {
    try {
      for (final timer in _cacheTimers.values) {
        timer.cancel();
      }
      _cacheTimers.clear();
      _connectivityController?.close();
      _logger.i('Network optimization service disposed');
    } catch (e) {
      _logger.e('Failed to dispose network optimization service: $e');
    }
  }
}

/// Cached response data class
class CachedResponse {
  final Map<String, dynamic> data;
  final DateTime timestamp;
  final Duration duration;

  const CachedResponse({
    required this.data,
    required this.timestamp,
    required this.duration,
  });
}

/// Cache statistics data class
class CacheStatistics {
  final int totalEntries;
  final int validEntries;
  final int expiredEntries;
  final int estimatedSizeBytes;

  const CacheStatistics({
    required this.totalEntries,
    required this.validEntries,
    required this.expiredEntries,
    required this.estimatedSizeBytes,
  });

  String get formattedSize {
    if (estimatedSizeBytes < 1024) return '$estimatedSizeBytes B';
    if (estimatedSizeBytes < 1024 * 1024) {
      return '${(estimatedSizeBytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(estimatedSizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  String toString() {
    return 'CacheStatistics('
        'total: $totalEntries, '
        'valid: $validEntries, '
        'expired: $expiredEntries, '
        'size: $formattedSize'
        ')';
  }
}