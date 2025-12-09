import 'package:flutter/foundation.dart';

/// Match status enum
enum MatchStatus {
  scheduled,
  inProgress,
  paused,
  completed,
  cancelled,
  postponed,
}

/// Match event type
enum MatchEventType {
  goal,
  ownGoal,
  yellowCard,
  redCard,
  substitution,
  injury,
  offside,
}

/// Main Match Model
@immutable
class Match {
  final String id;
  final String tournamentId;
  final String? groupId; // For group stage tournaments
  final String homeTeamId;
  final String homeTeamName;
  final String awayTeamId;
  final String awayTeamName;
  final int? homeTeamGoals;
  final int? awayTeamGoals;
  final DateTime scheduledTime;
  final String venueId;
  final String venueName;
  final int duration; // minutes
  final MatchStatus status;
  final List<MatchEvent>? events;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? refereeId;
  final String? refereeName;
  final int? round; // For knockout tournaments
  final bool isKnockout; // Is this a knockout match
  final String? notes;

  const Match({
    required this.id,
    required this.tournamentId,
    this.groupId,
    required this.homeTeamId,
    required this.homeTeamName,
    required this.awayTeamId,
    required this.awayTeamName,
    this.homeTeamGoals,
    this.awayTeamGoals,
    required this.scheduledTime,
    required this.venueId,
    required this.venueName,
    required this.duration,
    required this.status,
    this.events,
    required this.createdAt,
    this.updatedAt,
    this.refereeId,
    this.refereeName,
    this.round,
    this.isKnockout = false,
    this.notes,
  });

  /// Check if match is completed
  bool get isCompleted => status == MatchStatus.completed;

  /// Check if match is ongoing
  bool get isOngoing => status == MatchStatus.inProgress || status == MatchStatus.paused;

  /// Check if match is not started
  bool get isScheduled => status == MatchStatus.scheduled;

  /// Get match result as string
  String getResult() {
    if (!isCompleted || homeTeamGoals == null || awayTeamGoals == null) {
      return 'N/A';
    }
    return '$homeTeamGoals - $awayTeamGoals';
  }

  /// Check if home team won
  bool get homeTeamWon =>
      isCompleted &&
      homeTeamGoals != null &&
      awayTeamGoals != null &&
      homeTeamGoals! > awayTeamGoals!;

  /// Check if match is a draw
  bool get isDraw =>
      isCompleted &&
      homeTeamGoals != null &&
      awayTeamGoals != null &&
      homeTeamGoals == awayTeamGoals;

