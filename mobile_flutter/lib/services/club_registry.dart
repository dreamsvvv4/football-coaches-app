import '../models/club.dart';

class ClubRegistry {
  static List<Club> clubs = [];
  static Club? getClubById(String? id) {
    if (id == null) return null;
    try {
      return clubs.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }
}
