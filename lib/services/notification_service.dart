import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_foodybite/models/notification_model.dart';
import 'package:flutter_foodybite/models/user_settings_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Collection references
  CollectionReference get _notificationsCollection => _firestore.collection('notifications');
  CollectionReference get _userSettingsCollection => _firestore.collection('user_settings');
  
  // Get user notifications stream
  Stream<List<NotificationModel>> getUserNotifications(String userId) {
    return _notificationsCollection
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return NotificationModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
          }).toList();
        });
  }
  
  // Create notification
  Future<String> createNotification(NotificationModel notification) async {
    try {
      // Check user notification settings before creating
      UserSettingsModel? settings = await getUserSettings(notification.userId);
      
      if (settings != null && !settings.pushNotificationsEnabled) {
        return 'Notifications disabled';
      }
      
      DocumentReference docRef = await _notificationsCollection.add(notification.toMap());
      return docRef.id;
    } catch (e) {
      print('Error creating notification: $e');
      throw e;
    }
  }
  
  // Mark notification as read
  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await _notificationsCollection.doc(notificationId).update({
        'isRead': true
      });
    } catch (e) {
      print('Error marking notification as read: $e');
      throw e;
    }
  }
  
  // Delete notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _notificationsCollection.doc(notificationId).delete();
    } catch (e) {
      print('Error deleting notification: $e');
      throw e;
    }
  }
  
  // Get notification settings
  Future<UserSettingsModel?> getUserSettings(String userId) async {
    try {
      DocumentSnapshot doc = await _userSettingsCollection.doc(userId).get();
      
      if (!doc.exists) {
        // Create default settings if they don't exist
        UserSettingsModel defaultSettings = UserSettingsModel(userId: userId);
        await _userSettingsCollection.doc(userId).set(defaultSettings.toMap());
        return defaultSettings;
      }
      
      return UserSettingsModel.fromMap(doc.data() as Map<String, dynamic>);
    } catch (e) {
      print('Error getting user settings: $e');
      throw e;
    }
  }
  
  // Update notification settings
  Future<void> updateNotificationSettings(UserSettingsModel settings) async {
    try {
      await _userSettingsCollection.doc(settings.userId).update({
        'pushNotificationsEnabled': settings.pushNotificationsEnabled,
        'emailNotificationsEnabled': settings.emailNotificationsEnabled,
      });
      
      // Update local settings in SharedPreferences for quick access
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('pushNotificationsEnabled', settings.pushNotificationsEnabled);
      await prefs.setBool('emailNotificationsEnabled', settings.emailNotificationsEnabled);
    } catch (e) {
      print('Error updating notification settings: $e');
      throw e;
    }
  }
  
  // Clear all notifications for a user
  Future<void> clearAllNotifications(String userId) async {
    try {
      // Get all notifications for the user
      QuerySnapshot snapshot = await _notificationsCollection
          .where('userId', isEqualTo: userId)
          .get();
      
      // Delete each notification
      for (var doc in snapshot.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      print('Error clearing notifications: $e');
      throw e;
    }
  }
} 