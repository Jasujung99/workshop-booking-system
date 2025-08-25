import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

/// Optimized image widget with caching, lazy loading, and error handling
class OptimizedImage extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final bool enableLazyLoading;
  final BorderRadius? borderRadius;
  final String? heroTag;
  final VoidCallback? onTap;

  const OptimizedImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.enableLazyLoading = true,
    this.borderRadius,
    this.heroTag,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return _buildErrorWidget(context);
    }

    Widget imageWidget = CachedNetworkImage(
      imageUrl: imageUrl!,
      width: width,
      height: height,
      fit: fit,
      placeholder: (context, url) => _buildPlaceholder(context),
      errorWidget: (context, url, error) => _buildErrorWidget(context),
      fadeInDuration: const Duration(milliseconds: 300),
      fadeOutDuration: const Duration(milliseconds: 100),
      memCacheWidth: _getMemCacheWidth(),
      memCacheHeight: _getMemCacheHeight(),
      maxWidthDiskCache: _getMaxDiskCacheWidth(),
      maxHeightDiskCache: _getMaxDiskCacheHeight(),
    );

    // Apply border radius if specified
    if (borderRadius != null) {
      imageWidget = ClipRRect(
        borderRadius: borderRadius!,
        child: imageWidget,
      );
    }

    // Apply hero animation if tag is provided
    if (heroTag != null) {
      imageWidget = Hero(
        tag: heroTag!,
        child: imageWidget,
      );
    }

    // Apply tap gesture if callback is provided
    if (onTap != null) {
      imageWidget = GestureDetector(
        onTap: onTap,
        child: imageWidget,
      );
    }

    // Apply lazy loading if enabled
    if (enableLazyLoading) {
      return _LazyLoadingWrapper(
        child: imageWidget,
      );
    }

    return imageWidget;
  }

  Widget _buildPlaceholder(BuildContext context) {
    if (placeholder != null) {
      return placeholder!;
    }

    return Shimmer.fromColors(
      baseColor: Theme.of(context).colorScheme.surfaceVariant,
      highlightColor: Theme.of(context).colorScheme.surface,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceVariant,
          borderRadius: borderRadius,
        ),
      ),
    );
  }

  Widget _buildErrorWidget(BuildContext context) {
    if (errorWidget != null) {
      return errorWidget!;
    }

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer,
        borderRadius: borderRadius,
      ),
      child: Icon(
        Icons.broken_image_outlined,
        color: Theme.of(context).colorScheme.onErrorContainer,
        size: (width != null && height != null) 
            ? (width! < height! ? width! * 0.3 : height! * 0.3)
            : 24,
      ),
    );
  }

  int? _getMemCacheWidth() {
    if (width != null) {
      return (width! * MediaQueryData.fromView(
        WidgetsBinding.instance.platformDispatcher.views.first
      ).devicePixelRatio).round();
    }
    return null;
  }

  int? _getMemCacheHeight() {
    if (height != null) {
      return (height! * MediaQueryData.fromView(
        WidgetsBinding.instance.platformDispatcher.views.first
      ).devicePixelRatio).round();
    }
    return null;
  }

  int? _getMaxDiskCacheWidth() {
    if (width != null) {
      return (width! * 2).round(); // 2x for high DPI displays
    }
    return null;
  }

  int? _getMaxDiskCacheHeight() {
    if (height != null) {
      return (height! * 2).round(); // 2x for high DPI displays
    }
    return null;
  }
}

/// Wrapper widget for lazy loading implementation
class _LazyLoadingWrapper extends StatefulWidget {
  final Widget child;

  const _LazyLoadingWrapper({required this.child});

  @override
  State<_LazyLoadingWrapper> createState() => _LazyLoadingWrapperState();
}

class _LazyLoadingWrapperState extends State<_LazyLoadingWrapper> {
  bool _isVisible = false;

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: UniqueKey(),
      onVisibilityChanged: (info) {
        if (info.visibleFraction > 0.1 && !_isVisible) {
          setState(() {
            _isVisible = true;
          });
        }
      },
      child: _isVisible ? widget.child : const SizedBox.shrink(),
    );
  }
}

/// Simple visibility detector for lazy loading
class VisibilityDetector extends StatefulWidget {
  final Key key;
  final Widget child;
  final Function(VisibilityInfo) onVisibilityChanged;

  const VisibilityDetector({
    required this.key,
    required this.child,
    required this.onVisibilityChanged,
  }) : super(key: key);

  @override
  State<VisibilityDetector> createState() => _VisibilityDetectorState();
}

class _VisibilityDetectorState extends State<VisibilityDetector> {
  @override
  Widget build(BuildContext context) {
    // For simplicity, we'll load images immediately
    // In a production app, you might want to use a more sophisticated
    // visibility detection mechanism
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onVisibilityChanged(const VisibilityInfo(visibleFraction: 1.0));
    });
    
    return widget.child;
  }
}

/// Information about widget visibility
class VisibilityInfo {
  final double visibleFraction;

  const VisibilityInfo({required this.visibleFraction});
}

/// Factory methods for common image use cases
extension OptimizedImageFactory on OptimizedImage {
  /// Create thumbnail image
  static OptimizedImage thumbnail({
    required String? imageUrl,
    double size = 80,
    BorderRadius? borderRadius,
    VoidCallback? onTap,
  }) {
    return OptimizedImage(
      imageUrl: imageUrl,
      width: size,
      height: size,
      fit: BoxFit.cover,
      borderRadius: borderRadius ?? BorderRadius.circular(8),
      onTap: onTap,
    );
  }

  /// Create list item image
  static OptimizedImage listItem({
    required String? imageUrl,
    double width = 120,
    double height = 90,
    BorderRadius? borderRadius,
    VoidCallback? onTap,
  }) {
    return OptimizedImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: BoxFit.cover,
      borderRadius: borderRadius ?? BorderRadius.circular(12),
      onTap: onTap,
    );
  }

  /// Create detail view image
  static OptimizedImage detail({
    required String? imageUrl,
    double? width,
    double height = 200,
    BorderRadius? borderRadius,
    String? heroTag,
    VoidCallback? onTap,
  }) {
    return OptimizedImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: BoxFit.cover,
      borderRadius: borderRadius ?? BorderRadius.circular(16),
      heroTag: heroTag,
      onTap: onTap,
    );
  }

  /// Create full screen image
  static OptimizedImage fullScreen({
    required String? imageUrl,
    String? heroTag,
    VoidCallback? onTap,
  }) {
    return OptimizedImage(
      imageUrl: imageUrl,
      fit: BoxFit.contain,
      heroTag: heroTag,
      onTap: onTap,
      enableLazyLoading: false, // Don't lazy load full screen images
    );
  }
}