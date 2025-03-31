import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String? id;
  final String userId;
  final String title;
  final String message;
  final bool isRead;
  final DateTime createdAt;
  final String? imageUrl;
  final String? actionLink;
  
  NotificationModel({
    this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.isRead,
    required this.createdAt,
    this.imageUrl,
    this.actionLink,
  });
  
  factory NotificationModel.fromMap(Map<String, dynamic> data, String documentId) {
    return NotificationModel(
      id: documentId,
      userId: data['userId'] ?? '',
      title: data['title'] ?? '',
      message: data['message'] ?? '',
      isRead: data['isRead'] ?? false,
      createdAt: data['createdAt'] != null 
          ? (data['createdAt'] as Timestamp).toDate() 
          : DateTime.now(),
      imageUrl: data['imageUrl'],
      actionLink: data['actionLink'],
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'message': message,
      'isRead': isRead,
      'createdAt': createdAt,
      'imageUrl': imageUrl,
      'actionLink': actionLink,
    };
  }
  
  NotificationModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? message,
    bool? isRead,
    DateTime? createdAt,
    String? imageUrl,
    String? actionLink,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      message: message ?? this.message,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      imageUrl: imageUrl ?? this.imageUrl,
      actionLink: actionLink ?? this.actionLink,
    );
  }
  
  NotificationModel markAsRead() {
    return copyWith(isRead: true);
  }
} 