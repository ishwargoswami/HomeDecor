class UserModel {
  final String? uid;
  final String? email;
  final String? name;
  final String? photoUrl;
  final int projectsCount;
  final int wishlistCount;
  final int purchasesCount;

  UserModel({
    this.uid,
    this.email,
    this.name,
    this.photoUrl,
    this.projectsCount = 0,
    this.wishlistCount = 0,
    this.purchasesCount = 0,
  });

  factory UserModel.fromMap(Map<String, dynamic> data) {
    return UserModel(
      uid: data['uid'],
      email: data['email'],
      name: data['name'],
      photoUrl: data['photoUrl'],
      projectsCount: data['projectsCount'] ?? 0,
      wishlistCount: data['wishlistCount'] ?? 0,
      purchasesCount: data['purchasesCount'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'photoUrl': photoUrl,
      'projectsCount': projectsCount,
      'wishlistCount': wishlistCount,
      'purchasesCount': purchasesCount,
    };
  }
  
  Map<String, dynamic> toJson() => toMap();
  
  @override
  String toString() {
    return 'UserModel(uid: $uid, email: $email, name: $name, photoUrl: $photoUrl, projectsCount: $projectsCount, wishlistCount: $wishlistCount, purchasesCount: $purchasesCount)';
  }
} 