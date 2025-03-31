import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:decor_home/models/decor_item_model.dart';

class RecentlyViewedItem {
  final String id;
  final String itemId;
  final Timestamp? timestamp;
  final DecorItemModel? product;

  RecentlyViewedItem({
    required this.id,
    required this.itemId,
    this.timestamp,
    this.product,
  });

  factory RecentlyViewedItem.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return RecentlyViewedItem(
      id: doc.id,
      itemId: data['itemId'] ?? '',
      timestamp: data['timestamp'],
    );
  }
  
  // Create a copy with product data
  RecentlyViewedItem copyWith({DecorItemModel? product}) {
    return RecentlyViewedItem(
      id: id,
      itemId: itemId,
      timestamp: timestamp,
      product: product ?? this.product,
    );
  }
} 