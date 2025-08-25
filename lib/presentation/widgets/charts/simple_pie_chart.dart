import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Simple pie chart widget for displaying proportional data
class SimplePieChart extends StatelessWidget {
  final List<PieChartData> data;
  final String title;
  final double radius;

  const SimplePieChart({
    required this.data,
    required this.title,
    this.radius = 80,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return Column(
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: radius * 2,
            child: const Center(
              child: Text('데이터가 없습니다'),
            ),
          ),
        ],
      );
    }

    final theme = Theme.of(context);
    final total = data.fold<double>(0, (sum, item) => sum + item.value);

    return Column(
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            // Pie chart
            CustomPaint(
              size: Size(radius * 2, radius * 2),
              painter: PieChartPainter(
                data: data,
                total: total,
              ),
            ),
            const SizedBox(width: 24),
            // Legend
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: data.map((item) {
                  final percentage = total > 0 ? (item.value / total) * 100 : 0;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: item.color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${item.label} (${percentage.toStringAsFixed(1)}%)',
                            style: theme.textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Custom painter for pie chart
class PieChartPainter extends CustomPainter {
  final List<PieChartData> data;
  final double total;

  PieChartPainter({
    required this.data,
    required this.total,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty || total == 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;

    double startAngle = -math.pi / 2; // Start from top

    for (final item in data) {
      final sweepAngle = (item.value / total) * 2 * math.pi;
      
      final paint = Paint()
        ..color = item.color
        ..style = PaintingStyle.fill;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );

      startAngle += sweepAngle;
    }

    // Draw border
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawCircle(center, radius, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// Data class for pie chart items
class PieChartData {
  final String label;
  final double value;
  final Color color;

  const PieChartData({
    required this.label,
    required this.value,
    required this.color,
  });
}