class UserModel {
  final String uid;
  final String name;
  final String email;
  final String imageUrl;
  final String bio;
  final String location;
  final String skillMatched;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.imageUrl,
    required this.bio,
    required this.location,
    required this.skillMatched,
  });

  /// Creates a UserModel from a JSON map, ensuring no null or empty values slip through.
  factory UserModel.fromJson(Map<String, dynamic> json) {
    String _safeString(dynamic value) {
      if (value == null) return '';
      if (value is String) {
        return value.trim();
      }
      return value.toString().trim(); // handles numbers, etc. safely
    }

    return UserModel(
      uid: _safeString(json['id'] ?? json['uid']),
      name: _safeString(json['name']),
      email: _safeString(json['email']),
      imageUrl: _safeString(json['avatar'] ?? json['imageUrl']),
      bio: _safeString(json['bio']),
      location: _safeString(json['location']),
      skillMatched: _safeString(json['matched_skill_name']),
    );
  }

  /// Converts this UserModel into a JSON map for sending to APIs.
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'imageUrl': imageUrl,
      'bio': bio,
      'location': location,
      'matched_skill_name': skillMatched,
    };
  }

  @override
  String toString() {
    return 'UserModel(uid: $uid, name: $name, email: $email, imageUrl: $imageUrl, bio: $bio, location: $location, skillMatched: $skillMatched)';
  }
}
