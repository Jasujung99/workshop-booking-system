import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as path;
import '../../core/error/exceptions.dart';
import '../../core/error/result.dart';
import '../../core/utils/logger.dart';
import '../../core/constants/app_constants.dart';

class FirebaseStorageService {
  final FirebaseStorage _storage;

  FirebaseStorageService({
    FirebaseStorage? storage,
  }) : _storage = storage ?? FirebaseStorage.instance;

  /// Uploads an image file to Firebase Storage with compression
  Future<Result<String>> uploadImage({
    required File imageFile,
    required String storagePath,
    String? fileName,
    int maxWidth = 1920,
    int maxHeight = 1080,
    int quality = 85,
  }) async {
    try {
      // Generate filename if not provided
      final finalFileName = fileName ?? 
          '${DateTime.now().millisecondsSinceEpoch}_${path.basename(imageFile.path)}';
      
      // Compress image
      final compressedImageResult = await _compressImage(
        imageFile,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        quality: quality,
      );

      if (compressedImageResult is Failure) {
        return compressedImageResult;
      }

      final compressedImageData = (compressedImageResult as Success<Uint8List>).data;
      
      // Create storage reference
      final storageRef = _storage.ref().child('$storagePath/$finalFileName');
      
      // Set metadata
      final metadata = SettableMetadata(
        contentType: _getContentType(imageFile.path),
        customMetadata: {
          'originalSize': imageFile.lengthSync().toString(),
          'compressedSize': compressedImageData.length.toString(),
          'uploadedAt': DateTime.now().toIso8601String(),
        },
      );

      // Upload compressed image
      final uploadTask = storageRef.putData(compressedImageData, metadata);
      
      // Monitor upload progress (optional)
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        final progress = (snapshot.bytesTransferred / snapshot.totalBytes) * 100;
        AppLogger.info('Upload progress: ${progress.toStringAsFixed(1)}%');
      });

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      
      AppLogger.info('Image uploaded successfully: $finalFileName');
      AppLogger.info('Original size: ${imageFile.lengthSync()} bytes');
      AppLogger.info('Compressed size: ${compressedImageData.length} bytes');
      AppLogger.info('Download URL: $downloadUrl');
      
