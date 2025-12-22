import 'package:cloud_firestore/cloud_firestore.dart';

enum FriendlyMatchRequestStatus { pending, accepted, rejected, modified }

class FriendlyMatchRequest {
  final String id;
  final String fromClubId;
  final String fromTeamId;
  final String toClubId;
  final String toTeamId;
  final FriendlyMatchRequestStatus status;
  final DateTime proposedDate;
  final String proposedLocation;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? notes;

  FriendlyMatchRequest({
    required this.id,
    required this.fromClubId,
    required this.fromTeamId,
    required this.toClubId,
    required this.toTeamId,
    required this.status,
    required this.proposedDate,
    required this.proposedLocation,
    required this.createdAt,
    required this.updatedAt,
    this.notes,
  });

  factory FriendlyMatchRequest.fromMap(Map<String, dynamic> map, String id) {
    return FriendlyMatchRequest(
      id: id,
      fromClubId: map['fromClubId'],
      fromTeamId: map['fromTeamId'],
      toClubId: map['toClubId'],
      toTeamId: map['toTeamId'],
      status: FriendlyMatchRequestStatus.values.firstWhere((e) => e.toString().split('.').last == map['status']),
      proposedDate: (map['proposedDate'] is Timestamp) ? (map['proposedDate'] as Timestamp).toDate() : DateTime.parse(map['proposedDate']),
      proposedLocation: map['proposedLocation'],
      createdAt: (map['createdAt'] is Timestamp) ? (map['createdAt'] as Timestamp).toDate() : DateTime.parse(map['createdAt']),
      updatedAt: (map['updatedAt'] is Timestamp) ? (map['updatedAt'] as Timestamp).toDate() : DateTime.parse(map['updatedAt']),
      notes: map['notes'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fromClubId': fromClubId,
      'fromTeamId': fromTeamId,
      'toClubId': toClubId,
      'toTeamId': toTeamId,
      'status': status.toString().split('.').last,
      'proposedDate': Timestamp.fromDate(proposedDate),
      'proposedLocation': proposedLocation,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'notes': notes,
    };
  }

  // Add missing getters for compatibility
  String get category => 'friendly';
  String get opponentClub => toClubId;
  DateTime get scheduledAt => proposedDate;
  bool get createdByMe => false;
}
