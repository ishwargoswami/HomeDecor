import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:decor_home/models/user_model.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    clientId: '16247673730-n0b42cctdqti1adfgph33dinbh4mkkbk.apps.googleusercontent.com',
  );

  // Create user object based on FirebaseUser
  UserModel? _userFromFirebaseUser(User? user) {
    return user != null
        ? UserModel(
            uid: user.uid,
            email: user.email,
            name: user.displayName,
            photoUrl: user.photoURL,
          )
        : null;
  }

  // Auth change user stream
  Stream<UserModel?> get user {
    return _auth.authStateChanges().map(_userFromFirebaseUser);
  }

  // Sign in with email & password
  Future<UserModel?> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      User? user = result.user;
      
      // Save user session
      await _saveUserSession(true);
      
      return _userFromFirebaseUser(user);
    } catch (e) {
      print('Error in signInWithEmailAndPassword: ${e.toString()}');
      throw e;
    }
  }

  // Register with email & password
  Future<UserModel?> registerWithEmailAndPassword(
      String email, String password, String name) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      User? user = result.user;

      // Update the username
      await user?.updateDisplayName(name);
      
      // Reload the user to ensure updated profile data is available
      await user?.reload();
      // Get the fresh user data
      user = _auth.currentUser;
      
      // Create a new document for the user with uid
      await _firestore.collection('users').doc(user?.uid).set({
        'uid': user?.uid,
        'email': email,
        'name': name,
        'photoUrl': '',
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Save user session
      await _saveUserSession(true);
      
      return _userFromFirebaseUser(user);
    } catch (e) {
      print('Error in registerWithEmailAndPassword: ${e.toString()}');
      throw e;
    }
  }

  // Sign in with Google
  Future<UserModel?> signInWithGoogle() async {
    try {
      // Handle web platform differently
      if (kIsWeb) {
        // Create a new provider
        GoogleAuthProvider googleProvider = GoogleAuthProvider();
        googleProvider.addScope('email');
        googleProvider.addScope('profile');
        
        // Sign in using a popup
        final UserCredential result = await _auth.signInWithPopup(googleProvider);
        final User? user = result.user;

        await _handleSignedInUser(user);
        return _userFromFirebaseUser(user);
      } else {
        // For Android/iOS flow
        // Show loading indicator or disable buttons before starting sign-in
        try {
          print("Starting Google Sign In process...");
          // Begin interactive sign-in process
          final GoogleSignInAccount? googleSignInAccount = await _googleSignIn.signIn();
          
          if (googleSignInAccount == null) {
            print("Google Sign In was canceled by user");
            throw Exception("Google Sign In was canceled by user");
          }
          
          print("Google Sign In success, getting credentials...");
          // Show loading indicator during authentication
          final GoogleSignInAuthentication googleSignInAuthentication =
              await googleSignInAccount.authentication;

          final AuthCredential credential = GoogleAuthProvider.credential(
            accessToken: googleSignInAuthentication.accessToken,
            idToken: googleSignInAuthentication.idToken,
          );

          try {
            print("Signing in to Firebase with Google credential...");
            final UserCredential result = await _auth.signInWithCredential(credential);
            final User? user = result.user;

            print("Firebase sign in successful, handling user data...");
            await _handleSignedInUser(user);
            return _userFromFirebaseUser(user);
          } catch (credentialError) {
            print('Credential error: $credentialError');
            throw Exception("Failed to sign in with Google. Please try again.");
          }
        } catch (error) {
          print('Google sign in error: $error');
          if (error.toString().contains('network_error')) {
            throw Exception("Network error. Check your connection.");
          } else if (error.toString().contains('canceled')) {
            throw Exception("Google Sign In was canceled.");
          } else {
            throw error;
          }
        }
      }
    } catch (e) {
      print('Error in signInWithGoogle: ${e.toString()}');
      throw e;
    }
  }

  // Helper method to handle signed in user
  Future<void> _handleSignedInUser(User? user) async {
    if (user != null) {
      // Check if the user already exists in Firestore
      DocumentSnapshot doc = await _firestore.collection('users').doc(user.uid).get();
      
      // If the user doesn't exist, create a new document
      if (!doc.exists) {
        await _firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'email': user.email,
          'name': user.displayName,
          'photoUrl': user.photoURL,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      // Save user session
      await _saveUserSession(true);
    }
  }

  // Save user session
  Future<void> _saveUserSession(bool isLoggedIn) async {
    print("Saving user session. isLoggedIn: $isLoggedIn");
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', isLoggedIn);
    
    // Also save user ID for persistence
    if (isLoggedIn && _auth.currentUser != null) {
      await prefs.setString('userId', _auth.currentUser!.uid);
      print("Saved user ID: ${_auth.currentUser!.uid}");
    } else if (!isLoggedIn) {
      await prefs.remove('userId');
      print("Removed user ID from preferences");
    }
  }

  // Check if user is logged in
  Future<bool> isUserLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    final userId = prefs.getString('userId');
    
    // Double check with Firebase auth
    final currentUser = _auth.currentUser;
    
    print("SharedPrefs logged in: $isLoggedIn");
    print("SharedPrefs userId: $userId");
    print("Firebase currentUser: ${currentUser?.uid}");
    
    // Only consider logged in if both SharedPreferences and Firebase Auth agree
    if (isLoggedIn && currentUser != null) {
      return true;
    } else if (isLoggedIn && currentUser == null && userId != null) {
      // Inconsistent state - SharedPrefs says logged in but Firebase doesn't have user
      // This can happen if the Firebase auth state was cleared but SharedPrefs wasn't
      await _saveUserSession(false);
      return false;
    }
    
    return false;
  }

  // Sign out
  Future<void> signOut() async {
    try {
      print("Starting user sign out process...");
      
      // Step 1: Clear all shared preferences first
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      
      // Step 2: Explicitly set logged out state
      await prefs.setBool('isLoggedIn', false);
      await prefs.remove('userId');
      
      // Step 3: Try to sign out from Google if applicable
      try {
        await _googleSignIn.signOut();
        print("Successfully signed out from Google");
      } catch (e) {
        // Non-critical, just log it
        print("Google sign out error (non-critical): $e");
      }
      
      // Step 4: Sign out from Firebase Auth
      await _auth.signOut();
      
      print("User signed out successfully");
    } catch (e) {
      print("Error during sign out: $e");
      
      // Even if sign out fails, make sure local storage is cleared
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();
        await prefs.setBool('isLoggedIn', false);
        await prefs.remove('userId');
      } catch (e2) {
        print("Error clearing preferences: $e2");
      }
      
      // Rethrow the error for upstream handling
      throw e;
    }
  }

  // Password reset
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      print(e.toString());
      throw e;
    }
  }

  // Update user profile image
  Future<void> updateUserProfileImage(String uid, String imageUrl) async {
    try {
      // Update Firestore document
      await _firestore.collection('users').doc(uid).update({
        'photoUrl': imageUrl,
      });
      
      // If this is the current user, update auth profile
      User? currentUser = _auth.currentUser;
      if (currentUser != null && currentUser.uid == uid) {
        await currentUser.updatePhotoURL(imageUrl);
      }
    } catch (e) {
      print('Error updating profile image: ${e.toString()}');
      throw e;
    }
  }

  // Update user name
  Future<void> updateUserName(String uid, String name) async {
    try {
      // Update Firestore document
      await _firestore.collection('users').doc(uid).update({
        'name': name,
      });
      
      // If this is the current user, update auth profile
      User? currentUser = _auth.currentUser;
      if (currentUser != null && currentUser.uid == uid) {
        await currentUser.updateDisplayName(name);
      }
    } catch (e) {
      print('Error updating user name: ${e.toString()}');
      throw e;
    }
  }

  // Reauthenticate user (required for sensitive operations like changing password)
  Future<void> reauthenticateUser(String email, String password) async {
    try {
      // Get current user
      final currentUser = _auth.currentUser;
      
      if (currentUser == null) {
        throw Exception('No user is currently logged in');
      }
      
      // Create credential
      final credential = EmailAuthProvider.credential(
        email: email,
        password: password,
      );
      
      // Reauthenticate
      await currentUser.reauthenticateWithCredential(credential);
      print('User reauthenticated successfully');
    } catch (e) {
      print('Reauthentication error: $e');
      if (e.toString().contains('wrong-password')) {
        throw Exception('Current password is incorrect');
      } else {
        throw Exception('Failed to reauthenticate: $e');
      }
    }
  }
  
  // Update password
  Future<void> updatePassword(String newPassword) async {
    try {
      final currentUser = _auth.currentUser;
      
      if (currentUser == null) {
        throw Exception('No user is currently logged in');
      }
      
      await currentUser.updatePassword(newPassword);
      print('Password updated successfully');
    } catch (e) {
      print('Password update error: $e');
      throw Exception('Failed to update password: $e');
    }
  }

  // Force refresh user data
  Future<void> refreshUserData(String uid) async {
    try {
      final docSnapshot = await _firestore.collection('users').doc(uid).get();
      if (docSnapshot.exists && docSnapshot.data() != null) {
        final userData = docSnapshot.data()!;
        // Update our user stream with the fresh data
        final user = UserModel(
          uid: uid,
          email: userData['email'],
          name: userData['name'],
          photoUrl: userData['photoUrl'],
        );
        
        // Force reload of the current user to update the authStateChanges stream
        if (_auth.currentUser != null && _auth.currentUser!.uid == uid) {
          await _auth.currentUser!.reload();
        }
      }
    } catch (e) {
      print('Error refreshing user data: ${e.toString()}');
      throw e;
    }
  }
} 
