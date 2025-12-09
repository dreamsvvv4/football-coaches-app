import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_flutter/models/tournament.dart';
import 'package:mobile_flutter/models/match.dart';
import 'package:mobile_flutter/services/tournament_service.dart';

void main() {
  group('TournamentService', () {
    late TournamentService service;

    setUp(() {
      service = TournamentService();
    });

    group('Tournament Creation', () {
      test('Creates a new tournament with correct properties', () {
        final tournament = service.createTournament(
          name: 'Test Tournament',
          description: 'A test tournament',
          type: TournamentType.roundRobin,
          mode: FootballMode.football11,
          category: PlayerCategory.professional,
          matchDuration: 90,
          venueId: 'v1',
          venueName: 'Stadium',
          venueLat: '0.0',
          venueLng: '0.0',
          teamIds: ['t1', 't2', 't3', 't4'],
          teamNames: ['Team A', 'Team B', 'Team C', 'Team D'],
          startDate: DateTime(2024, 12, 1),
          createdBy: 'coach1',
        );

        expect(tournament.name, 'Test Tournament');
        expect(tournament.type, TournamentType.roundRobin);
        expect(tournament.status, TournamentStatus.draft);
        expect(tournament.teamIds.length, 4);
        expect(tournament.id, isNotEmpty);
      });

      test('Tournament IDs are unique', () {
        final t1 = service.createTournament(
          name: 'Tournament 1',
          description: 'First',
          type: TournamentType.roundRobin,
          mode: FootballMode.football11,
          category: PlayerCategory.amateur,
          matchDuration: 90,
          venueId: 'v1',
          venueName: 'Stadium 1',
          venueLat: '0.0',
          venueLng: '0.0',
          teamIds: ['t1', 't2'],
          teamNames: ['Team A', 'Team B'],
          startDate: DateTime(2024, 12, 1),
          createdBy: 'coach1',
        );

        final t2 = service.createTournament(
          name: 'Tournament 2',
          description: 'Second',
          type: TournamentType.knockout,
          mode: FootballMode.football7,
          category: PlayerCategory.junior,
          matchDuration: 60,
          venueId: 'v2',
          venueName: 'Stadium 2',
          venueLat: '0.0',
          venueLng: '0.0',
          teamIds: ['t3', 't4'],
          teamNames: ['Team C', 'Team D'],
          startDate: DateTime(2024, 12, 2),
          createdBy: 'coach2',
        );

        expect(t1.id, isNot(t2.id));
      });

      test('Retrieved tournament matches creation', () {
        final tournament = service.createTournament(
          name: 'Test',
          description: 'Test',
          type: TournamentType.roundRobin,
          mode: FootballMode.football11,
          category: PlayerCategory.amateur,
          matchDuration: 90,
          venueId: 'v1',
          venueName: 'Stadium',
          venueLat: '0.0',
          venueLng: '0.0',
          teamIds: ['t1', 't2'],
          teamNames: ['Team A', 'Team B'],
          startDate: DateTime(2024, 12, 1),
          createdBy: 'coach1',
        );

        final retrieved = service.getTournament(tournament.id);
        expect(retrieved, isNotNull);
        expect(retrieved!.id, tournament.id);
        expect(retrieved.name, tournament.name);
      });
    });

    group('Fixture Generation - Round Robin', () {
      late Tournament tournament;

      setUp(() {
        tournament = service.createTournament(
          name: 'Round Robin Test',
          description: 'Testing round robin fixtures',
          type: TournamentType.roundRobin,
          mode: FootballMode.football11,
          category: PlayerCategory.amateur,
          matchDuration: 90,
          venueId: 'v1',
          venueName: 'Stadium',
          venueLat: '0.0',
          venueLng: '0.0',
          teamIds: ['t1', 't2', 't3', 't4'],
          teamNames: ['Team A', 'Team B', 'Team C', 'Team D'],
          startDate: DateTime(2024, 12, 1),
          createdBy: 'coach1',
        );
      });

      test('Generates correct number of round-robin matches', () {
        final matches = service.generateFixtures(
          tournamentId: tournament.id,
          startDate: DateTime(2024, 12, 1),
          venueId: 'v1',
          venueName: 'Stadium',
          matchDuration: 90,
        );

        // With 4 teams: 4 * 3 / 2 = 6 matches
        expect(matches.length, 6);
      });

      test('No team plays itself in round robin', () {
        final matches = service.generateFixtures(
          tournamentId: tournament.id,
          startDate: DateTime(2024, 12, 1),
          venueId: 'v1',
          venueName: 'Stadium',
          matchDuration: 90,
        );

        for (final match in matches) {
          expect(match.homeTeamId, isNot(match.awayTeamId));
        }
      });

      test('No duplicate matches in round robin', () {
        final matches = service.generateFixtures(
          tournamentId: tournament.id,
          startDate: DateTime(2024, 12, 1),
          venueId: 'v1',
          venueName: 'Stadium',
          matchDuration: 90,
        );

        final matchPairs = <String>{};
        for (final match in matches) {
          final pair = {match.homeTeamId, match.awayTeamId}.toList()..sort();
          final pairKey = '${pair[0]}-${pair[1]}';
          expect(matchPairs.contains(pairKey), false);
          matchPairs.add(pairKey);
        }
      });

      test('All teams participate in round robin', () {
        final matches = service.generateFixtures(
          tournamentId: tournament.id,
          startDate: DateTime(2024, 12, 1),
          venueId: 'v1',
          venueName: 'Stadium',
          matchDuration: 90,
        );

        final teams = <String>{};
        for (final match in matches) {
          teams.add(match.homeTeamId);
          teams.add(match.awayTeamId);
        }

        expect(teams.length, 4);
        for (final teamId in tournament.teamIds) {
          expect(teams.contains(teamId), true);
        }
      });
    });

    group('Fixture Generation - Knockout', () {
      late Tournament tournament;

      setUp(() {
        tournament = service.createTournament(
          name: 'Knockout Test',
          description: 'Testing knockout fixtures',
          type: TournamentType.knockout,
          mode: FootballMode.football11,
          category: PlayerCategory.professional,
          matchDuration: 90,
          venueId: 'v1',
          venueName: 'Stadium',
          venueLat: '0.0',
          venueLng: '0.0',
          teamIds: ['t1', 't2', 't3', 't4'],
          teamNames: ['Team A', 'Team B', 'Team C', 'Team D'],
          startDate: DateTime(2024, 12, 1),
          createdBy: 'coach1',
        );
      });

      test('Generates knockout bracket', () {
        final matches = service.generateFixtures(
          tournamentId: tournament.id,
          startDate: DateTime(2024, 12, 1),
          venueId: 'v1',
          venueName: 'Stadium',
          matchDuration: 90,
        );

        expect(matches.isNotEmpty, true);
        final knockoutMatches = matches.where((m) => m.isKnockout).toList();
        expect(knockoutMatches.isNotEmpty, true);
      });
    });

    group('Match Management', () {
      late Tournament tournament;
      late List<Match> matches;

      setUp(() {
        tournament = service.createTournament(
          name: 'Match Test',
          description: 'Testing match management',
          type: TournamentType.roundRobin,
          mode: FootballMode.football11,
          category: PlayerCategory.amateur,
          matchDuration: 90,
          venueId: 'v1',
          venueName: 'Stadium',
          venueLat: '0.0',
          venueLng: '0.0',
          teamIds: ['t1', 't2', 't3'],
          teamNames: ['Team A', 'Team B', 'Team C'],
          startDate: DateTime(2024, 12, 1),
          createdBy: 'coach1',
        );

        matches = service.generateFixtures(
          tournamentId: tournament.id,
          startDate: DateTime(2024, 12, 1),
          venueId: 'v1',
          venueName: 'Stadium',
          matchDuration: 90,
        );
      });

      test('Updates match result correctly', () {
        final match = matches.first;
        final updated = service.updateMatchResult(
          tournament.id,
          match.id,
          3,
          1,
        );

        expect(updated, isNotNull);
        expect(updated!.homeTeamGoals, 3);
        expect(updated.awayTeamGoals, 1);
        expect(updated.status, MatchStatus.completed);
      });

      test('Updates match status', () {
        final match = matches.first;
        final updated = service.updateMatchStatus(
          tournament.id,
          match.id,
          MatchStatus.inProgress,
        );

        expect(updated, isNotNull);
        expect(updated!.status, MatchStatus.inProgress);
      });

      test('Adds match event', () {
        final match = matches.first;
        final event = MatchEvent(
          id: 'evt_123',
          matchId: match.id,
          type: MatchEventType.goal,
          minute: 25,
          teamId: match.homeTeamId,
          teamName: match.homeTeamName,
          playerId: 'p1',
          playerName: 'Player One',
          createdAt: DateTime.now(),
        );

        final updated = service.addMatchEvent(
          tournament.id,
          match.id,
          event,
        );

        expect(updated, isNotNull);
        expect(updated!.events, isNotNull);
        expect(updated.events!.length, 1);
        expect(updated.events!.first.type, MatchEventType.goal);
      });

      test('Reschedules match', () {
        final match = matches.first;
        final newTime = DateTime(2024, 12, 5, 14, 30);
        final updated = service.rescheduleMatch(
          tournament.id,
          match.id,
          newTime,
        );

        expect(updated, isNotNull);
        expect(updated!.scheduledTime, newTime);
      });
    });

    group('Tournament Status Management', () {
      late Tournament tournament;

      setUp(() {
        tournament = service.createTournament(
          name: 'Status Test',
          description: 'Testing status management',
          type: TournamentType.roundRobin,
          mode: FootballMode.football11,
          category: PlayerCategory.amateur,
          matchDuration: 90,
          venueId: 'v1',
          venueName: 'Stadium',
          venueLat: '0.0',
          venueLng: '0.0',
          teamIds: ['t1', 't2'],
          teamNames: ['Team A', 'Team B'],
          startDate: DateTime(2024, 12, 1),
          createdBy: 'coach1',
        );
      });

      test('Activates tournament from draft', () {
        expect(tournament.status, TournamentStatus.draft);

        final activated = service.activateTournament(tournament.id);

        expect(activated, isNotNull);
        expect(activated!.status, TournamentStatus.active);
      });

      test('Completes tournament', () {
        final activated = service.activateTournament(tournament.id)!;
        final completed = service.completeTournament(activated.id);

        expect(completed, isNotNull);
        expect(completed!.status, TournamentStatus.completed);
        expect(completed.endDate, isNotNull);
      });

      test('Cancels tournament', () {
        final cancelled = service.cancelTournament(tournament.id);

        expect(cancelled, isNotNull);
        expect(cancelled!.status, TournamentStatus.cancelled);
      });
    });

    group('Tournament CRUD Operations', () {
      test('Updates tournament', () {
        final tournament = service.createTournament(
          name: 'Original Name',
          description: 'Original description',
          type: TournamentType.roundRobin,
          mode: FootballMode.football11,
          category: PlayerCategory.amateur,
          matchDuration: 90,
          venueId: 'v1',
          venueName: 'Stadium',
          venueLat: '0.0',
          venueLng: '0.0',
          teamIds: ['t1', 't2'],
          teamNames: ['Team A', 'Team B'],
          startDate: DateTime(2024, 12, 1),
          createdBy: 'coach1',
        );

        final updated = tournament.copyWith(
          name: 'Updated Name',
          description: 'Updated description',
        );

        final savedUpdate = service.updateTournament(tournament.id, updated);

        expect(savedUpdate, isNotNull);
        expect(savedUpdate!.name, 'Updated Name');
        expect(savedUpdate.description, 'Updated description');
      });

      test('Deletes tournament', () {
        final tournament = service.createTournament(
          name: 'Delete Test',
          description: 'To be deleted',
          type: TournamentType.roundRobin,
          mode: FootballMode.football11,
          category: PlayerCategory.amateur,
          matchDuration: 90,
          venueId: 'v1',
          venueName: 'Stadium',
          venueLat: '0.0',
          venueLng: '0.0',
          teamIds: ['t1', 't2'],
          teamNames: ['Team A', 'Team B'],
          startDate: DateTime(2024, 12, 1),
          createdBy: 'coach1',
        );

        final deleted = service.deleteTournament(tournament.id);
        expect(deleted, true);

        final retrieved = service.getTournament(tournament.id);
        expect(retrieved, isNull);
      });

      test('Gets all tournaments', () {
        service.createTournament(
          name: 'Tournament 1',
          description: 'First',
          type: TournamentType.roundRobin,
          mode: FootballMode.football11,
          category: PlayerCategory.amateur,
          matchDuration: 90,
          venueId: 'v1',
          venueName: 'Stadium',
          venueLat: '0.0',
          venueLng: '0.0',
          teamIds: ['t1', 't2'],
          teamNames: ['Team A', 'Team B'],
          startDate: DateTime(2024, 12, 1),
          createdBy: 'coach1',
        );

        service.createTournament(
          name: 'Tournament 2',
          description: 'Second',
          type: TournamentType.knockout,
          mode: FootballMode.football7,
          category: PlayerCategory.junior,
          matchDuration: 60,
          venueId: 'v2',
          venueName: 'Stadium 2',
          venueLat: '0.0',
          venueLng: '0.0',
          teamIds: ['t3', 't4'],
          teamNames: ['Team C', 'Team D'],
          startDate: DateTime(2024, 12, 2),
          createdBy: 'coach2',
        );

        final all = service.getAllTournaments();
        expect(all.length, 2);
      });
    });

    group('Group Standings', () {
      late Tournament tournament;
      late String groupId;

      setUp(() {
        tournament = service.createTournament(
          name: 'Standings Test',
          description: 'Testing standings',
          type: TournamentType.mixed,
          mode: FootballMode.football11,
          category: PlayerCategory.amateur,
          matchDuration: 90,
          venueId: 'v1',
          venueName: 'Stadium',
          venueLat: '0.0',
          venueLng: '0.0',
          teamIds: ['t1', 't2', 't3', 't4'],
          teamNames: ['Team A', 'Team B', 'Team C', 'Team D'],
          startDate: DateTime(2024, 12, 1),
          createdBy: 'coach1',
        );

        service.generateFixtures(
          tournamentId: tournament.id,
          startDate: DateTime(2024, 12, 1),
          venueId: 'v1',
          venueName: 'Stadium',
          matchDuration: 90,
        );

        tournament = service.getTournament(tournament.id)!;
        if (tournament.groups != null && tournament.groups!.isNotEmpty) {
          groupId = tournament.groups!.first.id;
        }
      });

      test('Calculates standings correctly', () {
        if (tournament.groups == null) return;

        final standings = service.getGroupStandings(tournament.id, groupId);
        expect(standings.isNotEmpty, true);
      });

      test('Sorts standings by points', () {
        if (tournament.groups == null) return;

        final standings = service.getGroupStandings(tournament.id, groupId);
        
        for (int i = 0; i < standings.length - 1; i++) {
          expect(
            standings[i].points >= standings[i + 1].points,
            true,
            reason: 'Standings should be sorted by points descending',
          );
        }
      });
    });
  });
}
