import 'package:flutter/material.dart';

import '../models/friendly_match.dart';
import '../models/club_event.dart';

class DateRange {
  final DateTime start;
  final DateTime end;
  const DateRange({required this.start, required this.end});
}

class AgendaItem {
  final String? id;
  final String title;
  final String subtitle;
  final IconData icon;
  final DateTime when;
  final String? matchId;
  final String? routeName;
  AgendaItem({
    this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.when,
    this.matchId,
    this.routeName,
  });
}

class AgendaService {
  static final AgendaService instance = AgendaService._();
  AgendaService._();

  final Map<String, AgendaItem> _friendlyAgenda = <String, AgendaItem>{};
  final Map<String, AgendaItem> _customAgenda = <String, AgendaItem>{};
  final ValueNotifier<List<AgendaItem>> agendaNotifier = ValueNotifier<List<AgendaItem>>(<AgendaItem>[]);

  final List<AgendaItem> _staticItems = [
    // Tournaments hidden: replace with training placeholder
    AgendaItem(
      title: 'Entrenamiento semanal',
      subtitle: 'U12 · Campo 2 · 17:00',
      icon: Icons.fitness_center,
      when: DateTime.now().add(const Duration(days: 1, hours: 2)),
      routeName: '/calendar',
    ),
  ];

  Future<List<AgendaItem>> getUpcoming() async {
    final merged = [..._staticItems, ..._friendlyAgenda.values, ..._customAgenda.values];
    merged.sort((a, b) => a.when.compareTo(b.when));
    return merged;
  }

  DateRange get visibleRange => DateRange(
        start: DateTime.now(),
        end: DateTime.now().add(const Duration(days: 30)),
      );

  void syncFriendlyMatch(FriendlyMatch match) {
    if (!match.isActive) {
      removeFriendlyMatch(match.id);
      return;
    }

    final agendaItem = AgendaItem(
      title: 'Amistoso vs ${match.opponentClub}',
      subtitle: '${match.category} · ${match.location} · ${match.status.label}',
      icon: Icons.sports_soccer,
      when: match.scheduledAt,
      matchId: match.id,
      routeName: '/friendly_matches',
    );
    _friendlyAgenda[match.id] = agendaItem;
    _refreshNotifier();
  }

  void removeFriendlyMatch(String id) {
    _friendlyAgenda.remove(id);
    _refreshNotifier();
  }

  // Create custom events (training, meeting, etc.)
  void createCustomEvent(AgendaItem item) {
    // Avoid duplicates using id or matchId
    final key = item.id ?? item.matchId ?? '${item.title}_${item.when.millisecondsSinceEpoch}';
    if (_customAgenda.containsKey(key) || _friendlyAgenda.containsKey(key)) {
      return;
    }
    _customAgenda[key] = item;
    _applyRelevantRangePrune();
    _refreshNotifier();
  }

  void _applyRelevantRangePrune() {
    // Keep only items within relevant time range for dynamic stores
    final range = {
      'start': DateTime.now(),
      'end': DateTime.now().add(const Duration(days: 7)),
    };
    final start = range['start']!;
    final end = range['end']!;
    _customAgenda.removeWhere((_, it) => it.when.isBefore(start) || it.when.isAfter(end));
    _friendlyAgenda.removeWhere((_, it) => it.when.isBefore(start) || it.when.isAfter(end));
  }

  void _refreshNotifier() async {
    final items = await getUpcoming();
    agendaNotifier.value = items;
  }

  /// Inject a club event AgendaItem produced by ClubEventService
  void injectClubEventIntoAgenda(ClubEvent event, AgendaItem agendaItem) {
    final key = agendaItem.id ?? 'club_${event.id}_${agendaItem.when.millisecondsSinceEpoch}';
    _customAgenda[key] = agendaItem;
    _applyRelevantRangePrune();
    _refreshNotifier();
  }
}
