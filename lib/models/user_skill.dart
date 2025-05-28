class UserSkill {
  final String id; // <-- added this
  final String name;
  final String proficiency;
  final int yearAcquired;
  final String description;

  UserSkill({
    required this.id,
    required this.name,
    required this.proficiency,
    required this.yearAcquired,
    required this.description,
  });

  // Factory constructor to create a UserSkill from JSON
  factory UserSkill.fromJson(Map<String, dynamic> json) {
    return UserSkill(
      id: json['skill_id'] as String,
      name: json['name'] as String,
      proficiency: json['proficiency'] as String,
      yearAcquired: int.parse(json['year_acquired'].toString()), // handle if it's string or int
      description: json['description'] as String,
    );
  }

  // Method to convert a UserSkill to JSON
  Map<String, dynamic> toJson() {
    return {
      'skill_id': id,
      'name': name,
      'proficiency': proficiency,
      'year_acquired': yearAcquired,
      'description': description,
    };
  }
}
