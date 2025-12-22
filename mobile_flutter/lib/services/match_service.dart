import 'dart:async';

import '../models/friendly_match.dart';
import 'notification_service.dart';

class MatchEvent {
  final String minute;
  final String type; // goal, yellow_card, red_card, sub, match_end
  final String description;
  final String team; // home | away
  final String? player;
  final String? recordedById;
  final String? recordedByName;
  final DateTime? recordedAt;

  MatchEvent({
    required this.minute,
    required this.type,
    required this.description,
    required this.team,
    this.player,
    this.recordedById,
    this.recordedByName,
    this.recordedAt,
  });
}

class MatchDetail {
  final String id;
  final String homeTeam;
  final String awayTeam;
  final String competition;
  final DateTime kickoff;
  final String venue;
  final String status; // scheduled, live, finished
  final List<String> homeLineup;
  final List<String> awayLineup;
  final List<MatchEvent> timeline;
  final int homeScore;
  final int awayScore;

  MatchDetail({
    required this.id,
    required this.homeTeam,
    required this.awayTeam,
    required this.competition,
    required this.kickoff,
    required this.venue,
    required this.status,
    required this.homeLineup,
    required this.awayLineup,
    required this.timeline,
    required this.homeScore,
    required this.awayScore,
  });

  MatchDetail copyWith({
    String? status,
    List<MatchEvent>? timeline,
    List<String>? homeLineup,
    List<String>? awayLineup,
    int? homeScore,
    int? awayScore,
  }) {
    return MatchDetail(
      id: id,
      homeTeam: homeTeam,
      awayTeam: awayTeam,
      competition: competition,
      kickoff: kickoff,
      venue: venue,
      status: status ?? this.status,
      homeLineup: homeLineup ?? this.homeLineup,
      awayLineup: awayLineup ?? this.awayLineup,
      timeline: timeline ?? this.timeline,
      homeScore: homeScore ?? this.homeScore,
      awayScore: awayScore ?? this.awayScore,
    );
  }
}

class MatchService {
  static final MatchService instance = MatchService._();
  MatchService._();

  final Map<String, MatchDetail> _store = {};
  final Map<String, StreamController<MatchDetail>> _streams = {};

  StreamController<MatchDetail> _controllerFor(String matchId) {
    return _streams.putIfAbsent(
      matchId,
      () => StreamController<MatchDetail>.broadcast(),
    );
  }

  void _emitMatch(String matchId) {
    final detail = _store[matchId];
    if (detail == null) return;
    final controller = _streams[matchId];
    if (controller != null && !controller.isClosed) {
      controller.add(detail);
    }
  }

  Future<MatchDetail> fetchMatch(String matchId) async {
    if (matchId.trim().isEmpty || matchId.toLowerCase().startsWith('invalid')) {
      throw StateError('Match not found');
    }
    if (_store.containsKey(matchId)) {
      final detail = _store[matchId]!;
      _emitMatch(matchId);
      return detail;
    }
    // fallback mock if not stored
    final fallback = MatchDetail(
      id: matchId,
      homeTeam: 'Equipo A',
      awayTeam: 'Equipo B',
      competition: 'Liga Municipal',
      kickoff: DateTime.now().add(const Duration(hours: 3)),
      venue: 'Campo Municipal',
      status: 'scheduled',
      homeLineup: List.generate(11, (i) => 'Jugador A${i + 1}'),
      awayLineup: List.generate(11, (i) => 'Jugador B${i + 1}'),
      timeline: const [],
      homeScore: 0,
      awayScore: 0,
    );
    _store[matchId] = fallback;
    _emitMatch(matchId);
    return fallback;
  }

  void upsertFriendlyMatch(FriendlyMatch friendly) {
    final id = friendly.id;
    final existing = _store[id];

    final bool weAreHome = friendly.createdByMe;
    final String ourTeam = 'Nuestro Club';
    final String homeTeam = weAreHome ? ourTeam : friendly.opponentClub;
    final String awayTeam = weAreHome ? friendly.opponentClub : ourTeam;

    final String status;
    switch (friendly.status) {
      case FriendlyMatchStatus.accepted:
      case FriendlyMatchStatus.proposed:
        status = 'scheduled';
        break;
      case FriendlyMatchStatus.rejected:
      case FriendlyMatchStatus.cancelled:
        status = 'finished';
        break;
    }

    _store[id] = MatchDetail(
      id: id,
      homeTeam: existing?.homeTeam ?? homeTeam,
      awayTeam: existing?.awayTeam ?? awayTeam,
      competition: existing?.competition ?? 'Amistoso',
      kickoff: friendly.scheduledAt,
      venue: friendly.location,
      status: status,
      homeLineup: existing?.homeLineup ?? List.generate(11, (i) => 'Jugador Local ${i + 1}'),
      awayLineup: existing?.awayLineup ?? List.generate(11, (i) => 'Jugador Riv ${i + 1}'),
      timeline: existing?.timeline ?? const [],
      homeScore: existing?.homeScore ?? 0,
      awayScore: existing?.awayScore ?? 0,
    );
    _emitMatch(id);
  }

