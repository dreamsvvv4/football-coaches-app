class MatchModel {
  final String id;
  final String homeTeamId;
  final String awayTeamId;
  final DateTime startAt;
  final int? homeScore;
  final int? awayScore;
  final String? status; // scheduled, live, finished

  MatchModel({required this.id, required this.homeTeamId, required this.awayTeamId, required this.startAt, this.homeScore, this.awayScore, this.status});

  factory MatchModel.fromJson(Map<String, dynamic> json) => MatchModel(
    id: json['id'] as String,
    homeTeamId: json['homeTeamId'] as String,
    awayTeamId: json['awayTeamId'] as String,
    startAt: DateTime.parse(json['startAt'] as String),
    homeScore: json['homeScore'] as int?,
    awayScore: json['awayScore'] as int?,
    status: json['status'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'homeTeamId': homeTeamId,
    'awayTeamId': awayTeamId,
    'startAt': startAt.toIso8601String(),
    'homeScore': homeScore,
    'awayScore': awayScore,
    'status': status,
  };
}
