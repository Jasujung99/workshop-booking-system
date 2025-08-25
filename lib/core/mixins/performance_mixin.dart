import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Mixin to help optimize widget performance and reduce unnecessary rebuilds
mixin PerformanceMixin<T extends StatefulWidget> on State<T> {
  /// Track if widget is currently mounted and visible
  bool _isMounted = false;
  bool _isVisible = true;

  @override
  void initState() {
    super.initState();
    _isMounted = true;
  }

  @override
  void dispose() {
    _isMounted = false;
    super.dispose();
  }

  /// Check if widget is still mounted before calling setState
  void safeSetState(VoidCallback fn) {
    if (_isMounted && mounted) {
      setState(fn);
    }
  }

  /// Debounced setState to prevent rapid consecutive updates
  void debouncedSetState(VoidCallback fn, {Duration delay = const Duration(milliseconds: 100)}) {
    Future.delayed(delay, () {
      safeSetState(fn);
    });
  }

  /// Mark widget as visible/invisible for performance optimizations
  void setVisibility(bool visible) {
    if (_isVisible != visible) {
      _isVisible = visible;
      onVisibilityChanged(visible);
    }
  }

  /// Override this method to handle visibility changes
  void onVisibilityChanged(bool visible) {
    // Override in subclasses if needed
  }

  /// Check if widget is currently visible
  bool get isVisible => _isVisible;

  /// Check if widget is mounted
  bool get isMounted => _isMounted && mounted;
}

/// Mixin for optimizing list performance
mixin ListPerformanceMixin<T extends StatefulWidget> on State<T> {
  final ScrollController _scrollController = ScrollController();
  bool _isScrolling = false;
  
  ScrollController get scrollController => _scrollController;
  bool get isScrolling => _isScrolling;

  @override
  void initState() {
    super.initState();
    _setupScrollListener();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      if (!_isScrolling) {
        setState(() {
          _isScrolling = true;
        });
        
        // Reset scrolling state after a delay
        Future.delayed(const Duration(milliseconds: 150), () {
          if (mounted) {
            setState(() {
              _isScrolling = false;
            });
          }
        });
      }
    });
  }

  /// Override this method to handle scroll state changes
  void onScrollStateChanged(bool isScrolling) {
    // Override in subclasses if needed
  }
}

/// Widget that automatically optimizes rebuilds
class OptimizedBuilder extends StatefulWidget {
  final Widget Function(BuildContext context) builder;
  final bool Function()? shouldRebuild;
  final Duration rebuildDelay;

  const OptimizedBuilder({
    super.key,
    required this.builder,
    this.shouldRebuild,
    this.rebuildDelay = const Duration(milliseconds: 16), // ~60fps
  });

  @override
  State<OptimizedBuilder> createState() => _OptimizedBuilderState();
}

class _OptimizedBuilderState extends State<OptimizedBuilder> with PerformanceMixin {
  Widget? _cachedWidget;
  bool _needsRebuild = true;

  @override
  Widget build(BuildContext context) {
    if (_needsRebuild || _cachedWidget == null) {
      _cachedWidget = widget.builder(context);
      _needsRebuild = false;
    }
    
    return _cachedWidget!;
  }

  void _scheduleRebuild() {
    if (widget.shouldRebuild?.call() ?? true) {
      debouncedSetState(() {
        _needsRebuild = true;
      }, delay: widget.rebuildDelay);
    }
  }

  @override
  void didUpdateWidget(OptimizedBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);
    _scheduleRebuild();
  }
}

/// Widget that only rebuilds when specific values change
class SelectiveBuilder<T> extends StatefulWidget {
  final T value;
  final Widget Function(BuildContext context, T value) builder;
  final bool Function(T previous, T current)? shouldRebuild;

  const SelectiveBuilder({
    super.key,
    required this.value,
    required this.builder,
    this.shouldRebuild,
  });

  @override
  State<SelectiveBuilder<T>> createState() => _SelectiveBuilderState<T>();
}

class _SelectiveBuilderState<T> extends State<SelectiveBuilder<T>> {
  T? _previousValue;
  Widget? _cachedWidget;

  @override
  Widget build(BuildContext context) {
    final shouldRebuild = widget.shouldRebuild?.call(_previousValue as T, widget.value) ??
        (_previousValue != widget.value);

    if (shouldRebuild || _cachedWidget == null) {
      _cachedWidget = widget.builder(context, widget.value);
      _previousValue = widget.value;
    }

    return _cachedWidget!;
  }
}

/// Widget that provides lazy loading functionality
class LazyWidget extends StatefulWidget {
  final Widget Function(BuildContext context) builder;
  final Widget? placeholder;
  final double visibilityThreshold;

  const LazyWidget({
    super.key,
    required this.builder,
    this.placeholder,
    this.visibilityThreshold = 0.1,
  });

  @override
  State<LazyWidget> createState() => _LazyWidgetState();
}

class _LazyWidgetState extends State<LazyWidget> {
  bool _hasBeenVisible = false;
  Widget? _builtWidget;

  @override
  Widget build(BuildContext context) {
    if (!_hasBeenVisible) {
      return LayoutBuilder(
        builder: (context, constraints) {
          // Simple visibility check - in a real app you might want more sophisticated detection
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && !_hasBeenVisible) {
              setState(() {
                _hasBeenVisible = true;
              });
            }
          });
          
          return widget.placeholder ?? const SizedBox.shrink();
        },
      );
    }

    _builtWidget ??= widget.builder(context);
    return _builtWidget!;
  }
}

/// Extension to add performance helpers to StatefulWidget
extension PerformanceExtensions on State {
  /// Safely call setState only if widget is mounted
  void safeSetState(VoidCallback fn) {
    if (mounted) {
      setState(fn);
    }
  }

  /// Debounced setState
  void debouncedSetState(
    VoidCallback fn, {
    Duration delay = const Duration(milliseconds: 100),
  }) {
    Future.delayed(delay, () {
      safeSetState(fn);
    });
  }
}

/// Performance monitoring widget for development
class PerformanceMonitor extends StatefulWidget {
  final Widget child;
  final String? name;
  final bool enabled;

  const PerformanceMonitor({
    super.key,
    required this.child,
    this.name,
    this.enabled = kDebugMode,
  });

  @override
  State<PerformanceMonitor> createState() => _PerformanceMonitorState();
}

class _PerformanceMonitorState extends State<PerformanceMonitor> {
  int _buildCount = 0;
  DateTime? _lastBuildTime;

  @override
  Widget build(BuildContext context) {
    if (widget.enabled) {
      _buildCount++;
      final now = DateTime.now();
      
      if (_lastBuildTime != null) {
        final timeSinceLastBuild = now.difference(_lastBuildTime!);
        if (timeSinceLastBuild.inMilliseconds < 16) { // Less than 60fps
          debugPrint('Performance Warning: ${widget.name ?? 'Widget'} rebuilt too frequently');
        }
      }
      
      _lastBuildTime = now;
      
      if (_buildCount % 10 == 0) {
        debugPrint('Performance Info: ${widget.name ?? 'Widget'} build count: $_buildCount');
      }
    }

    return widget.child;
  }
}