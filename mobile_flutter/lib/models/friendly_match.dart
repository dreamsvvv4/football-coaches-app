import 'package:cloud_firestore/cloud_firestore.dart';

enum FriendlyMatchStatus {
  proposed,
  accepted,
  rejected,
  cancelled,
}

extension FriendlyMatchStatusLabel on FriendlyMatchStatus {
  String get label {
    switch (this) {
      case FriendlyMatchStatus.proposed:
        return 'Pendiente';
      case FriendlyMatchStatus.accepted:
        return 'Confirmado';
      case FriendlyMatchStatus.rejected:
        return 'Rechazado';
      case FriendlyMatchStatus.cancelled:
        return 'Cancelado';
    }
  }

  String get internalName {
    return toString().split('.').last;
  }
}

FriendlyMatchStatus friendlyMatchStatusFromString(String? value) {
  switch (value) {
    case 'accepted':
      return FriendlyMatchStatus.accepted;
    case 'rejected':
      return FriendlyMatchStatus.rejected;
    case 'cancelled':
      return FriendlyMatchStatus.cancelled;
    case 'proposed':
    default:
      return FriendlyMatchStatus.proposed;
  }
}

class FriendlyMatch {
  final String id;
  final String opponentClub;
  final String? opponentContact;
  final String location;
  final DateTime scheduledAt;
  final String category;
  final FriendlyMatchStatus status;
  final bool createdByMe;
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const FriendlyMatch({
    required this.id,
    required this.opponentClub,
    required this.location,
    required this.scheduledAt,
    required this.category,
    required this.status,
    required this.createdByMe,
    required this.createdAt,
    this.opponentContact,
    this.notes,
    this.updatedAt,
  });
  
  FriendlyMatch copyWith({
    String? id,
    String? opponentClub,
    String? opponentContact,
    String? location,
    DateTime? scheduledAt,
    String? category,
    FriendlyMatchStatus? status,
    bool? createdByMe,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FriendlyMatch(
      id: id ?? this.id,
      opponentClub: opponentClub ?? this.opponentClub,
      opponentContact: opponentContact ?? this.opponentContact,
      location: location ?? this.location,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      category: category ?? this.category,
      status: status ?? this.status,
      createdByMe: createdByMe ?? this.createdByMe,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
  
  factory FriendlyMatch.fromMap(Map<String, dynamic> map, String id) {
    return FriendlyMatch(
      id: id,
      opponentClub: map['opponentClub'] ?? 'Rival por definir',
      location: map['location'] ?? 'Ubicación por definir',
      scheduledAt: (map['scheduledAt'] as Timestamp).toDate(),
      category: map['category'] ?? 'General',
      status: friendlyMatchStatusFromString(map['status']),
      createdByMe: map['createdByMe'] ?? true,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      opponentContact: map['opponentContact'],
      notes: map['notes'],
      updatedAt: map['updatedAt'] != null ? (map['updatedAt'] as Timestamp).toDate() : null,
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'opponentClub': opponentClub,
      'location': location,
      'scheduledAt': Timestamp.fromDate(scheduledAt),
      'category': category,
      'status': status.internalName,
      'createdByMe': createdByMe,
      'createdAt': Timestamp.fromDate(createdAt),
      'opponentContact': opponentContact,
      'notes': notes,
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  bool get isActionable => status == FriendlyMatchStatus.proposed;
  bool get isActive => status == FriendlyMatchStatus.proposed || status == FriendlyMatchStatus.accepted;
  bool get isConfirmed => status == FriendlyMatchStatus.accepted;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'opponentClub': opponentClub,
      'opponentContact': opponentContact,
      'location': location,
      'scheduledAt': scheduledAt.toIso8601String(),
      'category': category,
      'status': status.internalName,
      'createdByMe': createdByMe,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory FriendlyMatch.fromJson(Map<String, dynamic> json) {
    return FriendlyMatch(
      id: json['id'] as String,
      opponentClub: json['opponentClub'] as String? ?? 'Rival por definir',
      opponentContact: json['opponentContact'] as String?,
      location: json['location'] as String? ?? 'Ubicación por definir',
      scheduledAt: DateTime.parse(json['scheduledAt'] as String),
      category: json['category'] as String? ?? 'General',
      status: friendlyMatchStatusFromString(json['status'] as String?),
      createdByMe: json['createdByMe'] as bool? ?? true,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String? ?? DateTime.now().toIso8601String()),
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt'] as String) : null,
    );
  }
}
