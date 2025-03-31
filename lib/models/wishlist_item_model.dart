import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:decor_home/models/decor_item_model.dart';

class WishlistItem {
  final String id;
  final String itemId;
  final Timestamp? timestamp;
  final DecorItemModel? product;

  WishlistItem({
    required this.id,
    required this.itemId,
    this.timestamp,
    this.product,
  });

  factory WishlistItem.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return WishlistItem(
      id: doc.id,
      itemId: data['itemId'] ?? '',
      timestamp: data['timestamp'],
    );
  }
  
  // Create a copy with product data
  WishlistItem copyWith({DecorItemModel? product}) {
    return WishlistItem(
      id: id,
      itemId: itemId,
      timestamp: timestamp,
      product: product ?? this.product,
    );
  }
} 