  /// Copy with new values
  Match copyWith({
    String? id,
    String? tournamentId,
    String? groupId,
    String? homeTeamId,
    String? homeTeamName,
    String? awayTeamId,
    String? awayTeamName,
    int? homeTeamGoals,
    int? awayTeamGoals,
    DateTime? scheduledTime,
    String? venueId,
    String? venueName,
    int? duration,
    MatchStatus? status,
    List<MatchEvent>? events,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? refereeId,
    String? refereeName,
    int? round,
    bool? isKnockout,
    String? notes,
  }) {
    return Match(
      id: id ?? this.id,
      tournamentId: tournamentId ?? this.tournamentId,
      groupId: groupId ?? this.groupId,
      homeTeamId: homeTeamId ?? this.homeTeamId,
      homeTeamName: homeTeamName ?? this.homeTeamName,
      awayTeamId: awayTeamId ?? this.awayTeamId,
      awayTeamName: awayTeamName ?? this.awayTeamName,
      homeTeamGoals: homeTeamGoals ?? this.homeTeamGoals,
      awayTeamGoals: awayTeamGoals ?? this.awayTeamGoals,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      venueId: venueId ?? this.venueId,
      venueName: venueName ?? this.venueName,
      duration: duration ?? this.duration,
      status: status ?? this.status,
      events: events ?? this.events,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      refereeId: refereeId ?? this.refereeId,
      refereeName: refereeName ?? this.refereeName,
      round: round ?? this.round,
      isKnockout: isKnockout ?? this.isKnockout,
      notes: notes ?? this.notes,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tournamentId': tournamentId,
      'groupId': groupId,
      'homeTeamId': homeTeamId,
      'homeTeamName': homeTeamName,
      'awayTeamId': awayTeamId,
      'awayTeamName': awayTeamName,
      'homeTeamGoals': homeTeamGoals,
      'awayTeamGoals': awayTeamGoals,
      'scheduledTime': scheduledTime.toIso8601String(),
      'venueId': venueId,
      'venueName': venueName,
      'duration': duration,
      'status': status.toString().split('.').last,
      'events': events?.map((e) => e.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'refereeId': refereeId,
      'refereeName': refereeName,
      'round': round,
      'isKnockout': isKnockout,
      'notes': notes,
    };
  }

  /// Create from JSON
  factory Match.fromJson(Map<String, dynamic> json) {
    return Match(
      id: json['id'] as String,
      tournamentId: json['tournamentId'] as String,
      groupId: json['groupId'] as String?,
      homeTeamId: json['homeTeamId'] as String,
      homeTeamName: json['homeTeamName'] as String,
      awayTeamId: json['awayTeamId'] as String,
      awayTeamName: json['awayTeamName'] as String,
      homeTeamGoals: json['homeTeamGoals'] as int?,
      awayTeamGoals: json['awayTeamGoals'] as int?,
      scheduledTime: DateTime.parse(json['scheduledTime'] as String),
      venueId: json['venueId'] as String,
      venueName: json['venueName'] as String,
      duration: json['duration'] as int,
      status: MatchStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
      ),
      events: json['events'] != null
          ? (json['events'] as List)
              .map((e) => MatchEvent.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      refereeId: json['refereeId'] as String?,
      refereeName: json['refereeName'] as String?,
      round: json['round'] as int?,
      isKnockout: json['isKnockout'] as bool? ?? false,
      notes: json['notes'] as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Match && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'Match(id: $id, $homeTeamName vs $awayTeamName, status: $status)';
}

/// Match Event - Goals, cards, substitutions, etc
@immutable
class MatchEvent {
  final String id;
  final String matchId;
  final MatchEventType type;
  final int minute;
  final int? extraMinute; // For extra time
  final String teamId;
  final String teamName;
  final String playerId;
  final String playerName;
  final String? secondPlayerId; // For substitutions (player going out)
  final String? secondPlayerName;
  final String? notes;
  final DateTime createdAt;

  const MatchEvent({
    required this.id,
    required this.matchId,
    required this.type,
    required this.minute,
    this.extraMinute,
    required this.teamId,
    required this.teamName,
    required this.playerId,
    required this.playerName,
    this.secondPlayerId,
    this.secondPlayerName,
    this.notes,
    required this.createdAt,
  });

  /// Get display time (minute + extra if applicable)
  String getDisplayTime() {
    if (extraMinute != null && extraMinute! > 0) {
      return "${minute}+$extraMinute'";
    }
    return "$minute'";
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'matchId': matchId,
      'type': type.toString().split('.').last,
      'minute': minute,
      'extraMinute': extraMinute,
      'teamId': teamId,
      'teamName': teamName,
      'playerId': playerId,
      'playerName': playerName,
      'secondPlayerId': secondPlayerId,
      'secondPlayerName': secondPlayerName,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Create from JSON
  factory MatchEvent.fromJson(Map<String, dynamic> json) {
    return MatchEvent(
      id: json['id'] as String,
      matchId: json['matchId'] as String,
      type: MatchEventType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
      ),
      minute: json['minute'] as int,
      extraMinute: json['extraMinute'] as int?,
      teamId: json['teamId'] as String,
      teamName: json['teamName'] as String,
      playerId: json['playerId'] as String,
      playerName: json['playerName'] as String,
      secondPlayerId: json['secondPlayerId'] as String?,
      secondPlayerName: json['secondPlayerName'] as String?,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MatchEvent && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// Friendly Match model (similar to tournament match but standalone)
@immutable
class FriendlyMatch {
  final String id;
  final String homeTeamId;
  final String homeTeamName;
  final String awayTeamId;
  final String awayTeamName;
  final int? homeTeamGoals;
  final int? awayTeamGoals;
  final DateTime scheduledTime;
  final String venueId;
  final String venueName;
  final int duration; // minutes
  final MatchStatus status;
  final List<MatchEvent>? events;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String createdBy;
  final String? refereeId;
  final String? refereeName;
  final String? notes;

  const FriendlyMatch({
    required this.id,
    required this.homeTeamId,
    required this.homeTeamName,
    required this.awayTeamId,
    required this.awayTeamName,
    this.homeTeamGoals,
    this.awayTeamGoals,
    required this.scheduledTime,
    required this.venueId,
    required this.venueName,
    required this.duration,
    required this.status,
    this.events,
    required this.createdAt,
    this.updatedAt,
    required this.createdBy,
    this.refereeId,
    this.refereeName,
    this.notes,
  });

  /// Check if match is completed
  bool get isCompleted => status == MatchStatus.completed;

  /// Get match result
  String getResult() {
    if (!isCompleted || homeTeamGoals == null || awayTeamGoals == null) {
      return 'N/A';
    }
    return '$homeTeamGoals - $awayTeamGoals';
  }

  /// Copy with new values
  FriendlyMatch copyWith({
    String? id,
    String? homeTeamId,
    String? homeTeamName,
    String? awayTeamId,
    String? awayTeamName,
    int? homeTeamGoals,
    int? awayTeamGoals,
    DateTime? scheduledTime,
    String? venueId,
    String? venueName,
    int? duration,
    MatchStatus? status,
    List<MatchEvent>? events,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? refereeId,
    String? refereeName,
    String? notes,
  }) {
    return FriendlyMatch(
      id: id ?? this.id,
      homeTeamId: homeTeamId ?? this.homeTeamId,
      homeTeamName: homeTeamName ?? this.homeTeamName,
      awayTeamId: awayTeamId ?? this.awayTeamId,
      awayTeamName: awayTeamName ?? this.awayTeamName,
      homeTeamGoals: homeTeamGoals ?? this.homeTeamGoals,
      awayTeamGoals: awayTeamGoals ?? this.awayTeamGoals,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      venueId: venueId ?? this.venueId,
      venueName: venueName ?? this.venueName,
      duration: duration ?? this.duration,
      status: status ?? this.status,
      events: events ?? this.events,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      createdBy: createdBy ?? this.createdBy,
      refereeId: refereeId ?? this.refereeId,
      refereeName: refereeName ?? this.refereeName,
      notes: notes ?? this.notes,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'homeTeamId': homeTeamId,
      'homeTeamName': homeTeamName,
      'awayTeamId': awayTeamId,
      'awayTeamName': awayTeamName,
      'homeTeamGoals': homeTeamGoals,
      'awayTeamGoals': awayTeamGoals,
      'scheduledTime': scheduledTime.toIso8601String(),
      'venueId': venueId,
      'venueName': venueName,
      'duration': duration,
      'status': status.toString().split('.').last,
      'events': events?.map((e) => e.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'createdBy': createdBy,
      'refereeId': refereeId,
      'refereeName': refereeName,
      'notes': notes,
    };
  }

  /// Create from JSON
  factory FriendlyMatch.fromJson(Map<String, dynamic> json) {
    return FriendlyMatch(
      id: json['id'] as String,
      homeTeamId: json['homeTeamId'] as String,
      homeTeamName: json['homeTeamName'] as String,
      awayTeamId: json['awayTeamId'] as String,
      awayTeamName: json['awayTeamName'] as String,
      homeTeamGoals: json['homeTeamGoals'] as int?,
      awayTeamGoals: json['awayTeamGoals'] as int?,
      scheduledTime: DateTime.parse(json['scheduledTime'] as String),
      venueId: json['venueId'] as String,
      venueName: json['venueName'] as String,
      duration: json['duration'] as int,
      status: MatchStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
      ),
      events: json['events'] != null
          ? (json['events'] as List)
              .map((e) => MatchEvent.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      createdBy: json['createdBy'] as String,
      refereeId: json['refereeId'] as String?,
      refereeName: json['refereeName'] as String?,
      notes: json['notes'] as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FriendlyMatch &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'FriendlyMatch(id: $id, $homeTeamName vs $awayTeamName)';
}
