class Team {
  final String id;
  final String name;
  final String category; // e.g., Sub-14, Femenino
  final String clubId;

  Team({required this.id, required this.name, required this.category, required this.clubId});

  factory Team.fromJson(Map<String, dynamic> json) => Team(
    id: json['id'] as String,
    name: json['name'] as String,
    category: json['category'] as String? ?? '',
    clubId: json['clubId'] as String,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'category': category,
    'clubId': clubId,
  };
}
