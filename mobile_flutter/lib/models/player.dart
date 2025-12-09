class Player {
  final String id;
  final String name;
  final int age;
  final int? number;
  final String position;
  final String? photoUrl;
  final String? medicalNotes;
  final String teamId;

  Player({required this.id, required this.name, required this.age, this.number, required this.position, this.photoUrl, this.medicalNotes, required this.teamId});

  factory Player.fromJson(Map<String, dynamic> json) => Player(
    id: json['id'] as String,
    name: json['name'] as String,
    age: json['age'] as int,
    number: json['number'] as int?,
    position: json['position'] as String? ?? 'Unknown',
    photoUrl: json['photoUrl'] as String?,
    medicalNotes: json['medicalNotes'] as String?,
    teamId: json['teamId'] as String,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'age': age,
    'number': number,
    'position': position,
    'photoUrl': photoUrl,
    'medicalNotes': medicalNotes,
    'teamId': teamId,
  };
}
