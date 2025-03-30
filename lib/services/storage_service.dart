import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Get the current user ID
  String? get userId => _auth.currentUser?.uid;
  
  // Upload an image file and return the download URL
  Future<String?> uploadImage(File file, String folder) async {
    try {
      if (userId == null) {
        print('Cannot upload image: No user logged in');
        return null;
      }
      
      // Generate a unique filename
      final String fileName = '${Uuid().v4()}.jpg';
      
      // Create a reference to the file location
      final Reference storageRef = _storage.ref()
          .child('users')
          .child(userId!)
          .child(folder)
          .child(fileName);
      
      // Upload the file
      final UploadTask uploadTask = storageRef.putFile(
        file,
        SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {
            'userId': userId!,
            'uploadedAt': DateTime.now().toIso8601String(),
          },
        ),
      );
      
      // Get the download URL after upload completes
      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      
      print('Image uploaded: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }
  
  // Upload image as bytes (useful for web)
  Future<String?> uploadImageBytes(Uint8List bytes, String folder) async {
    try {
      if (userId == null) {
        print('Cannot upload image: No user logged in');
        return null;
      }
      
      // Generate a unique filename
      final String fileName = '${Uuid().v4()}.jpg';
      
      // Create a reference to the file location
      final Reference storageRef = _storage.ref()
          .child('users')
          .child(userId!)
          .child(folder)
          .child(fileName);
      
      // Upload the file
      final UploadTask uploadTask = storageRef.putData(
        bytes,
        SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {
            'userId': userId!,
            'uploadedAt': DateTime.now().toIso8601String(),
          },
        ),
      );
      
      // Get the download URL after upload completes
      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      
      print('Image uploaded: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      print('Error uploading image bytes: $e');
      return null;
    }
  }
  
  // Delete an image by URL
  Future<bool> deleteImage(String imageUrl) async {
    try {
      if (userId == null) {
        print('Cannot delete image: No user logged in');
        return false;
      }
      
      // Create a reference from the image URL
      final Reference storageRef = _storage.refFromURL(imageUrl);
      
      // Delete the file
      await storageRef.delete();
      
      print('Image deleted: $imageUrl');
      return true;
    } catch (e) {
      print('Error deleting image: $e');
      return false;
    }
  }
  
  // List all images in a folder
  Future<List<String>> listImages(String folder) async {
    try {
      if (userId == null) {
        print('Cannot list images: No user logged in');
        return [];
      }
      
      // Create a reference to the folder
      final Reference folderRef = _storage.ref()
          .child('users')
          .child(userId!)
          .child(folder);
      
      // List all items in the folder
      final ListResult result = await folderRef.listAll();
      
      // Get download URLs for all items
      List<String> downloadUrls = [];
      for (Reference ref in result.items) {
        final String url = await ref.getDownloadURL();
        downloadUrls.add(url);
      }
      
      return downloadUrls;
    } catch (e) {
      print('Error listing images: $e');
      return [];
    }
  }
  
  // Get metadata for an image
  Future<Map<String, dynamic>?> getImageMetadata(String imageUrl) async {
    try {
      // Create a reference from the image URL
      final Reference storageRef = _storage.refFromURL(imageUrl);
      
      // Get metadata
      final FullMetadata metadata = await storageRef.getMetadata();
      
      return {
        'name': metadata.name,
        'size': metadata.size,
        'contentType': metadata.contentType,
        'createdTime': metadata.timeCreated?.toIso8601String(),
        'updatedTime': metadata.updated?.toIso8601String(),
        'customMetadata': metadata.customMetadata,
      };
    } catch (e) {
      print('Error getting image metadata: $e');
      return null;
    }
  }
  
  // Update metadata for an image
  Future<bool> updateImageMetadata(String imageUrl, Map<String, String> metadata) async {
    try {
      // Create a reference from the image URL
      final Reference storageRef = _storage.refFromURL(imageUrl);
      
      // Update metadata
      await storageRef.updateMetadata(
        SettableMetadata(
          customMetadata: metadata,
        ),
      );
      
      print('Image metadata updated: $imageUrl');
      return true;
    } catch (e) {
      print('Error updating image metadata: $e');
      return false;
    }
  }
} 