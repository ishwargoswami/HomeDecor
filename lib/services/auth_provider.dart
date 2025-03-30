import 'package:flutter/material.dart';
import 'package:flutter_foodybite/models/user_model.dart';
import 'package:flutter_foodybite/services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  UserModel? _user;
  bool _isLoading = false;
  String _error = '';

  // Getters
  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String get error => _error;
  Stream<UserModel?> get userStream => _authService.user;

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    return await _authService.isUserLoggedIn();
  }

  // Sign in with email and password
  Future<bool> signInWithEmail(String email, String password) async {
    _setLoading(true);
    _clearError();
    
    try {
      UserModel? result = await _authService.signInWithEmailAndPassword(email, password);
      _user = result;
      _setLoading(false);
      return result != null;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // Register with email and password
  Future<bool> registerWithEmail(String email, String password, String name) async {
    _setLoading(true);
    _clearError();
    
    try {
      UserModel? result = await _authService.registerWithEmailAndPassword(email, password, name);
      _user = result;
      _setLoading(false);
      return result != null;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // Sign in with Google
  Future<bool> signInWithGoogle() async {
    _setLoading(true);
    _clearError();
    
    try {
      UserModel? result = await _authService.signInWithGoogle();
      _user = result;
      _setLoading(false);
      return result != null;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // Reset password
  Future<bool> resetPassword(String email) async {
    _setLoading(true);
    _clearError();
    
    try {
      await _authService.resetPassword(email);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // Sign out
  Future<void> signOut() async {
    _setLoading(true);
    await _authService.signOut();
    _user = null;
    _setLoading(false);
  }

  // Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Set error
  void _setError(String error) {
    // Format Firebase error messages to be more user-friendly
    if (error.contains('user-not-found')) {
      _error = 'No user found with this email address.';
    } else if (error.contains('wrong-password')) {
      _error = 'Incorrect password. Please try again.';
    } else if (error.contains('email-already-in-use')) {
      _error = 'This email is already registered. Try logging in instead.';
    } else if (error.contains('weak-password')) {
      _error = 'Password is too weak. Use a stronger password.';
    } else if (error.contains('invalid-email')) {
      _error = 'The email address is invalid.';
    } else if (error.contains('network-request-failed')) {
      _error = 'Network error. Check your internet connection.';
    } else if (error.contains('too-many-requests')) {
      _error = 'Too many failed login attempts. Try again later.';
    } else if (error.contains('Google Sign In canceled')) {
      _error = 'Google Sign In was canceled.';
    } else {
      // Keep only the relevant part of the error message
      final RegExp regExp = RegExp(r'\[(.*?)\] (.*)');
      final match = regExp.firstMatch(error);
      if (match != null && match.groupCount >= 2) {
        _error = match.group(2) ?? error;
      } else {
        _error = error;
      }
    }
    
    notifyListeners();
  }

  // Clear error
  void _clearError() {
    _error = '';
    notifyListeners();
  }
} 