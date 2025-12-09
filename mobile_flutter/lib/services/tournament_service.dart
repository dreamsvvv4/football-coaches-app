import 'package:uuid/uuid.dart';
import '../models/tournament.dart';
import '../models/match.dart';

/// Tournament Service - Handles tournament creation, fixture generation, and management
class TournamentService {
  static const String _prefix = 'tour_';
  static const String _matchPrefix = 'match_';
  static const String _groupPrefix = 'group_';

  // In-memory storage (will be replaced with local DB in production)
  final Map<String, Tournament> _tournaments = {};
  final Map<String, List<Match>> _tournamentMatches = {};

  /// Create a new tournament
  Tournament createTournament({
    required String name,
    required String description,
    required TournamentType type,
    required FootballMode mode,
    required PlayerCategory category,
    required int matchDuration,
    required String venueId,
    required String venueName,
    required String venueLat,
    required String venueLng,
    required List<String> teamIds,
    required List<String> teamNames,
    required DateTime startDate,
    required String createdBy,
    String? imageUrl,
    bool isPublic = true,
    int? maxTeams,
    String? notes,
    TournamentRules? rules,
  }) {
    final id = _generateId(_prefix);

    final tournament = Tournament(
      id: id,
      name: name,
      description: description,
      type: type,
      mode: mode,
      category: category,
      matchDuration: matchDuration,
      venueId: venueId,
      venueName: venueName,
      venueLat: venueLat,
      venueLng: venueLng,
      teamIds: teamIds,
      teamNames: teamNames,
      startDate: startDate,
      createdBy: createdBy,
      createdAt: DateTime.now(),
      status: TournamentStatus.draft,
      rules: rules ??
          TournamentRules(
            allowExtraTime: true,
            allowPenalties: true,
            minPlayersRequired: mode == FootballMode.football11 ? 11 : (mode == FootballMode.football7 ? 7 : 5),
            maxSubstitutions: 3,
            maxCardWarnings: 2,
          ),
      imageUrl: imageUrl,
      isPublic: isPublic,
      maxTeams: maxTeams,
      notes: notes,
    );

    _tournaments[id] = tournament;
    _tournamentMatches[id] = [];

    return tournament;
  }

  /// Generate fixtures for tournament
  List<Match> generateFixtures({
    required String tournamentId,
    required DateTime startDate,
    required String venueId,
    required String venueName,
    required int matchDuration,
  }) {
    final tournament = getTournament(tournamentId);
    if (tournament == null) {
      throw Exception('Tournament not found');
    }

    List<Match> matches = [];

    switch (tournament.type) {
      case TournamentType.roundRobin:
        matches = _generateRoundRobinFixtures(
          tournament: tournament,
          startDate: startDate,
          venueId: venueId,
          venueName: venueName,
          matchDuration: matchDuration,
        );
        break;

      case TournamentType.knockout:
        matches = _generateKnockoutFixtures(
          tournament: tournament,
          startDate: startDate,
          venueId: venueId,
          venueName: venueName,
          matchDuration: matchDuration,
        );
        break;

      case TournamentType.mixed:
        matches = _generateGroupAndKnockoutFixtures(
          tournament: tournament,
          startDate: startDate,
          venueId: venueId,
          venueName: venueName,
          matchDuration: matchDuration,
        );
        break;
    }

    _tournamentMatches[tournamentId] = matches;
    return matches;
  }

  /// Generate round-robin fixtures (all teams play each other)
  List<Match> _generateRoundRobinFixtures({
    required Tournament tournament,
    required DateTime startDate,
    required String venueId,
    required String venueName,
    required int matchDuration,
  }) {
    final matches = <Match>[];
    final teams = tournament.teamIds;
    var matchDate = startDate;

    for (int i = 0; i < teams.length; i++) {
      for (int j = i + 1; j < teams.length; j++) {
        final match = Match(
          id: _generateId(_matchPrefix),
          tournamentId: tournament.id,
          homeTeamId: teams[i],
          homeTeamName: tournament.teamNames[i],
          awayTeamId: teams[j],
          awayTeamName: tournament.teamNames[j],
          scheduledTime: matchDate,
          venueId: venueId,
          venueName: venueName,
          duration: matchDuration,
          status: MatchStatus.scheduled,
          createdAt: DateTime.now(),
          isKnockout: false,
        );

        matches.add(match);

        // Space matches by matchDuration + 30 min buffer
        matchDate = matchDate.add(Duration(minutes: matchDuration + 30));
      }
    }

    return matches;
  }

