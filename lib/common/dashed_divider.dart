import 'package:flutter/material.dart';

class DashedLinePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashWidth; // Length of the solid line segment
  final double dashSpace; // Length of the gap

  DashedLinePainter({
    this.color = Colors.grey,
    this.strokeWidth = 1.0, // Thickness of the dash line
    this.dashWidth = 6.0,
    this.dashSpace = 4.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..strokeWidth = strokeWidth
          ..style =
              PaintingStyle
                  .stroke // Use stroke for lines
          ..strokeCap = StrokeCap.butt; // For sharp line ends

    final double endX = size.width;
    final double centerY = size.height / 2;

    // Start drawing from the left edge
    double currentX = 0;

    // Loop until we reach the end of the divider's width
    while (currentX < endX) {
      // 1. Define the start point of the dash
      final start = Offset(currentX, centerY);

      // 2. Define the end point of the dash
      // Ensure the dash doesn't extend beyond the total width (endX)
      double segmentEnd = currentX + dashWidth;
      final end = Offset(segmentEnd.clamp(0.0, endX), centerY);

      // 3. Draw the solid line segment (the dash)
      canvas.drawLine(start, end, paint);

      // 4. Move the starting point for the next dash
      // Skip the dash segment and the space
      currentX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // Only repaint if the properties have changed
    return oldDelegate is DashedLinePainter &&
        (oldDelegate.color != color ||
            oldDelegate.strokeWidth != strokeWidth ||
            oldDelegate.dashWidth != dashWidth ||
            oldDelegate.dashSpace != dashSpace);
  }
}

class DashedDivider extends StatelessWidget {
  final double height;
  final Color color;
  final double strokeWidth;
  final double dashWidth;
  final double dashSpace;

  const DashedDivider({
    super.key,
    this.height = 1.0, // Controls the height of the widget container
    this.color = Colors.grey,
    this.strokeWidth = 1.0,
    this.dashWidth = 6.0,
    this.dashSpace = 4.0,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      // The height is defined by the container size,
      // but the line itself is drawn using strokeWidth
      height: height,
      width: double.infinity, // Horizontal divider
      child: CustomPaint(
        painter: DashedLinePainter(
          color: color,
          strokeWidth: strokeWidth,
          dashWidth: dashWidth,
          dashSpace: dashSpace,
        ),
      ),
    );
  }
}
