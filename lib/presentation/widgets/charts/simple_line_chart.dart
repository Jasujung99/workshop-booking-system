import 'package:flutter/material.dart';

/// Simple line chart widget for displaying trend data
class SimpleLineChart extends StatelessWidget {
  final List<ChartPoint> points;
  final String title;
  final Color? lineColor;
  final double maxHeight;

  const SimpleLineChart({
    required this.points,
    required this.title,
    this.lineColor,
    this.maxHeight = 200,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) {
      return SizedBox(
        height: maxHeight,
        child: const Center(
          child: Text('데이터가 없습니다'),
        ),
      );
    }

    final theme = Theme.of(context);
    final effectiveLineColor = lineColor ?? theme.colorScheme.primary;

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
          child: CustomPaint(
            painter: LineChartPainter(
              points: points,
              lineColor: effectiveLineColor,
              textStyle: theme.textTheme.bodySmall!,
            ),
            child: Container(),
          ),
        ),
      ],
    );
  }
}

/// Custom painter for line chart
class LineChartPainter extends CustomPainter {
  final List<ChartPoint> points;
  final Color lineColor;
  final TextStyle textStyle;

  LineChartPainter({
    required this.points,
    required this.lineColor,
    required this.textStyle,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final pointPaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.fill;

    // Calculate bounds
    final maxValue = points.map((p) => p.value).reduce((a, b) => a > b ? a : b);
    final minValue = points.map((p) => p.value).reduce((a, b) => a < b ? a : b);
    final valueRange = maxValue - minValue;

    // Draw chart area
    final chartRect = Rect.fromLTWH(40, 20, size.width - 80, size.height - 60);
    
    // Draw grid lines
    final gridPaint = Paint()
      ..color = Colors.grey.withOpacity(0.3)
      ..strokeWidth = 1;

    // Horizontal grid lines
    for (int i = 0; i <= 4; i++) {
      final y = chartRect.top + (chartRect.height / 4) * i;
      canvas.drawLine(
        Offset(chartRect.left, y),
        Offset(chartRect.right, y),
        gridPaint,
      );
    }

    // Draw line
    final path = Path();
    final chartPoints = <Offset>[];

    for (int i = 0; i < points.length; i++) {
      final x = chartRect.left + (chartRect.width / (points.length - 1)) * i;
      final normalizedValue = valueRange > 0 
          ? (points[i].value - minValue) / valueRange
          : 0.5;
      final y = chartRect.bottom - (chartRect.height * normalizedValue);
      
      final point = Offset(x, y);
      chartPoints.add(point);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    // Draw the line
    canvas.drawPath(path, paint);

    // Draw points
    for (int i = 0; i < chartPoints.length; i++) {
      canvas.drawCircle(chartPoints[i], 4, pointPaint);
      
      // Draw labels
      final textPainter = TextPainter(
        text: TextSpan(
          text: points[i].label,
          style: textStyle,
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      
      final labelX = chartPoints[i].dx - textPainter.width / 2;
      final labelY = chartRect.bottom + 10;
      textPainter.paint(canvas, Offset(labelX, labelY));

      // Draw value labels
      final valuePainter = TextPainter(
        text: TextSpan(
          text: _formatValue(points[i].value),
          style: textStyle,
        ),
        textDirection: TextDirection.ltr,
      );
      valuePainter.layout();
      
      final valueX = chartPoints[i].dx - valuePainter.width / 2;
      final valueY = chartPoints[i].dy - 20;
      valuePainter.paint(canvas, Offset(valueX, valueY));
    }

    // Draw Y-axis labels
    for (int i = 0; i <= 4; i++) {
      final value = minValue + (valueRange / 4) * (4 - i);
      final y = chartRect.top + (chartRect.height / 4) * i;
      
      final labelPainter = TextPainter(
        text: TextSpan(
          text: _formatValue(value),
          style: textStyle,
        ),
        textDirection: TextDirection.ltr,
      );
      labelPainter.layout();
      labelPainter.paint(canvas, Offset(5, y - labelPainter.height / 2));
    }
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

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// Data class for chart points
class ChartPoint {
  final String label;
  final double value;

  const ChartPoint({
    required this.label,
    required this.value,
  });
}