  /// Generate knockout fixtures (bracket)
  List<Match> _generateKnockoutFixtures({
    required Tournament tournament,
    required DateTime startDate,
    required String venueId,
    required String venueName,
    required int matchDuration,
  }) {
    final matches = <Match>[];
    final teams = tournament.teamIds;

    if (teams.isEmpty || (teams.length & (teams.length - 1)) != 0) {
      // If teams count is not a power of 2, pad with byes or empty slots
      // For MVP, we'll just use what we have
    }

    var matchDate = startDate;
    var round = 1;
    var currentRound = _generateKnockoutRound(
      tournament: tournament,
      teams: teams,
      teamNames: tournament.teamNames,
      round: round,
      matchDate: matchDate,
      venueId: venueId,
      venueName: venueName,
      matchDuration: matchDuration,
    );

    matches.addAll(currentRound);
    matchDate = matchDate.add(Duration(days: 3)); // 3 days between rounds

    // Continue with further rounds until only one team remains
    while (teams.length > 1) {
      round++;
      // In real scenario, winners would be determined from previous round
      // For MVP, we generate placeholder next rounds
      if (round <= _calculateMaxRounds(teams.length)) {
        currentRound = _generateKnockoutRound(
          tournament: tournament,
          teams: [], // Next round teams would come from winners
          teamNames: [],
          round: round,
          matchDate: matchDate,
          venueId: venueId,
          venueName: venueName,
          matchDuration: matchDuration,
        );
        matches.addAll(currentRound);
        matchDate = matchDate.add(Duration(days: 3));
      }
      // Exit to avoid infinite loop in MVP
      break;
    }

    return matches;
  }

  /// Generate a single knockout round
  List<Match> _generateKnockoutRound({
    required Tournament tournament,
    required List<String> teams,
    required List<String> teamNames,
    required int round,
    required DateTime matchDate,
    required String venueId,
    required String venueName,
    required int matchDuration,
  }) {
    final matches = <Match>[];

    for (int i = 0; i < teams.length; i += 2) {
      if (i + 1 < teams.length) {
        final match = Match(
          id: _generateId(_matchPrefix),
          tournamentId: tournament.id,
          homeTeamId: teams[i],
          homeTeamName: teamNames[i],
          awayTeamId: teams[i + 1],
          awayTeamName: teamNames[i + 1],
          scheduledTime: matchDate,
          venueId: venueId,
          venueName: venueName,
          duration: matchDuration,
          status: MatchStatus.scheduled,
          createdAt: DateTime.now(),
          round: round,
          isKnockout: true,
        );

        matches.add(match);
        matchDate = matchDate.add(Duration(minutes: matchDuration + 30));
      }
    }

    return matches;
  }

