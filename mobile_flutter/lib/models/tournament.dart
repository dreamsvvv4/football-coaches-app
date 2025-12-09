import 'package:flutter/foundation.dart';

/// Enum for tournament type
enum TournamentType {
  roundRobin,
  knockout,
  mixed, // group + knockout
}

/// Enum for football mode
enum FootballMode {
  football11,
  football7,
  futsal,
}

/// Enum for player category
enum PlayerCategory {
  junior,
  senior,
  amateur,
  professional,
}

/// Enum for tournament status
enum TournamentStatus {
  draft,
  active,
  completed,
  cancelled,
}

/// Tournament Model - Main tournament data structure
class Tournament {
  final String id;
  final String name;
  final String description;
  final TournamentType type;
  final FootballMode mode;
  final PlayerCategory category;
  final int matchDuration; // in minutes
  final String venueId;
  final String venueName;
  final String venueLat;
  final String venueLng;
  final List<String> teamIds; // Team IDs participating
  final List<String> teamNames; // Team names for quick reference
  final DateTime startDate;
  final DateTime? endDate;
  final String createdBy; // Coach/Admin ID
  final DateTime createdAt;
  final DateTime? updatedAt;
  final TournamentStatus status;
  final TournamentRules rules;
  
  // Group stage info (for mixed tournaments)
  final List<Group>? groups;
  
  // Additional metadata
  final String? imageUrl;
  final bool isPublic;
  final int? maxTeams;
  final String? notes;

  Tournament({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.mode,
    required this.category,
    required this.matchDuration,
    required this.venueId,
    required this.venueName,
    required this.venueLat,
    required this.venueLng,
    required this.teamIds,
    required this.teamNames,
    required this.startDate,
    this.endDate,
    required this.createdBy,
    required this.createdAt,
    this.updatedAt,
    required this.status,
    required this.rules,
    this.groups,
    this.imageUrl,
    this.isPublic = true,
    this.maxTeams,
    this.notes,
  });

  /// Create a copy with updated fields
  Tournament copyWith({
    String? id,
    String? name,
    String? description,
    TournamentType? type,
    FootballMode? mode,
    PlayerCategory? category,
    int? matchDuration,
    String? venueId,
    String? venueName,
    String? venueLat,
    String? venueLng,
    List<String>? teamIds,
    List<String>? teamNames,
    DateTime? startDate,
    DateTime? endDate,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    TournamentStatus? status,
    TournamentRules? rules,
    List<Group>? groups,
    String? imageUrl,
    bool? isPublic,
    int? maxTeams,
    String? notes,
  }) {
    return Tournament(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      mode: mode ?? this.mode,
      category: category ?? this.category,
      matchDuration: matchDuration ?? this.matchDuration,
      venueId: venueId ?? this.venueId,
      venueName: venueName ?? this.venueName,
      venueLat: venueLat ?? this.venueLat,
      venueLng: venueLng ?? this.venueLng,
      teamIds: teamIds ?? this.teamIds,
      teamNames: teamNames ?? this.teamNames,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      status: status ?? this.status,
      rules: rules ?? this.rules,
      groups: groups ?? this.groups,
      imageUrl: imageUrl ?? this.imageUrl,
      isPublic: isPublic ?? this.isPublic,
      maxTeams: maxTeams ?? this.maxTeams,
      notes: notes ?? this.notes,
    );
  }

  /// Convert to JSON for API/storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type.toString().split('.').last,
      'mode': mode.toString().split('.').last,
      'category': category.toString().split('.').last,
      'matchDuration': matchDuration,
      'venueId': venueId,
      'venueName': venueName,
      'venueLat': venueLat,
      'venueLng': venueLng,
      'teamIds': teamIds,
      'teamNames': teamNames,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'status': status.toString().split('.').last,
      'rules': rules.toJson(),
      'groups': groups?.map((g) => g.toJson()).toList(),
      'imageUrl': imageUrl,
      'isPublic': isPublic,
      'maxTeams': maxTeams,
      'notes': notes,
    };
  }

  /// Create from JSON
  factory Tournament.fromJson(Map<String, dynamic> json) {
    return Tournament(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      type: TournamentType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
      ),
      mode: FootballMode.values.firstWhere(
        (e) => e.toString().split('.').last == json['mode'],
      ),
      category: PlayerCategory.values.firstWhere(
        (e) => e.toString().split('.').last == json['category'],
      ),
      matchDuration: json['matchDuration'] as int,
      venueId: json['venueId'] as String,
      venueName: json['venueName'] as String,
      venueLat: json['venueLat'] as String,
      venueLng: json['venueLng'] as String,
      teamIds: List<String>.from(json['teamIds'] as List),
      teamNames: List<String>.from(json['teamNames'] as List),
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate'] as String) : null,
      createdBy: json['createdBy'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt'] as String) : null,
      status: TournamentStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
      ),
      rules: TournamentRules.fromJson(json['rules'] as Map<String, dynamic>),
      groups: json['groups'] != null
          ? (json['groups'] as List).map((g) => Group.fromJson(g as Map<String, dynamic>)).toList()
          : null,
      imageUrl: json['imageUrl'] as String?,
      isPublic: json['isPublic'] as bool? ?? true,
      maxTeams: json['maxTeams'] as int?,
      notes: json['notes'] as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Tournament &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Tournament(id: $id, name: $name, type: $type)';
}

/// Tournament Rules Configuration
class TournamentRules {
  final bool allowExtraTime;
  final bool allowPenalties;
  final int minPlayersRequired;
  final int maxSubstitutions;
  final int maxCardWarnings;
  final bool useVAR; // Video Assistant Referee
  final String? customRules;

