enum ClubEventType { match, training, announcement, other }

enum ClubEventScope { wholeClub, team, customAudience }

enum RecurrenceFrequency { weekly, monthly, daily }

class RecurrenceRule {
  final RecurrenceFrequency frequency;
  final int interval; // e.g., every N units
  final List<int>? weekdays; // for weekly
  final DateTime until; // end date for series

  const RecurrenceRule({
    required this.frequency,
    this.interval = 1,
    this.weekdays,
    required this.until,
  });
}

class ClubEvent {
  final String id;
  final String title;
  final String description;
  final DateTime start;
  final DateTime end;
  final ClubEventType type; // match, training, announcement, other
  final ClubEventScope scope; // club, team, customAudience
  final String? teamId;
  final List<String>? audienceUserIds; // only for customAudience
  final RecurrenceRule? recurrence;
  final String createdByUserId;

  final List<String> attendees; // userIds who RSVP'd

  const ClubEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.start,
    required this.end,
    required this.type,
    required this.scope,
    this.teamId,
    this.audienceUserIds,
    this.recurrence,
    required this.createdByUserId,
    this.attendees = const [],
  });
}
