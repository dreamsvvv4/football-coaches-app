import 'package:cloud_firestore/cloud_firestore.dart';

enum NotificationType { friendlyRequest, matchCreated }

class NotificationService {
  final _firestore = FirebaseFirestore.instance;

  Future<void> notifyTeam(String teamId, String message, NotificationType type) async {
    await _firestore.collection('notifications').add({
      'teamId': teamId,
      'message': message,
      'type': type.toString().split('.').last,
      'createdAt': Timestamp.now(),
    });
  }
}
