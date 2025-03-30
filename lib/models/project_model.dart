class ProjectModel {
  final String? id;
  final String? name;
  final String? description;
  final String? room;
  final String? imageUrl;
  final double? progress;
  final List<String>? items;
  final double? budget;
  final String? userId;

  ProjectModel({
    this.id,
    this.name,
    this.description,
    this.room,
    this.imageUrl,
    this.progress,
    this.items,
    this.budget,
    this.userId,
  });

  factory ProjectModel.fromMap(Map<String, dynamic> data) {
    return ProjectModel(
      id: data['id'],
      name: data['name'],
      description: data['description'],
      room: data['room'],
      imageUrl: data['imageUrl'],
      progress: data['progress'] is int ? data['progress'].toDouble() : data['progress'],
      items: data['items'] != null ? List<String>.from(data['items']) : null,
      budget: data['budget'] is int ? data['budget'].toDouble() : data['budget'],
      userId: data['userId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'room': room,
      'imageUrl': imageUrl,
      'progress': progress,
      'items': items,
      'budget': budget,
      'userId': userId,
    };
  }
} 