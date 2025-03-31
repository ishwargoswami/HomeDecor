import 'package:flutter/material.dart';

class Category {
  final String name;
  final IconData? icon;
  final Color? color;
  final String imageUrl;
  final int itemCount;
  final String id;

  Category({
    required this.name,
    this.icon,
    this.color,
    this.imageUrl = '',
    this.itemCount = 0,
    String? id,
  }) : this.id = id ?? name.toLowerCase().replaceAll(' ', '_');

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'],
      name: map['name'] ?? '',
      icon: map['icon'] != null 
          ? IconData(int.parse(map['icon']), fontFamily: 'MaterialIcons') 
          : null,
      color: map['color'] != null 
          ? Color(int.parse(map['color'])) 
          : null,
      imageUrl: map['image'] ?? '',
      itemCount: map['items'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'icon': icon?.codePoint.toString(),
      'color': color?.value.toString(),
      'image': imageUrl,
      'items': itemCount,
    };
  }

  Category copyWith({
    String? name,
    IconData? icon,
    Color? color,
    String? imageUrl,
    int? itemCount,
    String? id,
  }) {
    return Category(
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      imageUrl: imageUrl ?? this.imageUrl,
      itemCount: itemCount ?? this.itemCount,
      id: id ?? this.id,
    );
  }
} 