class Skill {
  final String id;
  final String name;

  Skill({required this.id, required this.name});

  /// Creates a [Skill] instance from a JSON map.
  factory Skill.fromJson(Map<String, dynamic> json) {
    return Skill(
      id: json['skill_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
    );
  }

  /// Converts the [Skill] instance to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'skill_id': id,
      'name': name,
    };
  }

  /// Creates a copy of the current [Skill] with optional new values.
  Skill copyWith({String? id, String? name}) {
    return Skill(
      id: id ?? this.id,
      name: name ?? this.name,
    );
  }

  @override
  String toString() => 'Skill(id: $id, name: $name)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Skill &&
              runtimeType == other.runtimeType &&
              id == other.id &&
              name == other.name;

  @override
  int get hashCode => id.hashCode ^ name.hashCode;
}
