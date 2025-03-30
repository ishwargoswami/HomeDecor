import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'grid_loader.dart';

class TrendingLoader extends StatefulWidget {
  final Color primaryColor;
  final Color backgroundColor;
  final double size;

  const TrendingLoader({
    Key? key,
    this.primaryColor = Colors.white,
    this.backgroundColor = Colors.transparent,
    this.size = 200,
  }) : super(key: key);

  @override
  _TrendingLoaderState createState() => _TrendingLoaderState();
}

class _TrendingLoaderState extends State<TrendingLoader> with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;
  
  @override
  void initState() {
    super.initState();
    
    _rotationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 10),
    )..repeat();
  }
  
  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.size,
      height: widget.size,
      color: widget.backgroundColor,
      child: Stack(
        children: [
          // Rotating decorative ring
          AnimatedBuilder(
            animation: _rotationController,
            builder: (context, child) {
              return Transform.rotate(
                angle: _rotationController.value * 2 * math.pi,
                child: Container(
                  width: widget.size,
                  height: widget.size,
                  child: CustomPaint(
                    painter: CircleSegmentsPainter(
                      color: widget.primaryColor,
                      segments: 8,
                    ),
                  ),
                ),
              );
            },
          ),
          
          // Central grid animation
          Center(
            child: GridLoader(
              color: widget.primaryColor,
              gridSize: 4,
              size: widget.size * 0.6,
            ),
          ),
          
          // Decorative elements
          Positioned(
            top: 10,
            left: 10,
            child: _buildDecorativeElement(1.0),
          ),
          Positioned(
            bottom: 10,
            right: 10,
            child: _buildDecorativeElement(0.8),
          ),
          Positioned(
            top: 10,
            right: 10,
            child: _buildDecorativeElement(0.7),
          ),
          Positioned(
            bottom: 10,
            left: 10,
            child: _buildDecorativeElement(0.9),
          ),
          
          // Text indicator
          Positioned(
            bottom: 5,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                "Loading...",
                style: TextStyle(
                  color: widget.primaryColor,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
  
  Widget _buildDecorativeElement(double opacity) {
    return AnimatedBuilder(
      animation: _rotationController,
      builder: (context, child) {
        return Transform.rotate(
          angle: _rotationController.value * math.pi * opacity,
          child: Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: widget.primaryColor.withOpacity(opacity * 0.3),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Icon(
              Icons.star,
              color: widget.primaryColor.withOpacity(opacity),
              size: 15,
            ),
          ),
        );
      },
    );
  }
}

class CircleSegmentsPainter extends CustomPainter {
  final Color color;
  final int segments;
  
  CircleSegmentsPainter({
    required this.color,
    this.segments = 8,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    final outerRadius = radius * 0.98;
    final innerRadius = radius * 0.85;
    
    final segmentAngle = 2 * math.pi / segments;
    
    for (int i = 0; i < segments; i++) {
      // Skip every other segment for a dotted appearance
      if (i % 2 == 0) continue;
      
      final startAngle = i * segmentAngle;
      final endAngle = startAngle + segmentAngle;
      
      final path = Path()
        ..moveTo(
          center.dx + innerRadius * math.cos(startAngle),
          center.dy + innerRadius * math.sin(startAngle),
        )
        ..lineTo(
          center.dx + outerRadius * math.cos(startAngle),
          center.dy + outerRadius * math.sin(startAngle),
        )
        ..arcTo(
          Rect.fromCircle(center: center, radius: outerRadius),
          startAngle,
          segmentAngle,
          false,
        )
        ..lineTo(
          center.dx + innerRadius * math.cos(endAngle),
          center.dy + innerRadius * math.sin(endAngle),
        )
        ..arcTo(
          Rect.fromCircle(center: center, radius: innerRadius),
          endAngle,
          -segmentAngle,
          false,
        )
        ..close();
      
      final paint = Paint()
        ..color = color.withOpacity(0.2)
        ..style = PaintingStyle.fill;
      
      canvas.drawPath(path, paint);
    }
    
    // Draw small circles at equal intervals
    final dotRadius = radius * 0.02;
    final dotCount = segments * 2;
    final dotPaint = Paint()
      ..color = color.withOpacity(0.6)
      ..style = PaintingStyle.fill;
    
    for (int i = 0; i < dotCount; i++) {
      final angle = i * math.pi / dotCount;
      final dotCenter = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );
      
      canvas.drawCircle(dotCenter, dotRadius, dotPaint);
    }
  }
  
  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
} 