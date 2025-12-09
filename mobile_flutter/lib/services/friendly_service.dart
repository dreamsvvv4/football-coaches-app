import 'package:uuid/uuid.dart';
import '../models/match.dart';

/// Friendly Match Service - Manages friendly/practice matches
class FriendlyService {
  static const String _prefix = 'friendly_';
  static const String _eventPrefix = 'event_';

  final Map<String, FriendlyMatch> _friendlyMatches = {};
  final Map<String, List<MatchEvent>> _matchEvents = {};

  /// Create a new friendly match
  FriendlyMatch createFriendlyMatch({
    required String homeTeamId,
    required String homeTeamName,
    required String awayTeamId,
    required String awayTeamName,
    required DateTime scheduledTime,
    required String venueId,
    required String venueName,
    required int duration,
    required String createdBy,
    String? refereeId,
    String? refereeName,
    String? notes,
  }) {
    final id = _generateId(_prefix);

    final match = FriendlyMatch(
      id: id,
      homeTeamId: homeTeamId,
      homeTeamName: homeTeamName,
      awayTeamId: awayTeamId,
      awayTeamName: awayTeamName,
      scheduledTime: scheduledTime,
      venueId: venueId,
      venueName: venueName,
      duration: duration,
      status: MatchStatus.scheduled,
      createdAt: DateTime.now(),
      createdBy: createdBy,
      refereeId: refereeId,
      refereeName: refereeName,
      notes: notes,
    );

    _friendlyMatches[id] = match;
    _matchEvents[id] = [];

    return match;
  }

  /// Get friendly match by ID
  FriendlyMatch? getFriendlyMatch(String id) => _friendlyMatches[id];

  /// Get all friendly matches
  List<FriendlyMatch> getAllFriendlyMatches() => _friendlyMatches.values.toList();

  /// Get upcoming friendly matches
  List<FriendlyMatch> getUpcomingMatches() {
    final now = DateTime.now();
    return _friendlyMatches.values
        .where((m) => m.scheduledTime.isAfter(now) && !m.isCompleted)
        .toList()
      ..sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime));
  }

  /// Get team's friendly matches
  List<FriendlyMatch> getTeamMatches(String teamId) {
    return _friendlyMatches.values
        .where((m) => m.homeTeamId == teamId || m.awayTeamId == teamId)
        .toList()
      ..sort((a, b) => b.scheduledTime.compareTo(a.scheduledTime));
  }

  /// Update friendly match
  FriendlyMatch? updateFriendlyMatch(String id, FriendlyMatch updated) {
    if (_friendlyMatches.containsKey(id)) {
      _friendlyMatches[id] = updated;
      return updated;
    }
    return null;
  }

  /// Update match result
  FriendlyMatch? updateMatchResult(
    String matchId,
    int homeGoals,
    int awayGoals,
  ) {
    final match = getFriendlyMatch(matchId);
    if (match == null) return null;

    final updated = match.copyWith(
      homeTeamGoals: homeGoals,
      awayTeamGoals: awayGoals,
      status: MatchStatus.completed,
    );

    return updateFriendlyMatch(matchId, updated);
  }

  /// Update match status
  FriendlyMatch? updateMatchStatus(String matchId, MatchStatus status) {
    final match = getFriendlyMatch(matchId);
    if (match == null) return null;

    final updated = match.copyWith(status: status);
    return updateFriendlyMatch(matchId, updated);
  }

  /// Add event to match (goal, card, etc)
  FriendlyMatch? addMatchEvent(String matchId, MatchEvent event) {
    final match = getFriendlyMatch(matchId);
    if (match == null) return null;

    final events = List<MatchEvent>.from(match.events ?? [])..add(event);
    final updated = match.copyWith(events: events);

    _matchEvents.update(
      matchId,
      (existing) => [...existing, event],
      ifAbsent: () => [event],
    );

    return updateFriendlyMatch(matchId, updated);
  }

  /// Reschedule friendly match
  FriendlyMatch? rescheduleFriendly(String matchId, DateTime newTime) {
    final match = getFriendlyMatch(matchId);
    if (match == null) return null;

    final updated = match.copyWith(scheduledTime: newTime);
    return updateFriendlyMatch(matchId, updated);
  }

  /// Cancel friendly match
  FriendlyMatch? cancelFriendly(String matchId) {
    final match = getFriendlyMatch(matchId);
    if (match == null) return null;

    final updated = match.copyWith(status: MatchStatus.cancelled);
    return updateFriendlyMatch(matchId, updated);
  }

  /// Delete friendly match
  bool deleteFriendly(String matchId) {
    _friendlyMatches.remove(matchId);
    _matchEvents.remove(matchId);
    return true;
  }

  /// Get match events
  List<MatchEvent> getMatchEvents(String matchId) {
    return _matchEvents[matchId] ?? [];
  }

  /// Generate ID with prefix
  String _generateId(String prefix) {
    final uuid = const Uuid();
    return '$prefix${uuid.v4().substring(0, 8)}';
  }
}
