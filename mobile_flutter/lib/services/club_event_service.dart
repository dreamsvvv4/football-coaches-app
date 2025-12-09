import '../models/club_event.dart';
import 'agenda_service.dart';
import 'notification_service.dart';
import 'team_follower_service.dart';
import 'package:flutter/material.dart';

  /// RSVP: Add userId to event attendees
  void rsvpToEvent(ClubEvent event, String userId) {
    if (!event.attendees.contains(userId)) {
      event.attendees.add(userId);
    }
  }

  /// Get attendees for an event
  List<String> getAttendees(ClubEvent event) {
    return event.attendees;
  }

/// Premium ClubEventService: creation, recurrence, and distribution
class ClubEventService {
    /// RSVP: Add userId to event attendees
    void rsvpToEvent(ClubEvent event, String userId) {
      if (!event.attendees.contains(userId)) {
        event.attendees.add(userId);
      }
    }

    /// Get attendees for an event
    List<String> getAttendees(ClubEvent event) {
      return event.attendees;
    }
  ClubEventService._();
  static final instance = ClubEventService._();
  final Map<String, List<AgendaItem>> _occurrenceCache = {};

  /// Create an event and distribute + inject into agenda
  void createEvent(ClubEvent event, {bool notify = true}) {
    final range = AgendaService.instance.visibleRange;
    final occ = generateOccurrences(event, range);
    for (final item in occ) {
      AgendaService.instance.injectClubEventIntoAgenda(event, item);
    }
    if (notify) {
      final targets = _resolveTargets(event);
      NotificationService.instance.sendEventCreatedNotification(event, targets);
    }
  }

  /// Update an event and notify (placeholder)
  void updateEvent(ClubEvent event) {
    final range = AgendaService.instance.visibleRange;
    final occ = generateOccurrences(event, range);
    for (final item in occ) {
      AgendaService.instance.injectClubEventIntoAgenda(event, item);
    }
    final targets = _resolveTargets(event);
    NotificationService.instance.sendEventUpdatedNotification(event, targets);
  }

  /// Cancel an event and notify (placeholder)
  void cancelEvent(ClubEvent event) {
    final targets = _resolveTargets(event);
    NotificationService.instance.sendEventCancelledNotification(event, targets);
  }

  /// Generate AgendaItem occurrences from a parent ClubEvent within a range
  List<AgendaItem> generateOccurrences(ClubEvent base, DateRange range) {
    final cacheKey = '${base.id}_${range.start.toIso8601String()}_${range.end.toIso8601String()}';
    final cached = _occurrenceCache[cacheKey];
    if (cached != null) return cached;

    final List<AgendaItem> out = [];
    final duration = base.end.difference(base.start);

    if (base.recurrence == null) {
      out.add(_toAgendaItem(base, startOverride: base.start, endOverride: base.end));
    } else {
      final rule = base.recurrence!;
      DateTime cursor = DateTime(range.start.year, range.start.month, range.start.day, base.start.hour, base.start.minute);
      while (!cursor.isAfter(range.end) && !cursor.isAfter(rule.until)) {
        bool include = false;
        switch (rule.frequency) {
          case RecurrenceFrequency.daily:
            include = true;
            break;
          case RecurrenceFrequency.weekly:
            if (rule.weekdays == null || rule.weekdays!.isEmpty) {
              include = true;
            } else {
              include = rule.weekdays!.contains(cursor.weekday);
            }
            break;
          case RecurrenceFrequency.monthly:
            include = cursor.day == base.start.day;
            break;
        }
        if (include) {
          final end = cursor.add(duration);
          out.add(_toAgendaItem(base, startOverride: cursor, endOverride: end));
        }
        cursor = cursor.add(const Duration(days: 1));
      }
    }
    _occurrenceCache[cacheKey] = out;
    return out;
  }

  AgendaItem _toAgendaItem(ClubEvent event, {DateTime? startOverride, DateTime? endOverride}) {
    final start = startOverride ?? event.start;
    final end = endOverride ?? event.end;
    return AgendaItem(
      id: 'club_${event.id}_${start.millisecondsSinceEpoch}',
      title: event.title,
      subtitle: _subtitleFor(event),
      icon: _iconFor(event),
      when: start,
      matchId: event.type == ClubEventType.match ? event.id : null,
      routeName: null,
    );
  }

  String _subtitleFor(ClubEvent event) {
    switch (event.type) {
      case ClubEventType.training:
        return event.teamId != null ? 'Entrenamiento • Equipo ${event.teamId}' : 'Entrenamiento';
      case ClubEventType.match:
        return event.teamId != null ? 'Partido • Equipo ${event.teamId}' : 'Partido';
      case ClubEventType.announcement:
        return 'Anuncio';
      case ClubEventType.other:
        return 'Evento';
    }
  }

  IconData _iconFor(ClubEvent event) {
    switch (event.type) {
      case ClubEventType.training:
        return Icons.fitness_center;
      case ClubEventType.match:
        return Icons.sports_soccer;
      case ClubEventType.announcement:
        return Icons.campaign;
      case ClubEventType.other:
        return Icons.event;
    }
  }

  List<String> _resolveTargets(ClubEvent event) {
    switch (event.scope) {
      case ClubEventScope.wholeClub:
        // In a real app, fetch all userIds in the club. Here, return custom audience if provided.
        return event.audienceUserIds ?? const [];
      case ClubEventScope.team:
        if (event.teamId == null) return const [];
        return TeamFollowerService.instance.getFollowers(event.teamId!);
      case ClubEventScope.customAudience:
        return event.audienceUserIds ?? const [];
    }
  }
}
