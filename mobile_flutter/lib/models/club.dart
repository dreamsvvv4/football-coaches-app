class Club {
  final String id;
  final String name;
  final String? crestUrl;
  final String? city;
  final String? country;
  final String? description;
  final int? foundedYear;

  Club({
    required this.id,
    required this.name,
    this.crestUrl,
    this.city,
    this.country,
    this.description,
    this.foundedYear,
  });

  factory Club.fromJson(Map<String, dynamic> json) => Club(
    id: json['id'] as String,
    name: json['name'] as String,
    crestUrl: json['crestUrl'] as String?,
    city: json['city'] as String?,
    country: json['country'] as String?,
    description: json['description'] as String?,
    foundedYear: json['foundedYear'] as int?,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'crestUrl': crestUrl,
    'city': city,
    'country': country,
    'description': description,
    'foundedYear': foundedYear,
  };

  Club copyWith({
    String? id,
    String? name,
    String? crestUrl,
    String? city,
    String? country,
    String? description,
    int? foundedYear,
  }) =>
      Club(
        id: id ?? this.id,
        name: name ?? this.name,
        crestUrl: crestUrl ?? this.crestUrl,
        city: city ?? this.city,
        country: country ?? this.country,
        description: description ?? this.description,
        foundedYear: foundedYear ?? this.foundedYear,
      );
}
