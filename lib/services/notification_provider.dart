import 'package:flutter/material.dart';
import 'package:flutter_foodybite/models/notification_model.dart';
import 'package:flutter_foodybite/models/user_settings_model.dart';
import 'package:flutter_foodybite/services/notification_service.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationService _notificationService = NotificationService();
  
  List<NotificationModel> _notifications = [];
  UserSettingsModel? _userSettings;
  bool _isLoading = false;
  String _error = '';
  
  // Getters
  List<NotificationModel> get notifications => _notifications;
  UserSettingsModel? get userSettings => _userSettings;
  bool get isLoading => _isLoading;
  String get error => _error;
  bool get hasPushNotificationsEnabled => _userSettings?.pushNotificationsEnabled ?? true;
  bool get hasEmailNotificationsEnabled => _userSettings?.emailNotificationsEnabled ?? true;
  
  // Initialize user notifications stream
  Stream<List<NotificationModel>> getUserNotificationsStream(String userId) {
    return _notificationService.getUserNotifications(userId);
  }
  
  // Fetch user notifications
  Future<void> fetchUserNotifications(String userId) async {
    _setLoading(true);
    _clearError();
    
    try {
      _notificationService.getUserNotifications(userId).listen((notifications) {
        _notifications = notifications;
        _setLoading(false);
        notifyListeners();
      }, onError: (e) {
        _setError(e.toString());
        _setLoading(false);
      });
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }
  
  // Get user notification settings
  Future<void> fetchUserSettings(String userId) async {
    _setLoading(true);
    _clearError();
    
    try {
      _userSettings = await _notificationService.getUserSettings(userId);
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }
  
  // Toggle push notifications
  Future<bool> togglePushNotifications(String userId, bool enabled) async {
    _setLoading(true);
    _clearError();
    
    try {
      if (_userSettings == null) {
        await fetchUserSettings(userId);
      }
      
      if (_userSettings != null) {
        UserSettingsModel updatedSettings = _userSettings!.copyWith(
          pushNotificationsEnabled: enabled,
        );
        
        await _notificationService.updateNotificationSettings(updatedSettings);
        _userSettings = updatedSettings;
        
        _setLoading(false);
        return true;
      } else {
        _setError('User settings not found');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }
  
  // Toggle email notifications
  Future<bool> toggleEmailNotifications(String userId, bool enabled) async {
    _setLoading(true);
    _clearError();
    
    try {
      if (_userSettings == null) {
        await fetchUserSettings(userId);
      }
      
      if (_userSettings != null) {
        UserSettingsModel updatedSettings = _userSettings!.copyWith(
          emailNotificationsEnabled: enabled,
        );
        
        await _notificationService.updateNotificationSettings(updatedSettings);
        _userSettings = updatedSettings;
        
        _setLoading(false);
        return true;
      } else {
        _setError('User settings not found');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }
  
  // Mark notification as read
  Future<bool> markNotificationAsRead(String notificationId) async {
    _setLoading(true);
    _clearError();
    
    try {
      await _notificationService.markNotificationAsRead(notificationId);
      
      // Update notification in the list
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        _notifications[index] = _notifications[index].markAsRead();
        notifyListeners();
      }
      
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }
  
  // Delete notification
  Future<bool> deleteNotification(String notificationId) async {
    _setLoading(true);
    _clearError();
    
    try {
      await _notificationService.deleteNotification(notificationId);
      
      // Remove notification from the list
      _notifications.removeWhere((n) => n.id == notificationId);
      notifyListeners();
      
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }
  
  // Clear all notifications
  Future<bool> clearAllNotifications(String userId) async {
    _setLoading(true);
    _clearError();
    
    try {
      await _notificationService.clearAllNotifications(userId);
      
      // Clear notifications list
      _notifications = [];
      notifyListeners();
      
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }
  
  // Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  // Set error
  void _setError(String error) {
    _error = error;
    notifyListeners();
  }
  
  // Clear error
  void _clearError() {
    _error = '';
    notifyListeners();
  }
} 