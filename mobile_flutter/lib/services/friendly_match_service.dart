import 'dart:collection';

import 'package:flutter/foundation.dart';

import '../models/friendly_match.dart';
import 'agenda_service.dart';
import 'match_service.dart';

class FriendlyMatchService {
  FriendlyMatchService._internal();

  static final FriendlyMatchService instance = FriendlyMatchService._internal();

  final ValueNotifier<List<FriendlyMatch>> matchesNotifier = ValueNotifier<List<FriendlyMatch>>(<FriendlyMatch>[]);

  final Map<String, FriendlyMatch> _matches = HashMap<String, FriendlyMatch>();

  final List<String> _defaultCategories = const [
    'Benjamín',
    'Alevín',
    'Infantil',
    'Cadete',
    'Juvenil',
    'Senior',
  ];

  List<String> get categories => List.unmodifiable(_defaultCategories);

  void bootstrapSampleData() {
    if (_matches.isNotEmpty) {
      return;
    }
    final now = DateTime.now();
    final samples = [
      FriendlyMatch(
        id: 'friendly_${now.millisecondsSinceEpoch}',
        opponentClub: 'Atlético Norte',
        opponentContact: 'contacto@atlnorte.es',
        location: 'Campo Municipal',
        scheduledAt: now.add(const Duration(days: 2, hours: 3)),
        category: 'Alevín',
        status: FriendlyMatchStatus.proposed,
        createdByMe: false,
        notes: 'Buscan rival para amistoso con árbitro incluido.',
        createdAt: now.subtract(const Duration(days: 1)),
      ),
      FriendlyMatch(
        id: 'friendly_${now.millisecondsSinceEpoch + 1}',
        opponentClub: 'CF Ribera',
        location: 'Estadio Central',
        scheduledAt: now.add(const Duration(days: 5, hours: 1)),
        category: 'Juvenil',
        status: FriendlyMatchStatus.accepted,
        createdByMe: true,
        notes: 'Confirmado. Llegar 45 minutos antes.',
        createdAt: now.subtract(const Duration(days: 3)),
      ),
    ];

    for (final match in samples) {
      _matches[match.id] = match;
      _syncAgenda(match);
      _syncMatchDetail(match);
    }
    _refreshNotifier();
  }

  List<FriendlyMatch> get matches => matchesNotifier.value;

  FriendlyMatch? findById(String id) => _matches[id];

  FriendlyMatch createMatch({
    required String opponentClub,
    String? opponentContact,
    required String location,
    required DateTime scheduledAt,
    required String category,
    String? notes,
    bool createdByMe = true,
  }) {
    final now = DateTime.now();
    final match = FriendlyMatch(
      id: 'friendly_${now.microsecondsSinceEpoch}',
      opponentClub: opponentClub,
      opponentContact: opponentContact,
      location: location,
      scheduledAt: scheduledAt,
      category: category,
      status: FriendlyMatchStatus.proposed,
      createdByMe: createdByMe,
      notes: notes,
      createdAt: now,
    );
    _upsert(match);
    return match;
  }

  void updateMatch(String id, {
    String? opponentClub,
    String? opponentContact,
    String? location,
    DateTime? scheduledAt,
    String? category,
    String? notes,
  }) {
    final current = _matches[id];
    if (current == null) return;
    final updated = current.copyWith(
      opponentClub: opponentClub,
      opponentContact: opponentContact,
      location: location,
      scheduledAt: scheduledAt,
      category: category,
      notes: notes,
    );
    _upsert(updated);
  }

  void respondToInvitation(String id, FriendlyMatchStatus status) {
    final current = _matches[id];
    if (current == null) return;
    if (status == current.status) return;
    final updated = current.copyWith(status: status);
    _upsert(updated);
  }

  void cancel(String id) {
    final current = _matches[id];
    if (current == null) return;
    if (current.status == FriendlyMatchStatus.cancelled) return;
    _upsert(current.copyWith(status: FriendlyMatchStatus.cancelled));
  }

  void delete(String id) {
    if (_matches.remove(id) != null) {
      AgendaService.instance.removeFriendlyMatch(id);
      _refreshNotifier();
    }
  }

  void _upsert(FriendlyMatch match) {
    _matches[match.id] = match;
    _syncAgenda(match);
    _syncMatchDetail(match);
    _refreshNotifier();
  }

  void _refreshNotifier() {
    final ordered = _matches.values.toList()
      ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
    matchesNotifier.value = ordered;
  }

  void _syncAgenda(FriendlyMatch match) {
    AgendaService.instance.syncFriendlyMatch(match);
  }

  void _syncMatchDetail(FriendlyMatch match) {
    MatchService.instance.upsertFriendlyMatch(match);
  }
}
