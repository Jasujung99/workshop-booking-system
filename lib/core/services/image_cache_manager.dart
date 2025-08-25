import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:logger/logger.dart';

/// Enhanced image cache manager with custom configurations
class ImageCacheManager {
  static final Logger _logger = Logger();
  static ImageCacheManager? _instance;
  
  static ImageCacheManager get instance {
    _instance ??= ImageCacheManager._();
    return _instance!;
  }

  ImageCacheManager._();

  /// Initialize cache manager with custom settings
  Future<void> initialize() async {
    try {
      // Configure memory cache
      PaintingBinding.instance.imageCache.maximumSize = 100; // Max 100 images in memory
      PaintingBinding.instance.imageCache.maximumSizeBytes = 50 * 1024 * 1024; // 50MB max memory usage

      _logger.i('Image cache manager initialized successfully');
    } catch (e) {
      _logger.e('Failed to initialize image cache manager: $e');
    }
  }

  /// Clear all cached images
  Future<void> clearCache() async {
    try {
      // Clear memory cache
      PaintingBinding.instance.imageCache.clear();
      PaintingBinding.instance.imageCache.clearLiveImages();

      // Clear disk cache
      await DefaultCacheManager().emptyCache();

      _logger.i('Image cache cleared successfully');
    } catch (e) {
      _logger.e('Failed to clear image cache: $e');
    }
  }

  /// Get cache size information
  Future<CacheInfo> getCacheInfo() async {
    try {
      return CacheInfo(
        memoryImageCount: PaintingBinding.instance.imageCache.currentSize,
        memoryImageSizeBytes: PaintingBinding.instance.imageCache.currentSizeBytes,
        diskCacheSizeBytes: 0, // Simplified for web compatibility
        maxMemoryImages: PaintingBinding.instance.imageCache.maximumSize,
        maxMemorySizeBytes: PaintingBinding.instance.imageCache.maximumSizeBytes,
      );
    } catch (e) {
      _logger.e('Failed to get cache info: $e');
      return const CacheInfo(
        memoryImageCount: 0,
        memoryImageSizeBytes: 0,
        diskCacheSizeBytes: 0,
        maxMemoryImages: 0,
        maxMemorySizeBytes: 0,
      );
    }
  }

  /// Preload images for better performance
  Future<void> preloadImages(List<String> imageUrls) async {
    for (final url in imageUrls) {
      try {
        await DefaultCacheManager().downloadFile(url);
        _logger.d('Preloaded image: $url');
      } catch (e) {
        _logger.w('Failed to preload image $url: $e');
      }
    }
  }

  /// Remove specific image from cache
  Future<void> removeFromCache(String imageUrl) async {
    try {
      await DefaultCacheManager().removeFile(imageUrl);
      _logger.d('Removed image from cache: $imageUrl');
    } catch (e) {
      _logger.w('Failed to remove image from cache $imageUrl: $e');
    }
  }

  /// Check if image is cached
  Future<bool> isImageCached(String imageUrl) async {
    try {
      final fileInfo = await DefaultCacheManager().getFileFromCache(imageUrl);
      return fileInfo != null;
    } catch (e) {
      _logger.w('Failed to check cache status for $imageUrl: $e');
      return false;
    }
  }

  /// Configure cache settings based on device capabilities
  Future<void> configureCacheForDevice() async {
    try {
      // Get device memory info (simplified approach)
      final memoryInfo = await _getDeviceMemoryInfo();
      
      if (memoryInfo.isLowMemoryDevice) {
        // Configure for low memory devices
        PaintingBinding.instance.imageCache.maximumSize = 50;
        PaintingBinding.instance.imageCache.maximumSizeBytes = 25 * 1024 * 1024; // 25MB
        _logger.i('Configured cache for low memory device');
      } else {
        // Configure for high memory devices
        PaintingBinding.instance.imageCache.maximumSize = 150;
        PaintingBinding.instance.imageCache.maximumSizeBytes = 100 * 1024 * 1024; // 100MB
        _logger.i('Configured cache for high memory device');
      }
    } catch (e) {
      _logger.e('Failed to configure cache for device: $e');
    }
  }

  /// Get device memory information (simplified)
  Future<DeviceMemoryInfo> _getDeviceMemoryInfo() async {
    // This is a simplified approach. In a real app, you might want to use
    // platform-specific code to get actual device memory information
    return const DeviceMemoryInfo(isLowMemoryDevice: false);
  }
}

/// Information about cache usage
class CacheInfo {
  final int memoryImageCount;
  final int memoryImageSizeBytes;
  final int diskCacheSizeBytes;
  final int maxMemoryImages;
  final int maxMemorySizeBytes;

  const CacheInfo({
    required this.memoryImageCount,
    required this.memoryImageSizeBytes,
    required this.diskCacheSizeBytes,
    required this.maxMemoryImages,
    required this.maxMemorySizeBytes,
  });

  String get formattedMemorySize => _formatBytes(memoryImageSizeBytes);
  String get formattedDiskSize => _formatBytes(diskCacheSizeBytes);
  String get formattedMaxMemorySize => _formatBytes(maxMemorySizeBytes);

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

/// Device memory information
class DeviceMemoryInfo {
  final bool isLowMemoryDevice;

  const DeviceMemoryInfo({required this.isLowMemoryDevice});
}