  void addEvent(String matchId, MatchEvent event) {
    final current = _store[matchId];
    if (current == null) return;
    int home = current.homeScore;
    int away = current.awayScore;
    
    // Trigger notifications based on event type
    _notifyMatchEvent(matchId, current, event);
    
    if (event.type == 'goal') {
      if (event.team == 'home') {
        home += 1;
      } else {
        away += 1;
      }
    }
    final updatedTimeline = _sortedTimeline(List<MatchEvent>.from(current.timeline)..add(event));
    String nextStatus = current.status;
    if (nextStatus == 'scheduled') {
      nextStatus = 'live';
    }
    _store[matchId] = current.copyWith(
      timeline: updatedTimeline,
      homeScore: home,
      awayScore: away,
      status: nextStatus,
    );
    _emitMatch(matchId);
  }

  void endMatch(String matchId, {MatchEvent? closingEvent}) {
    final current = _store[matchId];
    if (current == null) return;
    
    // Notify match ended
    NotificationService.instance.subscribeToMatch(matchId); // Ensure subscribed
    
    final timeline = List<MatchEvent>.from(current.timeline);
    if (closingEvent != null) {
      timeline.add(closingEvent);
    }
    _store[matchId] = current.copyWith(
      status: 'finished',
      timeline: _sortedTimeline(timeline),
    );
    _emitMatch(matchId);
  }

  /// Notify subscribers about match events
  Future<void> _notifyMatchEvent(
    String matchId,
    MatchDetail match,
    MatchEvent event,
  ) async {
    final notificationService = NotificationService.instance;
    
    switch (event.type) {
      case 'goal':
        final teamName = event.team == 'home' ? match.homeTeam : match.awayTeam;
        final playerName = event.player ?? 'Unknown Player';
        await notificationService.subscribeToMatch(matchId);
        // In real scenario, FCM would deliver this
        if (notificationService.isInitialized) {
          print('Match notification: Goal by $playerName for $teamName');
        }
        break;
        
      case 'yellow_card':
        final playerName = event.player ?? 'Unknown Player';
        await notificationService.subscribeToMatch(matchId);
        if (notificationService.isInitialized) {
          print('Match notification: Yellow card to $playerName');
        }
        break;
        
      case 'red_card':
        final playerName = event.player ?? 'Unknown Player';
        await notificationService.subscribeToMatch(matchId);
        if (notificationService.isInitialized) {
          print('Match notification: Red card to $playerName');
        }
        break;
        
      case 'sub':
        final playerName = event.player ?? 'Unknown Player';
        await notificationService.subscribeToMatch(matchId);
        if (notificationService.isInitialized) {
          print('Match notification: Substitution - $playerName');
        }
        break;
        
      case 'match_end':
        await notificationService.subscribeToMatch(matchId);
        if (notificationService.isInitialized) {
          print('Match notification: Match ended - ${match.homeTeam} ${match.homeScore} - ${match.awayScore} ${match.awayTeam}');
        }
        break;
    }
  }

  Stream<MatchDetail> watchMatch(String matchId) {
    final controller = _streams.putIfAbsent(matchId, () {
      late StreamController<MatchDetail> created;
      created = StreamController<MatchDetail>.broadcast(
        onListen: () {
          final existing = _store[matchId];
          if (existing != null) {
            if (!created.isClosed) created.add(existing);
          } else {
            // Load data; fetchMatch will emit when ready.
            fetchMatch(matchId).then(
              (_) {},
              onError: (Object e, StackTrace st) {
                if (!created.isClosed) created.addError(e, st);
              },
            );
          }
        },
      );
      return created;
    });
    return controller.stream;
  }

  int _minuteValue(String minute) {
    final regex = RegExp(r'(\d+)(?:\+(\d+))?');
    final match = regex.firstMatch(minute);
    if (match == null) return 100000;
    final base = int.tryParse(match.group(1) ?? '') ?? 0;
    final extra = int.tryParse(match.group(2) ?? '') ?? 0;
    return base * 100 + extra;
  }

  List<MatchEvent> _sortedTimeline(List<MatchEvent> events) {
    events.sort((a, b) {
      final aTime = a.recordedAt?.millisecondsSinceEpoch ?? 0;
      final bTime = b.recordedAt?.millisecondsSinceEpoch ?? 0;
      if (aTime != bTime) return aTime.compareTo(bTime);
      return _minuteValue(a.minute).compareTo(_minuteValue(b.minute));
    });
    return events;
  }
}
