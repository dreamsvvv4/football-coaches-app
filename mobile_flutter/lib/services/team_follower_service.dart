/// Premium service to manage followers of teams for notifications
class TeamFollowerService {
  TeamFollowerService._();
  static final instance = TeamFollowerService._();

  // In a real app, this would use Firestore/Backend. Here we keep in-memory maps.
  final Map<String, Set<String>> _teamFollowers = {}; // teamId -> userIds
  final Map<String, Set<String>> _userFollowing = {}; // userId -> teamIds

  void followTeam(String teamId, String userId) {
    _teamFollowers.putIfAbsent(teamId, () => <String>{}).add(userId);
    _userFollowing.putIfAbsent(userId, () => <String>{}).add(teamId);
  }

  void unfollowTeam(String teamId, String userId) {
    _teamFollowers[teamId]?.remove(userId);
    _userFollowing[userId]?.remove(teamId);
  }

  List<String> getFollowers(String teamId) {
    return List.unmodifiable(_teamFollowers[teamId] ?? const <String>{});
  }

  List<String> getFollowingTeams(String userId) {
    return List.unmodifiable(_userFollowing[userId] ?? const <String>{});
  }
}
