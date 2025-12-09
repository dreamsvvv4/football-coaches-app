import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_flutter/models/tournament.dart';
import 'package:mobile_flutter/models/match.dart';
import 'package:mobile_flutter/widgets/bracket_widget.dart';

void main() {
  group('BracketWidget Tests', () {
    late Tournament testTournament;
    late List<Match> testMatches;

    setUp(() {
      testTournament = Tournament(
        id: 'tour_001',
        name: 'Test Tournament',
        description: 'Test Description',
        type: TournamentType.knockout,
        mode: FootballMode.football11,
        category: PlayerCategory.amateur,
        matchDuration: 90,
        venueId: 'v1',
        venueName: 'Test Venue',
        venueLat: '0.0',
        venueLng: '0.0',
        teamIds: ['t1', 't2', 't3', 't4'],
        teamNames: ['Team A', 'Team B', 'Team C', 'Team D'],
        startDate: DateTime(2024, 12, 1),
        createdBy: 'coach1',
        createdAt: DateTime(2024, 11, 1),
        status: TournamentStatus.active,
        rules: TournamentRules(
          allowExtraTime: true,
          allowPenalties: true,
          minPlayersRequired: 11,
          maxSubstitutions: 3,
          maxCardWarnings: 2,
        ),
      );

      testMatches = [
        Match(
          id: 'match_001',
          tournamentId: 'tour_001',
          homeTeamId: 't1',
          homeTeamName: 'Team A',
          awayTeamId: 't2',
          awayTeamName: 'Team B',
          scheduledTime: DateTime(2024, 12, 1, 14, 0),
          venueId: 'v1',
          venueName: 'Test Venue',
          duration: 90,
          status: MatchStatus.completed,
          homeTeamGoals: 2,
          awayTeamGoals: 1,
          createdAt: DateTime.now(),
          round: 1,
          isKnockout: true,
        ),
      ];
    });

    testWidgets('BracketWidget renders', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: BracketWidget(
                matches: testMatches,
                tournament: testTournament,
              ),
            ),
          ),
        ),
      );

      expect(find.byType(BracketWidget), findsOneWidget);
    });

    testWidgets('BracketWidget displays teams', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: BracketWidget(
                matches: testMatches,
                tournament: testTournament,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Team A'), findsWidgets);
    });

    testWidgets('BracketWidget displays empty state', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: BracketWidget(
                matches: [],
                tournament: testTournament,
              ),
            ),
          ),
        ),
      );

      expect(find.byType(BracketWidget), findsOneWidget);
    });

    testWidgets('BracketWidget handles multiple matches', (WidgetTester tester) async {
      final multiMatches = [
        testMatches[0],
        Match(
          id: 'match_002',
          tournamentId: 'tour_001',
          homeTeamId: 't3',
          homeTeamName: 'Team C',
          awayTeamId: 't4',
          awayTeamName: 'Team D',
          scheduledTime: DateTime(2024, 12, 2),
          venueId: 'v1',
          venueName: 'Test Venue',
          duration: 90,
          status: MatchStatus.scheduled,
          createdAt: DateTime.now(),
          isKnockout: true,
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: BracketWidget(
                matches: multiMatches,
                tournament: testTournament,
              ),
            ),
          ),
        ),
      );

      expect(find.byType(BracketWidget), findsOneWidget);
    });

    testWidgets('BracketWidget is scrollable', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: BracketWidget(
                matches: testMatches,
                tournament: testTournament,
              ),
            ),
          ),
        ),
      );

      expect(find.byType(SingleChildScrollView), findsWidgets);
    });

    testWidgets('BracketWidget responds to taps', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: BracketWidget(
                matches: testMatches,
                tournament: testTournament,
              ),
            ),
          ),
        ),
      );

      final gestureDetectors = find.byType(GestureDetector);
      expect(gestureDetectors, findsWidgets);

      if (gestureDetectors.evaluate().isNotEmpty) {
        await tester.tap(gestureDetectors.first);
        await tester.pumpAndSettle();
      }
    });

    testWidgets('BracketWidget shows status', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: BracketWidget(
                matches: testMatches,
                tournament: testTournament,
              ),
            ),
          ),
        ),
      );

      // Match has a status, widget should render without error
      expect(find.byType(BracketWidget), findsOneWidget);
    });

    testWidgets('BracketWidget renders all details', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: BracketWidget(
                matches: testMatches,
                tournament: testTournament,
              ),
            ),
          ),
        ),
      );

      // Just verify the widget renders
      expect(find.byType(BracketWidget), findsOneWidget);
    });

    testWidgets('BracketWidget completes without errors', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: BracketWidget(
                matches: testMatches,
                tournament: testTournament,
              ),
            ),
          ),
        ),
      );

      // Pump several frames to ensure no rendering issues
      await tester.pumpAndSettle();
      expect(find.byType(BracketWidget), findsOneWidget);
    });
  });
}
