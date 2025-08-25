import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:logger/logger.dart';

/// Service for optimizing and compressing images
class ImageOptimizationService {
  static final Logger _logger = Logger();
  
  /// Compress image file with specified quality and dimensions
  static Future<File?> compressImage(
    File imageFile, {
    int quality = 85,
    int? maxWidth,
    int? maxHeight,
  }) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final fileName = path.basenameWithoutExtension(imageFile.path);
      final extension = path.extension(imageFile.path);
      final targetPath = path.join(
        tempDir.path,
        '${fileName}_compressed$extension',
      );

      final compressedFile = await FlutterImageCompress.compressAndGetFile(
        imageFile.absolute.path,
        targetPath,
        quality: quality,
        minWidth: maxWidth ?? 1920,
        minHeight: maxHeight ?? 1080,
        format: _getCompressFormat(extension),
      );

      if (compressedFile != null) {
        _logger.i('Image compressed successfully: ${compressedFile.path}');
        return File(compressedFile.path);
      }
      
      _logger.w('Image compression failed, returning original file');
      return imageFile;
    } catch (e) {
      _logger.e('Error compressing image: $e');
      return imageFile;
    }
  }

  /// Compress image bytes
  static Future<Uint8List?> compressImageBytes(
    Uint8List imageBytes, {
    int quality = 85,
    int? maxWidth,
    int? maxHeight,
    CompressFormat format = CompressFormat.jpeg,
  }) async {
    try {
      final compressedBytes = await FlutterImageCompress.compressWithList(
        imageBytes,
        quality: quality,
        minWidth: maxWidth ?? 1920,
        minHeight: maxHeight ?? 1080,
        format: format,
      );

      _logger.i('Image bytes compressed successfully');
      return compressedBytes;
    } catch (e) {
      _logger.e('Error compressing image bytes: $e');
      return imageBytes;
    }
  }

  /// Get appropriate compression format based on file extension
  static CompressFormat _getCompressFormat(String extension) {
    switch (extension.toLowerCase()) {
      case '.png':
        return CompressFormat.png;
      case '.webp':
        return CompressFormat.webp;
      case '.heic':
        return CompressFormat.heic;
      default:
        return CompressFormat.jpeg;
    }
  }

  /// Create thumbnail from image file
  static Future<File?> createThumbnail(
    File imageFile, {
    int size = 200,
    int quality = 70,
  }) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final fileName = path.basenameWithoutExtension(imageFile.path);
      final targetPath = path.join(
        tempDir.path,
        '${fileName}_thumb.jpg',
      );

      final thumbnailFile = await FlutterImageCompress.compressAndGetFile(
        imageFile.absolute.path,
        targetPath,
        quality: quality,
        minWidth: size,
        minHeight: size,
        format: CompressFormat.jpeg,
      );

      if (thumbnailFile != null) {
        _logger.i('Thumbnail created successfully: ${thumbnailFile.path}');
        return File(thumbnailFile.path);
      }
      
      return null;
    } catch (e) {
      _logger.e('Error creating thumbnail: $e');
      return null;
    }
  }

  /// Get optimized image size for different use cases
  static ImageSize getOptimizedSize(ImageUseCase useCase) {
    switch (useCase) {
      case ImageUseCase.thumbnail:
        return const ImageSize(width: 200, height: 200);
      case ImageUseCase.listItem:
        return const ImageSize(width: 400, height: 300);
      case ImageUseCase.detail:
        return const ImageSize(width: 800, height: 600);
      case ImageUseCase.fullScreen:
        return const ImageSize(width: 1920, height: 1080);
    }
  }

  /// Calculate compression quality based on file size
  static int calculateOptimalQuality(int fileSizeBytes) {
    if (fileSizeBytes < 500 * 1024) { // < 500KB
      return 95;
    } else if (fileSizeBytes < 1024 * 1024) { // < 1MB
      return 85;
    } else if (fileSizeBytes < 2 * 1024 * 1024) { // < 2MB
      return 75;
    } else {
      return 65;
    }
  }
}

/// Enum for different image use cases
enum ImageUseCase {
  thumbnail,
  listItem,
  detail,
  fullScreen,
}

/// Class to represent image dimensions
class ImageSize {
  final int width;
  final int height;

  const ImageSize({required this.width, required this.height});
}