  /// Generate group stage and knockout fixtures
  List<Match> _generateGroupAndKnockoutFixtures({
    required Tournament tournament,
    required DateTime startDate,
    required String venueId,
    required String venueName,
    required int matchDuration,
  }) {
    final matches = <Match>[];

    // Calculate number of groups (typically 4, 8, 16 depending on teams)
    final groupCount = _calculateOptimalGroupCount(tournament.teamIds.length);
    final teamsPerGroup = tournament.teamIds.length ~/ groupCount;

    // Generate groups (for MVP, we'll create them)
    final groups = <Group>[];
    for (int g = 0; g < groupCount; g++) {
      final groupTeams = tournament.teamIds
          .skip(g * teamsPerGroup)
          .take(teamsPerGroup)
          .toList();
      final groupTeamNames = tournament.teamNames
          .skip(g * teamsPerGroup)
          .take(teamsPerGroup)
          .toList();

      groups.add(
        Group(
          id: _generateId(_groupPrefix),
          name: 'Group ${String.fromCharCode(65 + g)}',
          teamIds: groupTeams,
          teamNames: groupTeamNames,
          qualifiersCount: 2, // Top 2 from each group advance
        ),
      );
    }

    // Update tournament with groups
    var updatedTournament = tournament.copyWith(groups: groups);
    _tournaments[tournament.id] = updatedTournament;

    // Generate group stage matches (round-robin within each group)
    var matchDate = startDate;
    for (final group in groups) {
      for (int i = 0; i < group.teamIds.length; i++) {
        for (int j = i + 1; j < group.teamIds.length; j++) {
          final match = Match(
            id: _generateId(_matchPrefix),
            tournamentId: tournament.id,
            groupId: group.id,
            homeTeamId: group.teamIds[i],
            homeTeamName: group.teamNames[i],
            awayTeamId: group.teamIds[j],
            awayTeamName: group.teamNames[j],
            scheduledTime: matchDate,
            venueId: venueId,
            venueName: venueName,
            duration: matchDuration,
            status: MatchStatus.scheduled,
            createdAt: DateTime.now(),
            isKnockout: false,
          );

          matches.add(match);
          matchDate = matchDate.add(Duration(minutes: matchDuration + 30));
        }
      }

      // Add spacing between groups
      matchDate = matchDate.add(Duration(days: 1));
    }

    // Generate knockout stage (semi-finals, finals)
    // For MVP, we create placeholder knockouts
    matchDate = matchDate.add(Duration(days: 3));
    final qualifiers = 4; // 2 teams from each of 2 groups for simplicity
    for (int i = 0; i < qualifiers; i += 2) {
      if (i + 1 < qualifiers) {
        final match = Match(
          id: _generateId(_matchPrefix),
          tournamentId: tournament.id,
          homeTeamId: groups[0].teamIds[0], // Placeholder
          homeTeamName: groups[0].teamNames[0],
          awayTeamId: groups[groupCount > 1 ? 1 : 0].teamIds[0],
          awayTeamName: groups[groupCount > 1 ? 1 : 0].teamNames[0],
          scheduledTime: matchDate,
          venueId: venueId,
          venueName: venueName,
          duration: matchDuration,
          status: MatchStatus.scheduled,
          createdAt: DateTime.now(),
          round: 1,
          isKnockout: true,
        );

        matches.add(match);
        matchDate = matchDate.add(Duration(days: 3));
      }
    }

    return matches;
  }

  /// Calculate optimal group count
  int _calculateOptimalGroupCount(int teamCount) {
    if (teamCount <= 4) return 1;
    if (teamCount <= 8) return 2;
    if (teamCount <= 16) return 4;
    return 8;
  }

  /// Calculate max rounds for knockout
  int _calculateMaxRounds(int teamCount) {
    int rounds = 0;
    int temp = teamCount;
    while (temp > 1) {
      temp = temp ~/ 2;
      rounds++;
    }
    return rounds;
  }

  /// Get tournament by ID
  Tournament? getTournament(String id) => _tournaments[id];

  /// Get all tournaments
  List<Tournament> getAllTournaments() => _tournaments.values.toList();

  /// Update tournament
  Tournament? updateTournament(String id, Tournament updated) {
    if (_tournaments.containsKey(id)) {
      _tournaments[id] = updated;
      return updated;
    }
    return null;
  }

  /// Activate tournament
  Tournament? activateTournament(String id) {
    final tournament = getTournament(id);
    if (tournament != null) {
      final updated = tournament.copyWith(status: TournamentStatus.active);
      return updateTournament(id, updated);
    }
    return null;
  }

  /// Complete tournament
  Tournament? completeTournament(String id) {
    final tournament = getTournament(id);
    if (tournament != null) {
      final updated = tournament.copyWith(
        status: TournamentStatus.completed,
        endDate: DateTime.now(),
      );
      return updateTournament(id, updated);
    }
    return null;
  }

  /// Cancel tournament
  Tournament? cancelTournament(String id) {
    final tournament = getTournament(id);
    if (tournament != null) {
      final updated = tournament.copyWith(status: TournamentStatus.cancelled);
      return updateTournament(id, updated);
    }
    return null;
  }

  /// Delete tournament
  bool deleteTournament(String id) {
    _tournaments.remove(id);
    _tournamentMatches.remove(id);
    return true;
  }

  // ========== MATCH MANAGEMENT ==========

  /// Get matches for tournament
  List<Match> getTournamentMatches(String tournamentId) {
    return _tournamentMatches[tournamentId] ?? [];
  }

  /// Get match by ID
  Match? getMatch(String tournamentId, String matchId) {
    return getTournamentMatches(tournamentId)
        .firstWhereOrNull((m) => m.id == matchId);
  }

