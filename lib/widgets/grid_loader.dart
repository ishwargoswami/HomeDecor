import 'package:flutter/material.dart';
import 'dart:math' as math;

class GridLoader extends StatefulWidget {
  final Color color;
  final int gridSize;
  final double size;

  const GridLoader({
    Key? key, 
    this.color = Colors.white,
    this.gridSize = 3,
    this.size = 80,
  }) : super(key: key);

  @override
  _GridLoaderState createState() => _GridLoaderState();
}

class _GridLoaderState extends State<GridLoader> with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    
    final int totalCells = widget.gridSize * widget.gridSize;
    _controllers = List.generate(
      totalCells,
      (index) => AnimationController(
        duration: Duration(milliseconds: 600),
        vsync: this,
      ),
    );
    
    _animations = _controllers.map((controller) {
      return Tween<double>(begin: 0.3, end: 1.0).animate(
        CurvedAnimation(
          parent: controller,
          curve: Curves.easeInOut,
        ),
      );
    }).toList();
    
    // Start animations with a wave-like pattern
    for (int i = 0; i < widget.gridSize; i++) {
      for (int j = 0; j < widget.gridSize; j++) {
        final index = i * widget.gridSize + j;
        final delay = ((i + j) * 100) % 1200; // Wave effect delay
        
        Future.delayed(
          Duration(milliseconds: delay),
          () {
            if (mounted) {
              _controllers[index].repeat(reverse: true);
            }
          },
        );
      }
    }
  }
  
  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cellSize = widget.size / widget.gridSize;
    final items = <Widget>[];
    
    for (int i = 0; i < widget.gridSize; i++) {
      for (int j = 0; j < widget.gridSize; j++) {
        final index = i * widget.gridSize + j;
        
        // Get the distance from center for a radial effect
        final centerI = (widget.gridSize - 1) / 2;
        final centerJ = (widget.gridSize - 1) / 2;
        final distFromCenter = math.sqrt(math.pow(i - centerI, 2) + math.pow(j - centerJ, 2));
        final maxDist = math.sqrt(math.pow(centerI, 2) + math.pow(centerJ, 2));
        final distFactor = distFromCenter / maxDist; // 0 to 1
        
        items.add(
          Positioned(
            top: i * cellSize,
            left: j * cellSize,
            child: AnimatedBuilder(
              animation: _animations[index],
              builder: (context, child) {
                return Transform.scale(
                  scale: 0.85 + (_animations[index].value * 0.15), // Subtle scale effect
                  child: Container(
                    width: cellSize - 4,
                    height: cellSize - 4,
                    margin: EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: widget.color.withOpacity(
                        _animations[index].value * (1 - distFactor * 0.3)
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      }
    }

    return Container(
      width: widget.size,
      height: widget.size,
      child: Stack(
        children: items,
      ),
    );
  }
} 