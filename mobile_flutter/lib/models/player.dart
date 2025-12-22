import 'package:flutter/material.dart';

class Player {
  String id;
  String name;
  int number;
  String position;
  String dominantFoot;
  DateTime birthDate;
  String country;
  String countryCode;
  String? photoPath;
  String? medicalNote;
  int convocatorias;

  Player({
    this.id = '',
    required this.name,
    required this.number,
    required this.position,
    required this.dominantFoot,
    required this.birthDate,
    required this.country,
    required this.countryCode,
    this.photoPath,
    this.medicalNote,
    this.convocatorias = 0,
  });

  factory Player.fromJson(Map<String, dynamic> json) => Player(
    id: json['id'] as String? ?? '',
    name: json['name'] as String,
    number: json['number'] as int,
    position: json['position'] as String,
    dominantFoot: json['dominantFoot'] as String,
    birthDate: DateTime.parse(json['birthDate'] as String),
    country: json['country'] as String,
    countryCode: json['countryCode'] as String,
    photoPath: json['photoPath'] as String?,
    medicalNote: json['medicalNote'] as String?,
    convocatorias: json['convocatorias'] as int? ?? 0,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'number': number,
    'position': position,
    'dominantFoot': dominantFoot,
    'birthDate': birthDate.toIso8601String(),
    'country': country,
    'countryCode': countryCode,
    'photoPath': photoPath,
    'medicalNote': medicalNote,
    'convocatorias': convocatorias,
  };
}
