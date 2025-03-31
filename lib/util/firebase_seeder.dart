import 'package:cloud_firestore/cloud_firestore.dart';

/// Utility class to seed Firestore with sample data for development
class FirebaseSeeder {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  /// Seeds categories into Firestore
  static Future<void> seedCategories() async {
    try {
      final categoriesRef = _firestore.collection('categories');
      final snapshot = await categoriesRef.get();
      
      // Only seed if collection is empty
      if (snapshot.docs.isEmpty) {
        final batch = _firestore.batch();
        
        // Sample categories with enhanced data
        final categories = [
          {
            'name': 'Living Room',
            'icon': '59530', // Icons.weekend
            'image': 'https://images.pexels.com/photos/1571460/pexels-photo-1571460.jpeg?auto=compress&cs=tinysrgb&w=800',
            'color': '0xFFF8E8E0',
            'items': 42,
          },
          {
            'name': 'Bedroom',
            'icon': '58693', // Icons.bed
            'image': 'https://images.pexels.com/photos/1454806/pexels-photo-1454806.jpeg?auto=compress&cs=tinysrgb&w=800',
            'color': '0xFFE6F2FF',
            'items': 38,
          },
          {
            'name': 'Kitchen',
            'icon': '59828', // Icons.kitchen
            'image': 'https://images.pexels.com/photos/1080721/pexels-photo-1080721.jpeg?auto=compress&cs=tinysrgb&w=800',
            'color': '0xFFE0F2E9',
            'items': 27,
          },
          {
            'name': 'Bathroom',
            'icon': '58693', // Icons.bathtub
            'image': 'https://images.pexels.com/photos/6444254/pexels-photo-6444254.jpeg?auto=compress&cs=tinysrgb&w=800',
            'color': '0xFFF2E6FF',
            'items': 19,
          },
          {
            'name': 'Office',
            'icon': '58843', // Icons.computer
            'image': 'https://images.pexels.com/photos/1957477/pexels-photo-1957477.jpeg?auto=compress&cs=tinysrgb&w=800',
            'color': '0xFFFFE6E6',
            'items': 23,
          },
          {
            'name': 'Dining Room',
            'icon': '60364', // Icons.dinner_dining
            'image': 'https://images.pexels.com/photos/1080696/pexels-photo-1080696.jpeg?auto=compress&cs=tinysrgb&w=800',
            'color': '0xFFFFF3D9',
            'items': 15,
          },
          {
            'name': 'Outdoor',
            'icon': '59399', // Icons.deck
            'image': 'https://images.pexels.com/photos/1643383/pexels-photo-1643383.jpeg?auto=compress&cs=tinysrgb&w=800',
            'color': '0xFFE6E6FF',
            'items': 31,
          },
          {
            'name': 'Lighting',
            'icon': '60080', // Icons.lightbulb
            'image': 'https://images.pexels.com/photos/1123262/pexels-photo-1123262.jpeg?auto=compress&cs=tinysrgb&w=800',
            'color': '0xFFE0F8FF',
            'items': 24,
          },
        ];
        
        // Add categories to batch
        for (var category in categories) {
          final docRef = categoriesRef.doc(); // Auto-generate ID
          batch.set(docRef, {
            ...category,
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
        
        // Commit the batch
        await batch.commit();
        print('Categories seeded successfully!');
      } else {
        print('Categories collection already contains data, skipping seed.');
      }
    } catch (e) {
      print('Error seeding categories: $e');
    }
  }
  
  /// Seeds promotions into Firestore
  static Future<void> seedPromotions() async {
    try {
      final promotionsRef = _firestore.collection('promotions');
      final snapshot = await promotionsRef.get();
      
      // Only seed if collection is empty
      if (snapshot.docs.isEmpty) {
        final batch = _firestore.batch();
        
        // Sample promotions with enhanced data
        final promotions = [
          {
            'title': '30% Off On All Masks',
            'subtitle': 'Shop Now',
            'color': '0xFFFFF3D9',
            'image': 'https://images.pexels.com/photos/6069552/pexels-photo-6069552.jpeg?auto=compress&cs=tinysrgb&w=800',
            'url': '/trending',
            'order': 1,
          },
          {
            'title': 'New Arrivals',
            'subtitle': 'Check Out',
            'color': '0xFFE6F2FF',
            'image': 'https://images.pexels.com/photos/1350789/pexels-photo-1350789.jpeg?auto=compress&cs=tinysrgb&w=800',
            'url': '/trending',
            'order': 2,
          },
          {
            'title': 'Season Sale',
            'subtitle': 'Limited Time',
            'color': '0xFFFFE6E6',
            'image': 'https://images.pexels.com/photos/4099354/pexels-photo-4099354.jpeg?auto=compress&cs=tinysrgb&w=800',
            'url': '/trending',
            'order': 3,
          },
        ];
        
        // Add promotions to batch
        for (var promotion in promotions) {
          final docRef = promotionsRef.doc(); // Auto-generate ID
          batch.set(docRef, {
            ...promotion,
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
        
        // Commit the batch
        await batch.commit();
        print('Promotions seeded successfully!');
      } else {
        print('Promotions collection already contains data, skipping seed.');
      }
    } catch (e) {
      print('Error seeding promotions: $e');
    }
  }
  
  /// Run all seeders
  static Future<void> seedAll() async {
    await seedCategories();
    await seedPromotions();
    print('All seed operations completed.');
  }
} 