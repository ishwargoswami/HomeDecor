import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Create a widget to render
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  
  // Draw icon with size 1024x1024 (high resolution for app icon)
  const size = 1024.0;
  
  // Background
  Paint backgroundPaint = Paint()
    ..color = Color(0xFFDAD7CD) // Light sage
    ..style = PaintingStyle.fill;
  canvas.drawRect(Rect.fromLTWH(0, 0, size, size), backgroundPaint);
  
  // Outer house shape
  Paint housePaint = Paint()
    ..color = Color(0xFF3A5A40) // Hunter green
    ..style = PaintingStyle.fill;
  
  // House base
  canvas.drawRect(Rect.fromLTWH(size * 0.2, size * 0.4, size * 0.6, size * 0.4), housePaint);
  
  // Roof
  Path roofPath = Path();
  roofPath.moveTo(size * 0.1, size * 0.4);
  roofPath.lineTo(size * 0.5, size * 0.1);
  roofPath.lineTo(size * 0.9, size * 0.4);
  roofPath.close();
  canvas.drawPath(roofPath, housePaint);
  
  // Door
  Paint doorPaint = Paint()
    ..color = Color(0xFFA3B18A) // Sage
    ..style = PaintingStyle.fill;
  canvas.drawRect(Rect.fromLTWH(size * 0.4, size * 0.55, size * 0.2, size * 0.25), doorPaint);
  
  // Windows
  Paint windowPaint = Paint()
    ..color = Color(0xFF588157) // Fern green
    ..style = PaintingStyle.fill;
  canvas.drawRect(Rect.fromLTWH(size * 0.25, size * 0.45, size * 0.1, size * 0.1), windowPaint);
  canvas.drawRect(Rect.fromLTWH(size * 0.65, size * 0.45, size * 0.1, size * 0.1), windowPaint);
  
  // Furniture element (simple chair)
  Paint furniturePaint = Paint()
    ..color = Color(0xFF344E41) // Brunswick green
    ..style = PaintingStyle.fill;
  
  // Chair back
  canvas.drawRect(Rect.fromLTWH(size * 0.75, size * 0.7, size * 0.1, size * 0.15), furniturePaint);
  // Chair seat
  canvas.drawRect(Rect.fromLTWH(size * 0.72, size * 0.85, size * 0.16, size * 0.05), furniturePaint);
  // Chair legs
  canvas.drawRect(Rect.fromLTWH(size * 0.72, size * 0.9, size * 0.03, size * 0.05), furniturePaint);
  canvas.drawRect(Rect.fromLTWH(size * 0.85, size * 0.9, size * 0.03, size * 0.05), furniturePaint);
  
  // Extract image from canvas
  final picture = recorder.endRecording();
  final img = await picture.toImage(size.toInt(), size.toInt());
  final pngBytes = await img.toByteData(format: ui.ImageByteFormat.png);
  
  if (pngBytes != null) {
    // Get application documents directory
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/home_decor_icon.png';
    
    // Save the image
    final file = File(filePath);
    await file.writeAsBytes(pngBytes.buffer.asUint8List());
    
    print('Icon generated at: $filePath');
  } else {
    print('Failed to generate icon');
  }
  
  exit(0);
} 