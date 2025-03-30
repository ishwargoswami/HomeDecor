class DecorItemModel {
  final String? id;
  final String? title;
  final String? description;
  final String? category;
  final String? room;
  final String? imageUrl;
  final double? price;
  final double? rating;

  DecorItemModel({
    this.id,
    this.title,
    this.description,
    this.category,
    this.room,
    this.imageUrl,
    this.price,
    this.rating,
  });

  factory DecorItemModel.fromMap(Map<String, dynamic> data) {
    return DecorItemModel(
      id: data['id'],
      title: data['title'],
      description: data['description'],
      category: data['category'],
      room: data['room'],
      imageUrl: data['imageUrl'],
      price: data['price'],
      rating: data['rating'] is String ? double.parse(data['rating']) : data['rating'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'room': room,
      'imageUrl': imageUrl,
      'price': price,
      'rating': rating,
    };
  }
} 