      return Success(downloadUrl);
    } on FirebaseException catch (e) {
      AppLogger.error('Firebase Storage error during upload', exception: e);
      return Failure(StorageException(_mapFirebaseStorageError(e), code: e.code));
    } catch (e) {
      AppLogger.error('Unexpected error during image upload', exception: e);
      return Failure(UnknownException('Image upload failed: ${e.toString()}'));
    }
  }

  /// Uploads multiple images in batch
  Future<Result<List<String>>> uploadMultipleImages({
    required List<File> imageFiles,
    required String storagePath,
    int maxWidth = 1920,
    int maxHeight = 1080,
    int quality = 85,
  }) async {
    try {
      final uploadResults = <String>[];
      
      for (int i = 0; i < imageFiles.length; i++) {
        final file = imageFiles[i];
        final fileName = '${DateTime.now().millisecondsSinceEpoch}_$i_${path.basename(file.path)}';
        
        final result = await uploadImage(
          imageFile: file,
          storagePath: storagePath,
          fileName: fileName,
          maxWidth: maxWidth,
          maxHeight: maxHeight,
          quality: quality,
        );

        if (result is Failure) {
          // If any upload fails, clean up already uploaded files
          await _cleanupUploadedFiles(uploadResults);
          return result;
        }

        uploadResults.add((result as Success<String>).data);
      }

      AppLogger.info('Successfully uploaded ${uploadResults.length} images');
      return Success(uploadResults);
    } catch (e) {
      AppLogger.error('Error uploading multiple images', exception: e);
      return Failure(UnknownException('Multiple image upload failed: ${e.toString()}'));
    }
  }

  /// Downloads an image from Firebase Storage
  Future<Result<Uint8List>> downloadImage(String downloadUrl) async {
    try {
      final ref = _storage.refFromURL(downloadUrl);
      final imageData = await ref.getData();
      
      if (imageData == null) {
        return const Failure(StorageException('Failed to download image data'));
      }

      AppLogger.info('Image downloaded successfully: ${imageData.length} bytes');
      return Success(imageData);
    } on FirebaseException catch (e) {
      AppLogger.error('Firebase Storage error during download', exception: e);
      return Failure(StorageException(_mapFirebaseStorageError(e), code: e.code));
    } catch (e) {
      AppLogger.error('Unexpected error during image download', exception: e);
      return Failure(UnknownException('Image download failed: ${e.toString()}'));
    }
  }

  /// Deletes an image from Firebase Storage
  Future<Result<void>> deleteImage(String downloadUrl) async {
    try {
      final ref = _storage.refFromURL(downloadUrl);
      await ref.delete();
      
      AppLogger.info('Image deleted successfully: ${ref.fullPath}');
      return const Success(null);
    } on FirebaseException catch (e) {
      AppLogger.error('Firebase Storage error during deletion', exception: e);
      return Failure(StorageException(_mapFirebaseStorageError(e), code: e.code));
    } catch (e) {
      AppLogger.error('Unexpected error during image deletion', exception: e);
      return Failure(UnknownException('Image deletion failed: ${e.toString()}'));
    }
  }

  /// Deletes multiple images from Firebase Storage
  Future<Result<void>> deleteMultipleImages(List<String> downloadUrls) async {
    try {
      final deleteResults = <Future<void>>[];
      
      for (final url in downloadUrls) {
        try {
          final ref = _storage.refFromURL(url);
          deleteResults.add(ref.delete());
        } catch (e) {
          AppLogger.warning('Failed to create reference for URL: $url', exception: e);
        }
      }

      await Future.wait(deleteResults);
      
      AppLogger.info('Successfully deleted ${downloadUrls.length} images');
      return const Success(null);
    } catch (e) {
      AppLogger.error('Error deleting multiple images', exception: e);
      return Failure(UnknownException('Multiple image deletion failed: ${e.toString()}'));
    }
  }

  /// Gets metadata for an image
  Future<Result<FullMetadata>> getImageMetadata(String downloadUrl) async {
    try {
      final ref = _storage.refFromURL(downloadUrl);
      final metadata = await ref.getMetadata();
      
      AppLogger.info('Retrieved metadata for: ${ref.fullPath}');
      return Success(metadata);
    } on FirebaseException catch (e) {
      AppLogger.error('Firebase Storage error getting metadata', exception: e);
      return Failure(StorageException(_mapFirebaseStorageError(e), code: e.code));
    } catch (e) {
      AppLogger.error('Unexpected error getting image metadata', exception: e);
      return Failure(UnknownException('Get metadata failed: ${e.toString()}'));
    }
  }

  /// Lists all files in a storage path
  Future<Result<List<Reference>>> listFiles(String storagePath) async {
    try {
      final ref = _storage.ref().child(storagePath);
      final listResult = await ref.listAll();
      
      AppLogger.info('Listed ${listResult.items.length} files in: $storagePath');
      return Success(listResult.items);
    } on FirebaseException catch (e) {
      AppLogger.error('Firebase Storage error listing files', exception: e);
      return Failure(StorageException(_mapFirebaseStorageError(e), code: e.code));
    } catch (e) {
      AppLogger.error('Unexpected error listing files', exception: e);
      return Failure(UnknownException('List files failed: ${e.toString()}'));
    }
  }

  /// Compresses an image file
  Future<Result<Uint8List>> _compressImage(
    File imageFile, {
    required int maxWidth,
    required int maxHeight,
    required int quality,
  }) async {
    try {
      // Read image file
      final imageBytes = await imageFile.readAsBytes();
      
      // Decode image
      final image = img.decodeImage(imageBytes);
      if (image == null) {
        return const Failure(ValidationException('Invalid image format'));
      }

      // Calculate new dimensions while maintaining aspect ratio
      final originalWidth = image.width;
      final originalHeight = image.height;
      
      int newWidth = originalWidth;
      int newHeight = originalHeight;

      if (originalWidth > maxWidth || originalHeight > maxHeight) {
        final widthRatio = maxWidth / originalWidth;
        final heightRatio = maxHeight / originalHeight;
        final ratio = widthRatio < heightRatio ? widthRatio : heightRatio;
        
        newWidth = (originalWidth * ratio).round();
        newHeight = (originalHeight * ratio).round();
      }

      // Resize image if needed
      final resizedImage = (newWidth != originalWidth || newHeight != originalHeight)
          ? img.copyResize(image, width: newWidth, height: newHeight)
          : image;

      // Compress image based on file extension
      final extension = path.extension(imageFile.path).toLowerCase();
      late Uint8List compressedBytes;

      switch (extension) {
        case '.jpg':
        case '.jpeg':
          compressedBytes = Uint8List.fromList(img.encodeJpg(resizedImage, quality: quality));
          break;
        case '.png':
          compressedBytes = Uint8List.fromList(img.encodePng(resizedImage));
          break;
        case '.webp':
          compressedBytes = Uint8List.fromList(img.encodeWebP(resizedImage, quality: quality));
          break;
        default:
          // Default to JPEG for unknown formats
          compressedBytes = Uint8List.fromList(img.encodeJpg(resizedImage, quality: quality));
      }

      AppLogger.info('Image compressed: ${originalWidth}x${originalHeight} -> ${newWidth}x${newHeight}');
      AppLogger.info('Size reduced: ${imageBytes.length} -> ${compressedBytes.length} bytes');
      
      return Success(compressedBytes);
    } catch (e) {
      AppLogger.error('Error compressing image', exception: e);
      return Failure(ValidationException('Image compression failed: ${e.toString()}'));
    }
  }

  /// Cleans up uploaded files in case of batch upload failure
  Future<void> _cleanupUploadedFiles(List<String> uploadedUrls) async {
    try {
      for (final url in uploadedUrls) {
        await deleteImage(url);
      }
      AppLogger.info('Cleaned up ${uploadedUrls.length} uploaded files');
    } catch (e) {
      AppLogger.error('Error cleaning up uploaded files', exception: e);
    }
  }

  /// Gets content type based on file extension
  String _getContentType(String filePath) {
    final extension = path.extension(filePath).toLowerCase();
    switch (extension) {
      case '.jpg':
      case '.jpeg':
        return 'image/jpeg';
      case '.png':
        return 'image/png';
      case '.gif':
        return 'image/gif';
      case '.webp':
        return 'image/webp';
      case '.bmp':
        return 'image/bmp';
      default:
        return 'image/jpeg'; // Default to JPEG
    }
  }

  /// Maps Firebase Storage errors to user-friendly messages
  String _mapFirebaseStorageError(FirebaseException e) {
    switch (e.code) {
      case 'storage/object-not-found':
        return 'File not found.';
      case 'storage/bucket-not-found':
        return 'Storage bucket not found.';
      case 'storage/project-not-found':
        return 'Project not found.';
      case 'storage/quota-exceeded':
        return 'Storage quota exceeded.';
      case 'storage/unauthenticated':
        return 'User is not authenticated.';
      case 'storage/unauthorized':
        return 'User is not authorized to perform this action.';
      case 'storage/retry-limit-exceeded':
        return 'Upload retry limit exceeded.';
      case 'storage/invalid-checksum':
        return 'File checksum validation failed.';
      case 'storage/canceled':
        return 'Upload was canceled.';
      case 'storage/invalid-event-name':
        return 'Invalid event name.';
      case 'storage/invalid-url':
        return 'Invalid download URL.';
      case 'storage/invalid-argument':
        return 'Invalid argument provided.';
      case 'storage/no-default-bucket':
        return 'No default storage bucket configured.';
      case 'storage/cannot-slice-blob':
        return 'Cannot slice file blob.';
      case 'storage/server-file-wrong-size':
        return 'Server file size mismatch.';
      default:
        return e.message ?? 'A storage error occurred.';
    }
  }

  /// Utility method to generate unique filename
  static String generateUniqueFileName(String originalFileName) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final extension = path.extension(originalFileName);
    final nameWithoutExtension = path.basenameWithoutExtension(originalFileName);
    return '${nameWithoutExtension}_$timestamp$extension';
  }

  /// Utility method to validate image file
  static Result<void> validateImageFile(File imageFile) {
    try {
      // Check if file exists
      if (!imageFile.existsSync()) {
        return const Failure(ValidationException('Image file does not exist'));
      }

      // Check file size (max 10MB)
      const maxSizeBytes = 10 * 1024 * 1024; // 10MB
      final fileSizeBytes = imageFile.lengthSync();
      if (fileSizeBytes > maxSizeBytes) {
        return const Failure(ValidationException('Image file is too large (max 10MB)'));
      }

      // Check file extension
      final extension = path.extension(imageFile.path).toLowerCase();
      const allowedExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.webp', '.bmp'];
      if (!allowedExtensions.contains(extension)) {
        return const Failure(ValidationException('Unsupported image format'));
      }

      return const Success(null);
    } catch (e) {
      return Failure(ValidationException('Image validation failed: ${e.toString()}'));
    }
  }
}