  TournamentRules({
    required this.allowExtraTime,
    required this.allowPenalties,
    required this.minPlayersRequired,
    required this.maxSubstitutions,
    required this.maxCardWarnings,
    this.useVAR = false,
    this.customRules,
  });

  Map<String, dynamic> toJson() {
    return {
      'allowExtraTime': allowExtraTime,
      'allowPenalties': allowPenalties,
      'minPlayersRequired': minPlayersRequired,
      'maxSubstitutions': maxSubstitutions,
      'maxCardWarnings': maxCardWarnings,
      'useVAR': useVAR,
      'customRules': customRules,
    };
  }

  factory TournamentRules.fromJson(Map<String, dynamic> json) {
    return TournamentRules(
      allowExtraTime: json['allowExtraTime'] as bool? ?? true,
      allowPenalties: json['allowPenalties'] as bool? ?? true,
      minPlayersRequired: json['minPlayersRequired'] as int? ?? 7,
      maxSubstitutions: json['maxSubstitutions'] as int? ?? 3,
      maxCardWarnings: json['maxCardWarnings'] as int? ?? 2,
      useVAR: json['useVAR'] as bool? ?? false,
      customRules: json['customRules'] as String?,
    );
  }

  TournamentRules copyWith({
    bool? allowExtraTime,
    bool? allowPenalties,
    int? minPlayersRequired,
    int? maxSubstitutions,
    int? maxCardWarnings,
    bool? useVAR,
    String? customRules,
  }) {
    return TournamentRules(
      allowExtraTime: allowExtraTime ?? this.allowExtraTime,
      allowPenalties: allowPenalties ?? this.allowPenalties,
      minPlayersRequired: minPlayersRequired ?? this.minPlayersRequired,
      maxSubstitutions: maxSubstitutions ?? this.maxSubstitutions,
      maxCardWarnings: maxCardWarnings ?? this.maxCardWarnings,
      useVAR: useVAR ?? this.useVAR,
      customRules: customRules ?? this.customRules,
    );
  }
}

/// Group structure for group-stage tournaments (mixed type)
class Group {
  final String id;
  final String name;
  final List<String> teamIds;
  final List<String> teamNames;
  final int qualifiersCount; // How many teams advance to knockout

  Group({
    required this.id,
    required this.name,
    required this.teamIds,
    required this.teamNames,
    required this.qualifiersCount,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'teamIds': teamIds,
      'teamNames': teamNames,
      'qualifiersCount': qualifiersCount,
    };
  }

  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
      id: json['id'] as String,
      name: json['name'] as String,
      teamIds: List<String>.from(json['teamIds'] as List),
      teamNames: List<String>.from(json['teamNames'] as List),
      qualifiersCount: json['qualifiersCount'] as int,
    );
  }

  Group copyWith({
    String? id,
    String? name,
    List<String>? teamIds,
    List<String>? teamNames,
    int? qualifiersCount,
  }) {
    return Group(
      id: id ?? this.id,
      name: name ?? this.name,
      teamIds: teamIds ?? this.teamIds,
      teamNames: teamNames ?? this.teamNames,
      qualifiersCount: qualifiersCount ?? this.qualifiersCount,
    );
  }
}

/// Standing for group stage
@immutable
class TeamStanding {
  final String teamId;
  final String teamName;
  final int played;
  final int won;
  final int drawn;
  final int lost;
  final int goalsFor;
  final int goalsAgainst;
  final int goalDifference;
  final int points;

  const TeamStanding({
    required this.teamId,
    required this.teamName,
    required this.played,
    required this.won,
    required this.drawn,
    required this.lost,
    required this.goalsFor,
    required this.goalsAgainst,
    required this.goalDifference,
    required this.points,
  });

  /// Calculate points: 3 for win, 1 for draw, 0 for loss
  static int calculatePoints(int wins, int draws) => (wins * 3) + draws;

  /// Update standing with match result
  TeamStanding updateWithResult({
    required int goalsScored,
    required int goalsAgainst,
    required bool isWin,
    required bool isDraw,
  }) {
    final newPlayed = played + 1;
    final newWon = isWin ? won + 1 : won;
    final newDrawn = isDraw ? drawn + 1 : drawn;
    final newLost = isWin || isDraw ? lost : lost + 1;
    final newGoalsFor = goalsFor + goalsScored;
    final newGoalsAgainst = goalsAgainst + goalsAgainst;
    final newGoalDifference = newGoalsFor - newGoalsAgainst;
    final newPoints = calculatePoints(newWon, newDrawn);

    return TeamStanding(
      teamId: teamId,
      teamName: teamName,
      played: newPlayed,
      won: newWon,
      drawn: newDrawn,
      lost: newLost,
      goalsFor: newGoalsFor,
      goalsAgainst: newGoalsAgainst,
      goalDifference: newGoalDifference,
      points: newPoints,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'teamId': teamId,
      'teamName': teamName,
      'played': played,
      'won': won,
      'drawn': drawn,
      'lost': lost,
      'goalsFor': goalsFor,
      'goalsAgainst': goalsAgainst,
      'goalDifference': goalDifference,
      'points': points,
    };
  }

  factory TeamStanding.fromJson(Map<String, dynamic> json) {
    return TeamStanding(
      teamId: json['teamId'] as String,
      teamName: json['teamName'] as String,
      played: json['played'] as int,
      won: json['won'] as int,
      drawn: json['drawn'] as int,
      lost: json['lost'] as int,
      goalsFor: json['goalsFor'] as int,
      goalsAgainst: json['goalsAgainst'] as int,
      goalDifference: json['goalDifference'] as int,
      points: json['points'] as int,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TeamStanding &&
          runtimeType == other.runtimeType &&
          teamId == other.teamId;

  @override
  int get hashCode => teamId.hashCode;
}
