import 'package:flutter/material.dart';

/// Simple bar chart widget for displaying data
class SimpleBarChart extends StatelessWidget {
  final List<ChartData> data;
  final String title;
  final Color? barColor;
  final double maxHeight;

  const SimpleBarChart({
    required this.data,
    required this.title,
    this.barColor,
    this.maxHeight = 200,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return SizedBox(
        height: maxHeight,
        child: const Center(
          child: Text('데이터가 없습니다'),
        ),
      );
    }

    final maxValue = data.map((e) => e.value).reduce((a, b) => a > b ? a : b);
    final theme = Theme.of(context);
    final effectiveBarColor = barColor ?? theme.colorScheme.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: maxHeight,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: data.map((item) {
              final barHeight = maxValue > 0 
                  ? (item.value / maxValue) * (maxHeight - 40)
                  : 0.0;
              
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Value label
                      Text(
                        _formatValue(item.value),
                        style: theme.textTheme.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      // Bar
                      Container(
                        height: barHeight,
                        decoration: BoxDecoration(
                          color: effectiveBarColor,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Label
                      Text(
                        item.label,
                        style: theme.textTheme.bodySmall,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  String _formatValue(double value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    } else {
      return value.toStringAsFixed(0);
    }
  }
}

/// Data class for chart items
class ChartData {
  final String label;
  final double value;
  final Color? color;

  const ChartData({
    required this.label,
    required this.value,
    this.color,
  });
}