  /// Update match result
  Match? updateMatchResult(
    String tournamentId,
    String matchId,
    int homeGoals,
    int awayGoals,
  ) {
    final matches = _tournamentMatches[tournamentId];
    if (matches == null) return null;

    final index = matches.indexWhere((m) => m.id == matchId);
    if (index == -1) return null;

    final match = matches[index].copyWith(
      homeTeamGoals: homeGoals,
      awayTeamGoals: awayGoals,
      status: MatchStatus.completed,
    );

    matches[index] = match;
    return match;
  }

  /// Update match status
  Match? updateMatchStatus(
    String tournamentId,
    String matchId,
    MatchStatus status,
  ) {
    final matches = _tournamentMatches[tournamentId];
    if (matches == null) return null;

    final index = matches.indexWhere((m) => m.id == matchId);
    if (index == -1) return null;

    final match = matches[index].copyWith(status: status);
    matches[index] = match;
    return match;
  }

  /// Add match event (goal, card, substitution)
  Match? addMatchEvent(
    String tournamentId,
    String matchId,
    MatchEvent event,
  ) {
    final matches = _tournamentMatches[tournamentId];
    if (matches == null) return null;

    final index = matches.indexWhere((m) => m.id == matchId);
    if (index == -1) return null;

    final match = matches[index];
    final events = List<MatchEvent>.from(match.events ?? [])..add(event);

    final updatedMatch = match.copyWith(events: events);
    matches[index] = updatedMatch;
    return updatedMatch;
  }

  /// Reschedule match
  Match? rescheduleMatch(String tournamentId, String matchId, DateTime newTime) {
    final matches = _tournamentMatches[tournamentId];
    if (matches == null) return null;

    final index = matches.indexWhere((m) => m.id == matchId);
    if (index == -1) return null;

    final match = matches[index].copyWith(scheduledTime: newTime);
    matches[index] = match;
    return match;
  }

  /// Get standings for group stage
  List<TeamStanding> getGroupStandings(String tournamentId, String groupId) {
    final matches = getTournamentMatches(tournamentId)
        .where((m) => m.groupId == groupId && m.isCompleted)
        .toList();

    final standings = <String, TeamStanding>{};

    // Get all teams in group
    final tournament = getTournament(tournamentId);
    if (tournament != null && tournament.groups != null) {
      final groups = tournament.groups!;
      final group = groups.firstWhereOrNull((g) => g.id == groupId);
      if (group != null) {
        for (int i = 0; i < group.teamIds.length; i++) {
          standings[group.teamIds[i]] = TeamStanding(
            teamId: group.teamIds[i],
            teamName: group.teamNames[i],
            played: 0,
            won: 0,
            drawn: 0,
            lost: 0,
            goalsFor: 0,
            goalsAgainst: 0,
            goalDifference: 0,
            points: 0,
          );
        }
      }
    }

    // Update standings with match results
    for (final match in matches) {
      if (match.homeTeamGoals != null && match.awayTeamGoals != null) {
        final homeTeam = standings[match.homeTeamId];
        final awayTeam = standings[match.awayTeamId];

        if (homeTeam != null && awayTeam != null) {
          final isHomeDraw = match.homeTeamGoals == match.awayTeamGoals;
          final isHomeWin = match.homeTeamGoals! > match.awayTeamGoals!;

          standings[match.homeTeamId] = homeTeam.updateWithResult(
            goalsScored: match.homeTeamGoals!,
            goalsAgainst: match.awayTeamGoals!,
            isWin: isHomeWin,
            isDraw: isHomeDraw,
          );

          standings[match.awayTeamId] = awayTeam.updateWithResult(
            goalsScored: match.awayTeamGoals!,
            goalsAgainst: match.homeTeamGoals!,
            isWin: !isHomeWin && !isHomeDraw,
            isDraw: isHomeDraw,
          );
        }
      }
    }

    // Sort by points (descending), then goal difference
    final sortedStandings = standings.values.toList()
      ..sort((a, b) {
        if (b.points != a.points) {
          return b.points.compareTo(a.points);
        }
        if (b.goalDifference != a.goalDifference) {
          return b.goalDifference.compareTo(a.goalDifference);
        }
        return b.goalsFor.compareTo(a.goalsFor);
      });

    return sortedStandings;
  }

  /// Generate ID with prefix
  String _generateId(String prefix) {
    final uuid = const Uuid();
    return '$prefix${uuid.v4().substring(0, 8)}';
  }
}

extension<T> on List<T> {
  T? firstWhereOrNull(bool Function(T) test) {
    for (final element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}
