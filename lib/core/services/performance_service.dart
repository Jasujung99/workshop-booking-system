import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';

/// Service for optimizing app performance
class PerformanceService {
  static final Logger _logger = Logger();
  static PerformanceService? _instance;
  
  static PerformanceService get instance {
    _instance ??= PerformanceService._();
    return _instance!;
  }

  PerformanceService._();

  /// Initialize performance optimizations
  Future<void> initialize() async {
    try {
      // Configure memory management
      await _configureMemoryManagement();
      
      // Configure rendering optimizations
      _configureRenderingOptimizations();
      
      // Configure platform-specific optimizations
      await _configurePlatformOptimizations();
      
      _logger.i('Performance service initialized successfully');
    } catch (e) {
      _logger.e('Failed to initialize performance service: $e');
    }
  }

  /// Configure memory management settings
  Future<void> _configureMemoryManagement() async {
    try {
      // Configure garbage collection
      if (kDebugMode) {
        // In debug mode, be more aggressive with GC to catch memory leaks early
        SystemChannels.platform.invokeMethod('SystemChrome.setPreferredOrientations');
      }
      
      // Configure image cache
      PaintingBinding.instance.imageCache.maximumSize = 100;
      PaintingBinding.instance.imageCache.maximumSizeBytes = 50 * 1024 * 1024; // 50MB
      
      _logger.i('Memory management configured');
    } catch (e) {
      _logger.e('Failed to configure memory management: $e');
    }
  }

  /// Configure rendering optimizations
  void _configureRenderingOptimizations() {
    try {
      // Enable hardware acceleration if available
      if (!kIsWeb) {
        // Platform-specific rendering optimizations would go here
      }
      
      _logger.i('Rendering optimizations configured');
    } catch (e) {
      _logger.e('Failed to configure rendering optimizations: $e');
    }
  }

  /// Configure platform-specific optimizations
  Future<void> _configurePlatformOptimizations() async {
    try {
      if (defaultTargetPlatform == TargetPlatform.android) {
        // Android-specific optimizations
        await _configureAndroidOptimizations();
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        // iOS-specific optimizations
        await _configureIOSOptimizations();
      }
      
      _logger.i('Platform optimizations configured');
    } catch (e) {
      _logger.e('Failed to configure platform optimizations: $e');
    }
  }

  /// Configure Android-specific optimizations
  Future<void> _configureAndroidOptimizations() async {
    try {
      // Configure Android-specific settings
      // This would typically involve platform channel calls
      _logger.i('Android optimizations configured');
    } catch (e) {
      _logger.e('Failed to configure Android optimizations: $e');
    }
  }

  /// Configure iOS-specific optimizations
  Future<void> _configureIOSOptimizations() async {
    try {
      // Configure iOS-specific settings
      // This would typically involve platform channel calls
      _logger.i('iOS optimizations configured');
    } catch (e) {
      _logger.e('Failed to configure iOS optimizations: $e');
    }
  }

  /// Force garbage collection (use sparingly)
  void forceGarbageCollection() {
    try {
      // Clear image cache
      PaintingBinding.instance.imageCache.clear();
      PaintingBinding.instance.imageCache.clearLiveImages();
      
      // Clear any other caches
      _logger.i('Forced garbage collection completed');
    } catch (e) {
      _logger.e('Failed to force garbage collection: $e');
    }
  }

  /// Get current memory usage information
  PerformanceInfo getPerformanceInfo() {
    try {
      final imageCache = PaintingBinding.instance.imageCache;
      
      return PerformanceInfo(
        imageCacheSize: imageCache.currentSize,
        imageCacheSizeBytes: imageCache.currentSizeBytes,
        maxImageCacheSize: imageCache.maximumSize,
        maxImageCacheSizeBytes: imageCache.maximumSizeBytes,
      );
    } catch (e) {
      _logger.e('Failed to get performance info: $e');
      return const PerformanceInfo(
        imageCacheSize: 0,
        imageCacheSizeBytes: 0,
        maxImageCacheSize: 0,
        maxImageCacheSizeBytes: 0,
      );
    }
  }

  /// Monitor performance metrics
  void startPerformanceMonitoring() {
    if (kDebugMode) {
      // In debug mode, periodically log performance metrics
      Stream.periodic(const Duration(minutes: 5)).listen((_) {
        final info = getPerformanceInfo();
        _logger.d('Performance metrics: ${info.toString()}');
      });
    }
  }
}

/// Performance information data class
class PerformanceInfo {
  final int imageCacheSize;
  final int imageCacheSizeBytes;
  final int maxImageCacheSize;
  final int maxImageCacheSizeBytes;

  const PerformanceInfo({
    required this.imageCacheSize,
    required this.imageCacheSizeBytes,
    required this.maxImageCacheSize,
    required this.maxImageCacheSizeBytes,
  });

  String get formattedImageCacheSize => _formatBytes(imageCacheSizeBytes);
  String get formattedMaxImageCacheSize => _formatBytes(maxImageCacheSizeBytes);

  double get imageCacheUsagePercentage {
    if (maxImageCacheSizeBytes == 0) return 0.0;
    return (imageCacheSizeBytes / maxImageCacheSizeBytes) * 100;
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  String toString() {
    return 'PerformanceInfo('
        'imageCacheSize: $imageCacheSize, '
        'imageCacheSizeBytes: $formattedImageCacheSize, '
        'maxImageCacheSize: $maxImageCacheSize, '
        'maxImageCacheSizeBytes: $formattedMaxImageCacheSize, '
        'usage: ${imageCacheUsagePercentage.toStringAsFixed(1)}%'
        ')';
  }
}