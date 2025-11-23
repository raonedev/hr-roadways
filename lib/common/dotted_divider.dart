import 'package:flutter/material.dart';

class DottedLinePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dotSpace;
  final double dotRadius;

  DottedLinePainter({
    this.color = Colors.grey,
    this.strokeWidth =
        1.0, // Used for the line thickness if drawing a line, but we use dotRadius for dots
    this.dotSpace = 4.0, // Space between dots
    this.dotRadius = 1.0, // Radius of each dot
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..strokeWidth =
              dotRadius *
              2 // Using dot diameter for clearer visualization if needed
          ..style = PaintingStyle.fill; // Use fill for circles/dots

    final double startX = 0;
    final double endX = size.width;
    final double centerY = size.height / 2;

    // Calculate the distance from one dot center to the next
    final double step = (dotRadius * 2) + dotSpace;

    // Start position (center of the first dot)
    double currentX = startX + dotRadius;

    // Loop until we reach the end of the divider's width
    while (currentX < endX) {
      // Draw a dot (circle)
      canvas.drawCircle(Offset(currentX, centerY), dotRadius, paint);

      // Move to the next dot's center
      currentX += step;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // Only repaint if the properties have changed
    return oldDelegate is DottedLinePainter &&
        (oldDelegate.color != color ||
            oldDelegate.strokeWidth != strokeWidth ||
            oldDelegate.dotSpace != dotSpace ||
            oldDelegate.dotRadius != dotRadius);
  }
}

class DottedDivider extends StatelessWidget {
  final double height;
  final Color color;
  final double dotRadius;
  final double dotSpace;

  const DottedDivider({
    super.key,
    this.height = 1.0, // Controls the height of the divider widget
    this.color = Colors.grey,
    this.dotRadius = 1.5,
    this.dotSpace = 4.0,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity, // Take up all available width
      child: CustomPaint(
        painter: DottedLinePainter(
          color: color,
          dotRadius: dotRadius,
          dotSpace: dotSpace,
        ),
      ),
    );
  }
}
