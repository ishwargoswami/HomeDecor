class UserModel {
  final String? uid;
  final String? email;
  final String? name;
  final String? photoUrl;

  UserModel({
    this.uid,
    this.email,
    this.name,
    this.photoUrl,
  });

  factory UserModel.fromMap(Map<String, dynamic> data) {
    return UserModel(
      uid: data['uid'],
      email: data['email'],
      name: data['name'],
      photoUrl: data['photoUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'photoUrl': photoUrl,
    };
  }
  
  Map<String, dynamic> toJson() => toMap();
  
  @override
  String toString() {
    return 'UserModel(uid: $uid, email: $email, name: $name, photoUrl: $photoUrl)';
  }
} 