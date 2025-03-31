import 'package:cloud_firestore/cloud_firestore.dart';

class BudgetModel {
  final String? id;
  final String userId;
  final String title;
  final double totalAmount;
  final Map<String, double> categories;
  final DateTime createdAt;
  
  BudgetModel({
    this.id,
    required this.userId,
    required this.title,
    required this.totalAmount,
    required this.categories,
    required this.createdAt,
  });
  
  factory BudgetModel.fromMap(Map<String, dynamic> data, String documentId) {
    Map<String, double> categoriesMap = {};
    
    // Convert categories map from Firestore to proper types
    if (data['categories'] != null) {
      (data['categories'] as Map<String, dynamic>).forEach((key, value) {
        categoriesMap[key] = (value as num).toDouble();
      });
    }
    
    return BudgetModel(
      id: documentId,
      userId: data['userId'] ?? '',
      title: data['title'] ?? '',
      totalAmount: (data['totalAmount'] ?? 0.0).toDouble(),
      categories: categoriesMap,
      createdAt: data['createdAt'] != null 
          ? (data['createdAt'] as Timestamp).toDate() 
          : DateTime.now(),
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'totalAmount': totalAmount,
      'categories': categories,
      'createdAt': createdAt,
    };
  }
  
  BudgetModel copyWith({
    String? id,
    String? userId,
    String? title,
    double? totalAmount,
    Map<String, double>? categories,
    DateTime? createdAt,
  }) {
    return BudgetModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      totalAmount: totalAmount ?? this.totalAmount,
      categories: categories ?? this.categories,
      createdAt: createdAt ?? this.createdAt,
    );
  }
} 